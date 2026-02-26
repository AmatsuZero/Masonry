Pod::Spec.new do |s|
  s.name     = 'Masonry'
  s.version  = '1.2.0'
  s.license  = 'MIT'
  s.summary  = 'Harness the power of Auto Layout NSLayoutConstraints with a simplified, chainable and expressive syntax.'
  s.homepage = 'https://github.com/AmatsuZero/Masonry'
  s.author   = { 'AmatsuZero' => 'jzh16s@hotmail.com' }
  s.social_media_url = "http://twitter.com/cloudkite"

  s.source   = { :git => 'https://github.com/AmatsuZero/Masonry.git', :tag => "v#{s.version}" }

  s.description = %{
    Masonry is a light-weight layout framework which wraps AutoLayout with a nicer syntax.
	Masonry has its own layout DSL which provides a chainable way of describing your
	NSLayoutConstraints which results in layout code which is more concise and readable.
    Masonry supports iOS and Mac OSX.
  }

  pch_AF = <<-EOS
    #ifndef TARGET_OS_IOS
        #define TARGET_OS_IOS TARGET_OS_IPHONE
    #endif
    #ifndef TARGET_OS_TV
        #define TARGET_OS_TV 0
    #endif
  EOS

  s.ios.deployment_target = '9.0' # minimum SDK with autolayout
  s.osx.deployment_target = '10.7' # minimum SDK with autolayout
  s.tvos.deployment_target = '9.0' # minimum SDK with autolayout
  s.requires_arc = true
  s.swift_versions = ['5.0', '5.5', '5.7', '5.9', '6.0']

  # 默认只包含 ObjC 核心模块
  s.default_subspecs = 'Core'

  # ── Core: Objective-C 核心功能 ──
  s.subspec 'Core' do |core|
    core.source_files = 'Masonry/*.{h,m}'
  end

  # ── Swift: Swift 原生语法扩展 ──
  # 用法：pod 'Masonry/Swift'
  s.subspec 'Swift' do |sw|
    sw.dependency 'Masonry/Core'
    sw.source_files    = 'Masonry/*.swift'
  end
end
