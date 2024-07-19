//
//  CommonMethods+Extensions.swift
//  flashcard
//
//  Created by Nucha Powanusorn on 05/03/2024.
//

import UIKit
import KeychainSwift
import Toast

// MARK: - Common functions
func resetApp() {
    let keychain = KeychainSwift()
    keychain.clear()
    while !ChapterManager.shared.getChapters().isEmpty {
        _ = ChapterManager.shared.removeChapter(at: 0)
    }
}

func makeMenu(children: [UIMenuElement]) -> UIMenu {
    let menu = UIMenu(options: .displayInline, children: children)
    return menu
}

func clearAllData() {
    let keychain = KeychainSwift()
    keychain.clear()
}

func delay(_ delay: Double, closure: @escaping () -> Void) {
    DispatchQueue.main.asyncAfter(
        deadline: DispatchTime.now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC),
        execute: closure
    )
}

func main(_ closure: @escaping () -> Void) {
    DispatchQueue.main.async(execute: closure)
}

func background(closure: @escaping () -> Void) {
    DispatchQueue.global(qos: .background).async {
        closure()
    }
}

func getAttributedStringDict(fontSize: CGFloat, weight: UIFont.Weight) -> [NSAttributedString.Key : Any] {
    return [NSAttributedString.Key.font : UIFont.systemFont(ofSize: fontSize, weight: weight)]
}

func getAttributedString(for title: String, fontSize: CGFloat, weight: UIFont.Weight) -> NSAttributedString {
    return NSAttributedString(string: title, attributes: getAttributedStringDict(fontSize: fontSize, weight: weight))
}

func getAttributedString(for title: String, fontSize: CGFloat, weight: UIFont.Weight) -> AttributedString {
    return AttributedString(getAttributedString(for: title, fontSize: fontSize, weight: weight))
}

func generateUID() -> String {
    UUID().uuidString
}

// MARK: - UIAlertController
extension UIAlertController {
    func addActions(_ actions: [UIAlertAction]) {
        for action in actions {
            addAction(action)
        }
    }

    static func showAlert(
        with title: String?,
        message: String?,
        style: UIAlertController.Style,
        primaryActionName: String,
        primaryActionStyle: UIAlertAction.Style,
        secondaryActionName: String? = nil,
        secondaryActionStyle: UIAlertAction.Style? = nil,
        primaryCompletion: (() -> Void)?,
        secondaryCompletion: (() -> Void)? = nil
    ) -> UIAlertController {
        let alert = UIAlertController(title: title, message: message, preferredStyle: style)
        let primaryAction = UIAlertAction(title: primaryActionName, style: primaryActionStyle) { _ in primaryCompletion?() }
        if let secondaryActionName = secondaryActionName, let secondaryActionStyle = secondaryActionStyle {
            let secondaryAction = UIAlertAction(title: secondaryActionName, style: secondaryActionStyle) { _ in
                secondaryCompletion?()
            }
            alert.addActions([primaryAction, secondaryAction])
        } else {
            alert.addAction(primaryAction)
        }
        return alert
    }
    
    static func showErrorAlert(title: String = "Error", message: String, completion: (() -> Void)? = nil) -> UIAlertController {
        return showDismissAlert(with: title, message: message, completion: completion)
    }

    static func showDeleteConfirmationAlert(
        with title: String,
        message: String?,
        primaryCompletion: @escaping () -> Void,
        secondaryCompletion: (() -> Void)? = nil
    ) -> UIAlertController {
        return showAlert(
            with: title,
            message: message,
            style: .alert,
            primaryActionName: "Delete",
            primaryActionStyle: .destructive,
            secondaryActionName: "Cancel",
            secondaryActionStyle: .cancel,
            primaryCompletion: primaryCompletion,
            secondaryCompletion: secondaryCompletion
        )
    }
    
    static func showOkAlert(with title: String, message: String?, completion: (() -> Void)? = nil) -> UIAlertController {
        UIAlertController.showAlert(with: title, message: message, style: .alert, primaryActionName: "Ok", primaryActionStyle: .cancel, primaryCompletion: completion)
    }

    static func showDismissAlert(with title: String, message: String?, completion: (() -> Void)? = nil) -> UIAlertController {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let dismissAction = UIAlertAction(title: "Dismiss", style: .cancel) { _ in
            completion?()
        }
        alert.addAction(dismissAction)
        return alert
    }

    static func showDismissScreenAlertSheet(
        title: String?,
        message: String?,
        actionTitle: String,
        completion: @escaping () -> Void
    ) -> UIAlertController {
        return showAlert(
            with: title,
            message: message,
            style: .actionSheet,
            primaryActionName: actionTitle,
            primaryActionStyle: .destructive,
            secondaryActionName: "Cancel",
            secondaryActionStyle: .cancel,
            primaryCompletion: completion
        )
    }

    static func showUnsavedChangesSheet(completion: @escaping () -> Void) -> UIAlertController {
        return showDismissScreenAlertSheet(
            title: "You have unsaved changes",
            message: nil,
            actionTitle: "Discard Changes",
            completion: completion
        )
    }
    
