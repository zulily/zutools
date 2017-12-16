#!/bin/bash
#
# This shell script will set gitlab secret variables based on
# the text file passed in.  Each line of the file is to be formatted 
# Key=Value
#
# Related:
# Gitlab Secret Vars API doc ref
# https://docs.gitlab.com/ce/api/build_variables.html
#
# usage:    
# set_gitlab_vars.sh GL_NAMESPACE GL_PROJECT GL_VARS_FILE
#
# Test for parameter count
if [ $# -ne 3 ]; then
    echo "ERROR: Wrong number of parameters"
    exit 1
fi
# Test for variables file
if [ ! -f "$3" ]; then
    echo "ERROR: Could not find $3"
    exit 1
fi 

GL_ACCESS_TOKEN="<REPLACE_WITH_ACCESS_TOKEN>"

# Example GL_API_URL: https://gitlab.example.com/api/v4/projects
GL_API_URL="<REPLACE_WITH_GITLAB_API_URL>"
#
# bash urlencode function 
#
rawurlencode() {
  local string="${1}"
  local strlen=${#string}
  local encoded=""
  local pos c o

  for (( pos=0 ; pos<strlen ; pos++ )); do
     c=${string:$pos:1}
     case "$c" in
        [-_.~a-zA-Z0-9] ) o="${c}" ;;
        * )               printf -v o '%%%02x' "'$c"
     esac
     encoded+="${o}"
  done
  REPLY="${encoded}"   #+or echo the result (EASIER)... or both... :p
}

#
# API Communication function
# We catch case where variable exists and  push our value as an update.  
# This will allow a team to maintain their config in git without requiring UI.
#
curl_process() {

  # test if we got string values for our kv
  if [[ -z "$1" || -z "$2" ]] ;then
    echo "curl_process failed -- require k,v passed in"
    exit 1
  fi
    
  retval=$(curl --silent --request POST --header "PRIVATE-TOKEN: ${GL_ACCESS_TOKEN}" \
	  "${GL_API_URL}/${GL_PROJECTPATH}/variables" \
    --form "key=$1" --form "value=$2" )

  #
  # test if exists already on server, then do an update of it
  #
  if [[ $retval == *"{\"message\":{\"key\":[\"has already been taken\"]}}"* ]]; then
    retval=$(curl --silent --request PUT --header "PRIVATE-TOKEN: ${GL_ACCESS_TOKEN}" \
      "${GL_API_URL}/${GL_PROJECTPATH}/variables/$1" \
      --form "value=$2" )
  fi

  echo $retval
  echo


}
# main()
rawurlencode "$1/$2"
GL_PROJECTPATH=${REPLY}
vars=$(grep "=" $3)
for line in $vars; do
	key="$(cut -d'=' -f1 <<< $line)"
	val="$(cut -d'=' -f2 <<< $line)"
	curl_process $key $val
done

