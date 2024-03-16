//
//  BounceButton.swift
//  FlashCard
//
//  Created by Nucha Powanusorn on 10/03/2024.
//

import UIKit

class BounceButton: UIButton {
        
    override init(frame: CGRect) {
        super.init(frame: frame)
        setFont()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setFont()
    }

    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        setFont()
    }

    override func setTitle(_ title: String?, for state: UIControl.State) {
        self.configuration?.attributedTitle = getAttributedString(for: title ?? "", fontSize: 15.0, weight: .bold)
    }

    func setFont() {
        self.titleLabel?.font = UIFont.systemFont(ofSize: 15.0, weight: .bold)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
    }
        
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        self.animateClickStart()
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        self.restoreAnimation()
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        self.restoreAnimation()
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        if let touch = touches.first {
            let location = touch.location(in: self)
            if !self.bounds.contains(location) {
                self.restoreAnimation()
                cancelTracking(with: nil)
            }
        }
    }
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        return bounds.insetBy(dx: 0, dy: 0).contains(point)
    }
}
