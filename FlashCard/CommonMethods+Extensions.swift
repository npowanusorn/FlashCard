//
//  CommonMethods+Extensions.swift
//  flashcard
//
//  Created by Nucha Powanusorn on 05/03/2024.
//

import UIKit

func makeMenu(children: [UIMenuElement]) -> UIMenu {
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
    func fadeIn(duration: TimeInterval = 1, completion: ((Bool) -> Void)? = nil) {
        if isHidden {
            isHidden = false
        }
        UIView.animate(withDuration: duration, animations: {
            self.alpha = 1
        }, completion: completion)
    }
    
    func fadeOut(duration: TimeInterval = 1, completion: ((Bool) -> Void)? = nil) {
        if isHidden {
            isHidden = false
        }
        UIView.animate(withDuration: duration, animations: {
            self.alpha = 0
        }, completion: completion)
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
    func randomElement(count: Int) -> [Self.Element]? {
        guard count <= self.count else { return [Self.Element]() }
        if count == self.count { return self }
        var randIdx = [Int]()
        while randIdx.count < count {
            let rand = Int.random(in: 0..<self.count)
            if !randIdx.contains(rand) {
                randIdx.append(rand)
            }
        }
        var arr = [Self.Element]()
        for i in randIdx {
            arr.append(self[i])
        }
        return arr
    }
}

extension Array<String> {
    func countStringContainingOccurrences(_ elem: String) -> Int {
        var count = 0
        for item in self {
            if item.contains(elem) {
                count += 1
            }
        }
        return count
    }
    
    mutating func insertBeginning(_ elem: Element) {
        self.insert(elem, at: 0)
    }
}

extension Dictionary {
    static func stringAdd(lhs: [String: String], rhs: [String: String]) -> [String: String] {
        var result = lhs
        rhs.forEach { elem in
            if let _ = lhs[elem.key] {
                result[elem.key + K.Texts.dup] = elem.value
            } else {
                result[elem.key] = elem.value
            }
        }
        return result
    }
    
    static func += (lhs: inout [Key: Value], rhs: [Key: Value]) {
        rhs.forEach { lhs[$0] = $1 }
    }
}
