var/datum/configuration/config = null

var/host = null
var/join_motd = null
var/station_name = "NSS Athena"
var/game_version = "Custom Beat!Code"
var/changelog_hash = md5('html/changelog.html') //used to check if the CL changed
var/game_year = (text2num(time2text(world.realtime, "YYYY")) + 544)

var/aliens_allowed = 1
var/traitor_scaling = 1
//var/goonsay_allowed = 0
var/dna_ident = 1
var/abandon_allowed = 0
var/enter_allowed = 1
var/guests_allowed = 1
var/shuttle_frozen = 0
var/shuttle_left = 0
var/tinted_weldhelh = 1
var/mouse_respawn_time = 5 //Amount of time that must pass between a player dying as a mouse and repawning as a mouse. In minutes.

// Command to run if shutting down (SHUTDOWN_ON_REBOOT) instead of rebooting
// It's defined here as a global because this is a hilariously bad thing to have on the easily-edited config datum
var/global/shutdown_shell_command

// Also global to prevent easy edits
var/global/python_path = "" //Path to the python executable.  Defaults to "python" on windows and "/usr/bin/env python2" on unix

// Debug is used exactly once (in living.dm) but is commented out in a lot of places.  It is not set anywhere and only checked.
// Debug2 is used in conjunction with a lot of admin verbs and therefore is actually legit.
var/Debug = 0	// global debug switch
var/Debug2 = 1   // enables detailed job debug file in secrets

//This was a define, but I changed it to a variable so it can be changed in-game.(kept the all-caps definition because... code...) -Errorage
var/MAX_EX_DEVESTATION_RANGE = 3
var/MAX_EX_HEAVY_RANGE = 7
var/MAX_EX_LIGHT_RANGE = 14
var/MAX_EX_FLASH_RANGE = 14
var/MAX_EX_FLAME_RANGE = 14

//Random event stuff, apparently used
var/eventchance = 10 //% per 5 mins
var/event = 0
var/hadevent = 0
var/blobevent = 0

//Medals hub related variables
var/global/medal_hub = null
var/global/medal_pass = " "
var/global/medals_enabled = TRUE	//will be auto set to false if the game fails contacting the medal hub to prevent unneeded calls.
