#!/system/bin/sh

# --- Variables --- #
# CONFIG: Modify accordingly to your game!
victory=false
TIMER=0
COUNTER=0
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
pvpEvent=false

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
    sleep 1
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
    # echo "RGB: $RGB"
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
        # switchApp
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
  # Loops until the game has launched
  getColor 1050 1800
  while [ "$RGB" != "493018" ]; do
      sleep 1
      getColor 1050 1800
  done
  sleep 1
}

# Switches to another character. Params: character slot (1, 2 or 3)
function switchCharacter() {
    echo $CYAN"Checking loaded character"$NC
    case "$1" in
    "1")
        #Press Profile
        input tap 120 100
        sleep 1
        #Press Settings
        input tap 650 1675
        sleep 1
        #Press Server
        input tap 300 500
        sleep 1
        #Press Slot 1
        input tap 550 550
        sleep 1
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
          sleep 1
        fi
        verifyRGB 1050 1800 493018 $GREEN"Character checked."$NC
        echo
        ;;
    "2")
        #Press Profile
        input tap 120 100
        sleep 1
        #Press Settings
        input tap 650 1675
        sleep 1
        #Press Server
        input tap 300 500
        sleep 1
        #Press Slot 3
        input tap 550 750
        sleep 1
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
          sleep 1
        fi
        verifyRGB 1050 1800 493018 $GREEN"Character checked."$NC
        echo
        ;;
    "3")
        #Press Profile
        input tap 120 100
        sleep 1
        #Press Settings
        input tap 650 1675
        sleep 1
        #Press Server
        input tap 300 500
        sleep 1
        #Press Slot 3
        input tap 550 950
        sleep 1
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
          sleep 1
        fi
        verifyRGB 1050 1800 493018 $GREEN"Character checked."$NC
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
        sleep 2
        verifyRGB 450 1775 cc9261 $PURPLE"Switched to the Campaign Tab."$NC
        echo
        ;;
    "Dark Forest")
        input tap 300 1850
        sleep 2
        verifyRGB 240 1775 d49a61 $PURPLE"Switched to the Dark Forest Tab."$NC
        echo
        ;;
    "Ranhorn")
        input tap 110 1850
        sleep 2
        verifyRGB 20 1775 d49a61 $PURPLE"Switched to the Rahorn Tab."$NC
        echo
        ;;
    *)
        echo $RED"Failed to switch to another Tab."$NC
        exit 1
        ;;
    esac
}

# Checks for a battle to finish. Params: Seconds
function waitForBattleToFinish() {
    # echo "Waiting for battle to finish"
    sleep "$1"
    let "TIMER=0"
    while [ $TIMER -lt 90 ]; do
      # echo "Checking.. " $TIMER
      getColor 160 1150
      # echo "Def " $RGB
      if [ "$RGB" = "8191aa" ]; then
        echo $ORANGE"  Defeat!"$NC
        return
      fi
      getColor 420 380
      # echo "Vic " $RGB
      if [ "$RGB" = "ca9c5d" ] || [ "$RGB" = "4b3a23" ]; then
        echo $LGREEN"  Victory!"$NC
        return
      fi
      let "TIMER=TIMER+1"
      sleep 1
    done
    echo $RED"Battle status timer expired!"$NC
}

# Loots afk chest
function lootAfkChest() {
    echo $CYAN"Attempting to loot AFK chest."$NC
    # Click chest
    sleep 1
    input tap 550 1500
    sleep 1
    # Click claim
    input tap 700 1350
    sleep 1
    # Close Window twice, in case we have level up window
    input tap 550 1850
    sleep 1
    input tap 550 1850
    sleep 1
    # VerifyRGB with the top left of the campaign button
    wait
    verifyRGB 1050 1800 493018 $GREEN"AFK Chest looted successsfully."$NC
    echo
}

