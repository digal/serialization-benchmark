source 'https://github.com/CocoaPods/Specs.git'

link_with 'serialization-benchmark', 'serialization-benchmarkTests'
platform :ios, "7.0"

#Network / model / API
pod 'Mantle', '1.5.4'

pod 'MessagePack', '1.0.0'

pod 'MGBenchmark', :head

pod 'MessagePackCoder', :podspec => "https://raw.githubusercontent.com/VoltMobi/messagepackcoder/master/MessagePackCoder.podspec"

pod 'MsgPackSerialization', :head

pod 'MPMessagePack', '1.0.9'

target 'serialization-benchmarkTests', :exclusive => true do
    link_with 'serialization-benchmarkTests'

    pod 'MD5Digest', '0.1.0'
end