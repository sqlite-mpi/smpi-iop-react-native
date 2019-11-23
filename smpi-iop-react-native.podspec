require "json"

package = JSON.parse(File.read(File.join(__dir__, "package.json")))

# @see https://stackoverflow.com/questions/58691345/unable-to-determine-swift-version-for-the-following-pod-error
ENV['SWIFT_VERSION'] = "4.2"

Pod::Spec.new do |s|
  s.name         = "smpi-iop-react-native"
  s.version      = package["version"]
  s.summary      = package["description"]
  s.description  = <<-DESC
                  smpi-iop-react-native
                   DESC
  s.homepage     = "https://github.com/sqlite-mpi/smpi-iop-react-native"
  s.license      = "MIT"
  s.authors      = { "Enzo" => "emadda.dev@gmail.com" }
  s.platforms    = { :ios => "9.0" }
  s.source       = { :git => "https://github.com/sqlite-mpi/smpi-iop-react-native.git", :tag => "#{s.version}" }

  s.source_files = "ios/**/*.{h,m,swift}"
  s.requires_arc = true

  # @see https://stackoverflow.com/questions/23678729/how-to-add-vendor-static-library-in-project-via-podspec
  # - This has the same effect as adding it to the "Target -> General -> Linked Frameworks and Libraries" of the parent project.
  # Fixes: `Undefined symbols for architecture`.
  s.ios.vendored_library = 'ios/libs/libsmpi_iop_ffi.a'

  s.dependency "React"
end

