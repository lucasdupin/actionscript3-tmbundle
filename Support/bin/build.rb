#!/usr/bin/env ruby
# encoding: utf-8

require ENV['TM_BUNDLE_SUPPORT'] + '/bin/fcshd.rb'
require ENV['TM_BUNDLE_SUPPORT'] + '/bin/as3project.rb'
require File.expand_path(File.dirname(__FILE__)) + '/../lib/add_lib'

#Generate the beautiful header
FCSHD.generate_view

#Update status if needed
FCSHD.update_status

AS3Project.compile