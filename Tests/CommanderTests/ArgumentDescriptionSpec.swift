import Spectre
@testable import Commander


public func testArgumentDescription() {
  describe("help") {
    $0.it("shows arguments") {
      let help = Help([
        BoxedArgumentDescriptor(value: Argument<String>("arg1")),
        BoxedArgumentDescriptor(value: Argument<String>("arg2", description: "an example")),
      ])

      try expect(help.description) == "Arguments:\n\n    arg1\n    arg2 - an example\n"
      try expect(help.ansiDescription) == "Arguments:\n\n    \(ANSI.blue)arg1\(ANSI.reset)\n    \(ANSI.blue)arg2\(ANSI.reset) - an example\n"
    }

    $0.it("shows options") {
      let help = Help([
        BoxedArgumentDescriptor(value: Option("opt1", default: "example")),
        BoxedArgumentDescriptor(value: Flag("flag1", description: "an example")),
        BoxedArgumentDescriptor(value: Flag("flag2", default: true)),
      ])

      try expect(help.description) == "Options:\n    --opt1 [default: example]\n    --flag1 [default: false] - an example\n    --flag2 [default: true]"
      try expect(help.ansiDescription) == "Options:\n    \(ANSI.blue)--opt1\(ANSI.reset) [default: example]\n    \(ANSI.blue)--flag1\(ANSI.reset) [default: false] - an example\n    \(ANSI.blue)--flag2\(ANSI.reset) [default: true]"
    }

    $0.it("shows default for custom types conforming to CustomStringConvertible") {
      enum Direction: String, CustomStringConvertible, ArgumentConvertible {
        case north
        case south

        public init(parser: ArgumentParser) throws {
          if let value = parser.shift() {
            switch value {
              case "north":
                self = .north
              case "south":
                self = .south
              default:
                throw ArgumentError.invalidType(value: value, type: "direction", argument: nil)
            }
          } else {
            throw ArgumentError.missingValue(argument: nil)
          }
        }

        var description: String {
          return rawValue
        }
      }

      let help = Help([
        BoxedArgumentDescriptor(value: Option("direction", default: Direction.south)),
      ])

      try expect(help.description) == "Options:\n    --direction [default: south]"
    }
  }
}
