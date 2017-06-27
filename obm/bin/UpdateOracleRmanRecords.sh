#################  delete-archive-logs.sh  #################################
# You can use this batch to delete all archived logs entry from RMAN       #
# database. The RMAN script file 'delete-archive-logs.rman' must also be   #
# saved in the same directory of this file for this script to function     #
# all archived logs in the recovery catalog correctly to prevent the       #
# "ORA-00257 archiver error".                                              #
############################################################################

#---------------------------  CONNECT_STRING  ------------------------------
# You must provide a valid connect string with system privileges           |
# to the oracle database.                                                  |
# e.g. CONNECT_STRING=sys/sys@orcl                                         |
#---------------------------------------------------------------------------
CONNECT_STRING=

#---------------------------  CONNECT_STRING  ------------------------------
# The recovery catalog to connect to. Default to nocatalog                 |
# e.g. CATALOG=nocatalog                                                   |
#  or  CATALOG=catalog RMAN/RMAN@OEMREP                                    |
#---------------------------------------------------------------------------
CATALOG=nocatalog

####################  END: User Defined Section  ###########################
CMDFILE=UpdateOracleRmanRecords.rman

# ############################## Check config ##############################
if [ ! "$1" == "" ]; then CONNECT_STRING=$1
fi
if [ "${CONNECT_STRING}" == "" ]; then CONNECT_STRING=/
fi

${ORACLE_HOME}/bin/rman target ${CONNECT_STRING} ${CATALOG} cmdfile=${CMDFILE}
