#include maps\_utility;
#include common_scripts\utility;
#include maps\_zombiemode_utility;

/*---------------------------------------------------------------------------
	Init
---------------------------------------------------------------------------*/

init()
{
	// flag init
	flag_init("manualServerInit");
	test_flag();

	// Feature init
	level.getPlayerFeaturePressed = [];
	level thread isUnstableServer();

	//level waittill("isUnstableServer", );

	if (isManagedServer())
	{
		onCommon();

		if (flag("isTestServer"))
		{
			thread onTest();
		}
		else 
		{
			thread onStable();
		}
	}

	// init complete
	flag_set("manualServerInit");
}

/*---------------------------------------------------------------------------
	Server Profiles
---------------------------------------------------------------------------*/

onCommon()
{
	level thread preventServerGoingStale();
	level thread onPlayerConnectRegisterCommandKeys();
}

onTest()
{
	// Get Money Command
	addFeatureForKey(0, "Give Money", scripts\sp\zom\nex_drop_points::givePoints);

	// Debug Commands
	addFeatureForKey(1, "What server?", ::printHost);

	// Zomb Count
	scripts\sp\zom\zomb_count
		::manualInit();

	// Easter Egg
	scripts\sp\zom\nex_ee
		::manualInit();	
	
	// Welcome Message
	messages = [];
	messages[0] = scripts\sp\zom\nex_welcome
		::welcomeMessageStruct("^2This is a under active development ^1TEST SERVER^2 & may restart ^1anytime^2.", 3);
	messages[1] = scripts\sp\zom\nex_welcome
		::welcomeMessageStruct("^3This Server may be unstable", 1.5);
	messages[2] = scripts\sp\zom\nex_welcome
		::welcomeMessageStruct("^0Features:^7 (Solo) Moon Easter Egg Enabler, Zombie Counter,^8 Debug Point Giver ^1(Press 7)", 2);
	scripts\sp\zom\nex_welcome::manualInit(messages);
	
}

onStable()
{
	// Zomb Count
	scripts\sp\zom\zomb_count
		::manualInit();

	// Easter Egg
	scripts\sp\zom\nex_ee
		::manualInit();	
	
	// Welcome Message
	messages = [];
	messages[0] = scripts\sp\zom\nex_welcome
		::welcomeMessageStruct("^2 Welcome to NexRX Stable Server. Active Development in Progress", 3);
	messages[1] = scripts\sp\zom\nex_welcome
		::welcomeMessageStruct("^0Features:^7 (Solo) Moon Easter Egg Enabler, Zombie Counter", 2);
	scripts\sp\zom\nex_welcome::manualInit(messages);
}


/*---------------------------------------------------------------------------
	Utils & Features
---------------------------------------------------------------------------*/

addFeatureForKey(key, name, pointer, args)
{
	level.getPlayerFeaturePressed[key] = functionStruct(name, pointer, args);
}

/*removeFeatureForKey(key)
{
	level.getPlayerFeaturePressed[key] = undefined;
}*/

preventServerGoingStale()
{
	for(;;)
	{
		waitTillNoPlayers();
		whileZeroPlayersDelayedQuitServer();
	}
}

printHost()
{
	self iPrintLnBold(getDvar("sv_hostname"));
}

/*---------------------------------------------------------------------------
	(Internal) Functions
---------------------------------------------------------------------------*/

test_flag()
{
	flag_init("isTestServer");

	serverTag = "[NexRX] Test"; // I manage scripts (init) manually with another script for all my servers. You can remove or keep this safely.
    flag_set("isTestServer", GetSubStr(getDvar("sv_hostname"), 0, serverTag.size) == serverTag);
}

whileZeroPlayersDelayedQuitServer() // make sure server does auto restart (pluto usually does)
{
	level endon("connecting"); level endon("connected");
	wait 60 * 20;
	executeCommand("quit"); // Depends on T5-GSC-Utils | Tried "fast_restart", throws unknown command
}

waitTillNoPlayers()
{
	level endon("game_end");

	for(;;)
	{
		if (get_players().size == 0) 
		{
			return;
		}
		level waittill("disconnect");
	}
}

