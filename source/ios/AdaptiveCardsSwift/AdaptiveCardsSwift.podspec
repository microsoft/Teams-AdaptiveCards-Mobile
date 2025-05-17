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
  
  spec.source_files = 'Sources/AdaptiveCardsSwift/**/*.{swift}'
  spec.dependency 'SwiftAdaptiveCards'
  
  # This ensures the SwiftAdaptiveCards pod is included
  spec.subspec 'SwiftAdaptiveCards' do |sspec|
    sspec.source_files = '../AdaptiveCards/AdaptiveCards/Packages/SwiftAdaptiveCards/Sources/SwiftAdaptiveCards/**/*.{swift}'
    sspec.public_header_files = '../AdaptiveCards/AdaptiveCards/Packages/SwiftAdaptiveCards/Sources/SwiftAdaptiveCards/**/*.{h}'
  end
  
  # Optional dependency on AdaptiveCards Objective-C framework
  spec.dependency 'SVGKit', '3.0.0'
  
  # Include the bridging header
  spec.preserve_paths = 'Sources/AdaptiveCardsSwift/AdaptiveCardsSwift-Bridging-Header.h'
  
  # This ensures the bridging header is properly imported
  spec.xcconfig = { 
    'SWIFT_INCLUDE_PATHS' => '$(PODS_ROOT)/AdaptiveCardsSwift/Sources',
    'HEADER_SEARCH_PATHS' => '$(PODS_ROOT)/Headers/Public/SVGKit'
  }
end
