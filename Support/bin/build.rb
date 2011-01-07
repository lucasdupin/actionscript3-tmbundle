#!/usr/bin/env ruby
# encoding: utf-8

require ENV['TM_BUNDLE_SUPPORT'] + '/bin/fcshd.rb'
require ENV['TM_BUNDLE_SUPPORT'] + '/bin/as3project.rb'

require File.expand_path(File.dirname(__FILE__)) + '/../lib/add_lib'
require 'fm/flex_mate'
require 'fm/sdk'

#Generate the beautiful header
FCSHD.generate_view

#Add flex to path
FlexMate::SDK.add_flex_bin_to_path
if `which fcsh`.empty?
  if ENV["TM_FLEX_PATH"].empty?
    puts "Could not find the Flex SDK, please set TM_FLEX_PATH"
    exit
  end 
  unless File.exists? ENV["TM_FLEX_PATH"]+"/bin/fcsh"
    puts "Could not find the Flex SDK in the given path: " + ENV["TM_FLEX_PATH"]+"/bin/fcsh"
    exit
  end
  puts "Could not find Flex SDK"
  exit
end


AS3Project.compile ARGV.size > 0 and ARGV[0] == 'run'
# FCSHD.async_compile ARGV.size > 0 and ARGV[0] == 'run'