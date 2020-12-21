#!/system/bin/sh

# --- Variables --- #
# CONFIG: Modify accordingly to your game!
victory=false
RGBDEBUG=false
LAUNCHTIMER=0
BATTLETIMER=0
COUNTER=0
DAY=$(date +%u)
## Text Colours
GREEN='\033[0;32m'
LGREEN='\033[1;32m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
RED='\033[0;31m'
ORANGE='\033[0;33m'
NC='\033[0m' # No Color

# Probably you don't need to modify this. Do it if you know what you're doing, I won't blame you (unless you blame me).
DEVICEWIDTH=1080

# Do not modify
RGB=00000000
if [ $# -gt 0 ]; then
    SCREENSHOTLOCATION="/$1/scripts/afk-arena/screen.dump"
else
    SCREENSHOTLOCATION="/storage/emulated/0/scripts/afk-arena/screen.dump"
fi

# --- Functions --- #
# Test function: change apps, take screenshot, get rgb, change apps, exit. Params: X, Y, amountTimes, waitTime
function test() {
    #startApp
    #switchApp
    local COUNT=0
    until [ "$COUNT" -ge "$3" ]; do
        sleep $4
        getColor "$1" "$2"
        echo "RGB: $RGB"
        ((COUNT = COUNT + 1)) # Increment
    done
    #switchApp
    exit 1
}

# Default wait time for actions
function wait() {
    sleep 1
}

# Starts the app
function startApp() {
    monkey -p com.lilithgame.hgame.gp 1 >/dev/null 2>/dev/null
    wait
    disableOrientation
}

# Closes the app
function closeApp() {
    am force-stop com.lilithgame.hgame.gp >/dev/null 2>/dev/null
}

# Switches between last app
function switchApp() {
    input keyevent KEYCODE_APP_SWITCH
    input keyevent KEYCODE_APP_SWITCH
}

# Disables automatic orientation
function disableOrientation() {
    content insert --uri content://settings/system --bind name:s:accelerometer_rotation --bind value:i:0
}

# Takes a screenshot and saves it
function takeScreenshot() {
    screencap "$SCREENSHOTLOCATION"
}

# Gets pixel color. Params: X, Y
function readRGB() {
    let offset="$DEVICEWIDTH"*"$2"+"$1"+3
    RGB=$(dd if="$SCREENSHOTLOCATION" bs=4 skip="$offset" count=1 2>/dev/null | hexdump -C)
    RGB=${RGB:9:9}
    RGB="${RGB// /}"
    if [ $RGBDEBUG = true ]; then
      echo "RGB debug: $RGB"
    fi
}

# Sets RGB. Params: X, Y
function getColor() {
    takeScreenshot
    readRGB "$1" "$2"
}

# Verifies if X and Y have specific RGB. Params: X, Y, RGB, MessageSuccess, MessageFailure
function verifyRGB() {
    getColor "$1" "$2"
    if [ "$RGB" != "$3" ]; then
        echo $RED"VerifyRGB: Failure! Expected "$3", but got "$RGB" instead."$NC
        echo
        echo "$5"
        closeApp
        exit 1
    else
        echo "$4"
    fi
}

function openMenu() {
  # Open menu for friends, etc
  input tap 970 380
  wait
}

function waitUntilGameActive {
  # Loops until the game has launched, we use a pixel near the chat button
  # TODO Add timeout
  getColor 1050 1800
  while [ "$RGB" != "482f16" ]; do
      wait
      #we click the campaign button in case we have deal popups obscuring the pixel
      input tap 550 1850
      getColor 1050 1800
      let "LAUNCHTIMER=LAUNCHTIMER+1"
      # If we're unsuccessful for 60 cycles somethings amiss so we exit
      if [ $LAUNCHTIMER -gt 60 ]; then
        echo $RED"Timed out while launching"$NC
        closeApp
        exit 1
      fi
  done
  sleep 5
}

# Switches to another character. Params: character slot (1, 2 or 3)
function switchCharacter() {
    echo $CYAN"Checking loaded character"$NC
    case "$1" in
    "1")
        # Click Profile
        input tap 120 100
        wait
        # Click Settings
        input tap 650 1675
        wait
        # Click Server
        input tap 300 500
        wait
        # Click Slot 1
        input tap 550 550
        wait
        getColor 400 750
        #If we detect the change server notice
        if [ "$RGB" = "866442" ]; then
          echo $ORANGE"  Changing to Slot 1"$NC
          #Click confirm
          input tap 700 1250
          waitUntilGameActive
        else
          #Tap back
          input tap 70 1810
          wait
          #Tap back
          input tap 70 1810
          wait
        fi
        verifyRGB 1050 1800 482f16 $GREEN"Character checked."$NC
        echo
        ;;
    "2")
        # Click Profile
        input tap 120 100
        wait
        # Click Settings
        input tap 650 1675
        wait
        # Click Server
        input tap 300 500
        wait
        # Click Slot 3
        input tap 550 750
        wait
        getColor 400 750
        #If we detect the change server notice
        if [ "$RGB" = "866442" ]; then
          echo $ORANGE"  Changing to Slot 2"$NC
          #Click confirm
          input tap 700 1250
          waitUntilGameActive
        else
          #Tap back
          input tap 70 1810
          wait
          #Tap back
          input tap 70 1810
          wait
        fi
        verifyRGB 1050 1800 482f16 $GREEN"Character checked."$NC
        echo
        ;;
    "3")
        # Click Profile
        input tap 120 100
        wait
        # Click Settings
        input tap 650 1675
        wait
        # Click Server
        input tap 300 500
        wait
        # Click Slot 3
        input tap 550 950
        wait
        getColor 400 750
        #If we detect the change server notice
        if [ "$RGB" = "866442" ]; then
          echo $ORANGE"  Changing to Slot 3"$NC
          #Click confirm
          input tap 700 1250
          waitUntilGameActive
        else
          #Tap back
          input tap 70 1810
          wait
          #Tap back
          input tap 70 1810
          wait
        fi
        verifyRGB 1050 1800 482f16 $GREEN"Character checked."$NC
        echo
        ;;
    *)
        echo "Server check failed."
        exit 1
        ;;
    esac
}

