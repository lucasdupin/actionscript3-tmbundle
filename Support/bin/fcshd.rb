#!/usr/bin/env ruby -wKU
module FCSHD
	
BUN_SUP = ENV['TM_BUNDLE_SUPPORT']

require 'xmlrpc/client'
require 'Logger'
require ENV['TM_SUPPORT_PATH'] + '/lib/escape'
require ENV['TM_SUPPORT_PATH'] + '/lib/web_preview'


#Add flex to path


# @logger = Logger.new('/tmp/fcshd/gui.log')
# @logger.level = Logger::DEBUG

def self.invoke_task task
	require ENV['TM_BUNDLE_SUPPORT'] + '/lib/fm/sdk'
	FlexMate::SDK.add_flex_bin_to_path
	rakefile_path = e_sh(BUN_SUP + "/data/Rakefile")
	`PROJECT_PATH=#{e_sh(ENV['TM_PROJECT_DIRECTORY'])} PATH=#{e_sh ENV['PATH']}  rake -f #{rakefile_path} #{task}`
end

def self.status
	invoke_task('status').gsub(/\(.+\)/, '').strip
end

def self.running
	self.status == "up"
end

def self.update_status
	set_status self.status
end

def self.generate_view compiler_state=nil
		
		puts html_head(:window_title => "ActionScript 3", :page_title => "fcshd", :sub_title => "__" );

		puts	"<link rel='stylesheet' href='file://#{e_url(BUN_SUP)}/css/fcshd.css' type='text/css' charset='utf-8' media='screen'>"
		puts  "<script src='file://#{e_url(BUN_SUP)}/js/fcshd.js' type='text/javascript' charset='utf-8'></script>"
		puts "<div id='script-path'>#{BUN_SUP}/bin/</div>"
		puts "
		<h2><div id='status'>Checking daemon status</div></h2>
		<div id='controls'>
		  <a id='refresh' href='javascript:refreshStatus()' title='Check daemon status'>Check Status</a><br/>
		  <a id='toggle' href='javascript:toggleClick();'>Toggle State</a><br/>
		</div>
		<pre>"
		
		set_status self.status
end

def self.set_status compiler_state
	puts '<script type="text/javascript" charset="utf-8">setState("'+compiler_state+'")</script>'
end

def self.stop_server
	invoke_task('stop_server')
end

def self.start_server
	invoke_task('start_server')
	sleep 2
end

def self.success
    print "<script type='text/javascript' charset='utf-8'>
      if( document.getElementById('status').className != 'fail'){
        document.getElementById('status').className='success'
        document.getElementById('status').innerHTML='Success'
      }
    </script>"  
end

def self.fail
  print "<script type='text/javascript' charset='utf-8'>
      document.getElementById('status').innerHTML='Compilation Failed'
      document.getElementById('status').className='fail'
  </script>"
end

def self.close_window
  print "<script type='text/javascript' charset='utf-8'>
        window.close();
  </script>"
end

end

def run
  if ARGV[0] == "-success" 
    FCSHD.success
  elsif ARGV[0] == "-fail"
      FCSHD.fail
    elsif ARGV[0] == "-status"
      puts FCSHD.status
    elsif ARGV[0] == "-start"
      FCSHD.start_server
    elsif ARGV[0] == "-stop"
      FCSHD.stop_server
    elsif ARGV[0] == "-view"
      FCSHD.generate_view
  else
    "No command given"
  end
end
run