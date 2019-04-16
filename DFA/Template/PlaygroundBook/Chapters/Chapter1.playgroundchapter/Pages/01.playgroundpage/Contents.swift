//#-hidden-code
//
//  See LICENSE folder for this template’s licensing information.
//
//  Abstract:
//  The Swift file containing the source code edited by the user of this playground book.
//
//#-end-hidden-code

/*:
 # Deterministic Finite Automaton

 A deterministic finite automation (short **DFA**) is a finite-state maschine that accepts or rejects a word.
 Like a *regular expression*, it can be used determine if a string of characters is part of a certain *regular language*.
 Although a DFA is an abstract concept from the theory of computation,
 it is often used to to check if an email address is valid or if a number was entered in the correct format.

 ### Checking numbers

 The example on the right shows the formal definition of a DFA, that accepts a decimal number with two decimal digits (like 12.53).

 Let's test if the automaton works blow:

 Enter a value and hit "Run My Code"!

 */
//#-hidden-code

let numbers = (0...9).map { Character($0.description) }

let s1 = State(isStart: true, name: "q1")
let s2 = State(name: "q2")
let s3 = State(name: "q3")
let s4 = State(name: "q4")
let s5 = State(isAcceptedEnd: true, name: "q5")

let automaton = try DFA(alphabete: numbers + ["."],
                        states: [s1, s2, s3, s4, s5],
                        transitions: try s1.transition(with: numbers, to: s2)
                            .merging(s2.transition(with: numbers, to: s2))
                            .merging(s2.transition(with: ["."], to: s3))
                            .merging(s3.transition(with: numbers, to: s4))
                            .merging(s4.transition(with: numbers, to: s5)))
//#-end-hidden-code

let value: String = /*#-editable-code Input text*/""/*#-end-editable-code*/

if automaton.check(word: value) {
    print("The word is accepted 🎊")
} else {
    print("The word was rejected 😦")
}

//#-hidden-code

import PlaygroundSupport

let page = PlaygroundPage.current

do {
    try automaton._check(word: value)
    page.assessmentStatus = PlaygroundPage.AssessmentStatus.pass(message: "You found a valid number! 🎊 \n Try some other values or go to the [next page](@next) see how to better visulize a DFA.")
} catch CheckError.wrongCharacter(let character) {
    page.assessmentStatus = PlaygroundPage.AssessmentStatus.fail(hints: [
        "The word was reject, because the word contains invalid characters!",
        "Remove the \"\(character)\" from the word and try again."
        ], solution: "An example for a valid for is: 12.54")
} catch CheckError.noState(let config) {
    page.assessmentStatus = PlaygroundPage.AssessmentStatus.fail(hints: [
        "The word was reject, because there is no transition defined for \"\(config.character)\" from State \(config.state.name)!",
        ], solution: "An example for a valid for is: 12.54")
} catch CheckError.notAcceptedEnd(let state) {
    page.assessmentStatus = PlaygroundPage.AssessmentStatus.fail(hints: [
        "The word was reject, because the state maschine did stop at State \(state.name), which is not an accepted end state.",
        "Try to add some more characters to the value."
        ], solution: "An example for a valid for is: 12.54")
}

//#-end-hidden-code
