import Foundation

enum LayoutPreset: String, CaseIterable, Codable, Sendable
{
    case fill
    case almostFill
    case center
    case maximizeWidth
    case maximizeHeight
    case leftHalf
    case rightHalf
    case topHalf
    case bottomHalf
    case topLeftQuarter
    case topRightQuarter
    case bottomLeftQuarter
    case bottomRightQuarter
    case leftThird
    case centerThird
    case rightThird
    case leftTwoThirds
    case rightTwoThirds
    case topThird
    case middleThird
    case bottomThird
    case topTwoThirds
    case bottomTwoThirds
    case centeredHalf
    case centeredTwoThirds
    case centeredThreeQuarters

    static let paletteCases: [LayoutPreset] = [
        .fill,
        .center,
        .leftHalf,
        .rightHalf,
        .topHalf,
        .bottomHalf,
        .topLeftQuarter,
        .topRightQuarter,
        .bottomLeftQuarter,
        .bottomRightQuarter
    ]

    static let horizontalThirdCases: [LayoutPreset] = [
        .leftThird,
        .centerThird,
        .rightThird,
        .leftTwoThirds,
        .rightTwoThirds
    ]

    static let verticalThirdCases: [LayoutPreset] = [
        .topThird,
        .middleThird,
        .bottomThird,
        .topTwoThirds,
        .bottomTwoThirds
    ]

    static let centeredSizeCases: [LayoutPreset] = [
        .centeredHalf,
        .centeredTwoThirds,
        .centeredThreeQuarters,
        .almostFill
    ]

    var title: String
    {
        switch self
        {
        case .fill:
            "Fill"
        case .almostFill:
            "Almost Fill"
        case .center:
            "Center"
        case .maximizeWidth:
            "Maximize Width"
        case .maximizeHeight:
            "Maximize Height"
        case .leftHalf:
            "Left Half"
        case .rightHalf:
            "Right Half"
        case .topHalf:
            "Top Half"
        case .bottomHalf:
            "Bottom Half"
        case .topLeftQuarter:
            "Top Left"
        case .topRightQuarter:
            "Top Right"
        case .bottomLeftQuarter:
            "Bottom Left"
        case .bottomRightQuarter:
            "Bottom Right"
        case .leftThird:
            "Left Third"
        case .centerThird:
            "Center Third"
        case .rightThird:
            "Right Third"
        case .leftTwoThirds:
            "Left Two Thirds"
        case .rightTwoThirds:
            "Right Two Thirds"
        case .topThird:
            "Top Third"
        case .middleThird:
            "Middle Third"
        case .bottomThird:
            "Bottom Third"
        case .topTwoThirds:
            "Top Two Thirds"
        case .bottomTwoThirds:
            "Bottom Two Thirds"
        case .centeredHalf:
            "Centered Half"
        case .centeredTwoThirds:
            "Centered Two Thirds"
        case .centeredThreeQuarters:
            "Centered Three Quarters"
        }
    }

    var systemImage: String
    {
        switch self
        {
        case .fill:
            "rectangle.inset.filled"
        case .almostFill:
            "rectangle.inset.filled"
        case .center:
            "rectangle.center.inset.filled"
        case .maximizeWidth:
            "arrow.left.and.right"
        case .maximizeHeight:
            "arrow.up.and.down"
        case .leftHalf:
            "rectangle.lefthalf.inset.filled"
        case .rightHalf:
            "rectangle.righthalf.inset.filled"
        case .topHalf:
            "rectangle.tophalf.inset.filled"
        case .bottomHalf:
            "rectangle.bottomhalf.inset.filled"
        case .topLeftQuarter:
            "rectangle.topthird.inset.filled"
        case .topRightQuarter:
            "rectangle.topthird.inset.filled"
        case .bottomLeftQuarter:
            "rectangle.bottomthird.inset.filled"
        case .bottomRightQuarter:
            "rectangle.bottomthird.inset.filled"
        case .leftThird, .centerThird, .rightThird, .leftTwoThirds, .rightTwoThirds:
            "rectangle.split.3x1"
        case .topThird, .middleThird, .bottomThird, .topTwoThirds, .bottomTwoThirds:
            "rectangle.split.1x2"
        case .centeredHalf, .centeredTwoThirds, .centeredThreeQuarters:
            "rectangle.center.inset.filled"
        }
    }
}
