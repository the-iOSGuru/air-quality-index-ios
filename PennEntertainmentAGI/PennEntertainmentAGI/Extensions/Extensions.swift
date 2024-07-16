//
//  Extensions.swift
//  PennEntertainmentAGI
//
//  Created by Buddy Rich on 7/15/24.
//

import Foundation
import UIKit

extension UITextField {
    func addBottomBorder(){
        let bottomLine = CALayer()
        bottomLine.frame = CGRect(x: 0, y: self.frame.size.height - 10, width: self.frame.size.width + 30, height: 1)
        bottomLine.backgroundColor = UIColor(named: "OffWhite")?.cgColor
        borderStyle = .none
        layer.addSublayer(bottomLine)
    }
}
