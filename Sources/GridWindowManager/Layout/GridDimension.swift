import Foundation

enum GridDimension: Int, CaseIterable, Codable, Sendable
{
    case three = 3
    case four = 4
    case fourByTwo = 42

    var columnCount: Int
    {
        switch self
        {
        case .three:
            return 3
        case .four, .fourByTwo:
            return 4
        }
    }

    var rowCount: Int
    {
        switch self
        {
        case .three:
            return 3
        case .four:
            return 4
        case .fourByTwo:
            return 2
        }
    }

    var title: String
    {
        "\(columnCount) × \(rowCount)"
    }
}
