# Description:
# This script runs inside the Xiaomi Yi camera and allows to
# enable RAW file creation and change photographic options such as
# Exposure, ISO, White Balance, Noise Reduction and Scene
#
# Usage:
# 1) copy the script on the root of SD Card
# 2) enable wifi and connect to the camera using telnet
#    (IP:192.168.42.1; port:23; User:root)
# 3) Run /tmp/fuse_d/xyc.sh

FUSED=/tmp/fuse_d

welcome ()
{
  clear
  echo ""
  echo "   **************************** "
  echo "   *  Xiaomi Yi Configurator  * "
  echo "   *        7/09/2015         * "
  echo "   **************************** "
  echo ""
}

unset EXITACTION

inizializzeValues ()
{
  #Set reasonable defaults for any missing values
  ISO=0
  EXP=0
  AWB=y
  NR=-2
  RAW=n
  SCENE=-1
}

createAutoexec ()
{
  AASH=${FUSED}/autoexec.ash
  OUTFILE=${1:-$AASH}

  echo "Writing $OUTFILE"
  echo "#Script created by xyc.sh" > $OUTFILE
  echo "" >> $OUTFILE

  if [[ $ISO -ne 0 || $EXP -ne 0 ]]; then
    echo "#Set ISO and exposure" >> $OUTFILE
    echo "t ia2 -ae exp $ISO $EXP" >> $OUTFILE
    echo "" >> $OUTFILE
  fi

  if [[ $AWB == n ]]; then
    echo "#Set auto-whitebalance" >> $OUTFILE
    echo "t ia2 -awb off" >> $OUTFILE
    echo "" >> $OUTFILE
  fi

  if [[ $NR -ne -2 ]]; then
    echo "#Set noise reduction" >> $OUTFILE
    echo "t ia2 -adj tidx -1 $NR -1" >> $OUTFILE
    echo "" >> $OUTFILE
  fi

  if [[ $RAW == y ]]; then
    echo "#Create RAW files" >> $OUTFILE
    echo "t app test debug_dump 14" >> $OUTFILE
    echo "" >> $OUTFILE
  fi

  if [[ $SCENE -ne -1 ]]; then
    echo "#Set Scene Mode" >> $OUTFILE
    echo "t cal -sc $SCENE" >> $OUTFILE
    echo "" >> $OUTFILE
  fi
}

removeAutoexec ()
{
  #Note: This works in "t": rm 'd:\autoexec.ash'
  rm -f ${FUSED}/autoexec.ash
}

saveSettings ()
{
  removeAutoexec
  createAutoexec
}

showMainMenu ()
{
  local REPLY=0
  while [[ $REPLY -gt -1 && $REPLY -lt 5 ]]
  do
    echo "    ==== MAIN MENU ===="
    echo " [1] Edit Settings"
    echo " [2] Reset Settings"
    echo " [3] Show Card Space"
    echo " [4] Reset Camera"
    echo " [5] Exit"

    read -p "Select Option: " REPLY
    clear
    case $REPLY in
      1) inizializzeValues; showSettingsMenu;;
      2) removeAutoexec;;
      3) showSpaceUsage;;
      4) EXITACTION="reboot";;
      5) EXITACTION="nothing";;
      *) echo "Value Incorrect"; REPLY=0;;
    esac

  done
  clear
}

showSettingsMenu ()
{
  local REPLY=0
  while [[ $REPLY -gt -1 && $REPLY -lt 8 ]]
  do
    echo "    ==== SETTINGS MENU ===="
    echo " [1] Exposure[Current=$EXP]"
    echo " [2] ISO [Current=$ISO]"
    echo " [3] Auto White Balance s[Current=$AWB]"
    echo " [4] Noise Reduction [Current=$NR]"
    echo " [5] RAW [Current=$RAW]"
    echo " [6] Scene Mode [Current=$SCENE]"
    echo " [7] Save"
    echo " [8] Back"

    read -p "SELECT OPTION: " REPLY
    case $REPLY in
      1) getExposureInput; clear;;
      2) getISOInput; clear;;
      3) getAWBInput; clear;;
      4) getNRInput; clear;;
      5) getRawInput; clear;;
      6) getSceneInput; clear;;
      7) saveSettings; clear;;
      8) return 0;;
      *) clear; echo "Value Incorrect"; REPLY=0;;
    esac
  done

  clear
}

showSpaceUsage ()
{
    local JPEG_COUNT=`find ${FUSED} -name *.jpg | wc -l`
    local RAW_COUNT=`find ${FUSED} -name *.RAW | wc -l`
    local MP4_COUNT=`find ${FUSED} -name *.mp4 | wc -l`

  local SPACE_TOTAL=`df -h ${FUSED} | awk -F " " '/tmp/ {print $2}'`
  local SPACE_USED=`df -h ${FUSED} | awk -F " " '/tmp/ {print $3}'`
  local SPACE_FREE=`df -h ${FUSED} | awk -F " " '/tmp/ {print $4}'`
  local USED_PCT=`df -h ${FUSED} | awk -F " " '/tmp/ {print $5}'`

  local SPACE_FREE_KB=`df -k ${FUSED} | awk -F " " '/tmp/ {print $4}'`

  echo "SD Card Space:"
  echo "  Total=$SPACE_TOTAL, used=$SPACE_USED ($USED_PCT), Free=$SPACE_FREE"
  echo ""
  echo "File Couns:"
  echo "  JPEG=$JPEG_COUNT, RAW=$RAW_COUNT, MP4=$MP4_COUNT"
  echo ""
}

