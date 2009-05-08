#!/bin/bash

. "$TM_BUNDLE_SUPPORT/lib/flex_utils.sh";

OS=$(defaults read /System/Library/CoreServices/SystemVersion ProductVersion)

#search for the flex install directory.
set_flex_path -t

#Set and cd to TM_PROJECT_DIR 
cd_to_tmproj_root

if [ "$TM_FLEX_FILE_SPECS" == "" ]; then
	echo "Please specify a document to compile (using the variable TM_FLEX_FILE_SPECS)."
	exit 206;
fi

if [[ !(-f "$TM_PROJECT_DIR/$TM_FLEX_FILE_SPECS") ]]; then 
	echo "The TM_FLEX_FILE_SPECS file:"
	echo "    $TM_FLEX_FILE_SPECS"
	echo "cannot be found."
	exit 206;
fi

if [ "$TM_FLEX_OUTPUT" == "" ]; then
	echo "Please specify the location and name of the swf to create (using the variable TM_FLEX_OUTPUT)."
	exit 206;
fi


FCSH=$(echo "$TM_FLEX_PATH/bin/fcsh" | sed 's/ /\\ /g');
MXMLC_O=$(echo "$TM_PROJECT_DIR/$TM_FLEX_OUTPUT" | sed 's/ /\\ /g');
MXMLC_FS=$(echo "$TM_PROJECT_DIR/$TM_FLEX_FILE_SPECS" | sed 's/ /\\ /g');
MXMLC_ARGS="mxmlc $MXMLC_FS -o=$MXMLC_O"

if [ "$TM_FLEX_SOURCE" != "" ]; then
	for s in $(echo $TM_FLEX_SOURCE | sed 's/:/ /g'); do MXMLC_ARGS="$MXMLC_ARGS -sp+=$TM_PROJECT_DIR/$s"; done
fi

if [ "$TM_FLEX_SWC" != "" ]; then
	for s in $(echo $TM_FLEX_SWC | sed 's/:/ /g'); do MXMLC_ARGS="$MXMLC_ARGS -library-path+=$TM_PROJECT_DIR/$s"; done
fi

	
"$TM_BUNDLE_SUPPORT/lib/fcsh_terminal" "$FCSH" "$MXMLC_ARGS" >/dev/null; 

exit 200;
