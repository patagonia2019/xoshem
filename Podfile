source 'https://github.com/southfox/Specs.git'
source 'https://github.com/CocoaPods/Specs.git'

use_frameworks!

def sharedPods
    pod 'Localize-Swift', '~> 1.7'
    pod 'JFWindguru', :path => '/Users/javierfuchs/Job/southfox/jfwindguru'
    pod 'JFCore', :path => '/Users/javierfuchs/Job/southfox/jfcore'
end

def iosPods
    pod 'HockeySDK', '~> 4.1.5'
    pod 'SwiftSpinner', '~> 1.4.1'
    pod 'SwiftIconFont', '~> 2.7.2'
    pod 'Fabric'
    pod 'Crashlytics'
    pod 'FontWeather.swift', :path => '/Users/javierfuchs/Job/southfox/FontWeather.swift'
    pod 'FlexiCollectionViewLayout'
end

#def watchPods
#end

target 'Xoshem' do
    iosPods
    sharedPods
end

#target 'watchos Extension' do
#platform :watchos, '2.2'
#    watchPods
#    sharedPods
#end

