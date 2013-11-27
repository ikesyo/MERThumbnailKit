Pod::Spec.new do |s|
  s.name = "METhumbnailKit"
  s.version = "1.0.10"
  s.summary = "A framework for generating thumbnails from various file types. Uses the Accelerate framework. It is fast."
  s.homepage = "https://github.com/MaestroElearning/METhumbnailKit"
  s.license = "Commercial"
  s.author = {"William Towe" => "willbur1984@gmail.com"}
  
  s.platform = :ios, '7.0'
  s.requires_arc = true
  
  s.dependency 'MEFoundation', '~> 0.3.14'
  
  s.frameworks = 'CoreGraphics','UIKit','MobileCoreServices','CoreMedia','AVFoundation','Accelerate'
  
  s.source = {:git => "git@github.com:MaestroElearning/METhumbnailKit.git",:tag => s.version.to_s}
  s.source_files = 'METhumbnailKit'
end