# Switches to another tab. Params: Tab name
function switchTab() {
    case "$1" in
    "Campaign")
        input tap 550 1850
        wait
        verifyRGB 450 1775 cc9261 $PURPLE"Switched to the Campaign Tab."$NC
        echo
        ;;
    "Dark Forest")
        input tap 300 1850
        wait
        verifyRGB 240 1775 d49a61 $PURPLE"Switched to the Dark Forest Tab."$NC
        echo
        ;;
    "Ranhorn")
        input tap 110 1850
        wait
        verifyRGB 20 1775 d49a61 $PURPLE"Switched to the Rahorn Tab."$NC
        echo
        ;;
    *)
        echo $RED"Failed to switch to another Tab."$NC
        exit 1
        ;;
    esac
}

# Checks for a battle to finish. Param: Seconds before starting to check for victory/defeat screen
function waitForBattleToFinish() {
    sleep "$1"
    let "BATTLETIMER=0"
    while [ $BATTLETIMER -lt 90 ]; do
      getColor 160 1150
      # echo "Defeat Debug: " $RGB
      if [ "$RGB" = "8393a6" ] || [ "$RGB" = "617a92" ] || [ "$RGB" = "8191aa" ]; then
        echo $ORANGE"  Defeat!"$NC
        return
      fi
      getColor 420 380
      # echo "Victory Debug: " $RGB
      if [ "$RGB" = "ca9c5d" ] || [ "$RGB" = "4b3a23" ]; then
        echo $LGREEN"  Victory!"$NC
        return
      fi
      let "BATTLETIMER=BATTLETIMER+1"
      wait
    done
    echo $RED"Battle status timer expired!"$NC
}

