//
//  GNTickerButton.swift
//  Letters
//
//  Created by Gonzalo Nunez on 5/11/15.
//  Copyright (c) 2015 Gonzalo Nunez. All rights reserved.
//

import Foundation
import UIKit

@objc public protocol CaptureButtonRotationDelegate {
     func captureButtonTickerRotated(captureButton button:GNTickerButton)
}

@IBDesignable public class GNTickerButton : UIButton {
    
    static let kInnerRingLineWidth:CGFloat = 1
    static let kOuterRingLineWidth:CGFloat = 4
    static let kOutterInnerRingSpacing:CGFloat = 6
    static let kTearDropRadius:CGFloat = 5
    
    static let kTickerRotationAnimationKey = "transform.rotation"

    @IBInspectable public var fillColor = UIColor(red: 251/255, green: 77/255, blue: 31/255, alpha: 1) {
        didSet {
            setNeedsDisplay()
        }
    }
    
    @IBInspectable public var ringColor = UIColor.whiteColor() {
        didSet {
            setNeedsDisplay()
        }
    }
    
    @IBInspectable public var tickerColor  = UIColor.whiteColor() {
        didSet {
            setNeedsDisplay()
        }
    }
    
    public var shouldShowTicker = true {
        didSet {
            tickerLayer.hidden = !shouldShowTicker
        }
    }
    
    private var isPressed : Bool = false {
        didSet {
            setNeedsDisplay()
        }
    }
    
    private(set) var tickerIsSpinning = false
    
    private var tickerLayer = CAShapeLayer()
    
    weak var delegate : CaptureButtonRotationDelegate?
    
    //MARK: - Initiliazation
    
    required public init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        addTargets()
    }
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        addTargets()
    }
    
    //MARK: - Set Up
    
    private func setUpTicker() {
        tickerLayer.removeFromSuperlayer()
        
        let centerX = CGRectGetMidX(bounds)
        let centerY = CGRectGetMidY(bounds)
        
        let outerRadius = outerRadiusInRect(bounds)
        let innerRadius = outerRadius - GNTickerButton.kOutterInnerRingSpacing
        
        let path = CGPathCreateMutable()
        let padding = 8 as CGFloat
        
        CGPathAddArc(path, nil, centerX, centerY, GNTickerButton.kTearDropRadius,  CGFloat(2*M_PI),  CGFloat(M_PI), false)
        CGPathAddLineToPoint(path, nil, centerX, centerY  - innerRadius + padding)
        CGPathAddLineToPoint(path, nil, centerX + GNTickerButton.kTearDropRadius, centerY)
        
        let tearDropHeight = innerRadius - padding
        
        tickerLayer = CAShapeLayer()
        
        let boundingBox = CGPathGetBoundingBox(path)
        let height = CGRectGetHeight(boundingBox)
        let anchorY = 1 - (height - tearDropHeight)/height
        
        tickerLayer.anchorPoint = CGPoint(x: 0.5, y: anchorY)
        tickerLayer.position = CGPoint(x: CGRectGetMidX(layer.bounds), y: CGRectGetMidY(layer.bounds))
        tickerLayer.bounds = boundingBox
        tickerLayer.path = path
        tickerLayer.fillColor = tickerColor.CGColor
        tickerLayer.strokeColor = tickerColor.CGColor
        
        layer.addSublayer(tickerLayer)
    }
    
    private func addTargets() {
        addTarget(self, action: "touchDown", forControlEvents: .TouchDown)
        addTarget(self, action: "touchUpInside", forControlEvents: .TouchUpInside)
        addTarget(self, action: "touchUpOutside", forControlEvents: .TouchUpOutside)
    }
    
    @objc private func touchDown() {
        isPressed = true
    }
    
    @objc private func touchUpInside() {
        isPressed = false
    }
    
    @objc private func touchUpOutside() {
        isPressed = false
    }
    
    //MARK: Public
    
    public func rotateTickerWithDuration(duration:CFTimeInterval, repeatCount:Int = 1, rotationBlock: (Void -> Void)?) {
        tickerIsSpinning = true
        
        let rotationAnimation = CABasicAnimation(keyPath: GNTickerButton.kTickerRotationAnimationKey)
        rotationAnimation.duration = duration
        rotationAnimation.fromValue = 0
        rotationAnimation.toValue = 2*M_PI
        rotationAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        
        CATransaction.begin()
        var repeats = repeatCount
        CATransaction.setCompletionBlock() {
            dispatch_async(dispatch_get_main_queue()) {
                if (rotationBlock != nil) {
                    rotationBlock!()
                } else {
                    self.delegate?.captureButtonTickerRotated(captureButton: self)
                }
                if (repeats > 0) {
                    self.rotateTickerWithDuration(duration, repeatCount: --repeats, rotationBlock : rotationBlock)
                } else {
                    self.tickerIsSpinning = false
                }
            }
        }
        tickerLayer.addAnimation(rotationAnimation, forKey: GNTickerButton.kTickerRotationAnimationKey)
        CATransaction.commit()
    }
    
    public func stopRotatingTicker() {
        tickerLayer.removeAnimationForKey(GNTickerButton.kTickerRotationAnimationKey)
    }
    
    //MARK: - Drawing
    
    override public func drawRect(rect: CGRect) {
        super.drawRect(rect)
        
        func addCircleInContext(context:CGContextRef, centerX:CGFloat, centerY:CGFloat, radius:CGFloat) {
            CGContextAddArc(context, centerX, centerY, radius, CGFloat(0), CGFloat(2*M_PI), 0)
        }
        
        let context = UIGraphicsGetCurrentContext()
        
        let color = isPressed ? fillColor.colorWithAlphaComponent(0.5) : fillColor
        CGContextSetFillColorWithColor(context, color.CGColor)
        
        CGContextSetStrokeColorWithColor(context, ringColor.CGColor)
        
        let outerRadius = outerRadiusInRect(rect)
        let innerRadius = outerRadius - GNTickerButton.kOutterInnerRingSpacing
        
        let centerX = CGRectGetMidX(rect)
        let centerY = CGRectGetMidY(rect)
        
        // Outer Ring
        CGContextSetLineWidth(context, GNTickerButton.kOuterRingLineWidth)
        addCircleInContext(context, centerX, centerY, outerRadius)
        CGContextStrokePath(context)
        
        // Inner Circle
        addCircleInContext(context, centerX, centerY, innerRadius)
        CGContextFillPath(context)
        
        // Inner Ring
        CGContextSetLineWidth(context, GNTickerButton.kInnerRingLineWidth)
        addCircleInContext(context, centerX, centerY, innerRadius)
        CGContextStrokePath(context)
    }
    
    override public func drawLayer(layer: CALayer!, inContext ctx: CGContext!) {
        super.drawLayer(layer, inContext: ctx)
        setUpTicker()
    }
    
    //MARK - Helpers
    
    private func outerRadiusInRect(rect:CGRect) -> CGFloat {
        return rect.width/2 - 2
    }
    
}