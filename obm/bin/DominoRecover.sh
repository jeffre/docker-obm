#!/bin/sh
# Ahsay Online Backup Manager 6.29.0.0

############################### DominoRecover.sh ###############################
# You can use this script file to recover your database files from command     #
# line. Just customize the "User Defined Section" below with the values for    #
# your recovery action.                                                        #
################################################################################

#########################  Start: User Defined Section  ########################


# --------------------------------- DATA_DIR -----------------------------------
# | The Domino data directory which contains notes.ini,                        |
# | the Domino databases, and templates.                                       |
# | e.g. DATA_DIR=/local/notesdata                                             |
# ------------------------------------------------------------------------------

DATA_DIR=/local/notesdata



# ---------------------------------- LOTUS ------------------------------------
# | The directory in which all Lotus products for UNIX are installed.         |
# | e.g. LOTUS=/opt/ibm/lotus                                                 |
# -----------------------------------------------------------------------------

LOTUS=/opt/ibm/lotus



# -------------------------------- INPUT_FILE ----------------------------------
# | The path to an input file if you want to restore one database only.       |
# | If you want to restore all databases, leave INPUT_FILE blank.             |
# -----------------------------------------------------------------------------

INPUT_FILE=



# -------------------------------- RESTOREDB ----------------------------------
# | The path to a database file if you want to restore one database only.     |
# | If you want to restore all databases, leave RESTOREDB blank.              |
# -----------------------------------------------------------------------------

RESTOREDB=



# --------------------------------- RECDATE -----------------------------------
# | The year, month and day you want to recover the database to.              |
# | Set them according to the date format set in your system.                 |
# | e.g RECDATE=11/15/2006                                                    |
# | If you want to restore all databases leave RECDATE blank.                 |
# | e.g RECDATE=                                                              |
# -----------------------------------------------------------------------------

RECDATE=



# --------------------------------- RECTIME -----------------------------------
# | The time in hour and minute you want to recover the database to.          |
# | Set them according to the time format set in your system.                 |
# | e.g. RECTIME=13:00                                                        |
# | If you want to restore all databases, leave RECTIME blank.                |
# | e.g. RECTIME=                                                             |
# -----------------------------------------------------------------------------

RECTIME=



##########################  End: User Defined Section  #########################

################################################################################
#                 G L O B A L             P A R A M E T E R                    #
################################################################################

# DEFINE argument LOTUS_RESTORE_ARG
# If both $INPUT_FILE and $RESTOREDB are not empty string (null values),
# LOTUS_RESTORE_ARG will be set with "RESTORE" for LotusBM

LOTUS_RESTORE_ARG=

################################################################################
#          P A R A M E T E R             V E R I F I C A T I O N               #
################################################################################

DATA_DIR_STR_LENGTH=`echo "${DATA_DIR}" | wc -c`
DATA_DIR_STR_LENGTH=`expr ${DATA_DIR_STR_LENGTH} - 1`
DATA_DIR_STR_LASTCHAR=`echo "${DATA_DIR}" | cut -c ${DATA_DIR_STR_LENGTH}`

if [ ! "${DATA_DIR_STR_LASTCHAR}" = "/" ]; then
    DATA_DIR="${DATA_DIR}/"
fi

FINDFILE="${DATA_DIR}notes.ini"

if [ ! -f "${FINDFILE}" ]; then
    echo "${FINDFILE} does not exists"
    exit 1
fi

LOTUS_STR_LENGTH=`echo "${LOTUS}" | wc -c`
LOTUS_STR_LENGTH=`expr ${LOTUS_STR_LENGTH} - 1`
LOTUS_STR_LASTCHAR=`echo "${LOTUS}" | cut -c ${LOTUS_STR_LENGTH}`

if [ ! "${LOTUS_STR_LASTCHAR}" = "/" ]; then
    LOTUS="${LOTUS}/"
fi

FINDFILE="${LOTUS}notes/latest/linux/libnotes.so"

if [ ! -f "${FINDFILE}" ]; then
    echo "Invalid canonical Lotus directory."
    exit 1
fi

if [ -n "${INPUT_FILE}" ]; then
    if [ ! -f "${INPUT_FILE}" ]; then
        echo "Invalid path to input database file"
        exit 1
    fi
fi

if [ -n "${RESTOREDB}" ]; then
    if [ ! -f "${RESTOREDB}" ]; then
        echo "Invalid path to restored database file"
        exit 1
    fi
fi

if [ -n "${INPUT_FILE}" ] || [ -n "${RESTOREDB}" ]; then
    if [ -z "${INPUT_FILE}" ] || [ -z "${RESTOREDB}" ]; then
        echo "Please enter both INPUT_FILE and RESTOREDB if you want to restore one database."
        echo "If you want to restore all databases, leave them empty."
        exit 1
    fi
fi

if [ -n "${INPUT_FILE}" ] && [ -n "${RESTOREDB}" ]; then
    LOTUS_RESTORE_ARG="RESTORE"
    if [ "${INPUT_FILE}" = "${RESTOREDB}" ]; then
        echo "INPUT_FILE and RESTOREDB must be different."
        exit 1
    fi
fi

if [ -z "${INPUT_FILE}" ] && [ -n "${RECDATE}${RECTIME}" ]; then
    echo "Please leave RECDATE and RECTIME blank if you want to recover all databases."
    exit 1
fi

if [ -n "${INPUT_FILE}${RESTOREDB}" ] && [ -z "${RECDATE}" ] && [ -z "${RECTIME}" ]; then
    echo "Please enter RECDATE and RECTIME if you want to recover one database only."
    exit 1
fi

if [ -n "${INPUT_FILE}${RESTOREDB}" ] && [ -z "${RECDATE}" ]; then
    echo "Please enter RECDATE if you want to recover one database only."
    exit 1
fi

if [ -n "${INPUT_FILE}${RESTOREDB}" ] && [ -z "${RECTIME}" ]; then
    echo "Please enter RECTIME if you want to recover one database only."
    exit 1
fi


################################################################################
#      R E T R I E V E            A P P _ H O M E           P A T H            #
################################################################################

EXE_DIR=`pwd`
SCRIPT_HOME=`dirname "$0"`
cd "$SCRIPT_HOME"
APP_BIN=`pwd`
APP_HOME=`dirname "$APP_BIN"`

################################################################################
#           D O M I N O          P A T H         P R O P E R T I E S           #
################################################################################

LOTUS="${LOTUS}"
NOTES_DATA_DIR="${DATA_DIR}"
Notes_ExecDirectory="${LOTUS}notes/latest/linux/"
PATH="${PATH}:${LOTUS}:${DATA_DIR}:${Notes_ExecDirectory}res/C"
LD_LIBRARY_PATH="$APP_HOME/bin:$Notes_ExecDirectory:$LD_LIBRARY_PATH"
export LOTUS NOTES_DATA_DIR Notes_ExecDirectory PATH LD_LIBRARY_PATH

################################################################################
#               L O T U S B M                 E X E C U T I O N                #
################################################################################

cd "${APP_BIN}"
./LotusBMLinX86 $LOTUS_RESTORE_ARG $INPUT_FILE $RESTOREDB $RECDATE $RECTIME

################################################################################
#                   R E S E T          A N D          E X I T                  #
################################################################################

cd "${EXE_DIR}"
exit 0
