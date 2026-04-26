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
  # Newer compilers reject `override init` when the parent's designated
  # initializer is not visible as overridable in the generic subclass context.
  podfile_dir = File.dirname(__FILE__)
  [
    "#{podfile_dir}/Pods/RxCocoa/RxCocoa/iOS/DataSources/RxCollectionViewReactiveArrayDataSource.swift",
    "#{podfile_dir}/Pods/RxCocoa/RxCocoa/iOS/DataSources/RxTableViewReactiveArrayDataSource.swift"
  ].each do |file|
    next unless File.exist?(file)
    content = File.read(file)
    patched = content.gsub('    override init(cellFactory: @escaping CellFactory) {',
                           '    init(cellFactory: @escaping CellFactory) {')
    File.write(file, patched) if patched != content
  end
end