showExposureValues ()
{
  printf "${XYC_ENTER_EXPOSURE_PROMPT_2}:\n"
  printf "%s\t%s\t%s\n" "0=auto-exp " "1=8s       " "8=7.7s"
  printf "%s\t%s\t%s\n" "50=6.1s    " "84=5.s     " "100=4.6s"
  printf "%s\t%s\t%s\n" "200=2.7s   " "400=1s     " "500=1s"
  printf "%s\t%s\t%s\n" "590=1/3    " "600=1/5    " "700=1/5"
  printf "%s\t%s\t%s\n" "800=1/10   " "900=1/15   " "1000=1/30"
  printf "%s\t%s\t%s\n" "1100=1/50  " "1145=1/60  " "1200=1/80"
  printf "%s\t%s\t%s\n" "1275=1/125 " "1300=1/140 " "1405=1/250"
  printf "%s\t%s\t%s\n" "1450=1/320 " "1500=1/420 " "1531=1/500"
  printf "%s\t%s\t%s\n" "1600=1/624 " "1607=1/752 " "1660=1/1002"
  printf "%s\t%s\t%s\n" "1700=1/1244" "1750=1/1630" "1800=1/2138"
  printf "%s\t%s\t%s\n" "1825=1/2448" "1850=1/2803" "1900=1/3675"
  printf "%s\t%s\t%s\n" "2000=1/6316" "2047=1/8147"
}

getExposureInput ()
{
  local REPLY=$EXP
  read -p "Exposure: ?(help), 0-2047 [Enter=$EXP]: " REPLY
  if [ -n "$REPLY" ]; then
    if [ "$REPLY" == "s" ]; then
      SKIP=1
    elif [ "$REPLY" == "?" ]; then
      showExposureValues
      getExposureInput
    elif [[ $REPLY -gt -1 && $REPLY -lt 2048 ]]; then
      EXP=$REPLY
    fi
  fi
}

getISOInput ()
{
  local REPLY=$ISO
  read -p "ISO: (0=auto, 100-25600) [Enter=$ISO]: " REPLY
  if [ -n "$REPLY" ]; then
    if [ "$REPLY" == "s" ]; then
      SKIP=1
    elif [[ $REPLY -eq 0 || $REPLY -eq 100 || $REPLY -eq 200 ||  $REPLY -eq 400 || $REPLY -eq 800 || $REPLY -eq 1600 || $REPLY -eq 3200 || $REPLY -eq 6400 || $REPLY -eq 12800 || $REPLY -eq 25600 ]]; then
      ISO=$REPLY
    else
      echo "Choose: 0,100,200,400...25600"
      getISOInput
    fi
  fi
}

getAWBInput ()
{
  local REPLY=$AWB
  read -p "Auto White Balance (y/n) [Enter=$AWB]: " REPLY
  if [[ "$REPLY" == y || "$REPLY" == n ]]; then AWB=$REPLY; fi
}

getNRInput ()
{
  local REPLY=$CNR
  read -p "set NR (-2=default -1=disable 0-16383)[Enter=$NR]: " REPLY
  if [ -n "$REPLY" ]; then
    if [ "$REPLY" == "s" ]; then
      SKIP=1
    elif [[ $REPLY -gt -3 && $REPLY -lt 16384 ]]; then
      NR=$REPLY
    else
      echo "Choose: -2-16384"
      getNRInput
    fi
  fi
}

getRawInput ()
{
  local REPLY=$RAW
  read -p "Save RAW (y/n)[Enter=$RAW]: " REPLY
  if [[ "$REPLY" == y || "$REPLY" == n ]]; then RAW=$REPLY; fi
}

getSceneInput (){
  local REPLY=$SCENE
  read -p "Scene: (-1=default, 0-23) [Enter=$SCENE]: " REPLY
  if [ -n "$REPLY" ]; then
    if [ "$REPLY" == "s" ]; then
      SKIP=1
    elif [[ $REPLY -gt -2 && $REPLY -lt 24 ]]; then
      SCENE=$REPLY
    else
      echo "Choose: 0-23"
      getSceneInput
    fi
  fi
}



#Main program

welcome
showMainMenu

if [ "$EXITACTION" == "reboot" ]; then
  echo "Rebooting Now..."
  sleep 1
  reboot yes
elif [ "$EXITACTION" == "poweroff" ]; then
  echo "Shutting Down Now..."
  sleep 1
  poweroff yes
fi
