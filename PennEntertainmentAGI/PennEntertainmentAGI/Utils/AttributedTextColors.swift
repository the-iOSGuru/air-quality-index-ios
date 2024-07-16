//
//  AttributedTextColors.swift
//  PennEntertainmentAGI
//
//  Created by Buddy Rich on 7/15/24.
//
import UIKit

func colorizeText(with keyText: String) -> NSAttributedString {
    let attributedString = NSMutableAttributedString(string: keyText)
    
    // Define color mappings
    let colorMappings: [String: UIColor] = [
        "Green - Good": UIColor.green,
        "Yellow - Moderate": UIColor.yellow,
        "Orange - Unhealthy for Sensitive Groups": UIColor.orange,
        "Red - Unsafe": UIColor.red
    ]
    
    for (key, color) in colorMappings {
        let range = (keyText as NSString).range(of: key)
        if range.location != NSNotFound {
            attributedString.addAttribute(.foregroundColor, value: color, range: range)
        }
    }
    return attributedString
}


func makeBoldText(_ boldText: String, regularText: String) -> NSAttributedString {
    let boldFont = UIFont(name: "Menlo-Bold", size: 19) ?? UIFont.boldSystemFont(ofSize: 19)
    let regularFont = UIFont(name: "Menlo-Regular", size: 17) ?? UIFont.systemFont(ofSize: 17)
    
    let attributedString = NSMutableAttributedString(string: boldText, attributes: [.font: boldFont])
    let regularAttributedString = NSAttributedString(string: regularText, attributes: [.font: regularFont])
    
    attributedString.append(regularAttributedString)
    
    return attributedString
}

func makeColoredAQIText(_ aqi: Int) -> NSAttributedString {
    let color: UIColor
    switch aqi {
    case 0...50:
        color = UIColor.green
    case 51...100:
        color = UIColor.yellow
    case 101...150:
        color = UIColor.orange
    case 151...:
        color = UIColor.red
    default:
        color = UIColor.black
    }
    
    let attributedString = NSAttributedString(string: "\(aqi)", attributes: [.foregroundColor: color])
    return attributedString
}