isUnstableServer()
{
	unstablePort = 28960;
	currentPort = GetDvarInt("net_port");
	isSame = unstablePort == currentPort;
	level.isUnstableServer = isSame;
	wait 0.1;
	
	for (;;) {
		level notify("isUnstableServer", isSame);
		wait 1;
	}
}

onPlayerConnectRegisterCommandKeys()
{
	for (;;)
	{
		level waittill("connected", player);
		player thread scripts\sp\zom\nex_script_master::onPlayerPressedKey();
		player thread playerFixes();
	}
}

onPlayerPressedKey()
{
	self endon("disconnect");
	self.pressedCombo = 0;

	for(;;)
	{
		usePressed = self useButtonPressed();
		if (usePressed) 
		{ // combo multiplier
			self onUsedPressed();
		} 
		else if ( self actionslottwobuttonpressed()/*&& player.isAlive == true*/)
		{
				if (IsDefined(level.getPlayerFeaturePressed[0]) && 
					IsDefined(level.getPlayerFeaturePressed[0].args))
				{
					args = level.getPlayerFeaturePressed[0].args;
					[[level.getPlayerFeaturePressed[0].func]](args);
				}
				else if (IsDefined(level.getPlayerFeaturePressed[0]) && 
						 IsDefined(level.getPlayerFeaturePressed[0].func))
				{
					[[level.getPlayerFeaturePressed[0].func]]();
				}
		}
		else if(!usePressed && self.pressedCombo >= 1)
		{
			if (IsDefined(level.getPlayerFeaturePressed[self.pressedCombo]) && 
				IsDefined(level.getPlayerFeaturePressed[self.pressedCombo].func))
			{
				if (IsDefined(level.getPlayerFeaturePressed[self.pressedCombo].args))
				{
					args = level.getPlayerFeaturePressed[self.pressedCombo].args;
					[[level.getPlayerFeaturePressed[self.pressedCombo].func]](args);
				}
				else 
				{
					[[level.getPlayerFeaturePressed[self.pressedCombo].func]]();
				}
			}
			else 
			{
				self iprintlnbold("^1No Feature for " + self.pressedCombo + " Detected."); 
			}
			self.pressedCombo = 0;
		}

		wait .01;
    }
}

onUsedPressed()
{
	while (self useButtonPressed())
	{
		if ( self actionslottwobuttonpressed()/*&& player.isAlive == true*/)
		{
			self.pressedCombo += 1;

			numName = self.pressedCombo;
			if (IsDefined(level.getPlayerFeaturePressed[self.pressedCombo]) && 
				IsDefined(level.getPlayerFeaturePressed[self.pressedCombo].name))
			{
				numName = numName + " - " + level.getPlayerFeaturePressed[self.pressedCombo].name;
			}
			else 
			{
				numName = numName + " - " + "Nothing.";
			}

			self iprintlnbold("^4Command: ^5" + numName);
		}
		wait 0.04;
	}
}

testingScriptNex(pointer, arg)
{
	[[pointer]](arg);
}

functionStruct(name, pointer, args)
{
	toReturn = spawnStruct();
	toReturn.name = name;
	toReturn.func = pointer;
	toReturn.args = args;

	return toReturn;
}

foreachplayer(pointer)
{
	player = get_players(); //arr

	for (i = 0; i < player.size; i++) {
		[[pointer]](player[i]);
	}
}

playerFixes()
{
	if ( !isDefined(self.revive_hud) ) {
		self thread maps\_laststand::revive_hud_create();
	}
}

isManagedServer()
{
	serverTag = "[NexRX]";
	return GetSubStr(getDvar("sv_hostname"), 0, serverTag.size) == serverTag;
}

trackAlive()
{
	self endon("disconnect");

	self waittill( "spawned_player" );
	self.isAlive = true; // one of thes could cause laststand error when player downed (taken var name?)
	

	for(;;) 
	{
		self waittill_any( "fake_death", "death", "player_downed" ); // one of thes could cause laststand error when player downed
		self.isAlive = false; // if none of above then its probaly zomb_count.gsc (.alpha = 1)
		self waittill_any("spawned_player", "revived");
		self.isAlive = true;
	}
}