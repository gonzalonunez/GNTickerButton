//
//  GNTickerButton.swift
//  Letters
//
//  Created by Gonzalo Nunez on 5/11/15.
//  Copyright (c) 2015 Gonzalo Nunez. All rights reserved.
//

import UIKit

@objc public protocol CaptureButtonRotationDelegate {
    func captureButtonTickerRotated(captureButton button:GNTickerButton)
}

@IBDesignable public class GNTickerButton : UIButton {
    
    static private let kInnerRingLineWidth:CGFloat = 1
    static private let kOuterRingLineWidth:CGFloat = 4
    static private let kOutterInnerRingSpacing:CGFloat = 6
    static private let kTearDropRadius:CGFloat = 5
    
    static private let kTickerRotationAnimationKey = "transform.rotation"
    static private let kRingProgressAnimationKey = "strokeEnd"
    
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
    
    public var shouldShowRingProgress = true {
        didSet {
            ringLayer.hidden = !shouldShowRingProgress
        }
    }
    
    private var isPressed : Bool = false {
        didSet {
            setNeedsDisplay()
        }
    }
    
    private(set) var tickerIsSpinning = false
    
    private var tickerLayer = CAShapeLayer()
    private var ringLayer = CAShapeLayer()
    
    private var desiredRotations:Int?
    
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
    
    private func setUpRing() {
        ringLayer.removeFromSuperlayer()
        
        let rect = layer.bounds
        let outerRadius = outerRadiusInRect(rect)
        let centerX = CGRectGetMidX(rect)
        let centerY = CGRectGetMidY(rect)
        
        let ringPath = CGPathCreateMutable()
        CGPathAddArc(ringPath, nil, centerX, centerY, outerRadius, CGFloat(-M_PI_2), CGFloat(M_PI_2*3), false)
        
        ringLayer = CAShapeLayer()
        
        ringLayer.path = ringPath
        ringLayer.position = CGPoint(x: CGRectGetMidX(layer.bounds), y: CGRectGetMidY(layer.bounds))
        ringLayer.bounds = CGPathGetBoundingBox(ringPath)
        ringLayer.fillColor = UIColor.clearColor().CGColor
        ringLayer.strokeColor = ringColor.CGColor
        
        ringLayer.lineWidth = GNTickerButton.kOuterRingLineWidth
        ringLayer.strokeEnd = 0
        
        layer.addSublayer(ringLayer)
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
    
    public func rotateTickerWithDuration(duration:CFTimeInterval, rotations repeatCount:Int = 1, rotationBlock: (Void -> Void)?) {
        if (desiredRotations == nil) {
            _rotateTickerWithDuration(duration, rotations: repeatCount, shouldSetDesiredRotationCount: true, rotationBlock: rotationBlock)
        } else {
            _rotateTickerWithDuration(duration, rotations: repeatCount, shouldSetDesiredRotationCount: false, rotationBlock: rotationBlock)
        }
    }
    
    public func stopRotatingTicker() {
        tickerLayer.removeAnimationForKey(GNTickerButton.kTickerRotationAnimationKey)
    }
    
    public func clearRingProgress() {
        CATransaction.begin()
        CATransaction.setCompletionBlock() {
            CATransaction.begin()
            self.ringLayer.strokeStart = 0
            self.ringLayer.strokeEnd = 0
            CATransaction.commit()
        }
        ringLayer.strokeStart = 1
        CATransaction.commit()
    }
    
    //MARK: Private
    
    private func _rotateTickerWithDuration(duration:CFTimeInterval, rotations repeatCount:Int = 1, shouldSetDesiredRotationCount:Bool = true, rotationBlock: (Void -> Void)?) {
        tickerIsSpinning = true
        
        if (shouldSetDesiredRotationCount) {
            desiredRotations = repeatCount
        }
        
        let rotationAnimation = CABasicAnimation(keyPath: GNTickerButton.kTickerRotationAnimationKey)
        rotationAnimation.duration = duration
        rotationAnimation.fromValue = 0
        rotationAnimation.toValue = 2*M_PI
        rotationAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        
        var repeats = repeatCount
        
        CATransaction.begin()
        CATransaction.setCompletionBlock() {
            dispatch_async(dispatch_get_main_queue()) {
                self.updateRingProgress(repeatCount, animated: true)
                if (rotationBlock != nil) {
                    rotationBlock!()
                } else {
                    self.delegate?.captureButtonTickerRotated(captureButton: self)
                }
                if (repeats > 0) {
                    self._rotateTickerWithDuration(duration, rotations: --repeats, shouldSetDesiredRotationCount: false, rotationBlock: rotationBlock)
                } else {
                    self.desiredRotations = nil
                    self.tickerIsSpinning = false
                }
            }
        }
        
        tickerLayer.addAnimation(rotationAnimation, forKey: GNTickerButton.kTickerRotationAnimationKey)
        CATransaction.commit()
    }
    
    private func updateRingProgress(rotationsLeft:Int, animated:Bool) {
        var strokeEnd = 0 as CGFloat
        if (desiredRotations != nil) {
            strokeEnd = CGFloat((desiredRotations! - rotationsLeft)) / CGFloat(desiredRotations!)
        }
        
        let fillAnimation = CABasicAnimation(keyPath: GNTickerButton.kRingProgressAnimationKey)
        fillAnimation.duration = animated ? 0.15 : 0
        fillAnimation.fromValue = ringLayer.strokeEnd
        fillAnimation.toValue = strokeEnd
        fillAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        
        ringLayer.strokeEnd = strokeEnd
        
        CATransaction.begin()
        ringLayer.addAnimation(fillAnimation, forKey: GNTickerButton.kRingProgressAnimationKey)
        CATransaction.commit()
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
        setUpRing()
    }
    
    //MARK - Helpers
    
    private func outerRadiusInRect(rect:CGRect) -> CGFloat {
        return rect.width/2 - 2
    }
    
}