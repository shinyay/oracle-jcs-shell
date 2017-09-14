#!/bin/sh

# ###########################################################################
#
PROGNAME=$(basename $0)
VERSION="1.0.1"
#
# HISTORY:
#
# * 17/09/14 - v1.0.1  - Import Environment Information from an external file
# * 17/06/21 - v1.0.0  - First Creation
#
# ###########################################################################

function mainScript() {
  for line in "${ENV_FILE[@]}"; do
    row=(`echo $line`)
    IDDOMAIN=${row[0]}
    PASSWORD=${row[1]}
    echo "----- ${IDDOMAIN} --------------------"
    if [ -z ${IPINFO} ]; then
      displayServiceInfo
    else
      displayIPInfo
    fi
  done
}

function displayServiceInfo() {
  curl -i -X GET -u cloud.admin:${PASSWORD} -H "X-ID-TENANT-NAME:${IDDOMAIN}" https://jcs.emea.oraclecloud.com/paas/service/jcs/api/v1.1/instances/${IDDOMAIN}/Alpha01A-JCS
}

function displayIPInfo() {
  curl -i -X GET -u cloud.admin:${PASSWORD} -H "X-ID-TENANT-NAME:${IDDOMAIN}" https://jcs.emea.oraclecloud.com/paas/service/jcs/api/v1.1/instances/${IDDOMAIN}/Alpha01A-JCS|sed -n -e 's/^[ \t]*//' -e 's/\\//g' -e 's/,$//g' -e '/wls_admin_url/p' -e '/otd_admin_url/p' -e '/db_em_url/p'
}

function usage() {
    cat <<EOF
$(basename ${0}) is a tool for ...

Usage:
    $(basename ${0}) -l <ENVIRONMENT_LIST> [<options>]

Options:
    -v, --version     print $(basename ${0}) ${VERSION}
    -h, --help        print help
    -i, --ip          print JCS and OTD IP info (URL)
EOF
}

# Check Arguments
if [ $# -eq 0 ]; then
  usage
  exit 1
fi

# Handle Options
for OPT in "$@"
do
  case "$OPT" in
    '-v'|'--version' )
      echo "$(basename ${0}) ${VERSION}"
      exit 0
      ;;
    '-h'|'--help' )
      usage
      exit 0
      ;;
    '-d'|'--debug' )
      set -x
      ;;
    '-l'|'--list' )
      if [[ -z "$2" ]] || [[ "$2" =~ ^-+ ]]; then
        echo "$PROGNAME: option requires an argument -- $1" 1>&2
        exit 1
      elif [[ -e $2 ]]; then
        IFS=$'\n'
        ENV_FILE=(`cat "$2"`)
        unset IFS
      else
        echo "$PROGNAME: environment list does not exist -- $2" 1>&2
        exit 1
      fi
      shift 2
      ;;
    '-i'|'--ip' )
    	IPINFO=1
      shift 1
      ;;
    -*)
      echo "$PROGNAME: illegal option -- '$(echo $1 | sed 's/^-*//')'" 1>&2
      exit 1
      ;;
    *)
      if [[ ! -z "$1" ]] && [[ ! "$1" =~ ^-+ ]]; then
        param+=( "$1" )
        shift 1
      fi
      ;;
  esac
done

#if [ -z $param ]; then
#  echo "$PROGNAME: too few arguments" 1>&2
#  echo "Try '$PROGNAME --help' for more information." 1>&2
#  exit 1
#fi

mainScript > jcs-info-`date '+%Y%m%d-%H%M%S'`.lst
