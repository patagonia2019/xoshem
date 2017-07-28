source 'https://github.com/southfox/Specs.git'
source 'https://github.com/CocoaPods/Specs.git'

use_frameworks!

def sharedPods
    pod 'AlamofireObjectMapper', '~> 4.0'
    pod 'Localize-Swift', '~> 1.7'
    pod 'JFWindguru/ExtFwk', :path => '/Users/javierfuchs/Job/southfox/jfwindguru'
    pod 'JFCore', :path => '/Users/javierfuchs/Job/southfox/jfcore'
end

def iosPods
    pod 'HockeySDK', '~> 4.1.5'
    pod 'BadgeSegmentControl', '~> 1.0'
    pod 'AlamofireImage'
    pod 'SwiftSpinner'
    pod 'SCLAlertView', '~> 0.7'
    #pod 'SwiftIconFont', :git => 'https://github.com/southfox/SwiftIconFont', :branch => 'master'
    pod 'SwiftIconFont'
    pod 'Fabric'
    pod 'Crashlytics'
    pod 'Digits'
    pod 'FontWeather.swift', :path => '/Users/javierfuchs/Job/southfox/FontWeather.swift'
    pod 'FlexiCollectionViewLayout'
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

