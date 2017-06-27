#!/bin/sh
# Ahsay Online Backup Manager 6.27.0.0

# We Will NOT override any of the Currenty Environment Variable
# -------------- Check provided namd and path of the script --------------------

if [ $# != 1 ];
then
  echo "Please provide the path to the service script!"
fi

SCRIPT_PATH=`dirname $1`
SCRIPT_NAME=`basename $1`


# --------------------- Verify uname -------------------------------------------
case "`uname`" in
  Linux*)   INSTALL_TYPE=NIX ;;
  Solaris*) INSTALL_TYPE=NIX ;;
  SunOS*)   INSTALL_TYPE=NIX ;;
  OpenBSD*) INSTALL_TYPE=OPENBSD ;;
  *BSD*)    INSTALL_TYPE=BSD ;;
  **)       INSTALL_TYPE=NOT_SUPPORTED ;;
esac


# ------------------------ Installl according to OS type -----------------------
if [ $INSTALL_TYPE = "NIX" ];
then

    ############################################################################
    #         N I X                        I N S T A L L A T I O N             #
    ############################################################################

    echo "Install Service for NIX type OS"

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
    echo "Copying script $SCRIPT_NAME to $INIT_PATH"
    cp "$SCRIPT_PATH/$SCRIPT_NAME" "$INIT_PATH/$SCRIPT_NAME"

    chmod 755 "$SCRIPT_PATH/$SCRIPT_NAME"
    chmod 755 "$INIT_PATH/$SCRIPT_NAME"
            
    # Create new startup symbolic links 
    echo "Creating symbolic link to run levels" 

    if [ -d "$RC_PATH/rc1.d" ];
    then  
      rm -f "$RC_PATH/rc1.d/S??$SCRIPT_NAME"
      rm -f "$RC_PATH/rc1.d/K??$SCRIPT_NAME"
    fi
    
    if [ -d "$RC_PATH/rc2.d" ];
    then  
      rm -f "$RC_PATH/rc2.d/S??$SCRIPT_NAME"
      rm -f "$RC_PATH/rc2.d/K??$SCRIPT_NAME"
      ln -sf "$INIT_PATH/$SCRIPT_NAME" "$RC_PATH/rc2.d/S99$SCRIPT_NAME"
    fi

    case "`uname`" in
      Linux*)   
      if [ -d "$RC_PATH/rc3.d" ];
      then
        rm -f "$RC_PATH/rc3.d/S??$SCRIPT_NAME"
        rm -f "$RC_PATH/rc3.d/K??$SCRIPT_NAME"       
        ln -sf "$INIT_PATH/$SCRIPT_NAME" "$RC_PATH/rc3.d/S99$SCRIPT_NAME"
      fi

      if [ -d "$RC_PATH/rc4.d" ];
      then
        rm -f "$RC_PATH/rc4.d/S??$SCRIPT_NAME"
        rm -f "$RC_PATH/rc4.d/K??$SCRIPT_NAME"           
        ln -sf "$INIT_PATH/$SCRIPT_NAME" "$RC_PATH/rc4.d/S99$SCRIPT_NAME"
      fi

      if [ -d "$RC_PATH/rc5.d" ];
      then
        rm -f "$RC_PATH/rc5.d/S??$SCRIPT_NAME"
        rm -f "$RC_PATH/rc5.d/K??$SCRIPT_NAME"
        ln -sf "$INIT_PATH/$SCRIPT_NAME" "$RC_PATH/rc5.d/S99$SCRIPT_NAME"
      fi
      
      if [ -d "$RC_PATH/rc6.d" ];
      then
        rm -f "$RC_PATH/rc6.d/S??$SCRIPT_NAME"
        rm -f "$RC_PATH/rc6.d/K??$SCRIPT_NAME"    
      fi

      ;;
    esac    
       
    echo "You may start this service by:"
    echo ""
    echo "sh \"$INIT_PATH/$SCRIPT_NAME\" start &"
    echo ""

elif [ $INSTALL_TYPE = "BSD" ];
then

    ############################################################################
    #         B S D                        I N S T A L L A T I O N             #
    ############################################################################

    echo "Install Service for BSD type OS"

    INIT_PATH=/usr/local/etc/rc.d
    echo "Copying script $SCRIPT_NAME to $INIT_PATH"
    cp $SCRIPT_PATH/$SCRIPT_NAME $INIT_PATH/$SCRIPT_NAME
    chmod 755 $SCRIPT_PATH/$SCRIPT_NAME
    chmod 755 $INIT_PATH/$SCRIPT_NAME

    echo "You may start this service by:"
    echo ""
    echo "sh \"$INIT_PATH/$SCRIPT_NAME\" start &"
    echo ""
    echo "Remember to add an entry: ${SCRIPT_NAME}_enable=\"YES\" to /etc/rc.conf "
    echo ""

elif [ $INSTALL_TYPE = "OPENBSD" ];
then

    ############################################################################
    #     O P E N B S D                        I N S T A L L A T I O N         #
    ############################################################################

    echo "Install Service for OpenBSD type OS"    

    #get OpenBSD version
    OPENBSD_VERSION=`uname -r | cut -f1 -d"."`

    if [ $OPENBSD_VERSION -ge 5 ]
    then
      INIT_PATH=/etc/rc.d
      echo "Copying script $SCRIPT_NAME to $INIT_PATH"
      cp $SCRIPT_PATH/$SCRIPT_NAME $INIT_PATH/$SCRIPT_NAME
      chmod 755 $SCRIPT_PATH/$SCRIPT_NAME
      chmod 755 $INIT_PATH/$SCRIPT_NAME

      echo "You may start this service by:"
      echo ""
      echo "sh \"$INIT_PATH/$SCRIPT_NAME\" start &"
      echo ""
      echo "Remember to add an entry: pkg_scripts=\"${SCRIPT_NAME}\" to /etc/rc.conf.local "
      echo ""
      echo "or append \"${SCRIPT_NAME}\" to the existing entry: pkg_scripts=\"xxx yyy\" in /etc/rc.conf.local "
      echo "e.g. pkg_scripts=\"xxx yyy ${SCRIPT_NAME}\""
      echo ""
    
    else
      INIT_PATH=/etc
      echo "Copying script $SCRIPT_NAME to $INIT_PATH"
      cp $SCRIPT_PATH/$SCRIPT_NAME $INIT_PATH/$SCRIPT_NAME
      chmod 755 $SCRIPT_PATH/$SCRIPT_NAME
      chmod 755 $INIT_PATH/$SCRIPT_NAME
    
      echo "You may start this service by:"
      echo ""
      echo "sh \"$INIT_PATH/$SCRIPT_NAME\" start &"
      echo ""
      echo "Remember to add the following entry to /etc/rc.local "
      echo ""
      echo "if [ -x $INIT_PATH/$SCRIPT_NAME ] ; then"
      echo "  $INIT_PATH/$SCRIPT_NAME start"
      echo "fi"
      echo ""
    fi
    
else

    ############################################################################
    #       O T H E R         O S        N O T         S U P P O R T E D       #
    ############################################################################

    echo "This OS `uname` is not supported by this script! Exit `basename $0` now!"

fi

exit 0
