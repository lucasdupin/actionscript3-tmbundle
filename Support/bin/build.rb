#!/usr/bin/env ruby
# encoding: utf-8

require ENV['TM_BUNDLE_SUPPORT'] + '/bin/fcshd.rb'
require File.expand_path(File.dirname(__FILE__)) + '/../lib/add_lib'

#Generate the beautiful header
FCSHD.generate_view

#Update status if needed
FCSHD.update_status

# Build
puts FCSHD.invoke_task("build")

# Open?
FCSHD.invoke_task("open") if ARGV[0] == 'run'