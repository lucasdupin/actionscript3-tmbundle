#!/usr/bin/env ruby

require 'webrick'
require 'net/http'
require 'fileutils'

#Running as daemon
require 'rubygems'
require 'daemons'

module FCSHD_SERVER
  
  class << self
    
    PORT = 6924
    HOST = "localhost"

    ASSIGNED_REGEXP = /^ fcsh:.*(\d+).*/

    #remembering wich swfs we asked for compiling
    def start_server
      
      Daemons.call {
        @commands = Hash.new if @commands.nil?

        Dir.mkdir("/tmp/fcshd") unless File.directory? "/tmp/fcshd"
        log = Logger.new("/tmp/fcshd/server.log")
        log.debug("initializing server")
        # 
      	fcsh = IO.popen("#{ENV['TM_FLEX_PATH']}/bin/fcsh  2>&1", "w+")
      	read_to_prompt(fcsh)

      	#Creating the HTTP Server  
      	s = WEBrick::HTTPServer.new(
      		:Port => PORT,
      		:Logger => WEBrick::Log.new(nil, WEBrick::BasicLog::WARN),
      		:AccessLog => []
      	)

      	#giving it an action
      	s.mount_proc("/build"){|req, res|

      		#response variable
      		output = ""

      		#Searching for an id for this command
      		if @commands.has_key?(req.body)
      			# Exists, incremental
      			log.debug("compile #{@commands[req.body]}")
      			fcsh.puts "compile #{@commands[req.body]}"
      			output = read_to_prompt(fcsh)
      		else
      			# Does not exist, compile for the first time
      			fcsh.puts req.body
      			output = read_to_prompt(fcsh)
      			match = output.scan(ASSIGNED_REGEXP)
      			@commands[req.body] = match[0][0]
      		end

      		log.debug("asked: #{req.body}")
      		log.debug("output: #{output}")

      		res.body = output
      		res['Content-Type'] = "text/html"
      	}

      	s.mount_proc("/exit"){|req, res|
      	  log.debug("shutting down")
      		s.shutdown
      		fcsh.close
      		exit
      	}
        
      	s.mount_proc("/status"){|req, res|
      	  log.debug("getting status")
      	  begin
      	    fcsh.puts("info 0")
      	    output = read_to_prompt(fcsh)
      	    res.body = "UP"
      	  rescue Exception => e
      	    res.body = "DOWN"
      	  end
      		exit
      	}

      	trap("INT"){
      		s.shutdown 
      		fcsh.close
      	}

      	#Starting webrick
      	log.debug "\nStarting Webrick at http://#{HOST}:#{PORT}"
      	s.start
        
      } if not running
      
    	log = Logger.new("/tmp/log.txt")
    	if block_given?
        while not running
          sleep 3
        end
    	  yield
    	end

    end

    #Helper method to read output
    def read_to_prompt(f)
    	f.flush
    	output = ""
    	while chunk = f.read(1)
    		STDOUT.write chunk
    		output << chunk
    		if output =~ /^\(fcsh\)/
    			break
    		end
    	end
    	STDOUT.write ">"
    	output
    end
    
    def build(what)
      # puts arg
      http = Net::HTTP.new(HOST, PORT)
      resp = http.post('/build', what)
      resp.body
    end
    
    def stop_server
      http = Net::HTTP.new(HOST, PORT)
      resp = http.get('/exit')
      resp.body
    end
    
    def running
      begin
        http = Net::HTTP.new(HOST, PORT)
        resp = http.get('/status', nil)

        return true if resp.body == "UP"
        
      rescue => e
        # puts "Error #{e}"
      end
      return false
    end
  end
end