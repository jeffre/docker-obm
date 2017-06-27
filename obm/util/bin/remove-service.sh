#!/bin/sh
# Ahsay Online Backup Manager 6.27.0.0

if [ $# != 1 ];
then
  echo "Please provide the service script name!"
fi

SCRIPT_NAME=$1

# --------------------- Verify uname -------------------------------------------
case "`uname`" in
  Linux*)   INSTALL_TYPE=NIX ;;
  Solaris*) INSTALL_TYPE=NIX ;;
  SunOS*)   INSTALL_TYPE=NIX ;;
  OpenBSD*) INSTALL_TYPE=OPENBSD ;;
  *BSD*)    INSTALL_TYPE=BSD ;;
  **)       INSTALL_TYPE=NOT_SUPPORTED ;;
esac



# ---------------------- Uninstalll according to OS type -----------------------
if [ $INSTALL_TYPE = "NIX" ];
then

# -------------- Check local machine init Service Path -------------------------
    ############################################################################
    #         N I X                    U N I N S T A L L A T I O N             #
    ############################################################################

    echo "Uninstall Service for NIX type OS"

    # -------------- Check local machine init Service Path ---------------------
    # Setup INIT_PATH if not given

    if [ -z "$INIT_PATH" ]; then
      if [ -d /etc/init.d ]; then
        INIT_PATH=/etc/init.d
      else
        if [ -d /etc/rc.d/init.d ]; then
          INIT_PATH=/etc/rc.d/init.d
        else
          echo "INIT_PATH not found!"
          return -1
        fi
      fi
    fi

    echo "Using init script path $INIT_PATH"

    # -------------- Check local machine Run Level Path ------------------------
    # Setup RC_PATH if not given

    if [ -z "$RC_PATH" ]; then
      if [ -d /etc/rc.d ]; then
        RC_PATH=/etc/rc.d
      else
        if [ -d /etc/rc3.d ]; then
          RC_PATH=/etc
        elif [ -d /etc/init.d/rc3.d ]; then
          RC_PATH=/etc/init.d
        else
          echo "RC_PATH not found!"
          return -1
        fi
      fi
    fi

    echo "Using run level script path $RC_PATH"

    # --------------------------------------------------------------------------
    echo "Removing symbolic link from run levels"

    if [ -f $RC_PATH/rc2.d/S99$SCRIPT_NAME ];
    then
      rm $RC_PATH/rc2.d/S99$SCRIPT_NAME
    fi

    if [ -f $RC_PATH/rc3.d/S99$SCRIPT_NAME ];
    then
      rm $RC_PATH/rc3.d/S99$SCRIPT_NAME
    fi

    if [ -f $RC_PATH/rc4.d/S99$SCRIPT_NAME ];
    then
      rm $RC_PATH/rc4.d/S99$SCRIPT_NAME
    fi

    if [ -f $RC_PATH/rc5.d/S99$SCRIPT_NAME ];
    then
      rm $RC_PATH/rc5.d/S99$SCRIPT_NAME
    fi

    # ------------------------------------------------------------------------------

    echo "Removing script file $SCRIPT_NAME from $INIT_PATH"
    if [ -f $INIT_PATH/$SCRIPT_NAME ];
    then
      rm $INIT_PATH/$SCRIPT_NAME
    fi


elif [ $INSTALL_TYPE = "BSD" ];
then

    ############################################################################
    #         B S D                     U N I N S T A L L A T I O N            #
    ############################################################################

    echo "Uninstall Service for BSD type OS"

    INIT_PATH=/usr/local/etc/rc.d
    if [ -f "$INIT_PATH/$SCRIPT_NAME" ];
    then
    echo "Remove script $SCRIPT_NAME from $INIT_PATH"
      rm "$INIT_PATH/$SCRIPT_NAME"
    fi

elif [ $INSTALL_TYPE = "OPENBSD" ];
then

    ############################################################################
    #     O P E N B S D                     U N I N S T A L L A T I O N        #
    ############################################################################

    echo "Uninstall Service for OpenBSD type OS"

    #get OpenBSD version
    OPENBSD_VERSION=`uname -r | cut -f1 -d"."`

    if [ $OPENBSD_VERSION -ge 5 ]
    then
      INIT_PATH=/etc/rc.d
      if [ -f "$INIT_PATH/$SCRIPT_NAME" ];
      then
        echo "Remove script $SCRIPT_NAME from $INIT_PATH"
        rm "$INIT_PATH/$SCRIPT_NAME"
      fi    

    else
      INIT_PATH=/etc
      if [ -f "$INIT_PATH/$SCRIPT_NAME" ];
      then
        echo "Remove script $SCRIPT_NAME from $INIT_PATH"
        rm "$INIT_PATH/$SCRIPT_NAME"
      fi

    fi

else

    ############################################################################
    #       O T H E R         O S        N O T         S U P P O R T E D       #
    ############################################################################

    echo "This OS `uname` is not supported by this script! Exit `basename $0` now!"

fi

exit 0