# Loots afk chest
function lootAfkChest() {
    echo $CYAN"Attempting to loot AFK chest."$NC
    # Click chest
    wait
    input tap 550 1500
    wait
    # Click claim
    input tap 700 1350
    wait
    # Close Window twice, in case we have level up window
    input tap 550 1850
    wait
    input tap 550 1850
    wait
    # VerifyRGB with the top left of the chat button
    wait
    verifyRGB 1050 1800 482f16 $GREEN"AFK Chest looted successsfully."$NC
    echo
}

# Attempts campaign flag. Params: "1" to load and close for daily quest, "2" to attempt until victory/defeat
# "3" to continously retry, advancing to the next flag on victory
function attemptCampaign() {
    case "$1" in
    "1")
        echo $CYAN"Loading campaign level for daily quest."$NC
        # Click Begin
        input tap 550 1650
        wait

        # Check for 'boss' text in enemy formation
        getColor 550 740
        if [ "$RGB" = "f2d79f" ]; then
            input tap 550 1450
        fi

        wait
        # Click begin battle
        input tap 550 1850
        wait

        # Click Pause
        input tap 80 1460
        wait
        # Click exit battle
        input tap 230 960

        # VerifyRGB with the top left of the chat button
        wait
        verifyRGB 1050 1800 482f16 $GREEN"Campaign level loaded successfully."$NC
        echo
        ;;
    "2")
        echo $CYAN"Attempting campaign flag."$NC
        #Longer sleep for characters to load
        sleep 4
        # Click Begin
        input tap 550 1650
        wait

        # Check for 'boss' text in enemy formation
        getColor 550 740
        if [ "$RGB" = "f2d79f" ]; then
            input tap 550 1450
        fi

        wait
        # Click begin battle
        input tap 550 1850
        wait

        # Wait for the battle to finish
        waitForBattleToFinish 10

        # Click exit battle
        input tap 230 960

        # VerifyRGB with the top left of the chat button
        wait
        verifyRGB 1050 1800 482f16 $GREEN"Campaign flag attempted successfully."$NC
        echo
        ;;
    "3")
        echo $GREEN"Retrying until victorious.."$NC
        # Click Begin
        input tap 550 1650
        wait

        # Check for 'boss' text in enemy formation
        getColor 550 740
        if [ "$RGB" = "f1d79f" ]; then
            input tap 550 1450
        fi

        wait
        # Click begin battle
        input tap 550 1850
        wait

        #Not entirely sure what the victory variable does but if it ain't broke dont fix it
        while [ $victory = "false" ]; do
          getColor 160 1150
          # echo "Def " $RGB
          if [ "$RGB" = "8393a6" ] || [ "$RGB" = "8191aa" ] || [ "$RGB" = "090a11" ]; then
            let "COUNTER=COUNTER+1"
            echo $RED"Defeat!"$NC "#"$COUNTER
            input tap 550 1500
            wait
            attemptCampaign "3"
          fi
          getColor 420 380
          # echo "Vic " $RGB
          if [ "$RGB" = "ca9c5d" ] || [ "$RGB" = "4b3a23" ]; then
            let "COUNTER=0"
            echo $LGREEN"Victory! Moving to next flag.."$NC $(date +%H:%M)
            # exit 0
            input tap 550 1500
            wait
            attemptCampaign "3"
          fi
          wait
        done
        ;;
    *)
        echo $RED"Invalid parameter for attemptCampaign."$NC
        exit 1
        ;;
    esac
}

# Collects fast rewards (Only at campaign page, no error checking)
function fastRewards() {
  echo $CYAN"Attempting daily fast reward collection."$NC
  getColor 980 1620
  # echo "fastReward collection debug: " $RGB
  if [ "$RGB" == "f61b0b" ]; then
    # Click fast rewards
    input tap 950 1660
    wait
    # Double check to make sure the gem icon isn't in the 'use' button, so we only claim the free usage
    getColor 624 1253
    if [ ! "$RGB" = "f8f8ff" ]; then
      # Click claim
      input tap 710 1260
      wait
    fi
    # Click around campaign button
    input tap 560 1800
    wait
    # Click close
    input tap 400 1250
    wait
    # VerifyRGB with the top left of the chat button
    wait
    verifyRGB 1050 1800 482f16 $GREEN"Fast Rewards collected."$NC
    echo
  else
    echo $ORANGE"No fast rewards notication badge found."$NC
    echo
  fi
}

