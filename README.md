# GNTickerButton

[![CI Status](http://img.shields.io/travis/Gonzalo Nunez/GNTickerButton.svg?style=flat)](https://travis-ci.org/Gonzalo Nunez/GNTickerButton)
[![Version](https://img.shields.io/cocoapods/v/GNTickerButton.svg?style=flat)](http://cocoapods.org/pods/GNTickerButton)
[![License](https://img.shields.io/cocoapods/l/GNTickerButton.svg?style=flat)](http://cocoapods.org/pods/GNTickerButton)
[![Platform](https://img.shields.io/cocoapods/p/GNTickerButton.svg?style=flat)](http://cocoapods.org/pods/GNTickerButton)

## Usage

To run the example project, clone the repo, and run `pod install` from the Example directory first.

Using GNTickerButton is very easy. Rotating the ticker is as easy as calling one function:

```swift
public func rotateTickerWithDuration(duration:CFTimeInterval, rotations repeatCount:Int = 1, rotationBlock: (Void -> Void)?) {
```

The rotationBlock gets called everytime the ticker rotates completely. Keep in mind you can choose to pass nil into here and set yourself as the delegate of the GNTickerButton instead. For this, you'll need to conform to GNTickerButtonRotationDelegate.
*Note:* As of right now, passing in a non-nil block takes precedence over the delegate. The delegate method is only called if no block was passed in.

The rest of the variables should be very self explanatory. Oh and take note that this is an @IBDesignable class with many @IBInspectable variables!

## Installation

GNTickerButton is available through [CocoaPods](http://cocoapods.org). 
To install it, simply add the following lines to your Podfile:

```ruby
use_frameworks!
pod "GNTickerButton"
```

## Contribution

Please feel free to submit any and all pull requests, I know there's more we can add to this button! 

## Author

Gonzalo Nunez, gonzi@tcpmiami.com

## License

GNTickerButton is available under the MIT license. See the LICENSE file for more info.
