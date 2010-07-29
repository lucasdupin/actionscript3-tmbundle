#!/bin/bash

#-------------------------------------------------------------------------
#
# AS3 Project
# 
# Creates a default projet with build.yaml
#
#-------------------------------------------------------------------------

defaultProjectName="AS3Project";

fullProjectPath=$(CocoaDialog filesave \
			--text "Please name your project and select a folder to save it into" \
			--title "Create New Project" \
			--with-file "$defaultProjectName");

if [ -n "$fullProjectPath" ]; then
	
	fullProjectPath=$(tail -n1 <<<"$fullProjectPath");
	projectName=`basename "$fullProjectPath" ".tmproj"`;
	projectPath=`dirname "$fullProjectPath"`;
	
	# Now ask what the class path should be, used to create default dirs.
	fullClassPath="$projectName"
	#fullClassPath=$(CocoaDialog standard-inputbox \
	#			--title "Project Class Path" \
	#			--text "$defaultClassPath.$projectName" \
	#			--informative-text "Enter the project class path:");
	
	if [ -n "$fullClassPath" ]; then
		classPath=$(tail -n1 <<<"$fullClassPath");
		classPath=`echo $classPath | tr '.' '/'`;
		classPathDirectory="$projectPath/$projectName/source/classes/$classPath/";
		
		# Create our project directory structure.
		mkdir -p "$projectPath/$projectName/public/css";
		mkdir -p "$projectPath/$projectName/public/js";
		mkdir -p "$projectPath/$projectName/source/classes";
		mkdir -p "$projectPath/$projectName/doc";
		mkdir -p "$projectPath/$projectName/source/libs";
		mkdir -p "$projectPath/$projectName/source/swc";
		
		# This recursively creates all source code folders,
		# creating any missing directories along the way
		mkdir -p "$classPathDirectory/models";
		mkdir -p "$classPathDirectory/controllers";
		mkdir -p "$classPathDirectory/events";
		mkdir -p "$classPathDirectory/views";
		
		# Gather variables to be substituted.
		TM_NEW_FILE_BASENAME="$projectName";
		
		export TM_YEAR=`date "+%Y"`;
		export TM_DATE=`date "+%d.%m.%Y"`;
		
		# Customise file variables for the new project and rename
		# files to match the project name.
		perl -pe 's/\$\{([^}]*)\}/$ENV{$1}/g' < "build.yaml" > "$projectPath/$projectName/build.yaml";
		perl -pe 's/\$\{([^}]*)\}/$ENV{$1}/g' < "Project.as" > "$projectPath/$projectName/source/classes/$projectName.as";
		perl -pe 's/\$\{([^}]*)\}/$ENV{$1}/g' < "index.html" > "$projectPath/$projectName/public/index.html";
		perl -pe 's/\$\{([^}]*)\}/$ENV{$1}/g' < "index.html" > "$projectPath/$projectName/public/index-debug.html";

		# Copy static files.		
		cp "main.css" "$projectPath/$projectName/public/css/main.css";
		cp "swfaddress.js" "$projectPath/$projectName/public/js/swfaddress.js";
		cp "swfobject.js" "$projectPath/$projectName/public/js/swfobject.js";
		
		# Open the project in TextMate.
		open -a "TextMate.app" "$projectPath/$projectName";
		
	fi

fi