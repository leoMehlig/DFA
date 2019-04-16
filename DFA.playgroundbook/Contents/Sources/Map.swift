import UIKit

public class Map: UIView {
    public var automate: DFA? {
        didSet {
            self.stations.forEach { $0.station.removeFromSuperview() }
            if let automate = self.automate {
                self.current = automate.starting
                self.stations = automate.states.map { state in
                    return (state, Station(state: state))
                }
                for value in self.stations {
                    self.addSubview(value.station)
                }
            }
            self.setNeedsLayout()
        }
    }

    public var current: State?
    public var word: String = ""

    private let colors: [UIColor] = [.red, .blue, .green, .orange, .purple, .brown, .black, .gray, .magenta, .lightGray, .cyan]

    var stations: [(state: State, station: Station)] = []

    public override func layoutSubviews() {
        super.layoutSubviews()

        let margin: CGFloat = 20
        let space: CGFloat = 100
        let width: CGFloat = (self.bounds.width - 2 * margin - 2 * space) / 3
        let height: CGFloat = self.stations.first?.station.intrinsicContentSize.height ?? 20
        self.stations.enumerated().forEach { value in
            value.element.station.frame = CGRect(x: margin + (width + space) * CGFloat(value.offset % 3),
                                                 y: margin + (height + space) * CGFloat(value.offset / 3),
                                                 width: width, height: height)
        }
        self.setNeedsDisplay()
    }

    public func path(from startState: State, to endState: State) -> [CGPoint] {
        let (startIndex, start) = self.stations.enumerated()
            .first { $0.element.state == startState }!
        let (endIndex, end) = self.stations.enumerated()
            .first { $0.element.state == endState }!
        
        let points: [CGPoint]

        if startIndex == endIndex {
            points = [CGPoint(x: start.station.circleRect.minX, y: start.station.circleRect.minY + 5),
                      CGPoint(x: start.station.frame.minX - 10, y: start.station.circleRect.minY + 5),
                      CGPoint(x: start.station.frame.minX - 10, y: start.station.frame.minY - 4),
                      CGPoint(x: start.station.frame.maxX + 10, y: start.station.frame.minY - 4),
                      CGPoint(x: start.station.frame.maxX + 10, y: start.station.circleRect.minY + 5),
                      CGPoint(x: start.station.circleRect.maxX + 5, y: start.station.circleRect.minY + 5)]

        } else if startIndex + 1 == endIndex && startIndex % 3 != 2 {
            points = [CGPoint(x: start.station.circleRect.maxX, y: end.station.circleRect.midY),
                      CGPoint(x: end.station.circleRect.minX - 5, y: end.station.circleRect.midY)]
        } else if startIndex == endIndex + 1 && endIndex % 3 != 2 {
            points = [CGPoint(x: start.station.circleRect.minX, y: start.station.circleRect.midY + 10),
                      CGPoint(x: end.station.circleRect.maxX + 5, y: end.station.circleRect.midY + 10)]
        } else if startIndex % 3 == endIndex % 3 && startIndex < endIndex {
            points = [CGPoint(x: start.station.circleRect.midX + 5, y: start.station.circleRect.maxY),
                      CGPoint(x: start.station.circleRect.midX + 5, y: start.station.frame.maxY + 20),
                      CGPoint(x: start.station.frame.maxX + 5, y: start.station.frame.maxY + 20),
                      CGPoint(x: start.station.frame.maxX + 5, y: end.station.circleRect.midY - 5),
                      CGPoint(x: end.station.circleRect.maxX + 5, y: end.station.circleRect.midY - 5)]
        } else if startIndex % 3 + 1 == endIndex % 3 && startIndex > endIndex {
            points = [CGPoint(x: start.station.circleRect.maxX, y: start.station.circleRect.midY),
                      CGPoint(x: start.station.frame.maxX + 20, y: start.station.circleRect.midY),
                      CGPoint(x: start.station.frame.maxX + 20, y: end.station.frame.maxY + 20),
                      CGPoint(x: end.station.circleRect.midX - 10, y: end.station.frame.maxY + 20),
                      CGPoint(x: end.station.circleRect.midX - 10, y: end.station.circleRect.maxY + 5)]
        } else {
            points = []
            print(startIndex, start.state.name, endIndex, end.state.name)
        }
        return points
    }

    public override func draw(_ rect: CGRect) {
        super.draw(rect)
        guard let automate = self.automate else {
            return
        }
        for config in automate.transitions {
            let color = self.colors[automate.alphabete.index(of: config.key.character)!]
            let points = self.path(from: config.key.state, to: config.value)

            let path = UIBezierPath()
            path.addPath(with: points, cornerRadius: 10)

            path.lineWidth = 4

            color.setStroke()
            path.stroke()
            if let endPoint = points.last {
                let endCircle = UIBezierPath(ovalIn: CGRect(x: endPoint.x - 4, y: endPoint.y - 4, width: 8, height: 8))
                endCircle.lineWidth = 2
                color.setFill()
                endCircle.fill()
            }

            if let startPoint = points.first, let nextPoint = points.dropFirst().first {
                let charPoint = startPoint.move(15, to: nextPoint)
                let paragraphStyle = NSMutableParagraphStyle()
                paragraphStyle.alignment = .center
                (String(config.key.character) as NSString).draw(in: CGRect(x: charPoint.x - 20, y: charPoint.y - 8, width: 40, height: 16),
                                                                withAttributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 12), NSAttributedString.Key.paragraphStyle: paragraphStyle])
            }
        }
    }
}

public class Station: UIView {
    public let state: State

    private let label: UILabel = {
        let label = UILabel()
        label.font = UIFont.preferredFont(forTextStyle: .caption1)
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.5
        return label
    }()