# Collects mail
collectMail() {
    echo $CYAN"Attempting to collect mail."$NC
  getColor 1000 580
  # echo "collectMail collection debug: " $RGB
  if [ "$RGB" == "ff3120" ]; then
    # Click mail icon
    input tap 960 630
    wait
    # Click collect
    input tap 790 1470
    wait
    # Click outside the menu twice to close
    input tap 550 1500
    wait
    input tap 110 1850

    wait
    verifyRGB 1050 1800 482f16 $GREEN"Successfully collected Mail."$NC
    echo
  else
    echo $ORANGE"No mail notification badge found"$NC
    echo
  fi
}

# Collects and sends companion points, as well as auto lending mercenaries
function collectFriendsAndMercenaries() {
  echo $CYAN"Attempting companion point collection and mercenary lending."$NC
  getColor 1000 760
  # echo "collectFriendsAndMercenaries collection debug: " $RGB
  if [ "$RGB" == "fa1d0c" ]; then
    # Click friends
    input tap 970 810
    wait
    # Click send and recieve
    input tap 930 1600
    wait

    #TODO: Check if its necessary to send mercenaries
    #Click Mercenaries
    input tap 720 1760
    wait
    # Click manage
    input tap 990 190
    wait
    # Click apply
    input tap 630 1590
    wait
    # Click auto-lend
    input tap 750 1410
    wait
    # Click close button twice to exit 1
    input tap 70 1810

    input tap 70 1810
    wait
    verifyRGB 1050 1800 482f16 $GREEN"Companion point collection and mercenary lending successfull."$NC
    echo
  else
    echo $ORANGE"No Friends notification badge found"$NC
    echo
  fi
}

# Starts Solo bounties
function collectBounties() {
    echo $CYAN"Attempting Bounties."$NC
    #Open Bounties
    input tap 600 1320
    wait

    #Select Solo bounties
    input tap 650 1700
    wait
    #Select Dispatch
    input tap 350 1550
    wait
    #Select Confirm
    input tap 550 1540
    wait
    #Select Collect All
    input tap 850 1550
    wait

    #Select Team bounties
    input tap 950 1700
    wait
    #Select Dispatch
    input tap 350 1550
    wait
    #Select Confirm
    input tap 550 1540
    wait
    #Select Collect All
    input tap 850 1550
    wait

    #Tap back
    input tap 70 1810

    wait
    verifyRGB 1050 1800 482f16 $GREEN"Successfully finished Bounties."$NC
    echo
}

# Does the daily arena of heroes battles
function arenaOfHeroes() {
    echo $CYAN"Attempting Arena of Heroes battles."$NC
    #Click "Arena of Heroes"
    input tap 740 1050
    wait
    #Click first card in list
    input tap 550 450
    wait
    #Click Record and close to clear the notification
    input tap 1000 1800
    wait
    input tap 980 410
    wait
    #Click Challenge
    input tap 540 1800
    wait

    # We try and detect the 'Free' text on the top opponent
    getColor 813 691
    if [ "$RGB" = "fef7ec" ]; then # If it's found..
      wait
      while [ "$RGB" = "fef7ec" ]; do # Loop battles until we don't detect the 'Free' text
        echo $LGREEN"  Free arena battle found"$NC
        #Select second lowest slot
        input tap 820 1225
        wait
        #Click 'Begin Battle'
        input tap 550 1850
        #Wait for battle to finish
        waitForBattleToFinish 15
        #Tap to clear loot
        input tap 560 430
        wait
        #Tap to close Victory/Defeat screen
        input tap 560 430
        wait
        #We need to be back at the challenge menu again before we check the 'Free' text
        getColor 813 691
      done
    else
      echo $ORANGE"  No free arena battles found"$NC
    fi

    #Close opponent list window
    input tap 1000 380
    wait
    #Tap back
    input tap 70 1810
    wait
    #Tap back
    input tap 70 1810

    wait
    verifyRGB 1050 1800 482f16 $GREEN"Arena of Heroes successfully checked."$NC
    echo
}

