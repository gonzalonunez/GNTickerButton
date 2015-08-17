#
# Be sure to run `pod lib lint GNTickerButton.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "GNTickerButton"
  s.version          = "0.1.1"
  s.summary          = "Inspired by the Layout app by Instagram, this is a UIButton subclass with a ticker that spins around as desired."

  s.homepage         = "https://github.com/gonzalonunez/GNTickerButton"
  s.license          = 'MIT'
  s.author           = { "Gonzalo Nunez" => "gonzi@tcpmiami.com" }
  s.source           = { :git => "https://github.com/gonzalonunez/GNTickerButton.git", :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/gonz_ponz'

  s.platform     = :ios, '8.0'
  s.requires_arc = true

  s.source_files = 'Pod/Classes/**/*'
  s.resource_bundles = {
    'GNTickerButton' => ['Pod/Assets/*.png']
  }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit'
end
