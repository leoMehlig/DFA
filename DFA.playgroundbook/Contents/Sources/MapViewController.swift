//
//  MapViewController.swift
//  Book_Sources
//
//  Created by Leo Mehlig on 20.03.19.
//

import UIKit
import PlaygroundSupport

public class MapViewController: UIViewController, PlaygroundLiveViewMessageHandler, PlaygroundLiveViewSafeAreaContainer {


    @IBOutlet public var map: Map?

    @IBOutlet weak var train: Train!

    @IBOutlet var emojiButtons: [UIButton]!
    
    @IBOutlet weak var clearButton: UIButton!

    @IBOutlet weak var statusLabel: UILabel!

    private var currentState: State?

    private var isAnimating = false

    override public func viewDidLoad() {
        super.viewDidLoad()
        let start = State(isStart: true, name: "Start")
        let code = State(name: "Code")
        let bug = State(name: "Bug")
        let release = State(name: "Release")
        let party = State(isAcceptedEnd: true, name: "Party")

        let states = [start, code, bug, party, release]

        let alphabete: [Character] = ["💡", "👨‍💻", "📲", "🐛", "🎉", "💸"]
        let automate = try! DFA(alphabete: alphabete,
                                states: states,
                                transitions: [
                                    Configuration(state: start, character: "💡"): code,
                                    Configuration(state: code, character: "👨‍💻"): code,
                                    Configuration(state: code, character: "🐛"): bug,
                                    Configuration(state: bug, character: "👨‍💻"): code,
                                    Configuration(state: code, character: "📲"): release,
                                    Configuration(state: release, character: "💸"): party,
                                    Configuration(state: party, character: "🎉"): party,
                                    Configuration(state: party, character: "💡"): code
            ])

        self.map?.automate = automate
    }

    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if !self.isAnimating {
            self.train.frame = CGRect(x: self.view.bounds.width / 2 - 150, y: self.map!.frame.maxY + 20, width: 300, height: 75)
        }
    }

    @IBAction func addChar(_ sender: UIButton) {
        self.train.add(character: sender.currentTitle!.first!)
        if self.train.text.count >= 14 {
            self.emojiButtons.forEach {
                $0.isEnabled = false
                $0.alpha = 0.3
            }
        }
    }

    @IBAction func clear() {
        self.train.clear()
        self.emojiButtons.forEach {
            $0.isEnabled = true
            $0.alpha = 1
        }
    }

    @IBAction func start() {
        self.emojiButtons.forEach {
            $0.isEnabled = false
            $0.alpha = 0.3
        }
        self.clearButton.isEnabled = false
        self.isAnimating = true
        let start = self.map?.stations.first(where: { $0.state.isStart })
        let startCirle = self.map!.convert(start!.station.circleRect.center, to: self.view)
        self.animate(to: CGPoint(x: 30, y: self.train.center.y)) {
            self.animate(to: CGPoint(x: 30, y: startCirle.y)) {
                self.animate(to: startCirle) {
                    self.currentState = start?.state
                    self.startRide()
                }
            }
        }
    }

    private func startRide() {
        guard let char = self.train.text.first else {
            if self.currentState?.isAcceptedEnd ?? false {
                self.endRide(with: "✅")
                self.send(.string("success"))
            } else {
                self.endRide(with: "💥")
                self.send(.string("earlyEnd"))
            }
            return
        }

        guard let state = self.currentState else {
                return
        }

        if let endState = self.map?.automate?.transitions[Configuration(state: state, character: char)],
            let endStation = self.map?.stations.first(where: { $0.state == endState })?.station {
            let points = (self.map?.path(from: state, to: endState) ?? []).map { self.map!.convert($0, to: self.view) }
            UIView.animate(withDuration: 0.3, animations: {
                self.train.center = points[0]
            }) { _ in
                self.train.removeFirst()
                self.animate(points: Array(points.dropFirst()), end: self.map!.convert(endStation.circleRect.center, to: self.view)) {
                    self.currentState = endState
                    self.startRide()
                }
            }
        } else {
            self.endRide(with: "💥")
            self.send(.string("noState"))
        }
    }

    private func endRide(with string: String?) {
        if string != nil {
            self.statusLabel.text = string
            UIView.animate(withDuration: 0.5, animations: {
                self.statusLabel.alpha = 1
                self.statusLabel.transform = CGAffineTransform.identity.scaledBy(x: 2, y: 2)
            }) { _ in
                UIView.animate(withDuration: 1, animations: {
                    self.statusLabel.alpha = 0
                    self.statusLabel.transform = CGAffineTransform.identity
                })
            }
        }
        self.map?.bringSubviewToFront(self.statusLabel)
        self.clear()
        self.clearButton.isEnabled = true
        self.isAnimating = false
        UIView.animate(withDuration: 1, animations: {
            self.train.transform = .identity
            self.train.frame = CGRect(x: self.view.bounds.width / 2 - 150, y: self.map!.frame.maxY + 20, width: 300, height: 75)
        })
    }

    private func animate(points: [CGPoint], end: CGPoint, completion: @escaping () -> ()) {
        guard self.isAnimating else {
            return
        }
        if points.isEmpty {
            UIView.animate(withDuration: 0.3, animations: {
                self.train.center = end
            }) { _ in
                completion()
            }
        } else {
            self.animate(to: points[0]) {
                self.animate(points: Array(points.dropFirst()), end: end, completion: completion)
            }
        }
    }

    private func animate(to point: CGPoint, completion: @escaping () -> Void) {
        guard self.isAnimating else {
            return
        }
        let current = self.train.center
        let transform: CGAffineTransform
        if current.x > point.x {
            transform = CGAffineTransform.identity
        } else if current.x < point.x {
            transform = CGAffineTransform.identity.rotated(by: CGFloat.pi)
        } else if current.y > point.y {
            transform = CGAffineTransform.identity.rotated(by: CGFloat.pi / 2)
        } else if current.y < point.y {
            transform = CGAffineTransform.identity.rotated(by: CGFloat.pi * 1.5)
        } else {
            transform = self.train.transform
        }

        UIView.animate(withDuration: 0.3, animations: {
            self.train.transform = transform.scaledBy(x: 0.2, y: 0.2)
        }) { _ in
            UIView.animate(withDuration: 0.5, animations: {
                self.train.center = point
            }, completion: { _ in
                completion()
            })
        }

    }

    public func liveViewMessageConnectionClosed() {
        self.endRide(with: nil)
    }

    public func receive(_ message: PlaygroundValue) {
        if case .string("start") = message {
            self.start()
        }
    }
}
