Pod::Spec.new do |s|
  s.name         = "FDFullScreenPopGestureSwift"
  s.version      = "0.0.1"
  s.summary      = "FDFullScreenPopGesture Swift 版本"
  s.description  = <<-DESC
                   DESC

  s.homepage     = "https://github.com/Minlison/FDFullScreenPopGestureSwift.git"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author             = { "Minlison" => "yuanhang.1991@icloud.com" }
  s.platform     = :ios, "8.0"
  s.source       = { :git => "https://github.com/Minlison/FDFullScreenPopGestureSwift.git", :tag => "#{s.version}" }

  s.source_files  = "FDFullScreenPopGestureSwift/FDFullScreenPopGestureSwift.swift"
  s.requires_arc = true
end
