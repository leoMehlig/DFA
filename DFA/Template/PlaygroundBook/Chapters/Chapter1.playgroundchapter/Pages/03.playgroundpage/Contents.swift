//#-hidden-code
//
//  See LICENSE folder for this template’s licensing information.
//
//  Abstract:
//  The Swift file containing the source code edited by the user of this playground book.
//



import UIKit
import PlaygroundSupport

let page = PlaygroundPage.current
page.needsIndefiniteExecution = true
class FinishedProcessingListener: PlaygroundRemoteLiveViewProxyDelegate {
    func remoteLiveViewProxy(_ remoteLiveViewProxy: PlaygroundRemoteLiveViewProxy,
                             received message: PlaygroundValue) {
        if case let .string(text) = message {
            if text == "success" {
                page.assessmentStatus = PlaygroundPage.AssessmentStatus.pass(message: "Wow! You found a valid sequence of emojies 🎊. Now go and develop that idea! Thanks for having a look at my application!!!")
                page.finishExecution()
            } else if text == "earlyEnd" {
                page.assessmentStatus = PlaygroundPage.AssessmentStatus.fail(hints: ["Oh you didn't finish the development cycle. Be sure to actually release 📲 the app make money 💸!"], solution: "Try a sequence like 💡👨‍💻🐛👨‍💻📲💸🎉!")
                page.finishExecution()
            } else if text == "noState" {
                page.assessmentStatus = PlaygroundPage.AssessmentStatus.fail(hints: ["Oh there is no connection to your next station."], solution: "Try a sequence like 💡👨‍💻🐛👨‍💻📲💸🎉!")
                page.finishExecution()
            }
        }
    }

    func remoteLiveViewProxyConnectionClosed(_ remoteLiveViewProxy: PlaygroundRemoteLiveViewProxy) { }
}
let listener = FinishedProcessingListener()
(page.liveView as? PlaygroundRemoteLiveViewProxy)?.delegate = listener
var startCalled = false
func startTrain() {
    startCalled = true
    (page.liveView as? PlaygroundRemoteLiveViewProxy)?.send(.string("start"))
}
//#-code-completion(everything, hide)
//#-code-completion(identifier, show, startTrain())
//#-end-hidden-code

/*:
 # The Subway Map

The definition of a DFA can be quit confusing and hard to understand. But if you visulize it it in the correct way it becomes easy.

 Imagin a subway/tube/underground map! There are stations and differntly colors lines to connect them. In this example each station represents a state in the DFA, the color of the lines tells us with which character you can "drive" from one station to another and the emojis on the train can be seen as intruction which line to take next.

 ## The App Development Lifecycle

 The example on the right describs the app development cycle using emojis. Every app starts with an idea 💡! Then we need to code, code and code 👨‍💻. When we encounter a bug 🐛, we need to code 👨‍💻 again! Finally we can release the app 📲 and make some money 💸. When this happens we can party 🎉 as much as we want to.

 Let's test this example using the Subway Map on the right:
 1. Tap the emojis to add them to the train.
 2. Add the method call to start the train below.
 3. Hit "Run My Code" to start the train.
 4. Watch the train execute the emojis.
 */

//#-editable-code

//#-end-editable-code

//#-hidden-code

if !startCalled {
    page.assessmentStatus = PlaygroundPage.AssessmentStatus.fail(hints: [
        "You didn't start the train 🚅"
        ], solution: "Add startTrain() and hit \"Run My Code\" again.")
}
//#-end-hidden-code
