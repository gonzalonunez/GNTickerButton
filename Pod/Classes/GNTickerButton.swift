//
//  GNTickerButton.swift
//  Letters
//
//  Created by Gonzalo Nunez on 5/11/15.
//  Copyright (c) 2015 Gonzalo Nunez. All rights reserved.
//

import UIKit

public protocol GNTickerButtonRotationDelegate: class {
  func tickerButtonTickerRotated(tickerButton button:GNTickerButton)
}

@IBDesignable open class GNTickerButton : UIButton {
  
  static fileprivate let kInnerRingLineWidth:CGFloat = 1
  static fileprivate let kOuterRingLineWidth:CGFloat = 4
  static fileprivate let kOutterInnerRingSpacing:CGFloat = 6
  static fileprivate let kTearDropRadius:CGFloat = 5
  
  static fileprivate let kTickerRotationAnimationKey = "transform.rotation"
  static fileprivate let kRingProgressAnimationKey = "strokeEnd"
  
  static fileprivate let kRingProgressAnimationDuration = 0.15
  
  @IBInspectable open var fillColor = UIColor(red: 251/255, green: 77/255, blue: 31/255, alpha: 1) {
    didSet {
      setNeedsDisplay()
    }
  }
  
  @IBInspectable open var ringColor = UIColor.white {
    didSet {
      setNeedsDisplay()
    }
  }
  
  @IBInspectable open var tickerColor  = UIColor.white {
    didSet {
      setNeedsDisplay()
    }
  }
  
  open var shouldShowRingProgress = true {
    didSet {
      ringLayer.isHidden = !shouldShowRingProgress
    }
  }
  
  fileprivate var isPressed : Bool = false {
    didSet {
      setNeedsDisplay()
    }
  }
  
  fileprivate(set) var tickerIsSpinning = false
  
  fileprivate var tickerLayer = CAShapeLayer()
  fileprivate var ringLayer = CAShapeLayer()
  
  fileprivate var desiredRotations:Int?
  
  weak var delegate : GNTickerButtonRotationDelegate?
  
  //MARK: - Initiliazation
  
