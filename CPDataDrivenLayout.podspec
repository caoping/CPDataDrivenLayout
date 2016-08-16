Pod::Spec.new do |s|
  s.name         = "CPDataDrivenLayout"
  s.version      = "0.2.4"
  s.summary      = "Data driven content for UITableView"
  s.homepage     = "https://github.com/caoping/CPDataDrivenLayout"

  s.license      = { :type => "MIT", :file => "LICENSE" }

  s.author             = { "caoping" => "caoping.dev@gmail.com" }
  s.social_media_url   = "http://weibo.com/caoping"

  s.platform     = :ios, "7.0"

  s.source       = { :git => "https://github.com/caoping/CPDataDrivenLayout.git", :tag => s.version }
  s.source_files = "CPDataDrivenLayout/*.{h,m}", "CPDataDrivenLayout/Additional/*.{h,m}"
  s.requires_arc = true
  s.dependency "UITableView+FDTemplateLayoutCell", "1.4"
end
