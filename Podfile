use_frameworks!

def sharedPods
    pod 'AlamofireObjectMapper', '~> 2.1'
    pod 'Localize-Swift', :git => 'https://github.com/southfox/Localize-Swift.git', :branch => 'develop'
    #pod 'JFWindguru', :git => 'https://bitbucket.org/southfox/jfwindguru.git', :branch => 'develop'
    pod 'JFWindguru', :path => '../jfwindguru'
    #pod 'JFCore', :git => 'https://bitbucket.org/southfox/jfcore.git', :branch => 'develop'
    pod 'JFCore', :path => '../jfcore'
    pod 'FontWeather.swift', :path => '../FontWeather.swift'
end

def iosPods
    pod 'DGElasticPullToRefresh', :git => 'https://github.com/southfox/DGElasticPullToRefresh.git', :branch => 'develop'
    pod 'NVActivityIndicatorView', :git => 'https://github.com/southfox/NVActivityIndicatorView.git', :branch => 'develop'
    pod 'SCLAlertView', :git => 'https://github.com/southfox/SCLAlertView-Swift', :branch => 'swift-2.3'
    pod 'SwiftIconFont', :path => '../SwiftIconFont'
    pod 'Fabric'
    pod 'Crashlytics'
    pod 'Digits'
    #pod 'TwitterCore'
    #    pod 'AWSCognito'
    #pod 'SlackKit'
end

def watchPods
end

target 'Xoshem' do
    iosPods
    sharedPods
end

target 'watchos Extension' do
platform :watchos, '2.2'
    watchPods
    sharedPods
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
   target.build_configurations.each do |configuration|
     configuration.build_settings['SWIFT_VERSION'] = "2.3"
   end   
  end 
end