# Attempts campaign flag, params: 1 to load and close for daily quest, 2 to attempt until victory/defeat, 3 to repeat until victory
function attemptCampaign() {
    case "$1" in
    "1")
        echo $CYAN"Loading campaign level for daily quest."$NC
        # Press Begin
        input tap 550 1650
        sleep 1

        # Check for 'boss' text in enemy formation
        getColor 550 740
        if [ "$RGB" = "f1d79f" ]; then
            input tap 550 1450
        fi

        sleep 2
        # Press begin battle
        input tap 550 1850
        sleep 2

        # Press Pause
        input tap 80 1460
        wait
        # Press Exit battle
        input tap 230 960

        # VerifyRGB with the top left of the campaign button
        wait
        verifyRGB 1050 1800 493018 $GREEN"Campaign level loaded successfully."$NC
        echo
        ;;
    "2")
        echo $CYAN"Attempting campaign flag."$NC
        sleep 1
        # Press Begin
        input tap 550 1650
        sleep 1

        # Check for 'boss' text in enemy formation
        getColor 550 740
        if [ "$RGB" = "f1d79f" ]; then
            input tap 550 1450
        fi

        sleep 2
        # Press begin battle
        input tap 550 1850
        sleep 1

        waitForBattleToFinish 10

        # # Press Pause
        # input tap 80 1460
        # wait
        # # Press Exit battle
        # input tap 230 960

        # Press Exit battle
        input tap 230 960
        # Press Exit battle
        input tap 230 960


        # VerifyRGB with the top left of the campaign button
        wait
        verifyRGB 1050 1800 493018 $GREEN"Campaign flag attempted successfully."$NC
        echo
        ;;
    "3")
        echo $GREEN"Retrying until victorious.."$NC
        # Press Begin
        input tap 550 1650
        sleep 1

        # Check for 'boss' text in enemy formation
        getColor 550 740
        if [ "$RGB" = "f1d79f" ]; then
            input tap 550 1450
        fi

        sleep 2
        # Press begin battle
        input tap 550 1850
        sleep 1

        while [ $victory = "false" ]; do
          # echo "Checking.. " $TIMER
          getColor 160 1150
          # echo "Def " $RGB
          if [ "$RGB" = "8191aa" ]; then
            let "COUNTER=COUNTER+1"
            echo $RED"Defeat!"$NC "#"$COUNTER
            input tap 550 1500
            sleep 1
            attemptCampaign "3"
          fi
          getColor 420 380
          # echo "Vic " $RGB
          if [ "$RGB" = "ca9c5d" ] || [ "$RGB" = "4b3a23" ]; then
            let "COUNTER=0"
            echo $LGREEN"Victory! Moving to next flag.."$NC
            input tap 550 1500
            sleep 1
            attemptCampaign "3"
          fi
          sleep 1
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
  if [ "$RGB" == "ed1f06" ]; then
    # Press fast rewards
    input tap 950 1660
    wait
    # Check to make sure the gem icon isn't in the 'use' button, so we only claim the free usage
    getColor 624 1253
    if [ ! "$RGB" = "f8f8ff" ]; then
      # Click claim
      input tap 710 1260
      sleep 1
    fi
    # Click around campaign button
    input tap 560 1800
    wait
    # Click close
    input tap 400 1250
    # VerifyRGB with the top left of the campaign button
    wait
    verifyRGB 1050 1800 493018 $GREEN"Fast Rewards collected."$NC
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
  if [ "$RGB" == "fe2f1e" ]; then
    # Click mail icon
    input tap 960 630
    wait
    # Click collect
    input tap 790 1470
    wait
    # Click outside the menu twice to close?
    input tap 110 1850
    wait
    input tap 110 1850

    sleep 2
    verifyRGB 1050 1800 493018 $GREEN"Successfully collected Mail."$NC
    echo
  else
    echo $ORANGE"No mail notification found"$NC
    echo
  fi
}

