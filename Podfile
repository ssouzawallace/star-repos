# Uncomment the next line to define a global platform for your project
platform :ios, '12.0'

target 'Github Star Repos' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!

  # Pods for Github Star Repos
  pod 'RxSwift',    '~> 4.4.2'
  pod 'RxCocoa',    '~> 4.4.2'
  pod 'RxDataSources', '~> 3.1.0'
  pod 'Cartography', '~> 3.1.0'
  pod 'SDWebImage', '~> 4.4.6'
  
  target 'Github Star ReposTests' do
    inherit! :search_paths
    # Pods for testing
    pod 'Quick'
    pod 'Nimble'
    pod 'RxNimble/RxTest'
    pod 'OHHTTPStubs/Swift'
    pod 'iOSSnapshotTestCase'
    
  end

end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '12.0'
    end
  end

  # Fix RxCocoa 4.4.2 compatibility with newer Swift/Xcode versions.
  # Newer compilers produce "multiple definitions of symbol" when a generic
  # SequenceWrapper subclass re-declares the same init as its parent.
  # Removing the redundant init from the Wrapper classes lets Swift use the
  # inherited designated initializer instead.
  podfile_dir = File.dirname(__FILE__)
  [
    "#{podfile_dir}/Pods/RxCocoa/RxCocoa/iOS/DataSources/RxCollectionViewReactiveArrayDataSource.swift",
    "#{podfile_dir}/Pods/RxCocoa/RxCocoa/iOS/DataSources/RxTableViewReactiveArrayDataSource.swift"
  ].each do |file|
    next unless File.exist?(file)
    content = File.read(file)
    patched = content.gsub(/\n\s+(?:override )?init\(cellFactory: @escaping CellFactory\) \{\n\s+super\.init\(cellFactory: cellFactory\)\n\s+\}\n/, "\n")
    File.write(file, patched) if patched != content
  end
end