# Does the daily arena of heroes battles using skip feature
function arenaOfHeroesQuick() {
    echo $CYAN"Attempting Arena of Heroes battles."$NC
    #Click "Arena of Heroes"
    input tap 740 1050
    wait
    #Click first card in list
    input tap 550 450
    wait
    #Click Record and close to clear the notification
    input tap 1000 1800
    wait
    input tap 980 410
    wait
    #Click Challenge
    input tap 540 1800
    wait

    # We try and detect the 'Free' text on the top opponent
    getColor 813 691
    if [ "$RGB" = "fef7ec" ]; then # If it's found..
      wait
      while [ "$RGB" = "fef7ec" ]; do # Loop battles until we don't detect the 'Free' text
        echo $LGREEN"  Free arena battle found"$NC
        #Select second lowest slot
        input tap 820 1225
        wait
        #Click 'Begin Battle'
        input tap 550 1850
        sleep 1
        #Click skip
        input tap 800 1450
        # input tap 870 1450
        wait
        #Tap to clear loot
        input tap 560 430
        wait
        #Tap to close Victory/Defeat screen
        input tap 560 430
        sleep 4
        #We need to be back at the challenge menu again before we check the 'Free' text
        getColor 813 691
      done
    else
      echo $ORANGE"  No free arena battles found"$NC
    fi

    #Close opponent list window
    input tap 1000 380
    wait
    #Tap back
    input tap 70 1810
    wait
    #Tap back
    input tap 70 1810

    wait
    verifyRGB 1050 1800 482f16 $GREEN"Arena of Heroes successfully checked."$NC
    echo
}

# Does the daily Legends tournament battles
function legendsTournament() {
    echo $CYAN"Attempting Legends Tournament battles."$NC
    # Click Arena of Heroes
    input tap 740 1050
    wait

    #Second slot
    input tap 550 900
    # #Third Slot
    # input tap 550 1450
    wait

    #Collect Gladiator Coins
    input tap 550 280
    wait
    #Clear Gladiator coins loot overlay
    input tap 550 1550
    wait
    #Open and close 'Record'
    input tap 1000 1800
    input tap 990 380
    wait

    # Click Challenge
    input tap 550 1840
    wait

    # We try and detect the 'Free' text on the top opponent
    getColor 790 728
    if [ "$RGB" = "ffffff" ]; then # If it's found..
      wait
      while [ "$RGB" = "ffffff" ]; do # Loop battles until we don't detect the 'Free' text
        echo $LGREEN"  Free legends battle found"$NC
        #Select lowest slot
        # input tap 800 940 #middle slot
        input tap 800 1150 #bottom slot
        wait
        #Click 'Next Team twice'
        input tap 550 1850
        wait
        input tap 550 1850
        wait
        #Click Begin Battle
        input tap 550 1850
        #Make sure we're loaded then skip
        sleep 2
        input tap 800 1450
        input tap 870 1450
        wait

        #Tap to close Victory/Defeat screen
        input tap 550 1850
        wait
        # Click Challenge
        input tap 550 1840
        wait
        #We need to be back at the challenge menu again before we check the 'Free' text
        getColor 790 728
      done
    else
      echo $ORANGE"  No free legends battles found"$NC
    fi

    #Click back arrow three times
    input tap 70 1810
    wait
    input tap 70 1810
    wait
    input tap 70 1810
    wait

    verifyRGB 1050 1800 482f16 $GREEN"Legends Tournament sucessfully checked."$NC
    echo
}

