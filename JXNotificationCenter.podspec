Pod::Spec.new do |s|
  s.name         = "JXNotificationCenter"
  s.version      = "0.1.0"
  s.summary      = "The package of useful tools"
  s.homepage     = "https://github.com/joyhub2140/JXNotificationCenter"
  s.license      = "MIT"
  s.authors      = { 'JX' => 'xiejx.poco.cn'}
  s.platform     = :ios, "6.0"
  s.source       = { :git => "https://github.com/joyhub2140/JXNotificationCenter.git", :tag => s.version }
  s.source_files = 'JXNotificationCenter', 'JXNotificationCenter/**/*.{h,m}'
  s.requires_arc = true
end