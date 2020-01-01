Pod::Spec.new do |s|
  s.name         = "WQComponentManager" 
  s.version      = "1.4.0"
  s.license      = "MIT"
  s.summary      = "组件中间层"

  s.homepage     = "https://github.com/XiaoMing-Wang/WQComponentManager" 
  s.source       = { :git => "https://github.com/XiaoMing-Wang/WQComponentManager.git", :tag => "#{s.version}" }
  s.source_files = "WQComponentManager/**/*"
  s.requires_arc = true 
  s.platform     = :ios, "9.0" 
  # s.frameworks   = "UIKit", "Foundation" 
  # s.dependency   = "AFNetworking" 
  s.author             = { "wq" => "347511109@qq.com" } 
end
