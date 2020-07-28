//
//  UIViewExtension.swift
//  Digitail
//
//  Created by Iottive on 03/07/19.
//  Copyright © 2019 Iottive. All rights reserved.
//

import UIKit

extension UIView {
    
    /// Smoothens/Sharpens the edges of a View
    ///
    /// - Parameters:
    ///   - enable: Smoothening/Sharpening of edges toggled with enable
    ///   - radius: Curve radius for the edges
    func round(enable: Bool = true, withRadius radius: CGFloat? = 3.0) {
        let cornerRadius = radius ?? min(bounds.width, bounds.height)/10
        layer.cornerRadius = enable ? cornerRadius : 0
        layer.masksToBounds = enable
    }
    
    func roundCorners(corners:UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        let rect = self.bounds
        mask.frame = rect
        mask.path = path.cgPath
        self.layer.mask = mask
    }
    
    /// Circularises the View
    ///
    /// - Parameter enable: Circular or normal view toggled with enable
    func circle(enable: Bool = true) {
        self.layoutIfNeeded()
        let cornerRadius = min(bounds.width, bounds.height)/2
        layer.cornerRadius = enable ? cornerRadius : 0
        layer.masksToBounds = true
    }
    
    /// Adds a 50% opaque shadow to the view
    ///
    /// - Parameters:
    ///   - enable: toggles shadow on the
    ///   - color: color of the shadow
    func shadow(enable: Bool = true, colored color: CGColor, withRadius radius: CGFloat = 5.0) {
        layer.masksToBounds = !enable
        layer.shadowOffset = CGSize.zero
        layer.shadowOpacity = enable ? 1.0 : 0.0
        layer.shadowRadius = radius
        layer.shadowColor = enable ? color : UIColor.clear.cgColor
    }
    
    func setShadowWithCornerRadius(){
        let corners : CGFloat =  min(bounds.width, bounds.height)/2
        self.layer.cornerRadius = corners
        
        let shadowPath2 = UIBezierPath(rect: self.bounds)
        
        self.layer.masksToBounds = false
        
        self.layer.shadowColor = UIColor.lightGray.cgColor
        
        self.layer.shadowOffset = CGSize(width: CGFloat(1.0), height: CGFloat(3.0))
        
        self.layer.shadowOpacity = 0.3
        
        self.layer.shadowPath = shadowPath2.cgPath
        
    }
    /// Circularises the View
    ///
    /// - Parameter enable: Circular or normal view toggled with enable
    func border(enable: Bool = true, withWidth width: CGFloat = 2.0, andColor color: UIColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)) {
        layer.borderWidth = enable ? width : 0
        layer.borderColor = enable ? color.cgColor : UIColor.clear.cgColor
    }
    
}

// Used for making cards with rounded corner and shadow.
@IBDesignable
class CardView: UIView {
    
    @IBInspectable var cornerRadius: CGFloat = 5
    
    @IBInspectable var shadowOffsetWidth: Int = 0
    @IBInspectable var shadowOffsetHeight: Int = 2
    @IBInspectable var shadowColor: UIColor? = UIColor.black
    @IBInspectable var shadowOpacity: Float = 0.3
    
    override func layoutSubviews() {
        layer.cornerRadius = cornerRadius
        let shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius)
        layer.masksToBounds = false
        layer.shadowColor = shadowColor?.cgColor
        layer.shadowOffset = CGSize(width: shadowOffsetWidth, height: shadowOffsetHeight);
        layer.shadowOpacity = shadowOpacity
        layer.shadowPath = shadowPath.cgPath
    }
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        for subview in subviews as [UIView] {
            if !subview.isHidden && subview.alpha > 0 && subview.isUserInteractionEnabled && subview.point(inside: convert(point, to: subview), with: event) {
                return true
            }
        }
        return false
    }
}
