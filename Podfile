source 'https://github.com/CocoaPods/Specs.git'
source 'ssh://gerrit.zhenguanyu.com:29418/ios-specs'

pod 'FenbiLiveSdk'

target 'FenbiLiveSdkDemo' do
  use_frameworks!
  use_modular_headers!

end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    if target.name == 'YFDCommonLog'
      system(%q{
         mkdir -p Pods/Headers/Public/YFDCommonLog
         header=`grep '#import <YFDCommonLog/YFDCommonLogVersion.h>' -rl Pods/YFDCommonLog`
         if [[ ${#header} > 0 ]]; then
            str=`cat Podfile.lock | grep '^.*YFDCommonLog (.*:' | cut -d '(' -f 2 | cut -d ')' -f 1`
            sed -i '' 's/#import <YFDCommonLog\\/YFDCommonLogVersion.h>/static NSString *const kYFDCommonLogVersion = @\\"'"$str"'\\";/g' `grep '#import <YFDCommonLog/YFDCommonLogVersion.h>' -rl Pods/YFDCommonLog`
         fi
      })
      target.new_shell_script_build_phase("[CP-User]VersionModify").shell_script = <<-CMD
        versionDefined=`grep 'static NSString \\*const kYFDCommonLogVersion = @".*"' -rl ${PODS_ROOT}/YFDCommonLog`
        if [[ ${#versionDefined} > 0 ]]; then
          str=`cat ${PODS_ROOT}/../Podfile.lock | grep '^.*YFDCommonLog (.*\:' | cut -d '(' -f 2 | cut -d ')' -f 1`
          sed -i '' 's/static NSString \\*const kYFDCommonLogVersion = @\\".*\\";/static NSString \\*const kYFDCommonLogVersion = @\\"'"$str"'\\";/g' `grep 'static NSString \\*const kYFDCommonLogVersion = @".*"' -rl ${PODS_ROOT}/YFDCommonLog`
        fi
      CMD
    end
    if target.name == 'Protobuf'
      system(%q{
         filenames=`grep "@package" -rl Pods/Protobuf`
         if [[ ${#filenames} > 0 ]]; then
            sed -i '' 's/@package/@public/g' `grep "@package" -rl Pods/Protobuf`
         fi
      })
    end

    target.build_configurations.each do |config|
      config.build_settings.delete 'IPHONEOS_DEPLOYMENT_TARGET'
    end
  end
end