handleKingsTower() {
  #open and run standard tower
  openTower "0"
  kingsTower "$1"
  #handle faction towers based on day
  case "$DAY" in
  "1") #Monday
  echo $LGREEN"Running Monday factional towers"$NC
  openTower "1"
  kingsTower "1"
  ;;
  "2") #Tuesday
  echo $LGREEN"Running Tuesday factional towers"$NC
  openTower "2"
  kingsTower "1"
  ;;
  "3") #Wednesday
  echo $LGREEN"Running Wednesday factional towers"$NC
  openTower "3"
  kingsTower "1"
  ;;
  "4") #Thursday
  echo $LGREEN"Running Thursday factional towers"$NC
  openTower "4"
  kingsTower "1"
  ;;
  "5") #Friday
  echo $LGREEN"Running Friday factional towers"$NC
  openTower "1"
  kingsTower "1"
  openTower "2"
  kingsTower "1"
  ;;
  "6") #Saturday
  echo $LGREEN"Running Saturday factional towers"$NC
  openTower "3"
  kingsTower "1"
  openTower "4"
  kingsTower "1"
  ;;
  "7") #Sunday
  echo $LGREEN"Running Sunday factional towers"$NC
  openTower "1"
  kingsTower "1"
  openTower "2"
  kingsTower "1"
  openTower "3"
  kingsTower "1"
  openTower "4"
  kingsTower "1"
  ;;
  *)
  echo $RED"Invalid parameter for DAY variable."$NC
  exit 1
  ;;
  esac
}

function openTower() {
  #Click King's Tower in main map
  input tap 500 870
  wait
  case "$1" in
  "0") #Non-faction tower
  input tap 550 900
  wait
  ;;
  "1") #LB tower
  input tap 250 500
  wait
  ;;
  "2") #Mauler tower
  input tap 800 500
  wait
  ;;
  "3") #Wilder tower
  input tap 250 1400
  wait
  ;;
  "4") #Graveborn tower
  input tap 800 1400
  wait
  ;;
  *)
  echo $RED"Invalid parameter for openTower."$NC
  exit 1
  ;;
  esac
}

# Battles once in the kings tower
function kingsTower() {
    case "$1" in
    "1")
      echo $CYAN"Attempting King's tower for daily quest."$NC
      #Click "Challenge"
      input tap 540 1350
      wait
      #Click begin battle
      input tap 550 1850
      wait
      # Wait for battle to finish
      waitForBattleToFinish 10

      #Click exit battle
      input tap 230 960
      wait
      #Click back arrow
      input tap 70 1810
      #Below is if you have faction towers unlocked
      wait
      input tap 70 1810

      wait
      verifyRGB 1050 1800 482f16 $GREEN"Kings Tower attempted successfully."$NC
      echo
      ;;
    "2")
      #Click "Challenge"
      input tap 540 1350
      wait
      #Click begin battle
      input tap 550 1850
      wait

      while [ $victory = "false" ]; do
        getColor 160 1150
        if [ "$RGB" = "8495a6" ] || [ "$RGB" = "8191aa" ] || [ "$RGB" = "090a11" ]; then
          let "COUNTER=COUNTER+1"
          echo $RED"Defeat!"$NC "#"$COUNTER
          input tap 550 1500
          wait
          kingsTower "2"
        fi
        getColor 420 380
        if [ "$RGB" = "ca9c5d" ] || [ "$RGB" = "4b3a23" ]; then
          let "COUNTER=0"
          echo $LGREEN"Victory!"$NC $(date +%H:%M)
          input tap 550 1500
          wait
          kingsTower "2"
        fi
      wait
      done
      ;;
    *)
      echo $RED"Invalid parameter for kingsTower."$NC
      #Click back arrow
      input tap 70 1810
      wait
      input tap 70 1810
      wait
      ;;
    esac
}