# Collects and sends companion points, as well as auto lending mercenaries
function collectFriendsAndMercenaries() {
  echo $CYAN"Attempting companion point collection and mercenary lending."$NC
  getColor 1000 760
  if [ "$RGB" == "fd1f06" ]; then
    # Clic friends
    input tap 970 810
    sleep 1
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
    sleep 1
    # Click close button twice to exit
    input tap 70 1810

    input tap 70 1810
    wait
    verifyRGB 1050 1800 493018 $GREEN"Companion point collection and mercenary lending successfull."$NC
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
    sleep 1

    #Select Solo bounties
    input tap 650 1700
    sleep 1
    #Select Dispatch
    input tap 350 1550
    sleep 1
    #Select Confirm
    input tap 550 1540
    sleep 1
    #Select Collect All
    input tap 850 1550
    sleep 1

    #Select Team bounties
    input tap 950 1700
    sleep 1
    #Select Dispatch
    input tap 350 1550
    sleep 1
    #Select Confirm
    input tap 550 1540
    sleep 1
    #Select Collect All
    input tap 850 1550
    sleep 1

    #Tap back
    input tap 70 1810

    wait
    verifyRGB 1050 1800 493018 $GREEN"Successfully finished Bounties."$NC
    echo
}

# Does the daily arena of heroes battles
function arenaOfHeroes() {
    echo $CYAN"Attempting Arena of Heroes battles."$NC
    #Click "Arena of Heroes"
    input tap 740 1050
    sleep 1
    if [ "$pvpEvent" == false ]; then
        #Click first card in list
        input tap 550 450
    else
        # Click second card in list
        input tap 550 900
    fi
    sleep 1
    #Click Record and close to clear the notification
    input tap 1000 1800
    sleep 1
    input tap 980 410
    sleep 1
    #Click Challenge
    input tap 540 1800
    sleep 1

    getColor 813 691 #Free pixel + color
    if [ "$RGB" = "fef7ec" ]; then
      sleep 1
      while [ "$RGB" = "fef7ec" ]; do
        echo $LGREEN"  Free arena battle found"$NC
        #Select second lowest slot
        input tap 820 1225
        sleep 1
        #Click 'Begin Battle'
        input tap 550 1850
        #Wait for battle to finish
        waitForBattleToFinish 15
        #Tap to clear loot
        input tap 550 1550
        wait
        #Tap to close Victory/Defeat screen
        input tap 550 1550
        sleep 1
        #we need to be back at the challenge menu again before we check 'free' pixel
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

    sleep 1
    verifyRGB 1050 1800 493018 $GREEN"Arena of Heroes successfully checked."$NC
    echo
}

# Does the daily Legends tournament battles
function legendsTournament() {
    echo $CYAN"Attempting Legends Tournament battles."$NC
    #Press Arena of Heroes
    input tap 740 1050
    sleep 1
    if [ "$pvpEvent" == false ]; then
        #Second slot
        input tap 550 900
    else
        #Third Slot
        input tap 550 1450
    fi
    sleep 1
    #Collect Gladiator Coins
    input tap 550 280
    sleep 2
    #Clear Gladiator coins loot overlay
    input tap 550 1550
    sleep 1
    #Open and close 'Record'
    input tap 1000 1800
    input tap 990 380
    wait

    #Press Challenge
    input tap 550 1840
    sleep 1

    getColor 790 728 #Free pixel + color
    if [ "$RGB" = "ffffff" ]; then
      sleep 1
      while [ "$RGB" = "ffffff" ]; do
        echo $LGREEN"  Free legends battle found"$NC
        #Select lowest slot
        input tap 800 1150
        sleep 1
        #Click 'Next Team twice'
        input tap 550 1850
        wait
        input tap 550 1850
        sleep 1
        #Click Begin Battle
        input tap 550 1850
        #Make sure we're loaded then skip
        sleep 2
        input tap 870 1450
        sleep 2
        #Tap to close Victory/Defeat screen
        input tap 550 1850
        sleep 1
        #Press Challenge
        input tap 550 1840
        sleep 2
        #we need to be back at the challenge menu again before we check 'free' pixel
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
    sleep 1

    verifyRGB 1050 1800 493018 $GREEN"Legends Tournament sucessfully checked."$NC
    echo
}

