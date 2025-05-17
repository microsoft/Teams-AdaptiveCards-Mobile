Pod::Spec.new do |s|
  s.name             = 'SwiftAdaptiveCards'
  s.version          = '2.10.0'  # Match with AdaptiveCards version
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
  
  # Specify source files
  s.source_files = 'source/ios/AdaptiveCards/AdaptiveCards/Packages/SwiftAdaptiveCards/Sources/**/*.swift'
  
  # Make the headers public to ensure they can be imported
  s.public_header_files = 'source/ios/AdaptiveCards/AdaptiveCards/Packages/SwiftAdaptiveCards/Sources/**/*.h'
  
  # Framework dependencies if any
  s.frameworks = 'Foundation', 'UIKit'
  
  # Ensure module can be imported properly
  s.module_name = 'SwiftAdaptiveCards'
  s.pod_target_xcconfig = { 
    'DEFINES_MODULE' => 'YES',
    'SWIFT_INCLUDE_PATHS' => '$(PODS_ROOT)/SwiftAdaptiveCards/source/ios/AdaptiveCards/AdaptiveCards/Packages/SwiftAdaptiveCards/Sources'
  }
end
