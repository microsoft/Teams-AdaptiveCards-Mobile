Pod::Spec.new do |s|
  s.name             = 'SwiftAdaptiveCards'
  s.version          = '2.10.0'  # Match with AdaptiveCards version
  s.summary          = 'Swift implementation of Adaptive Cards'
  s.description      = <<-DESC
  A Swift package that provides implementation of Adaptive Cards for iOS applications.
                       DESC
  s.homepage         = 'https://github.com/microsoft/AdaptiveCards'
  s.license          = { :type => 'Adaptive Cards Binary EULA', :file => '../../../../../EULA-Non-Windows.txt' }
  s.author           = { 'Microsoft' => 'adaptivecardsdevelopers@microsoft.com' }
  s.source           = { :git => 'https://github.com/microsoft/AdaptiveCards-Mobile.git', :tag => 'iOS/adaptivecards-ios@2.10.0' }
  
  s.ios.deployment_target = '14.0'
  s.swift_version = '5.0'
  
  # Define header file paths
  s.ios.private_header_files = 'Sources/SwiftAdaptiveCards/SwiftAdaptiveCards.h'
  
  # Specify source files - using relative paths for better integration
  s.source_files = 'Sources/**/*.swift', 'Sources/SwiftAdaptiveCards/SwiftAdaptiveCards.h'
  
  # No public headers for a pure Swift module
  # s.public_header_files = 'Sources/**/*.h'
  
  # Framework dependencies if any
  s.frameworks = 'Foundation', 'UIKit'
  
  # Ensure module can be imported properly
  s.module_name = 'SwiftAdaptiveCards'
  s.pod_target_xcconfig = { 
    'DEFINES_MODULE' => 'YES',
    'SWIFT_INCLUDE_PATHS' => '$(PODS_TARGET_SRCROOT)/Sources',
    'BUILD_LIBRARY_FOR_DISTRIBUTION' => 'YES',
    'APPLICATION_EXTENSION_API_ONLY' => 'YES',
    'SWIFT_OPTIMIZATION_LEVEL' => '-Onone'
  }
  
  # Ensure proper compilation
  s.requires_arc = true
  s.static_framework = false
end
