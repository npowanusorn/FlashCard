//
//  CommonMethods+Extensions.swift
//  flashcard
//
//  Created by Nucha Powanusorn on 05/03/2024.
//

import UIKit

func makeMenu(children: [UIAction]) -> UIMenu {
    let menu = UIMenu(options: .displayInline, children: children)
    return menu
}

// MARK: - String
extension String {
    func formatted(string: String) -> String {
        self.replacingOccurrences(of: "%@", with: string)
    }

    var isValidDouble: Bool {
        return Double(self) != nil
    }

    var isValidInteger: Bool {
        return Int(self) != nil
    }
}

extension UITableView {

    func setEmptyMessage(_ message: String) {
        let messageLabel = UILabel(frame: CGRect(x: 20, y: 0, width: self.bounds.size.width - 40, height: self.bounds.size.height))
        messageLabel.text = message
        messageLabel.textColor = .black
        messageLabel.numberOfLines = 0
        messageLabel.textAlignment = .center
        messageLabel.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        messageLabel.sizeToFit()
        self.backgroundView = messageLabel
        self.separatorStyle = .none
        self.isUserInteractionEnabled = false
    }

    func restore() {
        self.backgroundView = nil
        self.separatorStyle = .singleLine
        self.isUserInteractionEnabled = true
    }
}

extension UIView {
    func roundCornerWithShadow(cornerRadius: CGFloat, shadowRadius: CGFloat, offsetX: CGFloat, offsetY: CGFloat, colour: UIColor, opacity: Float) {
        
        self.clipsToBounds = false

        let layer = self.layer
        layer.masksToBounds = false
        layer.cornerRadius = cornerRadius
        layer.shadowOffset = CGSize(width: offsetX, height: offsetY);
        layer.shadowColor = colour.cgColor
        layer.shadowRadius = shadowRadius
        layer.shadowOpacity = opacity
        layer.shadowPath = UIBezierPath(roundedRect: CGRect(x: layer.bounds.minX, y: layer.bounds.minY, width: layer.bounds.width+40, height: layer.bounds.height+45), cornerRadius: layer.cornerRadius).cgPath
        
//        let bColour = self.backgroundColor
//        self.backgroundColor = nil
//        layer.backgroundColor = bColour?.cgColor
        
    }
    
}

extension UIColor {
    static var customColor: UIColor {
        return UIColor { (traits) -> UIColor in
            return traits.userInterfaceStyle == .dark ? UIColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 1) : UIColor.systemGroupedBackground
        }
    }
    
    static var lineSeparatorColor: UIColor {
        return UIColor { (traits) -> UIColor in
            return traits.userInterfaceStyle == .dark ? UIColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 1) : UIColor.systemGroupedBackground
        }
    }
}

extension Array {
    mutating func insertBeginning(_ elem: Element) {
        self.insert(elem, at: 0)
    }
}
