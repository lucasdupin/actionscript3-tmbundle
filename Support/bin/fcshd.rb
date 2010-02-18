#!/usr/bin/env ruby -wKU

module FCSHD

BUN_SUP = ENV['TM_BUNDLE_SUPPORT']

require 'xmlrpc/client'
require 'Logger'
require ENV['TM_SUPPORT_PATH'] + '/lib/escape'
require ENV['TM_SUPPORT_PATH'] + '/lib/web_preview'

$server = XMLRPC::Client.new2("http://localhost:2345")
# @logger = Logger.new('/tmp/fcshd/gui.log')
# @logger.level = Logger::WARN

def self.server_status
	begin
		result = $server.call("no_existent_mehtod")
	rescue Errno::ECONNREFUSED => e
		return false
	rescue XMLRPC::FaultException => e
		return true
	end
end

def self.status
	if server_status
		puts "Running"
	else
		puts "Stopped"
	end
end

def self.generate_view
		
		puts html_head(:window_title => "ActionScript 3", :page_title => "fcshd", :sub_title => "__" );

		puts	"<link rel='stylesheet' href='file://#{e_url(BUN_SUP)}/css/fcshd.css' type='text/css' charset='utf-8' media='screen'>"
		puts  "<script src='file://#{e_url(BUN_SUP)}/../js/fcshd.js' type='text/javascript' charset='utf-8'></script>"
		puts "<div id='script-path'>#{BUN_SUP}/</div>"
		puts "
		<h2><div id='status'>Checking daemon status</div></h2>
		<div id='controls'>
		  <a id='refresh' href='javascript:refreshStatus()' title='Check daemon status'>Check Status</a><br/>
		  <a id='toggle' href='javascript:toggleClick();'>Toggle State</a><br/>
		</div>"
		
		compiler_state = server_status ? "up" : "down"
		puts '<script type="text/javascript" charset="utf-8">setState("'+compiler_state+'")</script>'
end

def self.stop_server
	return unless server_status
	`#{e_sh(BUN_SUP)}/fcshd.py --stop-server`
	sleep 0.5
	status
end

def self.start_server
	return if server_status
	`#{e_sh(BUN_SUP)}/fcshd.py --start-server`
	
	#Give up from waiting if it's taking too long
	start_time = Time.now.to_i
	while !server_status
	 sleep 0.5
	 break if Time.now.to_i - start_time > 1000 * 10
	end

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
    FCSHD.status
  end
end
run