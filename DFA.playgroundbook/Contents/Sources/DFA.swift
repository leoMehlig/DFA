public struct DFA: Hashable, Equatable {
    public let alphabete: Array<Character>
    public let states: Array<State>
    public let transitions: [Configuration: State]
    public let starting: State

    public init(alphabete: Array<Character>,
                states: Array<State>,
                transitions: [Configuration: State]) throws {
        self.alphabete = alphabete
        self.states = states
        self.transitions = transitions

        let startingStates = states.filter { $0.isStart }
        if startingStates.isEmpty {
            throw CreationError.noStartState
        } else if startingStates.count > 1 {
            throw CreationError.multipleStartStates(startingStates)
        } else {
            self.starting = startingStates[0]
        }

        for (config, state) in transitions {
            guard alphabete.contains(config.character) else {
                throw CreationError.wrongCharacter(config)
            }

            guard states.contains(config.state) else {
                throw CreationError.wrongState(config.state)
            }

            guard states.contains(state) else {
                throw CreationError.wrongState(state)
            }
        }
    }

    @discardableResult
    public func _check(word: String) throws -> State {
        let endState = try word.reduce(self.starting, self._check)
        guard endState.isAcceptedEnd else {
            throw CheckError.notAcceptedEnd(endState)
        }
        return endState
    }

    public func check(word: String) -> Bool {
        do {
            try self._check(word: word)
            return true
        } catch {
            return false
        }
    }

    public func _check(state: State, character: Character) throws -> State {
        guard self.alphabete.contains(character) else {
            throw CheckError.wrongCharacter(character)
        }
        let configuration = Configuration(state: state, character: character)
        guard let state = self.transitions[configuration] else {
            throw CheckError.noState(configuration)
        }
        return state
    }
}

public struct State: Hashable, Equatable {
    public let isAcceptedEnd: Bool
    public let isStart: Bool
    public let name: String

    public init(isAcceptedEnd: Bool = false, isStart: Bool = false, name: String) {
        self.isAcceptedEnd = isAcceptedEnd
        self.isStart = isStart
        self.name = name
    }

    public func transition(with characters: [Character], to state: State) -> [Configuration: State] {
        return Dictionary(uniqueKeysWithValues: characters.map { character in
            return (Configuration(state: self, character: character), state)
        })
    }

    public func transition(with character: Character, to state: State) -> [Configuration: State] {
        return [Configuration(state: self, character: character): state]
    }
}


public struct Configuration: Hashable, Equatable {
    public let state: State
    public let character: Character

    public init(state: State, character: Character) {
        self.state = state
        self.character = character
    }
}

public enum CreationError: Error {
    case noStartState
    case multipleStartStates([State])
    case wrongCharacter(Configuration)
    case wrongState(State)
}

public enum CheckError: Error {
    case wrongCharacter(Character)
    case noState(Configuration)
    case notAcceptedEnd(State)
}