# Battles once in the kings tower
function kingsTower() {
    echo $CYAN"Attempting King's tower for daily quest."$NC
    #Click King's Tower
    input tap 500 870
    sleep 1
    #Click non-faction tower
    # input tap 550 900
    # sleep 1
    #Click "Challenge"
    input tap 540 1350
    sleep 1
    #Click begin battle
    input tap 550 1850
    sleep 1

    waitForBattleToFinish 10

    # #Click Pause
    # input tap 80 1460
    # wait
    #Click Exit battle
    input tap 230 960
    wait
    #Click back arrow
    input tap 70 1810
    #Below is if you have faction towers unlocked
    # wait
    # input tap 70 1810

    sleep 1
    verifyRGB 1050 1800 493018 $GREEN"Kings Tower attempted successfully."$NC
    echo
}

# Battles against Guild bosses
function guildHunts() {
    echo $CYAN"Attempting Guild Hunts."$NC
    #Press Guild Hall
    input tap 380 360
    sleep 3
    #Press Guild Hunting
    input tap 290 860
    sleep 1
    #Press Challenge
    input tap 540 1800
    sleep 2

    #Now we check for the VS text at the top of the screen to see if Wrizz is active
    getColor 600 80
    # echo "Wrizz VS: " + $RGB
    if [ "$RGB" == "eedd9e" ] || [ "$RGB" == "efdd9e" ]; then
      while [ "$RGB" == "eedd9e" ] || [ "$RGB" == "efdd9e" ]; do
        echo $LGREEN"  Wrizz active, battling.."$NC
        # Clic Begin Battles
        input tap 550 1850

        #wait for battle end
        waitForBattleToFinish 40

        # Click collect
        input tap 540 1800
        sleep 2
        #Press Challenge
        input tap 540 1800
        sleep 2
        #Check for VS text again
        getColor 600 80
      done
    else
      echo $ORANGE"  Wrizz checked"$NC
    fi

    # Soren

    #Click the right -> arrow
    input tap 970 890
    sleep 1

    #Press Challenge
    input tap 540 1800
    sleep 2

    #Check for available but not unlocked notice
    getColor 330 725
    if [ "$RGB" == "83613f" ]; then
      echo $ORANGE"  Soren unlock notice found, skipping.."$NC
      input tap 550 1250
      sleep 1

      #Click back arrow twice
      input tap 70 1810
      wait
      input tap 70 1810

      sleep 1
      verifyRGB 1050 1800 493018 $GREEN"Guild Hunts battled successfully."$NC
      echo
      return
    fi

    #Now we check for the VS text at the top of the screen to see if Soren is active
    getColor 600 80
    # echo "Soren VS: " $RGB
    if [ "$RGB" == "eedd9e" ] || [ "$RGB" == "efdd9e" ]; then
      echo $LGREEN"Soren active, battling.."$NC
      while [ "$RGB" == "eedd9e" ] || [ "$RGB" == "efdd9e" ]; do
        # Click Begin Battles
        input tap 550 1850
        #wait for battle to finish
        waitForBattleToFinish 40
        # Click collect
        input tap 540 1800
        sleep 2
        #Press Challenge
        input tap 540 1800
        sleep 2
        #Check for VS text again
        getColor 600 80
      done
    fi
    echo $ORANGE"  Soren checked"$NC

    #Click back arrow twice
    input tap 70 1810
    wait
    input tap 70 1810

    sleep 1
    verifyRGB 1050 1800 493018 $GREEN"Guild Hunts battled successfully."$NC
    echo
}

# Battles against the Twisted Realm Boss
function twistedRealmBoss() {
    # TODO: Choose if 2x or not
    # TODO: Choose a formation (Would be dope!)
    ## For testing only! Keep as comment ##
    # input tap 380 360
    # sleep 3
    ## End of testing ##
    input tap 820 820
    sleep 1
    input tap 550 1850
    sleep 1
    input tap 550 1850

    # Sart checking for a finished Battle after 40 seconds
    waitForBattleToFinish 50

    sleep 1
    input tap 550 800
    sleep 3
    input tap 550 800
    wait

    # TODO: Repeat battle if variable says so

    input tap 70 1810
    wait
    input tap 70 1810

    sleep 1
    verifyRGB 20 1775 d49a61 "Successfully battled Twisted Realm Boss."
}

