#!/bin/sh

# ##################################################
#
version="1.0.0"
#
# HISTORY:
#
# * 17/09/15 - v1.0.1  - Fix input argument style
# * 17/06/21 - v1.0.0  - First Creation
#
# ##################################################

function mainScript() {
  case ${COMMAND} in
    'JSON' )
      generateJson
    ;;
    'INSTANCE' )
      createInstance
    ;;
    'BULK' )
      bulkCreate
    ;;
  esac
}

function generateJson() {
  sed "s/IDDOMAIN/${IDDOMAIN}/g" wls12cR1-EE-OTD.json | sed "s/CLOUDUSER/${USER}/g" | sed "s/CLOUDPASSWORD/${PASSWORD}/g" > wls12cR1-EE-OTD.json.${IDDOMAIN}
}

function createInstance() {
  #curl -i -X POST -u cloud.admin:${PASSWORD} -d @wls12cR1-EE-OTD.json.${IDDOMAIN} -H "Content-Type:application/vnd.com.oracle.oracloud.provisioning.Service+json" -H "X-ID-TENANT-NAME:${IDDOMAIN}" https://${ENDPOINT}/paas/service/jcs/api/v1.1/instances/${IDDOMAIN}
  curl -i -X POST -u ${USER}:${PASSWORD} -d @wls12cR1-EE-OTD.json.${IDDOMAIN} -H "Content-Type:application/vnd.com.oracle.oracloud.provisioning.Service+json" -H "X-ID-TENANT-NAME:${IDDOMAIN}" https://${ENDPOINT}/paas/service/jcs/api/v1.1/instances/${IDDOMAIN}
}

function bulkCreate() {
  generateJson
  createInstance
}

function usage() {
    cat <<EOF
$(basename ${0}) is a tool for ...

Usage:
    $(basename ${0}) [json|instance|bulk] -i <IDENTITYDOMAIN> -u <USER> -p <PASSWORD> -r <REGION [us|emea|jp]>

Commands:
    json              Create JSON for JCS Instance
    instance          Create JCS Instance with generated JSON
    bulk              Create JCS Instance and JSON simultaneously
Options:
    -v, --version     print $(basename ${0}) ${VERSION}
    -h, --help        print help
    -i, --iddomain    Your Identity Domain Name
    -u, --user        Your Cloud ID
    -p, --password    Your Cloud password
    -r, --regiron     Your Cloud Region
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
    '-i'|'--iddomain' )
      if [[ -z "$2" ]] || [[ "$2" =~ ^-+ ]]; then
        echo "$PROGNAME: option requires an argument -- $1" 1>&2
        exit 1
      fi
      IDDOMAIN="$2"
      shift 2
      ;;
    '-u'|'--user' )
      if [[ -z "$2" ]] || [[ "$2" =~ ^-+ ]]; then
        echo "$PROGNAME: option requires an argument -- $1" 1>&2
        exit 1
      fi
      USER="$2"
      shift 2
      ;;
    '-p'|'--password' )
      if [[ -z "$2" ]] || [[ "$2" =~ ^-+ ]]; then
        echo "$PROGNAME: option requires an argument -- $1" 1>&2
        exit 1
      fi
      PASSWORD="$2"
      shift 2
      ;;
    '-r'|'--region' )
      if [[ -z "$2" ]] || [[ "$2" =~ ^-+ ]]; then
        echo "$PROGNAME: option requires an argument -- $1" 1>&2
        exit 1
      fi
      REGION="$2"
      case ${REGION} in
	      "us")
	        ENDPOINT=jaas.oraclecloud.com
	        ;;
	      "emea")
	        ENDPOINT=jcs.emea.oraclecloud.com
	        ;;
	      "jp")
	        ENDPOINT=psm.jpcom.oraclecloud.com
          ;;
        *)
	        echo "[ERROR] Invalid Region '${REGION}'"
		      exit 1
	        ;;
	    esac
      shift 2
      ;;
    'json' )
      COMMAND="JSON"
      shift 1
      ;;
    'instance' )
      COMMAND="INSTANCE"
      shift 1
      ;;
    'bulk' )
      COMMAND="BULK"
      shift 1
      ;;
    '--'|'-' )
      shift 1
      param+=( "$@" )
      break
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

mainScript
