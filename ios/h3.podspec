


#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#
require 'yaml'
pubspec = YAML.load_file(File.join('..', 'pubspec.yaml'))
libraryVersion = pubspec['version'].gsub('+', '-')

Pod::Spec.new do |s|
  s.name             = 'h3'
  s.version          = '0.0.1'
  s.summary          = 'A new Flutter project.'
  s.description      = <<-DESC
A new Flutter project.
                       DESC
  s.homepage         = 'http://example.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Your Company' => 'email@example.com' }

  s.source           = { :path => '.' }
  s.source_files = 'h3/src/h3lib/**/*', 'dart_shim.cpp'
  s.public_header_files = 'h3/src/h3lib/**/*.h'
  s.prepare_command = <<-CMD
      if [ -d ./h3 ]
      then
          echo "Repo exists"
      else
          git clone https://github.com/uber/h3
      fi
      mkdir lib || echo "Dir exists "
      cd lib
      cmake ..
      make h3
    CMD
  s.ios.deployment_target = '10.0'
end




# #
# # To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
# #
# require 'yaml'
# pubspec = YAML.load_file(File.join('..', 'pubspec.yaml'))
# libraryVersion = pubspec['version'].gsub('+', '-')

# Pod::Spec.new do |s|
#   s.name             = 'h3'
#   s.version          = '0.0.1'
#   s.summary          = 'A new Flutter project.'
#   s.description      = <<-DESC
# A new Flutter project.
#                        DESC
#   s.homepage         = 'http://example.com'
#   s.license          = { :file => '../LICENSE' }
#   s.author           = { 'Your Company' => 'email@example.com' }

#   # s.source           = { :path => '.' }
#   # s.source_files = 'h3/src/h3lib/**/*', 'h3/ios/dart_shim.cc'
#   # s.public_header_files = 'h3/src/h3lib/**/*.h', 'h3/ios/dart_shim.h'
#   # # s.prepare_command = <<-CMD
#   # #     if [ -d ./h3 ]
#   # #     then
#   # #         echo "Repo exists"
#   # #     else
#   # #         git clone https://github.com/uber/h3
#   # #     fi
#   # #     mkdir build || echo "Dir exists "
#   # #     cd build
#   # #     cmake ..
#   # #     make h3
#   # #   CMD
#   # s.framework      = 'h3'
#   s.ios.deployment_target = '9.0'
#    # including C++ library
#   # s.library = 'h3/ios/dart_shim.cc'
# end

#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint native_add.podspec' to validate before publishing.
#
# Pod::Spec.new do |s|
#   s.name             = 'h3'
#   s.version          = '0.0.1'
#   s.summary          = 'A new flutter plugin project.'
#   s.description      = <<-DESC
# A new flutter plugin project.
#                        DESC
#   s.homepage         = 'http://example.com'
#   s.license          = { :file => '../LICENSE' }
#   s.author           = { 'Your Company' => 'email@example.com' }
#   s.source           = { :path => '.' }
#   s.source_files = 'Classes/**/*'
#   s.dependency 'Flutter'
#   s.platform = :ios, '9.0'
#   s.source_files = 'h3/src/h3lib/**/*', 'h3/ios/dart_shim.cc'
#   s.public_header_files = 'h3/src/h3lib/**/*.h', 'h3/ios/dart_shim.h'
#   # s.framework      = 'h3'

#   # Flutter.framework does not contain a i386 slice.
#   s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
#   s.swift_version = '5.0'
# end

