#include maps\_utility;
#include common_scripts\utility;
#include maps\_zombiemode_utility;
#include scripts\sp\zom\nex_hud;

/*---------------------------------------------------------------------------
	Init
---------------------------------------------------------------------------*/

init()
{
	initActionArrays();

	level.getPlayerFeaturePressed = [];

	onCommon();

	if (isTestServer())
	{
		thread onTest();
	}
	else 
	{
		thread onStable();
	}

	// init complete
	level notify("nex_script_master_initialised");
}

/*---------------------------------------------------------------------------
	Server Profiles
---------------------------------------------------------------------------*/

onCommon()
{
	level thread preventServerGoingStale();
	level thread onPlayerConnected();
}

onTest()
{
}

onStable()
{
	addOnAction("CONNECTED", functionStruct("Init PLayer Voting", scripts\sp\zom\nex_votes::initPlayer, undefined, true));

	// Get Money Command
	addFeatureForKey(0, "Give Money", scripts\sp\zom\nex_drop_points::givePointsDebug);

	// Drop Points
	scripts\sp\zom\nex_drop_points
		::manualInit();

	// Menu Init
	preUIInit();  // TODO! Make this an addition function for option index
	optionIndex = 0;
	level.menu["options"][optionIndex] = menuOptionStruct(0,0,"Drop Points", ::newMenu, 1); optionIndex++;
	level.menu["options"][optionIndex] = menuOptionStruct(0,1,"Server Votes (Beta)", ::newMenu, 2); optionIndex++;
	level.menu["options"][optionIndex] = menuOptionStruct(0,2,"-", ::test); optionIndex++;
	level.menu["options"][optionIndex] = menuOptionStruct(0,3,"-", ::test); optionIndex++;
	level.menu["options"][optionIndex] = menuOptionStruct(0,4,"-", ::test); optionIndex++;
	level.menu["options"][optionIndex] = menuOptionStruct(0,5,"-", ::test); optionIndex++;
	level.menu["options"][optionIndex] = menuOptionStruct(0,6,"-", ::test); optionIndex++; // The number of main options detirms the max number of all submenu options. TODO fix that?

	level.menu["options"][optionIndex] = menuOptionStruct(1,0,"Drop 1K Points", scripts\sp\zom\nex_drop_points::dropPoints); optionIndex++;
	level.menu["options"][optionIndex] = menuOptionStruct(1,1,"Drop 5k Points", scripts\sp\zom\nex_drop_points::dropPointsMax); optionIndex++;
 
	level.menu["options"][optionIndex] = menuOptionStruct(2,0,"Vote Map", ::newMenu, 4); optionIndex++;
	level.menu["options"][optionIndex] = menuOptionStruct(2,1,"Vote Restart", scripts\sp\zom\nex_votes::voteRestart); optionIndex++;
	level.menu["options"][optionIndex] = menuOptionStruct(2,2,"View Map Votes", scripts\sp\zom\nex_votes::getMapVotes); optionIndex++;
	optionIndex = addMapsToVoteMenu(optionIndex, 3);

	// Zomb Count
	thread scripts\sp\zom\zomb_count
		::manualInit(); // and perk limit

	// Easter Egg
	thread scripts\sp\zom\nex_ee
		::manualInit();	


	// Larger Hordes
	thread scripts\sp\zom\nex_more_zombies
		::increaseZombiesLimit();

	// Custom powerups
	thread scripts\sp\zom\custom_power_ups
		::manualInit();
	thread scripts\sp\zom\custom_power_ups
		::include_all_powerups(); // Todo Test in game to see if you get the werider custom powerups
								  // Todo, make a proper hud (commands shoudl still be in print (because the scroll text feature))
	
	// Welcome Message
	messages = [];
	messages[0] = scripts\sp\zom\nex_welcome
		::welcomeMessageStruct("^2Welcome to NexRX Server", 3);
	messages[1] = scripts\sp\zom\nex_welcome
		::welcomeMessageStruct("^0Features:^7 (Solo) Moon Easter Egg Enabler, Zombie Counter, Drop Points, Vote Map/Restart", 2);
	messages[2] = scripts\sp\zom\nex_welcome
		::welcomeMessageStruct("           ^7 Perk limit Removed, Custom Powerups, Point Drop", 0);
	messages[3] = scripts\sp\zom\nex_welcome
		::welcomeMessageStruct("           ^7 Press ^37^7 to open the ^2Server Menu", 5);
	thread scripts\sp\zom\nex_welcome::manualInit(messages);

	registerUIControls();
}