    static func showTextFieldAlert(with title: String, message: String?, actionTitle: String, isSecureEntry: Bool = false, completion: @escaping (_ textField: UITextField) -> Void) -> UIAlertController {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addTextField()
        if isSecureEntry, let textField = alertController.textFields?.first {
            textField.isSecureTextEntry = true
        }
        
        let submitAction = UIAlertAction(title: actionTitle, style: .default) { _ in
            guard let textField = alertController.textFields?[0] else { return }
            completion(textField)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        alertController.addActions([submitAction, cancelAction])
        return alertController
    }

    static func showNotImplementedAlert() -> UIAlertController {
        return showDismissAlert(with: "Error", message: "Not Implemented")
    }
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
        messageLabel.textColor = .label
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

// MARK: - Collection
extension Collection {
    subscript (safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

// MARK: - UIImage
extension UIImage {
    func resize(newWidth desiredWidth: CGFloat) -> UIImage {
        let oldWidth = size.width
        let scaleFactor = desiredWidth / oldWidth
        let newHeight = size.height * scaleFactor
        let newWidth = oldWidth * scaleFactor
        let newSize = CGSize(width: newWidth, height: newHeight)
        return resize(targetSize: newSize)
    }

    func resize(newHeight desiredHeight: CGFloat) -> UIImage {
        let scaleFactor = desiredHeight / size.height
        let newWidth = size.width * scaleFactor
        let newSize = CGSize(width: newWidth, height: desiredHeight)
        return resize(targetSize: newSize)
    }

    func resize(targetSize: CGSize) -> UIImage {
        return UIGraphicsImageRenderer(size:targetSize).image { _ in
            self.draw(in: CGRect(origin: .zero, size: targetSize))
        }
    }

    convenience init(color: UIColor, size: CGSize = CGSize(width: 1, height: 1)) {
        UIGraphicsBeginImageContextWithOptions(size, false, 1)
        defer {
            UIGraphicsEndImageContext()
        }
        color.setFill()
        UIRectFill(CGRect(origin: .zero, size: size))
        guard let aCgImage = UIGraphicsGetImageFromCurrentImageContext()?.cgImage else {
            self.init()
            return
        }
        self.init(cgImage: aCgImage)
    }
}

// MARK: - UILabel
extension UILabel {
    func setTextWithTypingAnimation(_ text: String, delay: TimeInterval = 0.1, completion: (() -> Void)?) {
        let textLength = text.count
        var counter = 0
        self.text = ""
        Timer.scheduledTimer(withTimeInterval: delay, repeats: true) { timer in
            if counter < textLength {
                self.text! += String(text[counter])
                counter += 1
            } else {
                timer.invalidate()
                Task {
                    try await Task.sleep(seconds: 0.5)
                    completion?()
                }
            }
        }
    }
}

// MARK: - UIView
extension UIView {
    func animateClickStart(withDuration duration: TimeInterval = 0.1, completion: (() -> Void)? = nil) {
        UIView.animate(withDuration: duration) {
            self.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        } completion: { _ in
            completion?()
        }
    }
    
    func restoreAnimation(withDuration duration: TimeInterval = 0.1, completion: (() -> Void)? = nil) {
        UIView.animate(withDuration: duration) {
            self.transform = CGAffineTransform.identity
        } completion: { _ in
            completion?()
        }
    }
    
    func addSubviews(_ views: UIView...) {
        views.forEach { addSubview($0) }
    }
    
    func animateClick(withDuration duration: TimeInterval = 0.1, completion: (() -> Void)? = nil) {
        animateClickStart(withDuration: duration) {
            self.restoreAnimation(withDuration: duration) {
                completion?()
            }
        }
    }
}

// MARK: - NotificationCenter
extension NotificationCenter {
    func post(name: String, object: Any?) {
        let notificationName = Notification.Name(name)
        post(name: notificationName, object: object)
    }

    func addObserver(_ observer: Any, selector aSelector: Selector, name aName: String, object anObject: Any?) {
        let notificationName = Notification.Name(aName)
        addObserver(observer, selector: aSelector, name: notificationName, object: anObject)
    }

    func removeObserver(_ observer: Any, name aName: String, object anObject: Any?) {
        let notificationName = Notification.Name(aName)
        removeObserver(observer, name: notificationName, object: anObject)
    }
    
}

// MARK: - Task
extension Task where Success == Never, Failure == Never {
    static func sleep(seconds: Double) async throws {
        let duration = UInt64(seconds * 1_000_000_000)
        try await Task.sleep(nanoseconds: duration)
    }
}

// MARK: - StringProtocol
extension StringProtocol {
    subscript(offset: Int) -> Character {
        self[index(startIndex, offsetBy: offset)]
    }
}

// MARK: - UIViewController
extension UIViewController {
    func goToHome() {
        let homeVC = HomeViewController()
        navigationController?.pushViewController(homeVC, animated: true, completion: {
            self.navigationController?.viewControllers = [homeVC]
        })
    }
}

// MARK: - UINavigationController
extension UINavigationController {
    public func pushViewController(_ viewController: UIViewController, animated: Bool, completion: (() -> Void)?) {
        CATransaction.begin()
        CATransaction.setCompletionBlock(completion)
        pushViewController(viewController, animated: animated)
        CATransaction.commit()
    }
}

// MARK: - Dictionary
extension Dictionary {
    static func += <K, V> (left: inout [K:V], right: [K:V]) {
        for (k, v) in right {
            left[k] = v
        }
    }
}

// MARK: - CGFloat
extension CGFloat {
    static func random() -> CGFloat {
        return CGFloat(arc4random()) / CGFloat(UInt32.max)
    }
}

// MARK: - UIColor
extension UIColor {
    static func random() -> UIColor {
        return UIColor(
           red:   .random(),
           green: .random(),
           blue:  .random(),
           alpha: 1.0
        )
    }
}
