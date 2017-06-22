#!/bin/bash

# ##################################################
#
version="1.0.0"
#
# HISTORY:
#
# * 17/06/21 - v1.0.0  - First Creation
#
# ##################################################

arrayIDDOMAIN=(IDENTITY DOMAIN NAME ARRAY)
arrayPASSWORD=(CLOUD PASSWORD ARRAY)

function mainScript() {
  count=${#arrayIDDOMAIN[@]}
  count=$((count-1))

  while [ ${count} -ge 0 ];
  do
    echo "----- ${arrayIDDOMAIN[$count]} --------------------"
    if [ ${IPINFO} -eq 1 ]; then
      displayIPInfo
    else
      displayServcieInfo
    fi
    count=$((count-1))
  done

}

function displayServcieInfo() {
  curl -i -X GET -u cloud.admin:${arrayPASSWORD[$count]} -H "X-ID-TENANT-NAME:${arrayIDDOMAIN[$count]}" https://jcs.emea.oraclecloud.com/paas/service/jcs/api/v1.1/instances/${arrayIDDOMAIN[$count]}/Alpha01A-JCS
}

function displayIPInfo() {
  curl -i -X GET -u cloud.admin:${arrayPASSWORD[$count]} -H "X-ID-TENANT-NAME:${arrayIDDOMAIN[$count]}" https://jcs.emea.oraclecloud.com/paas/service/jcs/api/v1.1/instances/${arrayIDDOMAIN[$count]}/Alpha01A-JCS|sed -n -e 's/^[ \t]*//' -e 's/\\//g' -e 's/,$//g' -e '/wls_admin_url/p' -e '/otd_admin_url/p'
}

function usage() {
    cat <<EOF
$(basename ${0}) is a tool for ...
Usage:
    $(basename ${0}) [<options>]
Options:
    --help, -h          print help
    --ip, -i            print JCS and OTD IP info (URL)
EOF
}

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

        --help|-h)
            usage
            exit 0
	;;
        --ip|-i)
	    IPINFO=1
        ;;

        *)
            echo "[ERROR] Invalid option '${1}'"
            usage
            exit 1
        ;;
    esac
    shift
done

mainScript > jcs-info-`date '+%Y%m%d-%H%M%S'`.lst
