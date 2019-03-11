# Disable sending stats
ENV['COCOAPODS_DISABLE_STATS'] = 'true'

source 'https://github.com/CocoaPods/Specs.git'
platform :ios, :deployment_target => '12.0'
inhibit_all_warnings!
use_frameworks!

def rx_swift
    pod 'RxSwift'
    pod 'RxSwiftExt'
end

def rx_cocoa
    pod 'RxCocoa'
end

def rx_cocoa
    pod 'Alamofire'
    pod 'AlamofireImage'
end

def objectMapper
    pod 'ObjectMapper'
end

def kingfisher
    pod 'Kingfisher', '~> 4.10.1'
end

target 'suryaAssignment' do
    rx_swift
    rx_cocoa
    objectMapper
    kingfisher
end


