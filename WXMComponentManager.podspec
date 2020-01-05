Pod::Spec.new do |s|
  s.name         = "WXMComponentManager" 
  s.version      = "1.4.1"
  s.license      = "MIT"
  s.summary      = "组件中间层"

  s.homepage     = "https://github.com/XiaoMing-Wang/WXMComponentManager"
  s.source       = { :git => "https://github.com/XiaoMing-Wang/WXMComponentManager.git", :tag => "#{s.version}" }
  s.source_files = "Class"
  s.requires_arc = true 
  s.platform     = :ios, "9.0" 
  # s.frameworks   = "UIKit", "Foundation" 
  # s.dependency   = "AFNetworking" 
  s.author             = { "wq" => "347511109@qq.com" } 
end
