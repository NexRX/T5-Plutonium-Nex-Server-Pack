#include maps\_utility; 
#include common_scripts\utility;
#include maps\_zombiemode_utility;
#include animscripts\zombie_Utility;

manualInit()
{
    if ( GetDvar( #"zombiemode" ) == "1" )
	{
        replacefunc(maps\_zombiemode_powerups::powerup_setup, ::custom_powerup_setup);

        level thread onPlayerConnect();
        maps\_zombiemode_powerups::include_zombie_powerup("random_perk"); //custom 
        maps\_zombiemode_powerups::include_zombie_powerup("c_bonus_points_player"); //custom
        maps\_zombiemode_powerups::include_zombie_powerup("c_bonus_points_team"); //custom
        maps\_zombiemode_powerups::include_zombie_powerup("c_bonfire_sale"); //custom
        maps\_zombiemode_powerups::include_zombie_powerup("c_random_weapon"); //custom

        maps\_zombiemode_powerups::include_zombie_powerup("nex_drop_points"); //nex custom
        maps\_zombiemode_powerups::include_zombie_powerup("nex_drop_points_max"); //nex custom

        maps\_zombiemode_powerups::add_zombie_powerup( "nex_drop_points", "zombie_z_money_icon", &"ZOMBIE_POWERUP_BONUS_POINTS", true, false, false );
        maps\_zombiemode_powerups::add_zombie_powerup( "nex_drop_points_max", "zombie_z_money_icon", &"ZOMBIE_POWERUP_BONUS_POINTS", true, false, false );

        if(level.script == "zombie_pentagon" || level.script == "zombie_theater" || level.script == "zombie_cosmodrome" || level.script == "zombie_coast" || level.script == "zombie_temple" || level.script == "zombie_moon" )
            maps\_zombiemode_powerups::include_zombie_powerup("free_pap"); //custom | not for waw maps

        maps\_zombiemode_powerups::add_zombie_powerup( "random_perk", "zombie_pickup_perk_bottle", &"ZOMBIE_POWERUP_FREE_PERK", false, false, false );
        maps\_zombiemode_powerups::add_zombie_powerup( "c_bonus_points_player", "zombie_z_money_icon", &"ZOMBIE_POWERUP_BONUS_POINTS", true, false, false );
        maps\_zombiemode_powerups::add_zombie_powerup( "c_bonus_points_team", "zombie_z_money_icon", &"ZOMBIE_POWERUP_BONUS_POINTS", false, false, false );
        maps\_zombiemode_powerups::add_zombie_powerup( "c_bonfire_sale", "zombie_pickup_bonfire", &"ZOMBIE_POWERUP_MAX_AMMO", false, false, false );
        maps\_zombiemode_powerups::add_zombie_powerup( "c_random_weapon", "zombie_pickup_minigun", &"ZOMBIE_POWERUP_MINIGUN", false, false, false );
        if(level.script == "zombie_pentagon" || level.script == "zombie_theater" || level.script == "zombie_cosmodrome" || level.script == "zombie_coast" || level.script == "zombie_temple" || level.script == "zombie_moon" )
            maps\_zombiemode_powerups::add_zombie_powerup( "free_pap", "zombie_pickup_bonfire", &"ZOMBIE_POWERUP_MAX_AMMO", true, false, false );
       
wait 2;
        level._zombiemode_powerup_grab = ::custom_powerup_grab;
	}
}

include_all_powerups() {
    maps\_zombiemode_powerups::include_zombie_powerup("random_perk");
    maps\_zombiemode_powerups::include_zombie_powerup("c_bonus_points_player");
    maps\_zombiemode_powerups::include_zombie_powerup("c_bonus_points_team");
    maps\_zombiemode_powerups::include_zombie_powerup("c_bonfire_sale");
    maps\_zombiemode_powerups::include_zombie_powerup("c_random_weapon");
    maps\_zombiemode_powerups::include_zombie_powerup("free_pap");
}

custom_powerup_grab(s_powerup)
{
    wait .1;
	e_player = s_powerup.power_up_grab_player;
	if(s_powerup.powerup_name == "  ")
	{
		level thread maps\_zombiemode_powerups::bonus_points_team_powerup( s_powerup );
		e_player thread maps\_zombiemode_powerups::powerup_vo( "bonus_points_team" ); 
	}
	if(s_powerup.powerup_name == "c_bonfire_sale")
	{
		level thread maps\_zombiemode_powerups::start_bonfire_sale( s_powerup );
		e_player thread maps\_zombiemode_powerups::powerup_vo("firesale");
	}
	if(s_powerup.powerup_name == "c_random_weapon")
	{
		if ( !level maps\_zombiemode_powerups::random_weapon_powerup( s_powerup, e_player ) )
		{
		}
	}
	if(s_powerup.powerup_name == "c_bonus_points_player")
	{
		level thread maps\_zombiemode_powerups::bonus_points_player_powerup( s_powerup, e_player );
		e_player thread maps\_zombiemode_powerups::powerup_vo( "bonus_points_solo" );
	}
	if(s_powerup.powerup_name == "random_perk")
	{
        players = get_players();
	    for(i=0;i<players.size;i++)
	    {
            players[i] maps\_zombiemode_perks::give_random_perk();
            
	    }
        level thread powerup_hud("FREE PERK!", false);
	}
    if(s_powerup.powerup_name == "free_pap")
	{
		current_weapon = e_player getCurrentWeapon();
		if(e_player maps\_zombiemode_weapons::is_weapon_upgraded( current_weapon ) || e_player maps\_laststand::player_is_in_laststand())
		{
			e_player maps\_zombiemode_score::add_to_player_score( 500 );
			return;
		}
		if ( "microwavegun_zm" == current_weapon )
		{
			current_weapon = "microwavegundw_zm";
		}
		if(!isdefined(level.zombie_weapons[current_weapon].upgrade_name))
		{
			return;
		}
		upgrade_weapon = level.zombie_weapons[current_weapon].upgrade_name;

		e_player takeweapon( current_weapon );
		e_player playsound( "zmb_perks_packa_upgrade" );
		e_player GiveWeapon( upgrade_weapon, 0, e_player maps\_zombiemode_weapons::get_pack_a_punch_weapon_options( upgrade_weapon ) );
		e_player GiveStartAmmo( upgrade_weapon );
		e_player switchtoweapon( upgrade_weapon );
		e_player thread powerup_hud("FREE PACK A PUNCH", true);
	}

    if (s_powerup.powerup_name == "nex_drop_points" || s_powerup.powerup_name == "nex_drop_points_max") {
		if (s_powerup.powerup_name == "nex_drop_points_max") {
			e_player scripts\sp\zom\nex_drop_points
            	::givePoints( level.dropPointsMaxAmount);
		} else {
			e_player scripts\sp\zom\nex_drop_points
            	::givePoints( level.dropPointsAmount);
		}
		e_player thread maps\_zombiemode_powerups::powerup_vo( "bonus_points_solo" );
        level notify("nex_drop_points_pickup");
    }
}

powerup_hud(text, solo)
{
	self endon ("disconnect");
    if(solo)
    {
        hudelem = create_simple_hud( self );
        hudelem.fontscale = 2;
		hudelem.foreground = true; 
		hudelem.sort = 2; 
		hudelem.hidewheninmenu = false; 
		hudelem.alignX = "top"; 
		hudelem.alignY = "top";
		hudelem.horzAlign = "user_center"; 
		hudelem.vertAlign = "user_bottom";
        hudelem.x = 0;
        hudelem.y = -100;
    }
    else
    {
        hudelem = maps\_hud_util::createFontString( "objective", 2 );
        hudelem maps\_hud_util::setPoint( "TOP", undefined, 0, level.zombie_vars["zombie_timer_offset"] - (level.zombie_vars["zombie_timer_offset_interval"] * 2));
        hudelem.sort = 0.5;
    }
    hudelem.alpha = 0;
    hudelem fadeovertime(0.5);
    hudelem.alpha = 1;
    hudelem settext(text);
    wait 0.5;
	move_fade_time = 1.5;
	hudelem FadeOverTime( move_fade_time ); 
	hudelem MoveOverTime( move_fade_time );
    if(solo)
    {
	    hudelem.y = -150;
    }
    else
    {
        hudelem.y = 270;
    }
	hudelem.alpha = 0;

	wait move_fade_time;

	hudelem destroy();
}

onPlayerConnect()
{
	level endon("end_game");
    for(;;)
    {
        level waittill("connected", player);
        player thread onPlayerSpawned();
    }
}

onPlayerSpawned()
{
    self endon("disconnect");
	level endon("end_game");
	self waittill("spawned_player");
    wait 6;
    self iprintln("Custom power ups has been added to the game.");
   
}


custom_powerup_setup( powerup_override )
{
	powerup = undefined;
	
	if ( !IsDefined( powerup_override ) )
	{
		powerup = maps\_zombiemode_powerups::get_valid_powerup();
	}
	else
	{
		powerup = powerup_override;

		if ( "tesla" == powerup && maps\_zombiemode_powerups::tesla_powerup_active() )
		{
			powerup = "minigun";
		}
	}	

	struct = level.zombie_powerups[powerup];

	if ( powerup == "c_random_weapon" )
	{
		self.weapon = maps\_zombiemode_weapons::treasure_chest_ChooseWeightedRandomWeapon();

		self.base_weapon = self.weapon;
		if ( !isdefined( level.random_weapon_powerups ) )
		{
			level.random_weapon_powerups = [];
		}
		level.random_weapon_powerups[level.random_weapon_powerups.size] = self;
		self thread maps\_zombiemode_powerups::cleanup_random_weapon_list();

		if ( IsDefined( level.zombie_weapons[self.weapon].upgrade_name ) && !RandomInt( 4 ) ) // 25% chance
		{
			self.weapon = level.zombie_weapons[self.weapon].upgrade_name;
		}

		self SetModel( GetWeaponModel( self.weapon ) );
		self useweaponhidetags( self.weapon );

		offsetdw = ( 3, 3, 3 );
		self.worldgundw = undefined;
		if ( maps\_zombiemode_weapons::weapon_is_dual_wield( self.weapon ) )
		{
			self.worldgundw = spawn( "script_model", self.origin + offsetdw );
			self.worldgundw.angles  = self.angles;
			self.worldgundw setModel( maps\_zombiemode_weapons::get_left_hand_weapon_model_name( self.weapon ) );
			self.worldgundw useweaponhidetags( self.weapon );
			self.worldgundw LinkTo( self, "tag_weapon", offsetdw, (0, 0, 0) );
		}
	}
	else
	{
		self SetModel( struct.model_name );
	}

	playsoundatposition("zmb_spawn_powerup", self.origin);

	self.powerup_name 		= struct.powerup_name;
	self.hint 				= struct.hint;
	self.solo 				= struct.solo;
	self.caution 			= struct.caution;
	self.zombie_grabbable 	= struct.zombie_grabbable;

	if( IsDefined( struct.fx ) )
	{
		self.fx = struct.fx;
	}

	self PlayLoopSound("zmb_spawn_powerup_loop");
}