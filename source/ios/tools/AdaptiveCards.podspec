Pod::Spec.new do |spec|
  spec.name             = 'AdaptiveCards'

  spec.version          = '2.10.0'

  spec.license          = { :type => 'Adaptive Cards Binary EULA', :file => 'source/EULA-Non-Windows.txt' } 

  spec.homepage         = 'https://adaptivecards.io'

  spec.authors          = { 'AdaptiveCards' => 'Joseph.Woo@microsoft.com' }

  spec.summary          = 'Adaptive Cards are a new way for developers to exchange card content in a common and consistent way'
  
  spec.source       = { :git => 'https://github.com/microsoft/AdaptiveCards-Mobile.git', :tag => 'iOS/adaptivecards-ios@2.10.0' }

  spec.default_subspecs = 'AdaptiveCardsCore', 'AdaptiveCardsPrivate', 'ObjectModel', 'UIProviders'

  spec.swift_versions = ['5.0']

  spec.pod_target_xcconfig = {
    'DEFINES_MODULE' => 'YES',
    'CLANG_ENABLE_MODULES' => 'YES'
  }

  spec.subspec 'SwiftAdapter' do |sa|
    sa.dependency 'AdaptiveCards/SwiftAdaptiveCards/Bridge'
  end

  spec.subspec 'AdaptiveCardsCore' do | sspec |
    sspec.source_files = 'source/ios/AdaptiveCards/AdaptiveCards/AdaptiveCards/*.{h,m,mm}'
    sspec.resource_bundles = {'AdaptiveCards' => ['source/ios/AdaptiveCards/AdaptiveCards/AdaptiveCards/Resources/**/*']}
    sspec.dependency 'AdaptiveCards/AdaptiveCardsPrivate'
    sspec.dependency 'AdaptiveCards/ObjectModel'
    sspec.dependency 'AdaptiveCards/SwiftAdapter'
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

  spec.subspec 'SwiftAdaptiveCards' do |sac|
    sac.subspec 'Core' do |core|
      core.source_files = 'source/ios/AdaptiveCards/AdaptiveCards/Packages/SwiftAdaptiveCards/Sources/SwiftAdaptiveCards/**/*.{swift,h}'
    end
  
    sac.subspec 'Bridge' do |bridge|
      bridge.source_files = 'source/ios/AdaptiveCards/AdaptiveCards/Packages/SwiftAdaptiveCards/Sources/SwiftAdaptiveCardsBridge/**/*.{swift,h}'
      bridge.dependency 'AdaptiveCards/SwiftAdaptiveCards/Core'
    end
  end


  spec.platform         = :ios, '14'

  spec.frameworks = 'AVFoundation', 'AVKit', 'CoreGraphics', 'QuartzCore', 'UIKit'

  spec.exclude_files = 'source/ios/AdaptiveCards/AdaptiveCards/AdaptiveCards/include/**/*'

end

