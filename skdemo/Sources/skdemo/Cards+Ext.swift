import Foundation
import ConsoleKit

func calculateColorDistribution(_ cardSet: [Card]) -> ConsoleText {
    guard cardSet.count > 0 else {
        return ""
    }
    
    let grouping = Dictionary(grouping: cardSet, by: { $0.color })
    
    let mappedGrouping = grouping
        .map({ (key: Card.Color, value: [Card]) -> (Card.Color, Double, Int) in
            let cardCountAsDouble  = Double(cardSet.count)
            let valueCountAsDouble = Double(value.count)
            return (key, (valueCountAsDouble / cardCountAsDouble), value.count)
        })
        .sorted { (left, right) -> Bool in
            left.0.rawValue < right.0.rawValue
        }
    
    return mappedGrouping
        .reduce(ConsoleText()) { result, next in
            result +
                "|> .: \(next.0.rawValue) \t".consoleText(color: next.0.consoleColor) +
                String(format: "%.0f", next.1 * 100.0).consoleText() + "%" +
                "\tx\(next.2)\n".consoleText(.info)
    }
}

func calculatePipDistribution(_ cardSet: [Card]) -> ConsoleText {
    guard cardSet.count > 0 else {
        return ""
    }
    
    let grouping = Dictionary(grouping: cardSet, by: { $0.pip })
    let mappedGrouping = grouping
        .map({ (key: Card.Pip, value: [Card]) -> (Card.Pip, Double, Int) in
            let cardCountAsDouble  = Double(cardSet.count)
            let valueCountAsDouble = Double(value.count)
            return (key, (valueCountAsDouble / cardCountAsDouble), value.count)
        })
        .sorted { (left, right) -> Bool in
            left.0.rawValue < right.0.rawValue
        }

    return mappedGrouping
        .reduce(ConsoleText()) { result, next in
            result +
                "|> .: \(next.0.asPip):\t".consoleText() +
                String(format: "%.0f", next.1 * 100.0).consoleText() + "%" +
                "\tx\(next.2)\n".consoleText(.info)
    }
}

func calculateLevelDistribution(_ cardSet: [Card]) -> ConsoleText {
    guard cardSet.count > 0 else {
        return ""
    }
    
    let grouping = Dictionary(grouping: cardSet, by: { $0.level })
    let mappedGrouping = grouping
        .map({ (key: Int, value: [Card]) -> (Int, Double, Int) in
            let cardCountAsDouble  = Double(cardSet.count)
            let valueCountAsDouble = Double(value.count)
            return (key, (valueCountAsDouble / cardCountAsDouble), value.count)
        })
        .sorted { (left, right) -> Bool in
            left.0 < right.0
        }
    
    return mappedGrouping
        .reduce(ConsoleText()) { result, next in
            result +
                "|> .: LVL: \(next.0)\t".consoleText() +
                String(format: "%.0f", next.1 * 100.0).consoleText() + "%" +
                "\tx\(next.2)\n".consoleText(.info)
    }
}

func drawCardStatistics(in console: Console, cardSet allEligibleCards: [Card]) {
    console.output("|> Total Cards: \(allEligibleCards.count)".consoleText(.warning))
    
    console.output("|> + By Color:".consoleText(.info))
    console.output(calculateColorDistribution(allEligibleCards))
    
    console.output("|> + By Pip:".consoleText(.info))
    console.output(calculatePipDistribution(allEligibleCards))
    
    console.output("|> + By Level:".consoleText(.info))
    console.output(calculateLevelDistribution(allEligibleCards))
}

