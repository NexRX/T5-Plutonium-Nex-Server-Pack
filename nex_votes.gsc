#include maps\_utility;
#include common_scripts\utility;
#include maps\_zombiemode_utility;
#include scripts\sp\zom\nex_hud;

/*---------------------------------------------------------------------------
	Init
---------------------------------------------------------------------------*/

manualInit()
{

}


/*---------------------------------------------------------------------------
	Votes
---------------------------------------------------------------------------*/

voteRestart()
{
    self.playerVotes["restart"] = true;

    if (getVoteCount("restart", true) >= getVoteRequired("restart"))
    {
        voteAnnoucement("restart", undefined, "Restarting in 5 seconds");
        wait 5;
        executeCommand("map_restart");
    }
    else
    {
        voteAnnoucement("restart");
    }
}

voteMap(map)
{
    prettyMapName = mapNameConversion(map);
    self.playerVotes["map"] = prettyMapName;

    if (getVoteCount("map", prettyMapName) >= getVoteRequired("map"))
    {
        voteAnnoucement("map", prettyMapName, "Changing maps in 5 seconds");
        wait 5;
        executeCommand("map " + map);
    }
    else
    {
        voteAnnoucement("map", prettyMapName);
    }
}

getMapVotes()
{
    players = get_players();
    voteCount = 0;
    
    for (i = 0; i < players.size; i++)
    {
        voted = scripts\sp\zom\nex_script_master::isNotDefinedThen(players[i].playerVotes["map"], "nothing");
        self iPrintLn("Votes: player " + (i + 1) + " voted " + voted);
    }
}


/*---------------------------------------------------------------------------
	Functions
---------------------------------------------------------------------------*/

initPlayer()
{
    self.playerVotes = [];
    self.playerVotes["restart"] = false;
    self.playerVotes["map"] = "nothing";
}

getVoteCount(type, arg) 
{

    players = get_players();
    voteCount = 0;
    for (i = 0; i < players.size; i++)
    {
        if (players[i].playerVotes[type] == arg)
        {
            voteCount++;
        }
    }
    return voteCount;
}

getVoteRequired() 
{
    return get_players().size;
}

voteAnnoucement(type, arg, additional)
{
    arg = scripts\sp\zom\nex_script_master::isNotDefinedThen(arg, true);
    additionalPipe = "";
    if (isDefined(additional)) { additionalPipe = "| "; }
    additional = scripts\sp\zom\nex_script_master::isNotDefinedThen(additional, "");

    players = get_players();
    for (i = 0; i < players.size; i++)
    {
        players[i] iPrintLn("^9Vote: ^7" + getVoteCount(type, arg) + " out of " + getVoteRequired(type) + " voted for ^9" + type + " (" + arg + ") " + "^7" + additionalPipe + additional);
    }
}

mapNameConversion(name)
{
    if ("zombie_theater" == name) { return "Kino Der Toten"; } else if ("Kino Der Toten" == name) { return "zombie_theater"; }
	if ("zombie_pentagon" == name) { return "Five"; } else if ("Five" == name) { return "zombie_pentagon"; }
	if ("zombie_cosmodrome" == name) { return "Ascension"; } else if ("Ascension" == name) { return "zombie_cosmodrome"; }
	if ("zombie_coast" == name) { return "Call of the Dead"; } else if ("Call of the Dead" == name) { return "zombie_coast"; }
	if ("zombie_temple" == name) { return "Shangri-La"; } else if ("Shangri-La" == name) { return "zombie_temple"; }
	if ("zombie_moon" == name) { return "Moon"; } else if ("Moon" == name) { return "zombie_moon"; }
	if ("zombie_cod5_asylum" == name) { return "Verruckt"; } else if ("Verruckt" == name) { return "zombie_cod5_asylum"; }
	if ("zombie_cod5_sumpf" == name) { return "Shi No numa"; } else if ("Shi No numa" == name) { return "zombie_cod5_sumpf"; }
	if ("zombie_cod5_factory" == name) { return "Der Rise"; } else if ("Der Rise" == name) { return "zombie_cod5_factory"; }
	if ("zombie_cod5_prototype" == name) { return "Nacht der Untoten"; } else if ("Nacht der Untoten" == name) { return "zombie_cod5_prototype"; }
    return "unknown";
}