    var circleRect: CGRect {
        let labelHeight = self.label.intrinsicContentSize.height
        return self.frame.divided(atDistance: labelHeight + 8, from: .minYEdge)
            .remainder.insetBy(dx: max((self.frame.width - 30) / 2, 0), dy: 0)
            .divided(atDistance: 8, from: .maxYEdge).remainder

    }

    init(state: State) {
        self.state = state
        super.init(frame: .zero)
        self.contentMode = .redraw
        self.backgroundColor = .clear
        self.label.text = self.state.name
        self.addSubview(self.label)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func draw(_ rect: CGRect) {
        super.draw(rect)
        let circleRect = self.convert(self.circleRect, from: self.superview)
        let path: UIBezierPath
        if self.state.isAcceptedEnd {
            path = UIBezierPath()
            path.move(to: CGPoint(x: circleRect.midX + 4, y: self.bounds.maxY))
            path.addLine(to: CGPoint(x: circleRect.midX + 4, y: circleRect.maxY))
            path.addPath(with: [
                CGPoint(x: circleRect.midX + 4, y: circleRect.maxY),
                CGPoint(x: circleRect.maxX, y: circleRect.maxY),
                CGPoint(x: circleRect.maxX, y: circleRect.minY),
                CGPoint(x: circleRect.minX, y: circleRect.minY),
                CGPoint(x: circleRect.minX, y: circleRect.maxY),
                CGPoint(x: circleRect.midX - 4, y: circleRect.maxY),
                ], cornerRadius: 6, moveToFirst: false)
            path.addLine(to: CGPoint(x: circleRect.midX - 4, y: self.bounds.maxY))
        } else if self.state.isStart {
            path = UIBezierPath()
            path.move(to: CGPoint(x: circleRect.minX - 8, y: circleRect.midY + 4))
            path.addLine(to: CGPoint(x: circleRect.minX, y: circleRect.midY + 4))
            path.addPath(with: [
                CGPoint(x: circleRect.minX, y: circleRect.midY + 4),
                CGPoint(x: circleRect.minX, y: circleRect.maxY),
                CGPoint(x: circleRect.maxX, y: circleRect.maxY),
                CGPoint(x: circleRect.maxX, y: circleRect.minY),
                CGPoint(x: circleRect.minX, y: circleRect.minY),
                CGPoint(x: circleRect.minX, y: circleRect.midY - 4),
                ], cornerRadius: 6, moveToFirst: false)
            path.addLine(to: CGPoint(x: circleRect.minX - 8, y: circleRect.midY - 4))
        } else {
            path = UIBezierPath(roundedRect: circleRect, cornerRadius: 6)
        }
        path.lineWidth = 4
        UIColor.white.setFill()
        path.fill()
        UIColor.black.setStroke()
        path.stroke()

    }

   public  override func layoutSubviews() {
        super.layoutSubviews()
        let labelHeight = self.label.intrinsicContentSize.height
        self.label.frame = self.bounds.divided(atDistance: labelHeight, from: .minYEdge).slice
    }

    public override var intrinsicContentSize: CGSize {
        let labelSize = self.label.intrinsicContentSize
        return CGSize(width: labelSize.width, height: labelSize.height + 8 + 30 + 8)
    }

}

public class Train: UIView {
    let upperLight: CALayer = {
        let layer = CALayer()
        layer.backgroundColor = UIColor.lightGray.cgColor
        return layer
    }()

    let lowerLight: CALayer = {
        let layer = CALayer()
        layer.backgroundColor = UIColor.lightGray.cgColor
        return layer
    }()

    let upperLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 30)
        label.adjustsFontSizeToFitWidth = true
        return label
    }()

    let lowerLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 30)
        label.adjustsFontSizeToFitWidth = true
        return label
    }()

    public var text: String {
        let upperText = self.upperLabel.text ?? ""
        let lowerText = self.lowerLabel.text ?? ""

        let chars = upperText.enumerated().reduce("") {  (string, element) in
            let (index, char) = element
            if index < lowerText.count {
                return string + String(char) + String(lowerText[lowerText.index(lowerText.startIndex, offsetBy: index)])
            }
            return string + String(char)
        }
        return chars
    }

    public init() {
        super.init(frame: .zero)
        self.initalize()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.initalize()
    }

    private func initalize() {
        self.contentMode = .redraw
        self.backgroundColor = .gray
        self.layer.addSublayer(self.upperLight)
        self.layer.addSublayer(self.lowerLight)
        self.addSubview(self.upperLabel)
        self.addSubview(self.lowerLabel)
    }

    public override func layoutSubviews() {
        super.layoutSubviews()
        self.upperLight.frame = CGRect(x: -10, y: 5, width: 30, height: 30)
        self.upperLight.cornerRadius = 15
        
        self.lowerLight.frame = CGRect(x: -10, y: 40, width: 30, height: 30)
        self.lowerLight.cornerRadius = 15

        self.upperLabel.frame = CGRect(x: 30, y: 5, width: self.bounds.width - 30, height: 30)
        self.lowerLabel.frame = CGRect(x: 30, y: 40, width: self.bounds.width - 30, height: 30)

    }

    public func add(character: Character) {
        if (self.upperLabel.text?.count ?? 0) > (self.lowerLabel.text?.count ?? 0) {
            self.lowerLabel.text = (self.lowerLabel.text ?? "") + String(character)
        } else {
            self.upperLabel.text = (self.upperLabel.text ?? "") + String(character)
        }
    }

    public func removeFirst() {
        let text = self.text.dropFirst()
        self.upperLabel.text = nil
        self.lowerLabel.text = nil
        for char in text {
            self.add(character: char)
        }
    }

    public func clear() {
        self.upperLabel.text = nil
        self.lowerLabel.text = nil
    }
}