/*---------------------------------------------------------------------------
	Features
---------------------------------------------------------------------------*/

godMode() 
{
	self.god = isNotDefinedThen(self.god, false);

	if (self.god) 
	{
		self disableInvulnerability();
		self.god = false;
	} 
	else 
	{
		self enableInvulnerability();
		self.god = true;
	}
}

addFeatureForKey(key, name, pointer, args)
{
	level.getPlayerFeaturePressed[key] = functionStruct(name, pointer, args);
}

/*removeFeatureForKey(key)
{
	level.getPlayerFeaturePressed[key] = undefined;
}*/

givePointsDebug()
{
	self.score = self.score + 5555;
}

preventServerGoingStale()
{
	thread playerPulseCheck();
	for(;;)
	{
		waitTillNoPlayers();
		quitAfterNoPlayers(60 * 20);
	}
}

printDvar(key)
{
	self iPrintLnBold(getDvar(key));
}

registerUIControls()
{
	addOnAction("UTILITY",  functionStruct("Navigate Menu", ::menuOpenElseNavigate, false, true));
	addOnAction("UTILITYALT",  functionStruct("Navigate Menu", ::menuNavigateIfOpen, false, true));
	addOnAction("USE", functionStruct("Select From Menu", ::menuSelect, undefined, true));
	//addOnAction("USE", functionStruct("Select From Menu", ::printHost, undefined, false));
	addOnAction("USEALT", functionStruct("Close Menu", ::menuClose, undefined, true));
}

/*---------------------------------------------------------------------------
	(Internal) Functions
---------------------------------------------------------------------------*/

addMapsToVoteMenu(index, subMenuIndex)
{
	index = isNotDefinedThen(index, 0);
	menuIndex = 0;
	mapName = getDvar("ui_mapname");

	if ("zombie_theater" != mapName) {
		level.menu["options"][index] = menuOptionStruct(subMenuIndex, menuIndex,"Kino der Toten", scripts\sp\zom\nex_votes::voteMap, "zombie_theater");
		menuIndex++; index++; }
	if ("zombie_pentagon" != mapName) {
		level.menu["options"][index] = menuOptionStruct(subMenuIndex, menuIndex,"Five", scripts\sp\zom\nex_votes::voteMap, "zombie_pentagon");
		menuIndex++; index++; }
	if ("zombie_cosmodrome" != mapName) {
		level.menu["options"][index] = menuOptionStruct(subMenuIndex, menuIndex,"Ascension", scripts\sp\zom\nex_votes::voteMap, "zombie_cosmodrome");
		menuIndex++; index++; }
	if ("zombie_coast" != mapName) {
		level.menu["options"][index] = menuOptionStruct(subMenuIndex, menuIndex,"Call of the Dead", scripts\sp\zom\nex_votes::voteMap, "zombie_coast");
		menuIndex++; index++; }
	if ("zombie_temple" != mapName) {
		level.menu["options"][index] = menuOptionStruct(subMenuIndex, menuIndex,"Shangri-La", scripts\sp\zom\nex_votes::voteMap, "zombie_temple");
		menuIndex++; index++; }
	if ("zombie_moon" != mapName) {
		level.menu["options"][index] = menuOptionStruct(subMenuIndex, menuIndex,"Moon", scripts\sp\zom\nex_votes::voteMap, "zombie_moon");
		menuIndex++; index++; }
	if ("zombie_cod5_asylum" != mapName) {
		level.menu["options"][index] = menuOptionStruct(subMenuIndex, menuIndex,"Verruckt", scripts\sp\zom\nex_votes::voteMap, "zombie_cod5_asylum");
		menuIndex++; index++; }
	if ("zombie_cod5_sumpf" != mapName) {
		level.menu["options"][index] = menuOptionStruct(subMenuIndex, menuIndex,"Shi No numa", scripts\sp\zom\nex_votes::voteMap, "zombie_cod5_sumpf");
		menuIndex++; index++; }
	if ("zombie_cod5_factory" != mapName) {
		level.menu["options"][index] = menuOptionStruct(subMenuIndex, menuIndex,"Der Rise", scripts\sp\zom\nex_votes::voteMap, "zombie_cod5_factory");
		menuIndex++; index++; }
	if ("zombie_cod5_prototype" != mapName) {
		level.menu["options"][index] = menuOptionStruct(subMenuIndex, menuIndex,"Nacht der Untoten", scripts\sp\zom\nex_votes::voteMap, "zombie_cod5_prototype");
		menuIndex++; index++; }

	return index;
}


