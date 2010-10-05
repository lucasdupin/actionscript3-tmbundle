#!/usr/bin/env ruby -wKU

require 'yaml'
require ENV['TM_SUPPORT_PATH'] + "/lib/io"
require ENV['TM_SUPPORT_PATH'] + '/lib/web_preview'
require ENV['TM_SUPPORT_PATH'] + '/lib/exit_codes'

require ENV['TM_BUNDLE_SUPPORT'] + '/bin/fcshd_server'
require ENV['TM_BUNDLE_SUPPORT'] + '/bin/fcshd'
require ENV['TM_BUNDLE_SUPPORT'] + '/lib/fm/mxmlc_exhaust'

module AS3Project     
  
    # @logger = Logger.new('/tmp/fcshd/gui.log')
    # @logger.level = Logger::DEBUG
    
    @project = ENV['TM_PROJECT_DIRECTORY']
    @build_yaml = nil
    
    def self.build_file
        if !@build_yaml:
            
			if !file = File.open(build_file_path) rescue nil 
                printf('Could not find the build file at %s', build_file_path)
                exit
            end

            @build_yaml = YAML::load(file) rescue nil
            if !@build_yaml
              print "Something wrong when parsing YAML file"
              exit
            end    
        end        
        
        @build_yaml
    end  

  	def self.build_file_path
  		path = ENV['TM_FLEX_BUILD']

        if !path and not @project.nil?
            path = File.join(@project, "build.yaml")
        end
		path
		
  	end
    
    def self.get_path_list(attr_name)
        dirs = []                    
        
        if build_file.has_key?(attr_name)
            build_file.fetch(attr_name).each do |path|
                dirs.push path
            end
        end
        
        dirs
    end     
    
    def self.definitions(paths, relative_path_from=nil)
        classes = {}
        paths.each do |path|
        source_path = Pathname.new(File.join(@project,path))
          
        Find.find(source_path.to_s) do |f|
            if f =~ /.as$/
              if !relative_path_from
                clean_path = Pathname.new(f).relative_path_from(source_path).to_s
              else
                clean_path = Pathname.new(f).relative_path_from(Pathname.new(File.join(@project, relative_path_from))).to_s
              end
              
              classes[f.to_s] = clean_path.gsub("/", ".").gsub(".as", "")
            end
          end
        end
        classes
    end 
                
    def self.source_path_list
        get_path_list("source-path")
    end
                                          
    def self.library_path_list
        get_path_list("library-path")
    end
    
    def self.mxmlc_source_path
        paths = source_path_list
        source_path = []
        
        paths.each do |path|
            source_path.push "-sp+="+File.join(@project, path)
        end                                 
        
        source_path.join(" ")
    end       
    
    def self.mxmlc_library_path
        paths = library_path_list
        library_path = []
        
        paths.each do |path|
            library_path.push "-library-path+="+File.join(@project, path)
        end                                 
        
        library_path.join(" ")
    end                          
    
    def self.mxmlc_default_extra
        build_file.fetch("default")[0].fetch("extras") rescue ""
    end
    
    def self.mxmlc_default_debug                             
        build_file.fetch("default")[0].fetch("debug") rescue "false"
    end   
    
    def self.default_run_file
        build_file.fetch("default")[0].fetch("open") rescue ""
    end
    
    def self.mxmlc_applications
        apps = []
        
        if build_file.has_key?("applications")  
            build_file.fetch("applications").each do |app|
                if app && app.has_key?("class") && app.has_key?("output")
                    debug = app.fetch("debug") rescue mxmlc_default_debug
                    extra = app.fetch("extra") rescue mxmlc_default_extra
                    klass = File.join(@project, app.fetch("class"))
                    output = File.join(@project, app.fetch("output"))
                    library_path = mxmlc_library_path rescue ""
                    source_path = mxmlc_source_path rescue ""
                    
                    app_obj = {"klass"=>app.fetch("class")}
                    if output =~ /.swc$/
                      require 'pathname'
                      require 'find'
                      app_obj["mxmlc"] = "compc -include-classes=#{definitions(source_path_list)[klass]} -o=#{output} #{library_path} #{source_path} #{extra}"
                    else
                      app_obj["mxmlc"] = "mxmlc #{klass} -o=#{output} -debug=#{debug} #{library_path} #{source_path} #{extra}"
                    end
                    
                    apps.push(app_obj)
                end
            end
        end 
            
        apps
    end

    def self.asdocs()   
      
      require 'find'
      require 'pathname'
      
      puts html_head(:window_title => "ActionScript 3", :page_title => "ASDocs", :sub_title => "__" );
      
      if build_file.has_key?("asdoc")
         print("<h2>Running ASDoc...</h2><pre>")
		 system("rake doc")
         print "</pre>"
         print "<strong>Done!</strong>"
       else
         print "You have to set ASDocs settings on YAML file"
       end  
    end
    
    def self.compile(build_and_run)
      
      # Build
  		puts "<pre>"
      # Create the output parser
      mxmlc_parser = MxmlcExhaust.new
      mxmlc_parser.print_output = true
      
      require "open3"
  		Open3.popen3(FCSHD.get_task "build") do |stdin, stdout, stderr|
  		  all_output = ''
  		  
        TextMate::IO.exhaust(:out => stdout, :err => stderr) do |data|
  		    data.each_line do |line|
  			    mxmlc_parser.line line
  		    end
        end
  		end

      puts "</pre>"
      mxmlc_parser.complete

      if mxmlc_parser.error_count <= 0
        FCSHD.success          
        if build_and_run
          run
          FCSHD.close_window
        end
      else
        FCSHD.fail
      end
        
		mxmlc_parser.error_count
    end 
    
    def self.run() 
        if default_run_file != ""
          #checking if the default_run_file is local or remote
          if default_run_file.include?("://") #oh man, we have a protocol (http://, https://, ftp://)
            system("open #{default_run_file}")
          else
            system("open #{File.join(@project, default_run_file)}")
          end
        end
    end
    
	private
	
	def self.read_to_prompt f
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
end     


def init    
    if !ARGV.empty?
        AS3Project.compile(ARGV[1] == "true") if ARGV[0] == "-compile"
        AS3Project.run() if ARGV[0] == "-run"
        AS3Project.asdocs() if ARGV[0] == "-docs"
    end
        
end

init