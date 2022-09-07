#include maps\_utility;
#include common_scripts\utility;
#include maps\_zombiemode_utility;

init()
{
    if (!scripts\sp\zom\nex_script_master::isManagedServer())
    {
		manualInit();
   	}
}

manualInit() 
{
    level thread overrideEEState();
    level thread onPlayerConnectedFixes();
}

overrideEEState()
{
    level thread overrideEEStateStop();
    level endon("ee_force_enable_stop");

    for (;;)
    {

        level.onlineGame = true;
        level.zombie_sidequest_previously_completed["EOA"] = true;
        level.zombie_sidequest_previously_completed["COTD"] = true;
        wait 0.01;
    }
}

overrideEEStateStop()
{
    level waittill("all_players_spawned");
    wait 2; // to be safe
    level notify("ee_force_enable_stop");
    level.early_level[level.script] = true; // should stop a crash when "maps\_load_common::map_is_early_in_the_game()" is called.
}

onPlayerConnectedFixes()
{
    for (;;)
    {
        level waittill("connected", player);
        player thread fixPlayer();
    }
}

fixPlayer() 
{
    self endon("disconnect");
    self waittill("spawned_player");

    if( !isDefined(self.zombie_vars) )
    {
        self.zombie_vars = []; // should be unnessecary but I've see the next line cause issues
    }

    if( !isDefined(self.zombie_vars[ "zombie_powerup_minigun_on" ]) )
    {
        self.zombie_vars[ "zombie_powerup_minigun_on" ] = false;
    }

    if( !isDefined(self.last_hacked_round) )
    {
        self.last_hacked_round = 0;
    }
}