/*			Add To onCommands			 */

addOnAction(action, functionStruct)
{
	if (isDefined(action) && isDefined(functionStruct))
	{
		level.onAction[action] = arrayAdd(level.onAction[action], functionStruct);
	}
}

removeOnAction(action, functionStruct, isShift)
{
	isShift = isNotDefinedThen(isShift, true);
	if (isDefined(action) && isDefined(functionStruct))
	{
		level.onAction[action] = arrayRemove(level.onAction[action], functionStruct, isShift);
	}
}

getActions(action)
{
	return level.onAction[action];
}

initActionArrays()
{
	level.onAction["USE"] = [];	 		//USE	  | F
	level.onAction["USEALT"] = [];		//USEALT  | Shift + F
	level.onAction["UTILITY"] = []; 	//UTILITY | 7
	level.onAction["UTILITYALT"] = [];  //UTILITY (Extra) | V
	level.onAction["CONNECTED"] = [];   // Automated on Player Connected
}

/////////////////////////////////////////


/*			Pointer Utilities			*/

runPointerSafely(pointer, args, shouldThread, debugOnFailure)  // todo, see if you need to make sure you don't go over args.
{
	debugOnFailure = isNotDefinedThen(debugOnFailure, false);

	if (IsDefined(pointer))
	{
		if (shouldThread)
		{
			self thread [[pointer]](args);
		}
		else
		{
			self [[pointer]](args);
		}
	} 
	else if (debugOnFailure)
	{
		self iprintlnbold("^1[NexRX] Debug - Feature option was not undefined."); 
	}
}

runFunctionStruct(functionStruct, debugOnFailure)
{
	self runPointerSafely(functionStruct.func, functionStruct.args, functionStruct.shouldThread,debugOnFailure);
}


forEachPlayer(runnable, args)
{
	player = get_players();
	
	if (isDefined(runnable.name) && isDefined(runnable.func))
	{
		for (i = 0; i < player.size; i++) {
			player[i] runFunctionStruct(runnable);
		}
	}
	else
	{
		for (i = 0; i < player.size; i++) {
			player[i] runPointerSafely(runnable, args);
		}
	}
}

/////////////////////////////////////////


/*			Looping/Detection/waiting Logic			*/

playerPulseCheck()
{
	for (;;)
	{
		wait 60 * 5;
		level notify ("playerPulseCheck");
	}
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
		level waittill_any("disconnect", "playerPulseCheck");
	}
}

onPlayerConnected()
{
	for (;;)
	{
		level waittill("connected", player);
		player thread onPlayerPressedKey();
		player thread playerFixes();
		player thread startingPlayersHUD();
		
		action = getActions("CONNECTED");
		for (i = 0; i < action.size; i++)
		{
			player runFunctionStruct(action[i]);
		}
	}
}

