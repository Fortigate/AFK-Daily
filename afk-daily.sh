#!/system/bin/sh

# --- Variables --- #
# CONFIG: Modify accordingly to your game!
canOpenSoren=false
totalAmountDailyQuests=8
endAtSoren=true
victory=false
# TODO: End at legends torunament to bet
# TODO: Let player choose VIP and script knows how often

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
    exit
}

# Default wait time for actions
function wait() {
    sleep 0.5
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
        echo "VerifyRGB: Failure! Expected "$3", but got "$RGB" instead."
        echo ""
        echo "$5"
        # switchApp
        exit
    else
        echo "$4"
    fi
}

# Switches to another character. Params: character slot
function switchCharacter() {
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
          echo "Changing to Slot 1"
          #Click confirm
          input tap 700 1250
          sleep 20
        else
          echo "No server change necessary"
          #Tap back
          input tap 70 1810
          wait
          #Tap back
          input tap 70 1810
          sleep 1
        fi
        #If above = popup we need to change, else we go back to the main menu
        verifyRGB 450 1775 cc9261 "Server checked."
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
          echo "Changing to Slot 2"
          #Click confirm
          input tap 700 1250
          sleep 20
        else
          echo "No server change necessary"
          #Tap back
          input tap 70 1810
          wait
          #Tap back
          input tap 70 1810
          sleep 1
        fi
        #If above = popup we need to change, else we go back to the main menu
        verifyRGB 450 1775 cc9261 "Server checked."
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
          echo "Changing to Slot 3"
          #Click confirm
          input tap 700 1250
          sleep 20
        else
          echo "No server change necessary"
          #Tap back
          input tap 70 1810
          wait
          #Tap back
          input tap 70 1810
          sleep 1
        fi
        #If above = popup we need to change, else we go back to the main menu
        verifyRGB 450 1775 cc9261 "Server checked."
        ;;
    *)
        echo "Server check failed."
        exit
        ;;
    esac
}

# Switches to another tab. Params: Tab name
function switchTab() {
    case "$1" in
    "Campaign")
        input tap 550 1850
        wait
        verifyRGB 450 1775 cc9261 "Successfully switched to the Campaign Tab."
        ;;
    "Dark Forest")
        input tap 300 1850
        wait
        verifyRGB 240 1775 d49a61 "Successfully switched to the Dark Forest Tab."
        ;;
    "Ranhorn")
        input tap 110 1850
        wait
        verifyRGB 20 1775 d49a61 "Successfully switched to the Rahorn Tab."
        ;;
    *)
        echo "Failed to switch to another Tab."
        exit
        ;;
    esac
}

# Checks for a battle to finish. Params: Seconds
function waitForBattleToFinish() {
    sleep "$1"
    while [ "$RGB" != "ca9c5d" ]; do
        sleep 1
        getColor 420 380
    done
}

# Repeat a battle for as long as totalAmountArenaTries
function quickBattleGuildBosses() {
    local COUNT=0
    until [ "$COUNT" -ge "$totalAmountGuildBossTries" ]; do
        input tap 710 1840
        wait
        input tap 720 1300
        sleep 1
        input tap 550 800
        input tap 550 800
        sleep 1
        ((COUNT = COUNT + 1)) # Increment
    done
}

# Loots afk chest
function lootAfkChest() {
    # Click chest
    sleep 1
    input tap 550 1500
    sleep 1
    # Click claim
    input tap 700 1350
    sleep 1
    # Close Window
    input tap 550 1850
    sleep 1
    # VerifyRGB with the top left of the campaign button
    wait
    verifyRGB 450 1775 cc9261 "AFK Chest looted."
}

# Challenges a boss in the campaign
function challengeBoss() {
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

    # Press Pause
    input tap 80 1460
    wait
    # Press Exit battle
    input tap 230 960
    # VerifyRGB with the top left of the campaign button
    wait
    verifyRGB 450 1775 cc9261 "Challenged boss in campaign."
}

# Challenges a boss in the campaign
function challengeBossRetry() {
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
      getColor 160 1150
      # While defeat text not found
      while [ ! "$RGB" = "8191aa" ]; do
          getColor 160 1150
          sleep 1
      done

      # If defeat text found click retry
      if [ "$RGB" = "8191aa" ]; then
        input tap 550 1700
        sleep 1
        # Press begin battle
        input tap 550 1850
        sleep 1
      fi
    done
}