# Battles against Guild bosses
function guildHunts() {
    echo $CYAN"Attempting Guild Hunts."$NC
    # First we check Wrizz
    # Click Guild Hall
    input tap 380 360
    #Longer sleep for the loading animation
    sleep 5
    # Click Guild Hunting
    input tap 290 860
    wait
    # Click Challenge
    input tap 540 1800
    wait

    # Check for quick battles first, else check standard Wrizz battle
    getColor 710 1820
    if [ "$RGB" == "96e9c8" ]; then
      while [ "$RGB" == "96e9c8" ]; do
        echo $LGREEN"  Wrizz quick battle active, battling.."$NC
        # Click Quick Battle
        input tap 710 1820
        wait
        # Click Begin
        input tap 725 1300
        wait
        # Click collect
        input tap 540 1800
        wait
        input tap 540 1800
        sleep 3
        #Check for VS text again
        getColor 710 1820
      done
    fi

    # We check for the VS text at the top of the screen to see if Wrizz is active
    getColor 600 80
    if [ "$RGB" == "eedd9e" ] || [ "$RGB" == "efdd9e" ] || [ "$RGB" == "efde99" ]; then
      while [ "$RGB" == "eedd9e" ] || [ "$RGB" == "efdd9e" ] || [ "$RGB" == "efde99" ]; do
        echo $LGREEN"  Wrizz active, battling.."$NC
        # Click Begin Battles
        input tap 550 1850

        #wait for battle end
        waitForBattleToFinish 40

        # Click collect
        input tap 540 1800
        wait
        input tap 540 1800
        wait
        # Click Challenge
        input tap 540 1800
        sleep 3
        #Check for VS text again
        getColor 600 80
      done
    else
      echo $ORANGE"  Wrizz checked"$NC
    fi

    # Now we click the right arrow and check Soren

    #Click the right -> arrow
    input tap 970 890
    wait

    # Check for quick battles first, else check standard Soren battle
    getColor 710 1820
    # echo "Soren quick RGB: " $RGB
    if [ "$RGB" == "98ecc5" ]; then
      while [ "$RGB" == "98ecc5" ]; do
        echo $LGREEN"  Soren quick battle active, battling.."$NC
        # Click Quick Battle
        input tap 710 1820
        wait
        # Click Begin
        input tap 725 1300
        wait
        # Click collect
        input tap 540 1800
        wait
        input tap 540 1800
        sleep 3
        #Check for quick battle text again
        getColor 710 1820
      done
    fi

    # Click Challenge
    echo "soren challenge clicked"
    input tap 540 1800
    wait

    # Check for available but not unlocked notice
    getColor 330 725 # Pixel on the left of the 'Notice' banner
    if [ "$RGB" == "83613f" ]; then
      echo $ORANGE"  Soren unlock notice found, skipping.."$NC
      input tap 550 1250
      wait

      #Click back arrow twice
      input tap 70 1810
      wait
      input tap 70 1810

      wait
      verifyRGB 1050 1800 482f16 $GREEN"Guild Hunts battled successfully."$NC
      echo
      return
    fi

    # We check for the VS text at the top of the screen to see if Soren is active
    getColor 600 80
    # echo "Soren VS: " $RGB
    if [ "$RGB" == "eedd9e" ] || [ "$RGB" == "efdd9e" ] || [ "$RGB" == "efde99" ]; then
      echo $LGREEN"Soren active, battling.."$NC
      while [ "$RGB" == "eedd9e" ] || [ "$RGB" == "efdd9e" ] || [ "$RGB" == "efde99" ]; do
        # Click Begin Battles
        input tap 550 1850
        #wait for battle to finish
        waitForBattleToFinish 40
        # Click collect
        input tap 540 1800
        wait
        input tap 540 1800
        wait
        # Click Challenge
        input tap 540 1800
        sleep 3
        #Check for VS text again
        getColor 600 80
      done
    fi
    echo $ORANGE"  Soren checked"$NC

    #Click back arrow twice
    input tap 70 1810
    wait
    input tap 70 1810

    wait
    verifyRGB 1050 1800 482f16 $GREEN"Guild Hunts battled successfully."$NC
    echo
}

# Battles against the Twisted Realm Boss
function twistedRealmBoss() {
    # TODO: Choose if 2x or not
    # TODO: Choose a formation (Would be dope!)
    input tap 820 820
    wait
    input tap 550 1850
    wait
    input tap 550 1850

    # Wait for battle to finish
    waitForBattleToFinish 30

    wait
    input tap 550 800
    sleep 3
    input tap 550 800
    wait

    # TODO: Repeat battle if variable says so

    input tap 70 1810
    wait
    input tap 70 1810

    wait
    verifyRGB 20 1775 d49a61 "Successfully battled Twisted Realm Boss."
}

