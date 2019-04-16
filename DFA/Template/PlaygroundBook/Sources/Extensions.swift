import UIKit

extension Dictionary {
    public func merging(_ other: [Key: Value]) throws -> [Key: Value] {
        return try self.merging(other, uniquingKeysWith: { throw MergingError.matchingKeys($0, $1) })
    }
}

public enum MergingError<Value>: Error {
    case matchingKeys(Value, Value)
}

extension CGRect {
    var center: CGPoint {
        return CGPoint(x: self.midX, y: self.midY)
    }
}

extension CGPoint {
    func move(_ distance: CGFloat, to point: CGPoint) -> CGPoint {
        if self.x == point.x {
            return CGPoint(x: self.x, y: self.y < point.y ? self.y + distance : self.y - distance)
        } else if self.y == point.y {
            return CGPoint(x: self.x < point.x ? self.x + distance : self.x - distance, y: self.y)
        } else {
            fatalError("The points have to be on one axis!")
        }
    }
}
extension UIBezierPath {
    func addPath(with points: [CGPoint], cornerRadius: CGFloat, moveToFirst: Bool = true) {
        if moveToFirst {
            self.move(to: points[0])
        }
        for (index, point) in points.enumerated().dropFirst() {
            guard index + 1 < points.count else {
                self.addLine(to: point)
                break
            }
            let start = point.move(cornerRadius, to: points[index - 1])
            let end = point.move(cornerRadius, to: points[index + 1])
            let center = CGPoint(x: point.x == start.x ? end.x : start.x, y: point.y == start.y ? end.y : start.y)
            let startAngle = -(atan2(start.x - center.x, start.y - center.y) - CGFloat.pi / 2)
            let endAngle = -(atan2(end.x - center.x, end.y - center.y) - CGFloat.pi / 2)
            self.addLine(to: start)
            self.addArc(withCenter: center,
                        radius: cornerRadius,
                        startAngle: startAngle,
                        endAngle: endAngle,
                        clockwise: endAngle > startAngle && endAngle - startAngle <= CGFloat.pi / 2  || startAngle - endAngle > CGFloat.pi / 2)
        }
    }
}
