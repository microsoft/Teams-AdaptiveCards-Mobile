Pod::Spec.new do |spec|
  spec.name             = 'AdaptiveCards'

  spec.version          = '2.10.0'

  spec.license          = { :type => 'Adaptive Cards Binary EULA', :file => 'source/EULA-Non-Windows.txt' } 

  spec.homepage         = 'https://adaptivecards.io'

  spec.authors          = { 'AdaptiveCards' => 'Joseph.Woo@microsoft.com' }

  spec.summary          = 'Adaptive Cards are a new way for developers to exchange card content in a common and consistent way'
  
  spec.source       = { :git => 'https://github.com/microsoft/AdaptiveCards-Mobile.git', :tag => 'iOS/adaptivecards-ios@2.10.0' }

  spec.default_subspecs = 'AdaptiveCardsCore', 'AdaptiveCardsPrivate', 'ObjectModel', 'UIProviders', 'Swift'
  
  # AdaptiveCardsSwift is now a required dependency for automatic Swift implementation integration

  spec.subspec 'AdaptiveCardsCore' do | sspec |
    sspec.source_files = 'source/ios/AdaptiveCards/AdaptiveCards/AdaptiveCards/*.{h,m,mm}'
    sspec.resource_bundles = {'AdaptiveCards' => ['source/ios/AdaptiveCards/AdaptiveCards/AdaptiveCards/Resources/**/*']}
    sspec.dependency 'AdaptiveCards/AdaptiveCardsPrivate'
    sspec.dependency 'AdaptiveCards/ObjectModel'
    sspec.dependency 'AdaptiveCards/Swift'
    sspec.dependency 'SVGKit', '>= 3.0.0'
  end

  spec.subspec 'ObjectModel' do | sspec |
    sspec.source_files = 'source/shared/cpp/ObjectModel/**/*.{h,cpp}'
    sspec.header_mappings_dir = 'source/shared/cpp/ObjectModel/'
    sspec.private_header_files = 'source/shared/cpp/ObjectModel/**/*.{h}'
    sspec.xcconfig = {
         'CLANG_CXX_LANGUAGE_STANDARD' => 'c++17',
         'CLANG_CXX_LIBRARY' => 'libc++'
    }
  end

  spec.subspec 'AdaptiveCardsPrivate' do | sspec |
    sspec.source_files = 'source/ios/AdaptiveCards/AdaptiveCards/AdaptiveCards/PrivateHeaders/**/*.{h,m,mm}'
    sspec.header_mappings_dir = 'source/ios/AdaptiveCards/AdaptiveCards/AdaptiveCards/PrivateHeaders/'
    sspec.private_header_files = 'source/ios/AdaptiveCards/AdaptiveCards/AdaptiveCards/PrivateHeaders/*.h'
  end

  spec.subspec 'UIProviders' do | sspec |
    sspec.dependency 'MicrosoftFluentUI/Tooltip_ios', '~> 0.3.6'
    sspec.pod_target_xcconfig = { 'GCC_PREPROCESSOR_DEFINITIONS' => 'ADAPTIVECARDS_USE_FLUENT_TOOLTIPS=1' }
  end

  spec.platform         = :ios, '14'

  spec.frameworks = 'AVFoundation', 'AVKit', 'CoreGraphics', 'QuartzCore', 'UIKit'

  spec.exclude_files = 'source/ios/AdaptiveCards/AdaptiveCards/AdaptiveCards/include/**/*'
  
  # Swift implementation subspec
  spec.subspec 'Swift' do | sspec |
    # Include AdaptiveCardsSwift files
    sspec.source_files = 'source/ios/AdaptiveCardsSwift/Sources/AdaptiveCardsSwift/**/*.swift', 'source/ios/AdaptiveCardsSwift/Sources/AdaptiveCardsSwift/AdaptiveCardsSwift.h'
    
    # Define preprocessor macros for conditional compilation
    sspec.pod_target_xcconfig = {
      'SWIFT_VERSION' => '5.0',
      'SWIFT_ACTIVE_COMPILATION_CONDITIONS' => 'COCOAPODS',
      'DEFINES_MODULE' => 'YES',
      'BUILD_LIBRARY_FOR_DISTRIBUTION' => 'YES',
      'SWIFT_INCLUDE_PATHS' => '$(PODS_TARGET_SRCROOT)/source/ios/AdaptiveCardsSwift/Sources $(PODS_CONFIGURATION_BUILD_DIR)/SwiftAdaptiveCards',
      'SWIFT_OPTIMIZATION_LEVEL' => '-Onone'
    }
    
    # Add SwiftAdaptiveCards as a dependency
    sspec.dependency 'AdaptiveCards/SwiftAdaptiveCards'
    sspec.requires_arc = true
  end
  
  # SwiftAdaptiveCards integration directly within the pod
  spec.subspec 'SwiftAdaptiveCards' do |swiftspec|
    swiftspec.source_files = 'source/ios/AdaptiveCards/AdaptiveCards/Packages/SwiftAdaptiveCards/Sources/**/*.swift', 'source/ios/AdaptiveCards/AdaptiveCards/Packages/SwiftAdaptiveCards/Sources/**/SwiftAdaptiveCards.h'
    swiftspec.pod_target_xcconfig = {
      'SWIFT_VERSION' => '5.0',
      'DEFINES_MODULE' => 'YES',
      'SWIFT_INCLUDE_PATHS' => '$(PODS_TARGET_SRCROOT)/source/ios/AdaptiveCards/AdaptiveCards/Packages/SwiftAdaptiveCards/Sources',
      'BUILD_LIBRARY_FOR_DISTRIBUTION' => 'YES',
      'APPLICATION_EXTENSION_API_ONLY' => 'YES',
      'SWIFT_OPTIMIZATION_LEVEL' => '-Onone',
      'PRODUCT_MODULE_NAME' => 'SwiftAdaptiveCards'
    }
    # Removed module_name attribute as it's not allowed on subspecs
    swiftspec.frameworks = 'Foundation', 'UIKit'
    swiftspec.requires_arc = true
  end

end