# Buys daily dust from ths store
function storeBuyDust() {
    echo $CYAN"Attempting to purchase daily dust from the store."$NC
    #Click on the shop
    input tap 330 1650
    wait
    # Check for purple dust pixel
    getColor 175 840
    if [ "$RGB" == "bb81dd" ] || [ "$RGB" == "bb87dd" ] || [ "$RGB" == "bb7edd" ]  ||  [ "$RGB" == "bb7dde" ]  ||  [ "$RGB" == "bb80de" ]  ||  [ "$RGB" == "bb88de" ]; then
      input tap 170 840
      wait
      #Click Purchase (Two clicks as it can appear in two locations)
      input tap 550 1420
      input tap 550 1550
      wait
      #Close loot window
      input tap 550 1220
      wait
    else
      echo "  Dust colour found: " $RGB
    fi
    #Back arrow to exit 1 shop
    input tap 70 1810

    wait
    verifyRGB 1050 1800 482f16 $GREEN"Daily Dust purchase attempted successfully."$NC
    echo
}

# Collects
function collectQuestChests() {
    #TODO: Check weekly/campaign
    echo $CYAN"Attempting to collect daily quest chests."$NC
    getColor 1000 200
    # Click quests
    input tap 960 250
    wait
    # Click Dailies
    input tap 400 1650
    wait
    # Collect Quests loop
    getColor 700 670
    while [ "$RGB" == "7dfff1" ]; do
      # If blue 'completed' bar found, click collect
        echo $LGREEN"  Quest found, collecting.."$NC
        input tap 930 680
        sleep 0.5
        getColor 700 670
    done

    input tap 330 430
    sleep 0.5
    input tap 580 600
    input tap 500 430
    sleep 0.5
    input tap 580 600
    input tap 660 430
    sleep 0.5
    input tap 580 600
    input tap 830 430
    sleep 0.5
    input tap 580 600
    input tap 990 430
    sleep 0.5
    input tap 580 600
    sleep 0.5
    input tap 70 1650
    wait

    verifyRGB 1050 1800 482f16 $GREEN"Successfully collected daily Quest chests."$NC
    echo
}

# --- Script Start --- #
echo
echo $GREEN"Script started, waiting for game to load.."$NC
closeApp
sleep 0.5
startApp
sleep 10

# #Wait until game is active
waitUntilGameActive

echo $GREEN"Game loaded! starting activities.."$NC
echo

switchTab "Ranhorn"
switchTab "Dark Forest"
switchTab "Campaign"

# Load first character
switchCharacter "1"
openMenu

# CAMPAIGN TAB
switchTab "Campaign"
lootAfkChest
collectMail
collectFriendsAndMercenaries
fastRewards
attemptCampaign "2"

# DARK FOREST TAB
switchTab "Dark Forest"
# collectBounties
arenaOfHeroesQuick
legendsTournament
openTower
kingsTower "1"

# RANHORN TAB
switchTab "Ranhorn"
guildHunts
# twistedRealmBoss #12-40 required
storeBuyDust

# CAMPAIGN TAB
switchTab "Campaign"
lootAfkChest
collectQuestChests

# Load second character
switchCharacter "2"
openMenu

# CAMPAIGN TAB
switchTab "Campaign"
lootAfkChest
collectMail
collectFriendsAndMercenaries
fastRewards
attemptCampaign "2"

# DARK FOREST TAB
switchTab "Dark Forest"
collectBounties
arenaOfHeroes
legendsTournament
openTower
kingsTower "1"

# RANHORN TAB
switchTab "Ranhorn"
guildHunts
# twistedRealmBoss #12-40 required
storeBuyDust

# CAMPAIGN TAB
switchTab "Campaign"
lootAfkChest
collectQuestChests

switchCharacter "1"

echo $GREEN"End of script!"$NC
closeApp
exit 0
