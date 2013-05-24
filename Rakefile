# -*- coding: utf-8 -*-
$:.unshift("/Library/RubyMotion/lib")
require 'motion/project/template/ios'

require 'bundler'
Bundler.setup
Bundler.require

Motion::Project::App.setup do |app|
  # Use `rake config' to see complete project settings.
  app.name = 'Twee'
  app.identifier = 'name.goshakkk.twee'
  app.provisioning_profile(//)
  app.device_family = :iphone
  app.interface_orientations = [:portrait]

  app.frameworks += ['Twitter', 'Accounts']
end
