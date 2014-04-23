Pod::Spec.new do |s|
  s.name = "MERThumbnailKit"
  s.version = "2.0.0"
  s.summary = "A framework for generating thumbnails from urls, both local and remote. Built on top of ReactiveCocoa, compatible with iOS, 7.0+."
  s.homepage = "https://github.com/MaestroElearning/MERThumbnailKit"
  s.license = "Commercial"
  s.author = {"William Towe" => "willbur1984@gmail.com"}
  
  s.platform = :ios, '7.0'
  s.requires_arc = true
  
  s.dependency 'MEFoundation', '~> 1.0.0'
  s.dependency "ReactiveCocoa", "~> 2.3.0"
  s.dependency "libextobjc/EXTScope", "~> 0.4.0"
  
  s.frameworks = 'UIKit','MobileCoreServices','CoreMedia','AVFoundation','Accelerate'
  
  s.source = {:git => "git@github.com:MaestroElearning/METhumbnailKit.git",:tag => s.version.to_s}
  s.source_files = "MERThumbnailKit"
end