# Collects fast rewards (Only at campaign page, no error checking)
function fastRewards() {
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
    verifyRGB 450 1775 cc9261 "Fast Rewards collected."
  else
    echo "No fast rewards notication badge found"
  fi
}

# Collects and sends companion points, as well as auto lending mercenaries
function collectFriendsAndMercenaries() {
  # TODO: Check if its necessary to send mercenaries
  getColor 1000 760
  if [ "$RGB" == "fd1f06" ]; then
    # Clic friends
    input tap 970 810
    sleep 1
    # Click send and recieve
    input tap 930 1600
    wait
    # Click Mercenaries
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
    verifyRGB 450 1775 cc9261 "Sent and recieved companion points, as well as auto lending mercenaries."
  else
    echo "No Friends notification badge found"
  fi
}

# Starts Solo bounties
function soloBounties() {
    input tap 600 1320
    sleep 1

    # Check if there are bounties to collect
    getColor 650 520
    until [ "$RGB" != "80f6ef" ]; do
        input tap 915 470
        sleep 0.5
        getColor 650 520
    done

    input tap 915 470
    wait
    input tap 350 1160
    input tap 750 1160
    input tap 915 680
    wait
    input tap 350 1160
    input tap 750 1160
    input tap 915 890
    wait
    input tap 350 1160
    input tap 750 1160
    input tap 915 1100
    wait
    input tap 350 1160
    input tap 750 1160
    input tap 915 1310
    wait
    input tap 350 1160
    input tap 750 1160
    input tap 915 1520
    wait
    input tap 350 1160
    input tap 750 1160
    input swipe 550 1100 550 800 500
    wait
    input tap 915 1350
    wait
    input tap 350 1160
    input tap 750 1160
    input tap 915 1560
    wait
    input tap 350 1160
    input tap 750 1160

    wait
    verifyRGB 650 1820 ac5714 "Successfully finished Solo Bounties."
}

# Starts Team Bounties
function teamBounties() {
    ## For testing only! Keep as comment ##
    # input tap 600 1320
    # sleep 1
    ## End of testing ##
    input tap 910 1770
    wait

    # Check if there are bounties to collect
    getColor 650 520
    until [ "$RGB" != "80f6ef" ]; do
        input tap 930 500
        sleep 0.5
        getColor 650 520
    done

    input tap 930 500
    wait
    input tap 350 1160
    input tap 750 1160
    wait
    input tap 930 710
    wait
    input tap 350 1160
    input tap 750 1160
    wait
    input tap 70 1810

    wait
    verifyRGB 240 1775 d49a61 "Successfully finished Team Bounties."
}

# Does the daily arena of heroes battles
function arenaOfHeroes() {
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
        echo "Free arena battle found"
        #Select lowest slot
        input tap 820 1400
        sleep 1
        #Click 'Begin Battle'
        input tap 550 1850
        #Wait 90 seconds as I can't skip
        sleep 90
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
      echo "No free arena battles found"
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
    verifyRGB 240 1775 d49a61 "Successfully battled at the Arena of Heroes."
}

# Does the daily Legends tournament battles
function legendsTournament() {
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

    # Repeat a battle for as long as totalAmountArenaTries
    #TODO Replace with 'Free' text detection

    #Press Challenge
    input tap 550 1840
    sleep 1

    getColor 790 728 #Free pixel + color
    if [ "$RGB" = "ffffff" ]; then
      sleep 1
      while [ "$RGB" = "ffffff" ]; do
        echo "Free legends battle found"
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
      echo "No free legends battles found"
    fi

    #Click back arrow three times
    input tap 70 1810
    wait
    input tap 70 1810
    wait
    input tap 70 1810

    wait
    verifyRGB 240 1775 d49a61 "Successfully battled at the Legends Tournament."
}

