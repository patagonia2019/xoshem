source 'https://github.com/southfox/Specs.git'
source 'https://github.com/CocoaPods/Specs.git'

use_frameworks!

def sharedPods
    pod 'Localize-Swift', '~> 1.7'
    pod 'JFWindguru', :path => '../jfwindguru'
    pod 'JFCore', :path => '../jfcore'
end

def iosPods
    pod 'HockeySDK', '~> 4.1.5'
    pod 'SwiftSpinner', '~> 1.4.1'
    pod 'SwiftIconFont', '~> 2.7.2'
    pod 'Fabric'
    pod 'Crashlytics'
    pod 'FlexiCollectionViewLayout'
end

#def watchPods
#end

target 'Xoshem' do
    platform :ios, '12.0'
    iosPods
    sharedPods
end

#target 'watchos Extension' do
#platform :watchos, '5.2'
#    watchPods
#    sharedPods
#end

#target 'XoshemTvOS' do
#  platform :tvos, '12.0'
#  pod 'JFWindguru', :path => '../'
#end


#target 'XoshemMacOS' do
#  platform :macos, '10.14'
#  pod 'JFWindguru', :path => '../'
#end


