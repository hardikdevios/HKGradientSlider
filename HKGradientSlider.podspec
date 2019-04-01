Pod::Spec.new do |s|
  s.name             = 'HKGradientSlider'
  s.version          = '1.0.3'
  s.summary          = 'Gradient Layer'

  s.description      = "Gradient Layer Slider for custom use"

  s.homepage         = 'https://github.com/hardikdevios/HKGradientSlider'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Hardik Shah' => 'hardik@thetatechnolabs.com' }
  s.source           = { :git => 'https://github.com/hardikdevios/HKGradientSlider.git', :tag => s.version.to_s }

  s.ios.deployment_target = '10.0'
  s.source_files = 'HKGradientSlider/Source/HKGradientSlider.swift'

end
