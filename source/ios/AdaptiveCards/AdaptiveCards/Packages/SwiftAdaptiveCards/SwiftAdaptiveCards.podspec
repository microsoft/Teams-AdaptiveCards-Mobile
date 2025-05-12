Pod::Spec.new do |s|
  s.name             = 'SwiftAdaptiveCards'
  s.version          = '0.1.0'
  s.summary          = 'Swift implementation of Adaptive Cards'
  s.description      = <<-DESC
  A Swift package that provides implementation of Adaptive Cards for iOS applications.
                       DESC
  s.homepage         = 'https://github.com/microsoft/AdaptiveCards'
  s.license          = { :type => 'MIT', :text => 'Copyright (c) Microsoft Corporation. All rights reserved.' }
  s.author           = { 'Microsoft' => 'hugogonzalez@microsoft.com' }
  s.source           = { :git => 'https://github.com/microsoft/AdaptiveCards.git', :tag => s.version.to_s }
  
  s.ios.deployment_target = '15.0'
  s.swift_version = '5.0'
  
  # Specify source files
  s.source_files = 'Sources/**/*.swift'
  
  # Framework dependencies if any
  s.frameworks = 'Foundation'
end