# Buys daily dust from ths store
function storeBuyDust() {
    echo $CYAN"Attempting to purchase daily dust from the store."$NC
    #Click on the shop
    input tap 330 1650
    sleep 1
    #Click on dust top left
    #TODO Add verification
    getColor 175 840
    echo "  Dust colour found: " $RGB
    if [ "$RGB" == "bb81dd" ] || [ "$RGB" == "bb87dd" ] || [ "$RGB" == "bb7edd" ]  ||  [ "$RGB" == "bb7dde" ]; then
      input tap 170 840
      wait
      #Click Purchase (Two clicks it can be in two locations)
      input tap 550 1420
      input tap 550 1550
      sleep 1
      #Close loot window
      input tap 550 1220
      wait
    fi
    #Back arrow to exit shop
    input tap 70 1810

    sleep 1
    verifyRGB 1050 1800 493018 $GREEN"Daily Dust purchase attempted successfully."$NC
    echo
}

# Collects
function collectQuestChests() {
  echo $CYAN"Attempting to collect daily quest chests."$NC
  #TODO Check for daily/weekly/campaign
  getColor 1000 200
  # if [ "$RGB" == "f53a29" ]; then
    # Click quests
    input tap 960 250
    sleep 1
    # Click Dailies
    input tap 400 1650
    sleep 1

    # Collect Quests loop
    getColor 700 670
    while [ "$RGB" == "7cfff3" ]; do
      # If blue 'completed' bar found, click collect
        echo $LGREEN"  Quest found, collecting.."$NC
        input tap 930 680
        wait
        getColor 700 670
    done

    input tap 330 430
    wait
    input tap 580 600
    input tap 500 430
    wait
    input tap 580 600
    input tap 660 430
    wait
    input tap 580 600
    input tap 830 430
    wait
    input tap 580 600
    input tap 990 430
    wait
    input tap 580 600
    wait
    input tap 70 1650
    sleep 1

    verifyRGB 1050 1800 493018 $GREEN"Successfully collected daily Quest chests."$NC
    echo
}

# TODO: Make it pretty
# RED='\033[0;34m'
# NC='\033[0m' # No Color
# printf "I ${RED}love${NC} Stack Overflow\n"

# Test function (X, Y, amountTimes, waitTime)
# test 700 670 3 0.5

# --- Script Start --- #
echo
echo $GREEN"Script started, waiting for game to load.."$NC
closeApp
sleep 0.5
startApp
sleep 10

#Wait until game is active
waitUntilGameActive

echo $GREEN"Game loaded! starting activities.."$NC
echo

# Load first character
switchCharacter "1"
openMenu

# CAMPAIGN TAB
switchTab "Campaign"
lootAfkChest
fastRewards
collectMail
collectFriendsAndMercenaries
attemptCampaign "2"

# DARK FOREST TAB
switchTab "Dark Forest"
collectBounties #Auto-fill required
arenaOfHeroes #Edit for quick battle when unlocked
legendsTournament
kingsTower #Changed for faction towers not unlocked

# RANHORN TAB
switchTab "Ranhorn"
guildHunts
# twistedRealmBoss #12-40 required
storeBuyDust # TODO Buy elite soulstone as well

# CAMPAIGN TAB
switchTab "Campaign"
lootAfkChest
collectQuestChests

# # Load second character
# switchCharacter "2"
# openMenu
#
# # CAMPAIGN TAB
# switchTab "Campaign"
# lootAfkChest
# fastRewards
# collectMail
# collectFriendsAndMercenaries
# attemptCampaign "2"
#
# # DARK FOREST TAB
# switchTab "Dark Forest"
# # collectBounties #Auto-fill required
# arenaOfHeroes #Edit for quick battle when unlocked
# # legendsTournament
# kingsTower #Changed for faction towers not unlocked
#
# # RANHORN TAB
# switchTab "Ranhorn"
# guildHunts
# # twistedRealmBoss #12-40 required
# storeBuyDust # TODO Buy elite soulstone as well
#
# # CAMPAIGN TAB
# switchTab "Campaign"
# lootAfkChest
# collectQuestChests
#
# switchCharacter "1"

echo $GREEN"End of script!"$NC
exit 0
