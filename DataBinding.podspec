#
# Be sure to run `pod lib lint DataBinding.podspec' to ensure this is a
# valid spec and remove all comments before submitting the spec.
#
# Any lines starting with a # are optional, but encouraged
#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "DataBinding"
  s.version          = "0.1.2"
  s.summary          = "A short description of DataBinding."
  s.description      = <<-DESC
                       An optional longer description of DataBinding

                       * Markdown format.
                       * Don't worry about the indent, we strip it!
                       DESC
  s.homepage         = "https://github.com/<GITHUB_USERNAME>/DataBinding"
  # s.screenshots     = "www.example.com/screenshots_1", "www.example.com/screenshots_2"
  s.license          = 'MIT'
  s.author           = { "Softshag & Me" => "admin@softshag.dk" }
  s.source           = { :git => "https://github.com/<GITHUB_USERNAME>/DataBinding.git", :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.platform     = :ios, '8.0'
  s.requires_arc = true

  s.source_files = 'Pod/Classes/**/*'
  s.resource_bundles = {
    'DataBinding' => ['Pod/Assets/*.png']
  }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
  s.dependency 'RKValueTransformers',   '~> 1.1.2'
  s.dependency 'MTDates',               '~> 0.9.3'
  s.dependency 'JRSwizzle',              '~> 1.0'
  s.dependency "XCGLogger",             '~> 2.1.1'
  s.dependency 'Block-KVO',             '~> 2.2.3'
end
