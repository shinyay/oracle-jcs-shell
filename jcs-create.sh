#!/bin/sh

# ##################################################
#
version="1.0.0"
#
# HISTORY:
#
# * 17/06/21 - v1.0.0  - First Creation
#
# ##################################################

function mainScript() {
  echo -n
}

function generateJson() {
  sed "s/IDDOMAIN/${IDDOMAIN}/g" wls12cR1-EE-OTD.json | sed "s/CLOUDPASSWORD/${PASSWORD}/g" > wls12cR1-EE-OTD.json.${IDDOMAIN}
}

function createInstance() {
  curl -i -X POST -u cloud.admin:${PASSWORD} -d @wls12cR1-EE-OTD.json.${IDDOMAIN} -H "Content-Type:application/vnd.com.oracle.oracloud.provisioning.Service+json" -H "X-ID-TENANT-NAME:${IDDOMAIN}" https://${ENDPOINT}/paas/service/jcs/api/v1.1/instances/${IDDOMAIN}
}

function bulkCreate() {
  generateJson
  createInstance
}

function usage() {
    cat <<EOF
$(basename ${0}) is a tool for ...
Usage:
    $(basename ${0}) [json|instance|bulk] -i <IDENTITYDOMAIN> -p <PASSWORD> -r <REGION [us|emea]>
Options
    json         print Create JSON for JCS Instance
    instance     print Create JCS Instance with generated JSON
    bulk         print Create JCS Instance and JSON simultaneously
EOF
}

# Check Arguments
if [ $# -eq 0 ]; then
  usage
  exit 1
fi

# Handle Options
while [ $# -gt 0 ];
do
    case ${1} in

        --debug|-d)
            set -x
        ;;

        --version|-v)
            echo "$(basename ${0}) ${version}"
            exit 0
        ;;

        json)
            COMMAND=JSON
        ;;

        instance)
            COMMAND=INSTANCE
        ;;

        bulk)
            COMMAND=BULK
        ;;

        --iddomain|-i)
            IDDOMAIN=${2}
            shift
        ;;

        --password|-p)
            PASSWORD=${2}
            shift
        ;;

        --region|-r)
            REGION=${2}
	    case ${REGION} in
	      "us")
	        ENDPOINT=jaas.oraclecloud.com
	      ;;
	      "emea")
	        ENDPOINT=jcs.emea.oraclecloud.com
              ;;
              *)
	        echo "[ERROR] Invalid Region '${REGION}'"
		exit 1
	      ;;
	    esac
            shift
        ;;

        *)
            echo "[ERROR] Invalid option '${1}'"
            usage
            exit 1
        ;;
    esac
    shift
done

case ${COMMAND} in
  "JSON")
    generateJson
  ;;

  "INSTANCE")
    createInstance
  ;;

  "BULK")
    bulkCreate
  ;;

  *)
    mainScript
  ;;
esac