# Battles once in the kings tower
function kingsTower() {
    input tap 500 870
    sleep 1
    input tap 550 900
    sleep 1
    input tap 540 1350
    sleep 1
    input tap 550 1850
    sleep 1
    input tap 80 1460
    input tap 230 960
    wait
    input tap 70 1810
    #Below is if you have faction towers unlocked
    # wait
    # input tap 70 1810

    wait
    verifyRGB 240 1775 d49a61 "Successfully battled at the Kings Tower."
}

# Battles against Guild bosses
function guildHunts() {
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
    if [ "$RGB" == "eedd9e" ]; then
      while [ "$RGB" == "eedd9e" ]; do
        # Clic Begin Battles
        input tap 550 1850
        sleep 100
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

    # Soren

    #Click the right -> arrow
    input tap 970 890
    sleep 1

    #Press Challenge
    input tap 540 1800
    sleep 2

    #Now we check for the VS text at the top of the screen to see if Wrizz is active
    getColor 600 80
    if [ "$RGB" == "eedd9e" ]; then
      while [ "$RGB" == "eedd9e" ]; do
        # Clic Begin Battles
        input tap 550 1850
        sleep 100
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

    #Click back arrow twice
    input tap 70 1810
    wait
    input tap 70 1810

    sleep 1
    verifyRGB 450 1775 58371f "Successfully battled Guild Hunts."
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
    #Click on the shop
    input tap 330 1650
    sleep 1
    #Click on dust top left
    #TODO Add verification
    getColor 175 840
    echo $RGB
    if [ "$RGB" == "bb81dd" ] || [ "$RGB" == "bb87dd" ]; then
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

    wait
    verifyRGB 20 1775 d49a61 "Successfully bought daily Dust from the store."
}

# Collects
function collectQuestChests() {
  getColor 1000 200
  # if [ "$RGB" == "f53a29" ]; then
    # Click quests
    input tap 960 250
    sleep 1

    # Collect Quests loop
    getColor 700 670
    while [ "$RGB" == "7cfff3" ]; do
      # If blue 'completed' bar found, click collect
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

    verifyRGB 20 1775 54331a "Successfully collected daily Quest chests."
}

# Collects mail
collectMail() {
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
    wait
    verifyRGB 20 1775 d49a61 "Successfully collected Mail."
  else
    echo "No mail notification found"
  fi
}

# Says Hi to Soren
function visitSoren() {
    switchTab "Ranhorn"
    input tap 380 360
    sleep 3
    input tap 290 860
    sleep 1
    input tap 970 890

    wait
    echo
    verifyRGB 540 1220 aa42d0 "Go back to the game to say Hi to Soren!" "Somehow I didn't manage to say Hi to Soren... Guess he got scared."
}

# TODO: Make it pretty
# RED='\033[0;34m'
# NC='\033[0m' # No Color
# printf "I ${RED}love${NC} Stack Overflow\n"

# Test function (X, Y, amountTimes, waitTime)
# test 700 670 3 0.5

# --- Script Start --- #
echo "Starting script..."
echo
closeApp
sleep 0.5
startApp
sleep 10

# Loops until the game has launched
while [ "$RGB" != "cc9261" ]; do
    sleep 1
    getColor 450 1775
done
sleep 1

input tap 970 380 # Open menu for friends, etc
wait

# challengeBossRetry

# echo "Caching zones"
# switchTab "Campaign"
# sleep 1
# switchTab "Dark Forest"
# sleep 1
# switchTab "Ranhorn"
# sleep 1

echo "Starting activities"
# CAMPAIGN TAB
switchTab "Campaign"
lootAfkChest #Done
fastRewards #Done
collectMail #Done
collectFriendsAndMercenaries #Done
challengeBoss #Done
#
# # DARK FOREST TAB
switchTab "Dark Forest"
# # soloBounties #Auto-fill required
# # teamBounties #Auto-fill required
arenaOfHeroes #Edit for quick battle when unlocked
legendsTournament #Done
kingsTower #Changed for faction towers not unlocked

# RANHORN TAB
switchTab "Ranhorn"
guildHunts #Done
# twistedRealmBoss #12-40 required
storeBuyDust # TODO: Verification / Buy elite soulstone as well

# CAMPAIGN TAB
switchTab "Campaign"
lootAfkChest #Done
collectQuestChests #Done

echo
echo "End of script!"
exit
