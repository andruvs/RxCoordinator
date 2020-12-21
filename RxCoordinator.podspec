Pod::Spec.new do |spec|

  spec.name         = "RxCoordinator"
  spec.version      = "1.0.0"
  spec.summary      = "Coordinator pattern with RxSwift"

  spec.homepage     = "https://github.com/andruvs/RxCoordinator"
  spec.license      = { :type => "MIT", :file => "LICENSE" }

  spec.author             = { "andruvs" => "andruvs@gmail.com" }

  spec.ios.deployment_target = "11.0"
  spec.swift_version = "5.2"


  spec.source       = { :git => "https://github.com/andruvs/RxCoordinator.git", :tag => "#{spec.version}" }


  spec.source_files  = "Sources/**/*.{h,m,swift}"


  spec.dependency "RxSwift", ">= 5.0"

end
