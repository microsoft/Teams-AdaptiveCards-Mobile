Pod::Spec.new do |s|
  s.name             = 'SwiftAdaptiveCards'
  s.version          = '2.10.0'
  s.summary          = 'Swift implementation of Adaptive Cards'
  s.description      = <<-DESC
  A Swift package that provides implementation of Adaptive Cards for iOS applications.
                       DESC
  s.homepage         = 'https://github.com/microsoft/AdaptiveCards'
  s.license          = { :type => 'Adaptive Cards Binary EULA', :file => 'source/EULA-Non-Windows.txt' }
  s.author           = { 'Microsoft' => 'adaptivecardsdevelopers@microsoft.com' }
  s.source           = { :git => 'https://github.com/microsoft/AdaptiveCards-Mobile.git', :tag => 'iOS/adaptivecards-ios@2.10.0' }
  
  s.ios.deployment_target = '14.0'
  s.swift_version = '5.0'
  
  # Default to include both the core library and bridge
  s.default_subspecs = 'Core', 'Bridge'
  
  s.frameworks = 'Foundation', 'UIKit'
  
  # Core implementation
  s.subspec 'Core' do |core|
    core.source_files = 'source/ios/AdaptiveCards/AdaptiveCards/Packages/SwiftAdaptiveCards/Sources/SwiftAdaptiveCards/**/*.swift'
    core.pod_target_xcconfig = {
      'DEFINES_MODULE' => 'YES',
      'SWIFT_INCLUDE_PATHS' => '$(PODS_ROOT)/SwiftAdaptiveCards/source/ios/AdaptiveCards/AdaptiveCards/Packages/SwiftAdaptiveCards/Sources'
    }
  end
  
  # Bridge implementation for Objective-C interoperability
  s.subspec 'Bridge' do |bridge|
    bridge.source_files = 'source/ios/AdaptiveCards/AdaptiveCards/Packages/SwiftAdaptiveCards/Sources/SwiftAdaptiveCardsBridge/**/*.swift'
    bridge.dependency 'SwiftAdaptiveCards/Core'
    bridge.pod_target_xcconfig = {
      'DEFINES_MODULE' => 'YES'
    }
  end
end
