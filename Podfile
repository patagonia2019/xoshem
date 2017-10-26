source 'https://github.com/southfox/Specs.git'
source 'https://github.com/CocoaPods/Specs.git'

use_frameworks!

def sharedPods
    pod 'Localize-Swift', '~> 1.7'
    pod 'JFWindguru', :git => 'https://github.com/southfox/jfwindguru', :branch => 'master'
    pod 'JFCore', :git => 'https://github.com/southfox/jfcore', :branch => 'master'
end

def iosPods
    pod 'HockeySDK', '~> 4.1.5'
    pod 'SwiftSpinner', '~> 1.4.1'
    pod 'SwiftIconFont', '~> 2.7.2'
    pod 'Fabric'
    pod 'Crashlytics'
    pod 'FontWeather.swift', :git => 'https://github.com/southfox/FontWeather.swift', :branch => 'master'
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

