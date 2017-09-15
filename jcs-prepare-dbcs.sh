#!/bin/sh

# ##################################################
#
version="1.0.0"
#
# HISTORY:
#
# * 17/09/07 - v1.0.0  - First Creation
#
# ##################################################

function mainScript() {
 scp -i ${SSHKEY} -oStrictHostKeyChecking=no resources/human_resources/* oracle@${DBCSIP}:/u01/app/oracle/product/12.1.0/dbhome_1/demo/schema/human_resources/
 ssh -i ${SSHKEY} oracle@${DBCSIP} ls -l /u01/app/oracle/product/12.1.0/dbhome_1/demo/schema/human_resources/
 ssh -i ${SSHKEY} oracle@${DBCSIP} sqlplus sys/${PASSWORD}@PDB1 as sysdba @/u01/app/oracle/product/12.1.0/dbhome_1/demo/schema/human_resources/hr_main_custom.sql
}

function usage() {
    cat <<EOF
$(basename ${0}) is a tool for creating HR Schema
Usage:
    $(basename ${0}) -i DBCSIP -p password -k SSHKEY-PATH
Options:
    --version, -v     print $(basename ${0}) ${version}
    --help, -h        print help
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

        --help|-h)
            usage
            exit 0
        ;;

        --ip|-i)
            DBCSIP=${2}
            shift
        ;;

        --password|-p)
            PASSWORD=${2}
            shift
        ;;

        --key|-k)
            SSHKEY=${2}
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

mainScript |tee jcs-prepare-`date '+%Y%m%d-%H%M%S'`.lst
