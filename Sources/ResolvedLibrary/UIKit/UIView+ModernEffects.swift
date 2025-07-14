////
////  UIView+ModernEffects.swift
////  ResolvedLibrary
////
////  Created by Olami on 2025-07-13.
////
//
//import UIKit
//
//extension UIView {
//    func addModernShadow(theme: ResolvedTheme, color: UIColor? = nil) {
//        layer.shadowColor = (color ?? UIColor.black).cgColor
//        layer.shadowOpacity = theme.shadowOpacity
//        layer.shadowOffset = CGSize(width: 0, height: 4)
//        layer.shadowRadius = theme.shadowRadius / 2
//        layer.masksToBounds = false
//    }
//    
//    func addModernBorder(theme: ResolvedTheme) {
//        layer.borderWidth = 1
//        layer.borderColor = theme.effectiveColors.borderColor.cgColor
//    }
//    
//    func addGlassEffect(theme: ResolvedTheme) {
//        addModernShadow(theme: theme)
//        addModernBorder(theme: theme)
//        
//        let innerBorder = CALayer()
//        innerBorder.frame = bounds
//        innerBorder.cornerRadius = layer.cornerRadius
//        innerBorder.borderWidth = 1
//        innerBorder.borderColor = UIColor.white.withAlphaComponent(0.2).cgColor
//        layer.addSublayer(innerBorder)
//    }
//    
//    func addFadeInAnimation(delay: TimeInterval = 0) {
//        alpha = 0
//        transform = CGAffineTransform(translationX: 0, y: 20)
//        
//        UIView.animate(
//            withDuration: 0.6,
//            delay: delay,
//            usingSpringWithDamping: 0.8,
//            initialSpringVelocity: 0,
//            options: [.curveEaseOut],
//            animations: {
//                self.alpha = 1
//                self.transform = .identity
//            }
//        )
//    }
//    
//    func addRippleEffect(at point: CGPoint, color: UIColor) {
//        let ripple = CAShapeLayer()
//        let radius = max(bounds.width, bounds.height)
//        let path = UIBezierPath(arcCenter: point, radius: radius, startAngle: 0, endAngle: .pi * 2, clockwise: true)
//        
//        ripple.path = path.cgPath
//        ripple.fillColor = color.withAlphaComponent(0.3).cgColor
//        ripple.transform = CATransform3DMakeScale(0, 0, 1)
//        layer.addSublayer(ripple)
//        
//        CATransaction.begin()
//        CATransaction.setCompletionBlock { ripple.removeFromSuperlayer() }
//        
//        let scaleAnimation = CABasicAnimation(keyPath: "transform.scale")
//        scaleAnimation.fromValue = 0
//        scaleAnimation.toValue = 1
//        scaleAnimation.duration = 0.4
//        scaleAnimation.timingFunction = CAMediaTimingFunction(name: .easeOut)
//        
//        let opacityAnimation = CABasicAnimation(keyPath: "opacity")
//        opacityAnimation.fromValue = 1
//        opacityAnimation.toValue = 0
//        opacityAnimation.duration = 0.4
//        
//        ripple.add(scaleAnimation, forKey: "scale")
//        ripple.add(opacityAnimation, forKey: "opacity")
//        CATransaction.commit()
//    }
//}