  required public init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    addTargets()
  }
  
  override public init(frame: CGRect) {
    super.init(frame: frame)
    addTargets()
  }
  
  //MARK: - Set Up
  
  fileprivate func setUpTicker() {
    tickerLayer.removeFromSuperlayer()
    
    let centerX = bounds.midX
    let centerY = bounds.midY
    
    let outerRadius = outerRadiusInRect(bounds)
    let innerRadius = outerRadius - GNTickerButton.kOutterInnerRingSpacing
    
    let path = CGMutablePath()
    let padding = 8 as CGFloat
    
    path.addArc(center: CGPoint(x: centerX, y: centerY), radius: GNTickerButton.kTearDropRadius, startAngle: 2 * CGFloat.pi, endAngle: CGFloat.pi, clockwise: false)
    path.addLine(to: CGPoint(x: centerX, y: centerY  - innerRadius + padding))
    path.addLine(to: CGPoint(x: centerX + GNTickerButton.kTearDropRadius, y: centerY))
    
    let tearDropHeight = innerRadius - padding
    
    let boundingBox = path.boundingBox
    let height = boundingBox.height
    let anchorY = 1 - (height - tearDropHeight)/height
    
    tickerLayer.anchorPoint = CGPoint(x: 0.5, y: anchorY)
    tickerLayer.position = CGPoint(x: layer.bounds.midX, y: layer.bounds.midY)
    tickerLayer.bounds = boundingBox
    tickerLayer.path = path
    tickerLayer.fillColor = tickerColor.cgColor
    tickerLayer.strokeColor = tickerColor.cgColor
    
    layer.addSublayer(tickerLayer)
  }
  
  fileprivate func setUpRing() {
    ringLayer.removeFromSuperlayer()
    
    let rect = layer.bounds
    let outerRadius = outerRadiusInRect(rect)
    let centerX = rect.midX
    let centerY = rect.midY
    
    let ringPath = CGMutablePath()
    ringPath.addArc(center: CGPoint(x: centerX, y: centerY), radius: outerRadius, startAngle: -CGFloat.pi/2, endAngle: 3 * CGFloat.pi/2, clockwise: false)
    
    ringLayer.path = ringPath
    ringLayer.position = CGPoint(x: layer.bounds.midX, y: layer.bounds.midY)
    ringLayer.bounds = ringPath.boundingBox
    ringLayer.fillColor = UIColor.clear.cgColor
    ringLayer.strokeColor = ringColor.cgColor
    
    ringLayer.lineWidth = GNTickerButton.kOuterRingLineWidth
    ringLayer.strokeEnd = 0
    
    layer.addSublayer(ringLayer)
  }
  
  fileprivate func addTargets() {
    addTarget(self, action: #selector(GNTickerButton.touchDown), for: .touchDown)
    addTarget(self, action: #selector(GNTickerButton.touchUpInside), for: .touchUpInside)
    addTarget(self, action: #selector(GNTickerButton.touchUpOutside), for: .touchUpOutside)
  }
  
  @objc fileprivate func touchDown() {
    isPressed = true
  }
  
  @objc fileprivate func touchUpInside() {
    isPressed = false
  }
  
  @objc fileprivate func touchUpOutside() {
    isPressed = false
  }
  
  //MARK: Public
  
  open func rotateTickerWithDuration(_ duration:CFTimeInterval, rotations repeatCount:Int = 1, rotationBlock: ((Void) -> Void)?) {
    _rotateTickerWithDuration(duration, rotations: repeatCount, shouldSetDesiredRotationCount: desiredRotations == nil, rotationBlock: rotationBlock)
  }
  
  open func stopRotatingTicker() {
    tickerLayer.removeAnimation(forKey: GNTickerButton.kTickerRotationAnimationKey)
  }
  
  open func clearRingProgress() {
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
  
  fileprivate func _rotateTickerWithDuration(_ duration:CFTimeInterval, rotations repeatCount:Int = 1, shouldSetDesiredRotationCount:Bool = true, rotationBlock: ((Void) -> Void)?) {
    tickerIsSpinning = true
    
    if (shouldSetDesiredRotationCount) {
      desiredRotations = repeatCount
    }
    
    let rotationAnimation = CABasicAnimation(keyPath: GNTickerButton.kTickerRotationAnimationKey)
    rotationAnimation.duration = duration
    rotationAnimation.fromValue = 0
    rotationAnimation.toValue = 2*M_PI
    rotationAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
    
    CATransaction.begin()
    CATransaction.setCompletionBlock() {
      DispatchQueue.main.async {
        self.updateRingProgress(repeatCount, animated: true)
        if (rotationBlock != nil) {
          rotationBlock!()
        } else {
          self.delegate?.tickerButtonTickerRotated(tickerButton: self)
        }
        if (repeatCount > 0) {
          self.rotateTickerWithDuration(duration, rotations: repeatCount - 1, rotationBlock: rotationBlock)
        } else {
          self.desiredRotations = nil
          self.tickerIsSpinning = false
        }
      }
    }
    
    tickerLayer.add(rotationAnimation, forKey: GNTickerButton.kTickerRotationAnimationKey)
    CATransaction.commit()
  }
  
  fileprivate func updateRingProgress(_ rotationsLeft:Int, animated:Bool) {
    var strokeEnd = 0 as CGFloat
    if (desiredRotations != nil) {
      strokeEnd = CGFloat((desiredRotations! - rotationsLeft)) / CGFloat(desiredRotations!)
    }
    
    let fillAnimation = CABasicAnimation(keyPath: GNTickerButton.kRingProgressAnimationKey)
    fillAnimation.duration = animated ? GNTickerButton.kRingProgressAnimationDuration : 0
    fillAnimation.fromValue = ringLayer.strokeEnd
    fillAnimation.toValue = strokeEnd
    fillAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
    
    ringLayer.strokeEnd = strokeEnd
    
    CATransaction.begin()
    ringLayer.add(fillAnimation, forKey: GNTickerButton.kRingProgressAnimationKey)
    CATransaction.commit()
  }
  
  //MARK: - Drawing
  
  override open func draw(_ rect: CGRect) {
    super.draw(rect)
    
    func addCircleInContext(_ context:CGContext, centerX:CGFloat, centerY:CGFloat, radius:CGFloat) {
      context.addArc(center: CGPoint(x: centerX, y: centerY), radius: radius, startAngle: 0, endAngle: 2 * CGFloat.pi, clockwise: false)
    }
    
    guard let context = UIGraphicsGetCurrentContext() else {
      return
    }
    
    let color = isPressed ? fillColor.withAlphaComponent(0.5) : fillColor
    context.setFillColor(color.cgColor)
    
    context.setStrokeColor(ringColor.cgColor)
    
    let outerRadius = outerRadiusInRect(rect)
    let innerRadius = outerRadius - GNTickerButton.kOutterInnerRingSpacing
    
    let centerX = rect.midX
    let centerY = rect.midY
    
    // Inner Circle
    addCircleInContext(context, centerX: centerX, centerY: centerY, radius: innerRadius)
    context.fillPath()
    
    // Inner Ring
    context.setLineWidth(GNTickerButton.kInnerRingLineWidth)
    addCircleInContext(context, centerX: centerX, centerY: centerY, radius: innerRadius)
    context.strokePath()
  }
  
  override open func draw(_ layer: CALayer, in ctx: CGContext) {
    super.draw(layer, in: ctx)
    setUpTicker()
    setUpRing()
  }
  
  //MARK - Helpers
  
  fileprivate func outerRadiusInRect(_ rect:CGRect) -> CGFloat {
    return rect.width/2 - 2
  }
  
}