onPlayerPressedKey()
{
	self endon("disconnect");

	for(;;)
	{
		if( self sprintbuttonpressed() && self useButtonPressed() ) // IMPORTANT: The order matter a lot! Combos of keys should be first to avoid single key firing condition only firing.
		{
			self onActionPressed("USEALT");
			while ( self useButtonPressed() ) { wait 0.01; }
		}
		else if ( self actionslottwobuttonpressed() )
		{
			self onActionPressed("UTILITY");
			while ( self useButtonPressed() ) { wait 0.01; }
		}
		else if ( self meleebuttonpressed() )
		{
			self onActionPressed("UTILITYALT");
			while ( self meleebuttonpressed() ) { wait 0.01; }
		}
		else if(  self useButtonPressed() )
		{
			self onActionPressed("USE");
			while ( self useButtonPressed() ) { wait 0.01; }
		}
		wait .02;
    }
}

//////////////////////////////////////////////

onActionPressed(action)
{
	funcs = getActions(action);
	for (i = 0; i < funcs.size; i++)
	{
		self runFunctionStruct(funcs[i]);
	}
}

quitAfterNoPlayers(time) // make sure server does auto restart (pluto usually does)
{
	level endon("connected");
	wait time;
	executeCommand("quit"); // Depends on T5-GSC-Utils | Tried "fast_restart", throws unknown command
}

isTestServer(considerPort)
{
	unstablePort = 28960;
	serverTag = "[NexRX] Test"; // TODO make this configurable in a config init
    return GetSubStr(getDvar("sv_hostname"), 0, serverTag.size) == serverTag || (considerPort && unstablePort == GetDvarInt("net_port"));
}

playerFixes()
{
	if ( isNotDefined(self.revive_hud) ) {
		self thread maps\_laststand::revive_hud_create();
	}
}

/*			Structs			*/

functionStruct(name, pointer, args, shouldThread)
{
	toReturn = spawnStruct();
	toReturn.name = name;
	toReturn.func = pointer;
	toReturn.args = args;
	toReturn.shouldThread = isNotDefinedThen(shouldThread, false);

	return toReturn;
}

/////////////////////////////

/*			Array Utilities			*/

/** 
	Add's an element to the end of the array.

	Return The new array. Otherwise, undefined
 */
arrayAdd(arr, value)
{
	if (isArray(arr))
	{
		arr[arr.size] = value;
		return arr;
	}
	return undefined;
}

arrayRemove(arr, value, isShift)
{
	isShift = isNotDefinedThen(isShift, true);
	
	if (isDefined(arr))
	{
		for (i = 0; i < arr.size; i++)
		{
			if (arr[i] == value)
			{
				if (isShift)
				{
					originalCount = arr.size;
					for (ii = i; i < originalCount; i++)
					{
						if (ii == originalCount-1)
						{
							arr[ii] = undefined;
							return arr;
						}
						else
						{
							arr[ii] = arr[ii+1];
						}
					}
				}
				else
				{
					arr[i] = undefined;
					return arr;
				}
			}
		}
	}
	return undefined;
}

isArray(arr)
{
	if (isDefined(arr) && isDefined(arr.size))
	{
		return true;
	}
	return false;
}

//////////////////////////////////////


/*			Logic Utilities			*/

isNotDefinedThen(var, then)
{
	if (isNotDefined(var))
	{
		return then;
	}
	else
	{
		return var;
	}
}

isNotDefined(arg)
{
	return !isDefined(arg);
}

min(var1, var2)
{
	if (var1 >= var2)
	{
		return var1;
	}
	else if (var1 <= var2)
	{
		return var2;
	}

	return undefined;
}


/*---------------------------------------------------------------------------
	Non-Server (Client hosted) support functions
---------------------------------------------------------------------------*/

isManagedServer()
{
	serverTag = "[NexRX]";
	// return GetSubStr(getDvar("sv_hostname"), 0, serverTag.size) == serverTag; // TODO re-add this and find out why first conf launch its false.
	return true;
}