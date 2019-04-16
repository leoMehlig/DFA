//#-hidden-code
//
//  See LICENSE folder for this template’s licensing information.
//
//  Abstract:
//  The Swift file containing the source code edited by the user of this playground book.
//
//#-end-hidden-code

/*:
 ## The Swift Implementation

 Now that you had a chance to play around with a simple *DFA*, lets take a look at how to used it in Swift.

 Every DFA consists of:
 - a set of characters that are accepted
 - a list of states, some accepting end state and one start state
 - and a list of transitions between those states.

 On the right you can see the definition for a DFA that a string of emojies, which represents the weather of any number of days.
 It always has to start with sunrise 🌅 and end with night 🌜. There are also some other rules, like that sun 🌞 can't be direclty followed by rain 🌧.

 It's a bit hard to understand and the diagram looks a bit messy.

 So let's build this DFA in Swift!

 First we need to create the alphabete of all the emojies that are allowed:
*/

let alphabete: [Character] = ["🌅", "🌞", "☁️", "🌧", "⛈", "🌜"]

//: Now we create all the states of the automaton:

let night = State(isAcceptedEnd: true, isStart: true, name: "Night")
let morning = State(name: "Morning")
let sunny = State(name: "Sunny")
let cloudy = State(name: "Cloudy")
let rain = State(name: "Rain")
let storm = State(name: "Strom")

let states =  [night, morning, sunny, cloudy, rain, storm]

//: And the transitions:

let transitions = [
    Configuration(state: night, character: "🌅") : morning,
    Configuration(state: morning, character: "🌞"): sunny,
    Configuration(state: morning, character: "☁️"): cloudy,
    Configuration(state: sunny, character: "☁️"): cloudy,
    Configuration(state: cloudy, character: "🌞"): sunny,
    Configuration(state: cloudy, character: "🌧"): rain,
    Configuration(state: rain, character: "☁️"): cloudy,
    Configuration(state: rain, character: "⛈"): storm,
    Configuration(state: storm, character: "🌧"): rain,
    Configuration(state: sunny, character: "🌜"): night,
    Configuration(state: cloudy, character: "🌜"): night,
    Configuration(state: rain, character: "🌜"): night,
    Configuration(state: storm, character: "🌜"): night,
]

//: Now we create the DFA with the previousely defined variables:
//#-hidden-code
//#-code-completion(everything, hide)
//#-code-completion(identifier, show, alphabete, states, transitions)
//#-end-hidden-code



let automaton = try DFA(alphabete: alphabete,
    states: states,
    transitions: transitions)

//: Now test the DFA, using the `check(word:)` method, against some string or use the predefined `exampleString`.
//: Then it "Run My Code" to execute the DFA.
//#-hidden-code
import PlaygroundSupport

let page = PlaygroundPage.current

var checkCalled = false

func check(word: String) -> Bool {
    checkCalled = true
    do {
        try automaton._check(word: word)
        page.assessmentStatus = PlaygroundPage.AssessmentStatus.pass(message: "You found a weather string 🌞! \n Try some other values or go to the [next page](@next) to see a nice way to visualize a DFA.")
        return true
    } catch CheckError.wrongCharacter(let character) {
        page.assessmentStatus = PlaygroundPage.AssessmentStatus.fail(hints: [
            "The word was reject, because the word contains invalid characters!",
            "Remove the \"\(character)\" from the word and try again."
            ], solution: "An example for a valid for is 🌅🌞🌜, or just use the `exampleString`.")
    } catch CheckError.noState(let config) {
        page.assessmentStatus = PlaygroundPage.AssessmentStatus.fail(hints: [
            "The word was reject, because there is no transition defined for \"\(config.character)\" from State \(config.state.name)!",
            ], solution: "An example for a valid for is 🌅🌞🌜, or just use the `exampleString`.")
    } catch CheckError.notAcceptedEnd(let state) {
        page.assessmentStatus = PlaygroundPage.AssessmentStatus.fail(hints: [
            "The word was reject, because the state maschine did stop at State \(state.name), which is not an accepted end state.",
            "Try to add some more characters to the value."
            ], solution: "An example for a valid for is 🌅🌞🌜, or just use the `exampleString`.")
    } catch {
        page.assessmentStatus = PlaygroundPage.AssessmentStatus.fail(hints: [
            "Unknown error"
            ], solution: "An example for a valid for is 🌅🌞🌜, or just use the `exampleString`.")
    }
    return false
}
//#-code-completion(everything, hide)
//#-code-completion(identifier, hide, alphabete, states, transitions)
//#-code-completion(identifier, show, check(word:), exampleString)
//#-code-completion(literal, show, string)
//#-end-hidden-code

let exampleString = "🌅🌞☁️🌧☁️🌧⛈🌧☁️🌞☁️🌜"

//#-editable-code

//#-end-editable-code

//#-hidden-code

if !checkCalled {
    page.assessmentStatus = PlaygroundPage.AssessmentStatus.fail(hints: [
        "You didn't test the DFA. How do you now if it works?"
        ], solution: "Add check(word: \"🌅🌞🌜\") for a start.")
}
//#-end-hidden-code
