Pod::Spec.new do |spec|
  spec.name             = 'AdaptiveCardsSwift'
  spec.version          = '1.0.0'
  spec.license          = { :type => 'Adaptive Cards Binary EULA', :file => '../../EULA-Non-Windows.txt' }
  spec.homepage         = 'https://adaptivecards.io'
  spec.authors          = { 'AdaptiveCards' => 'adaptivecardsdevelopers@microsoft.com' }
  spec.summary          = 'Swift implementation of Adaptive Cards'
  spec.description      = <<-DESC
  AdaptiveCardsSwift provides a Swift-native API surface for the AdaptiveCards framework,
  making it easier for Swift developers to integrate and use adaptive cards in their iOS apps.
  This package bridges between the Objective-C++ implementation and Swift.
                       DESC
  spec.source           = { :git => 'https://github.com/microsoft/AdaptiveCards-Mobile.git', :tag => 'iOS/adaptivecards-ios-swift@1.0.0' }
  spec.swift_version    = '5.0'
  
  spec.ios.deployment_target = '15.0'
  
  # Define header file paths
  spec.ios.private_header_files = 'Sources/AdaptiveCardsSwift/AdaptiveCardsSwift.h'
  
  # Source files - include both Swift files and umbrella header
  spec.source_files = 'Sources/AdaptiveCardsSwift/**/*.swift', 'Sources/AdaptiveCardsSwift/AdaptiveCardsSwift.h'
  
  # Direct dependency on SwiftAdaptiveCards
  spec.dependency 'SwiftAdaptiveCards'
  
  # Optional dependency on SVGKit
  spec.dependency 'SVGKit', '3.0.0'
  
  # This ensures proper module definition for pure Swift module
  spec.pod_target_xcconfig = {
    'DEFINES_MODULE' => 'YES',
    'SWIFT_INCLUDE_PATHS' => '$(PODS_TARGET_SRCROOT)/Sources $(PODS_CONFIGURATION_BUILD_DIR)/SwiftAdaptiveCards',
    'HEADER_SEARCH_PATHS' => '$(PODS_ROOT)/Headers/Public/SVGKit $(PODS_CONFIGURATION_BUILD_DIR)/SwiftAdaptiveCards/SwiftAdaptiveCards.framework/Headers',
    'BUILD_LIBRARY_FOR_DISTRIBUTION' => 'YES',
    'SWIFT_OPTIMIZATION_LEVEL' => '-Onone'
  }
  
  # Ensure proper compilation
  spec.libraries = 'c++'
  spec.requires_arc = true
  spec.static_framework = false
end
