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
            let textColor = next.0.consoleColor
            let cardText  = next.0.rawValue
            let padding   = String(repeating: " ", count: 13 - cardText.count)
            
            let percent     = next.1 * 100.0
            let percentText = String(format: "%.0f", percent).consoleText(color: .brightWhite)
            
            let cardCount = next.2
            let countText = "x\(cardCount)\n".consoleText(color: .brightWhite)
            
            return result +
                "|  - ".consoleText(.info)
                + cardText.consoleText(color: textColor)
                + padding.consoleText(color: .green)
                + percentText + "%\t".consoleText(color: .brightWhite)
                + countText
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
            let cardText  = "\(next.0.description) (\(next.0.rawValue)) "
            let padding   = String(repeating: " ", count: 13 - cardText.count)
            
            let percent     = next.1 * 100.0
            let percentText = String(format: "%.0f", percent).consoleText(color: .brightWhite)
            
            let cardCount = next.2
            let countText = "x\(cardCount)\n".consoleText(color: .brightWhite)
            
            return result +
                "|  - ".consoleText(.info)
                + cardText.consoleText(color: .brightBlack)
                + padding.consoleText(color: .green)
                + percentText + "%\t".consoleText(color: .brightWhite)
                + countText
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
            let cardText  = "LVL \(next.0) "
            let padding   = String(repeating: " ", count: 13 - cardText.count)
            
            let percent     = next.1 * 100.0
            let percentText = String(format: "%.0f", percent).consoleText(color: .brightWhite)
            
            let cardCount = next.2
            let countText = "x\(cardCount)\n".consoleText(color: .brightWhite)
            
            return result +
                "|  - ".consoleText(.info)
                + cardText.consoleText(color: .brightBlack)
                + padding.consoleText(color: .green)
                + percentText + "%\t".consoleText(color: .brightWhite)
                + countText
    }
}

func drawCardStatistics(in console: Console, title: String, cardSet allEligibleCards: [Card]) {
    console.output("| \(title): \(allEligibleCards.count)".consoleText(color: .brightWhite))
    
    console.output("| [COLOR]".consoleText(.info))
    console.output(calculateColorDistribution(allEligibleCards))
    
    console.output("| [SUIT]".consoleText(.info))
    console.output(calculatePipDistribution(allEligibleCards))
    
    console.output("| [LEVEL]".consoleText(.info))
    console.output(calculateLevelDistribution(allEligibleCards))
}

