#include maps\_utility;
#include common_scripts\utility;
#include maps\_zombiemode_utility;

main()
{
	if ( GetDvarInt( "scr_disableHotJoinFixes" ) )
		return;

	if ( isDedicated() )
	{
		// always coop
		replaceFunc( maps\_utility::is_coop, ::alwaysTrue );

		// make sure quickrevive is coop
		replaceFunc( maps\_zombiemode_perks::vending_trigger_think, ::vending_trigger_think );

		// host is not players[0] on dedi
		replaceFunc( maps\_utility::get_host, ::getHostDedi );

		// prevent force end exploit
		replaceFunc( maps\_cooplogic::forceEnd, ::noop );

		// Fix join too early 
		replaceFunc( maps\_load_common::all_players_connected, ::all_players_connected );
	}
}

init()
{
	if ( GetDvarInt( "scr_disableHotJoinFixes" ) )
		return;

	// do prints, handle hotjoining and leavers
	level thread onPlayerConnect();

	// lets be the last to setup func ptrs
	for ( i = 0; i < 10; i++ )
		waittillframeend;

	// setup hot joining
	level.oldSpawnClient = level.spawnClient;
	level.spawnClient = ::spawnClientOverride;

	if ( !isDefined( level.hotJoinPlayer ) )
		level.hotJoinPlayer = ::hotJoin;

	// setup how endgame
	if ( !isDefined( level.endGame ) )
	{
		level.endGame = ::endGameNotify;
	}

	if ( !isDefined( level.isPlayerDead ) )
		level.isPlayerDead = ::checkIsPlayerDead;

	// make dead players into spectators
	level.oldOverridePlayerKilled = level.overridePlayerKilled;
	level.overridePlayerKilled = ::playerKilledOverride;

	// fix spawning
	level thread endOfRoundSpectatorRespawnWatch();
}

getHostDedi()
{
	return get_players()[0];
}

alwaysTrue()
{
	return true;
}

noop()
{
}

endGameNotify()
{
	level notify( "end_game" );
}

checkIsPlayerDead( player )
{
	return ( player.sessionstate == "spectator" || player maps\_laststand::player_is_in_laststand() || ( isDefined( player.is_zombie ) && player.is_zombie ) );
}

playerKilledOverride()
{
	self [[level.player_becomes_zombie]]();
	checkForAllDead( self );
	self [[level.oldOverridePlayerKilled]]();
}

spawnClientOverride()
{
	if ( flag( "all_players_spawned" ) )
		self thread [[level.hotJoinPlayer]]();
	else
		self thread [[level.oldSpawnClient]]();
}

getHotJoinPlayer()
{
	players = get_players();

	for ( i = 0; i < players.size; i++ )
	{
		player = players[i];

		if ( !isDefined( player ) || !isDefined( player.sessionstate ) )
			continue;

		if ( player == self )
			continue;

		if ( player.sessionstate == "spectator" )
			continue;

		if ( isDefined( player.is_zombie ) && player.is_zombie )
			continue;

		return player;
	}

	return undefined;
}

getHotJoinAi( team )
{
	ais = GetAiArray( team );
	ai = undefined;

	if ( ais.size )
		ai = ais[randomint( ais.size )];

	return ai;
}

getHotJoinInitSpawn()
{
	structs = getstructarray( "initial_spawn_points", "targetname" );
	players = get_players();
	i = 0;

	for ( i = 0; i < players.size; i++ )
	{
		if ( !isDefined( players[i] ) )
			continue;

		if ( self == players[i] )
			break;
	}

	spawn_obj = structs[i];

	if ( !isDefined( spawn_obj ) )
		spawn_obj = structs[0];

	return spawn_obj;
}

hotJoin()
{
	self endon( "disconnect" );
	self endon( "end_respawn" );

	// quik hax: prevent spectators_respawn from spawning us
	self.sessionstate = "playing";
	waittillframeend;
	self.sessionstate = "spectator";

	player = self getHotJoinPlayer();
	ally = self getHotJoinAi( "allies" );
	enemy = self getHotJoinAi( "axis" );
	spawn_pt = self getHotJoinInitSpawn();

	spawn_obj = spawnStruct();

	if ( isDefined( spawn_pt ) )
	{
		spawn_obj = spawn_pt;
	}
	else if ( isDefined( player ) )
	{
		spawn_obj.origin = player getOrigin();
		spawn_obj.angles = player.angles;
	}
	else if ( isDefined( ally ) )
	{
		spawn_obj.origin = ally getOrigin();
		spawn_obj.angles = ally.angles;
	}
	else if ( isDefined( enemy ) )
	{
		spawn_obj.origin = enemy getOrigin();
		spawn_obj.angles = enemy.angles;
	}
	else
	{
		spawn_obj.origin = ( 0, 0, 0 );
		spawn_obj.angles = ( 0, 0, 0 );
	}

	// check if custom logic for hotjoining
	if ( isDefined( level.customHotJoinPlayer ) )
	{
		temp_obj = self [[level.customHotJoinPlayer]]( spawn_obj );

		// check if theres a spawn obj
		if ( isDefined( temp_obj ) )
		{
			// check if we should cancel spawning this player (maybe its already done)
			if ( isDefined( temp_obj.cancel ) && temp_obj.cancel )
				return;

			// set our spawn location
			spawn_obj = temp_obj;
		}
	}

	// set spawn params
	self setorigin( spawn_obj.origin );
	self setplayerangles( spawn_obj.angles );
	self.spectator_respawn = spawn_obj;
	self.respawn_point = spawn_obj;

	// do the spawn
	println( "*************************Client hotjoin***" );

	self unlink();

	if ( isdefined( self.spectate_cam ) )
		self.spectate_cam delete ();

	if ( isDefined( spawn_obj.force_spawn ) && spawn_obj.force_spawn )
		self thread [[level.spawnPlayer]]();
	else
	{
		self thread [[level.spawnSpectator]]();
		checkForAllDead( self );
	}
}

onDisconnect()
{
	lpselfnum = self getentitynumber();
	lpguid = self getguid();
	name = self.playername;

	self waittill( "disconnect" );

	logprint( "Q;" + lpguid + ";" + lpselfnum + ";" + name + "\n" );

	// check if we need to end the game cause last person left alive left the game
	checkForAllDead( self );
}

onConnect()
{
	self endon( "disconnect" );

	logprint( "J;" + self getguid() + ";" + self getentitynumber() + ";" + self.playername + "\n" );

	// this only happens on first connect, we need to do it for hot joiners...
	if ( flag( "all_players_spawned" ) )
	{
		self waittill( "spawned_player" );
		wait 0.05;
		self freezecontrols( false );
		self setClientDvars( "ammoCounterHide", "0",
		    "miniscoreboardhide", "0" );

		if ( level.round_number > 6 )
			self.score = 1500;
		else
			self.score = 500;

		self.score_total = self.score;
		self.old_score = self.score;
	}
}

onPlayerConnect()
{
	for ( ;; )
	{
		level waittill( "connected", player );

		iprintln( player.playername + " connected." );

		player thread onDisconnect();
		player thread onConnect();
	}
}

checkForAllDead( excluded_player )
{
	players = get_players();
	count = 0;

	for ( i = 0; i < players.size; i++ )
	{
		player = players[ i ];

		if ( isDefined( excluded_player ) && excluded_player == player )
			continue;

		if ( !isDefined( player ) || !isDefined( player.sessionstate ) )
			continue;

		if ( [[level.isPlayerDead]]( player ) )
			continue;

		count++;
	}

	if ( count == 0 )
	{
		printf( "Ending game as no players are left alive..." );
		level thread [[level.endGame]]();
	}
}

endOfRoundSpectatorRespawnWatch()
{
	flag_wait( "all_players_spawned" );

	for ( ;; )
	{
		level waittill( "end_of_round" );
		level thread maps\_zombiemode::spectators_respawn();
	}
}

vending_trigger_think()
{
	perk = self.script_noteworthy;
	solo = false;
	flag_init( "_start_zm_pistol_rank" );

	printf( "Replaced vending_trigger_think" );
	if ( IsDefined( perk ) &&
	    ( perk == "specialty_quickrevive" || perk == "specialty_quickrevive_upgrade" ) )
	{
		flag_wait( "all_players_connected" );
		/*  players = GetPlayers();
		    if ( players.size == 1 )
		    {
			solo = true;
			flag_set( "solo_game" );
			level.solo_lives_given = 0;
			players[0].lives = 0;
			level maps\_zombiemode::zombiemode_solo_last_stand_pistol();
		    }*/
	}

	flag_set( "_start_zm_pistol_rank" );

	if ( !solo )
	{
		self SetHintString( &"ZOMBIE_NEED_POWER" );
	}

	self SetCursorHint( "HINT_NOICON" );
	self UseTriggerRequireLookAt();

	if ( !solo )
	{
		notify_name = perk + "_power_on";
		level waittill( notify_name );
	}

	if ( !IsDefined( level._perkmachinenetworkchoke ) )
	{
		level._perkmachinenetworkchoke = 0;
	}
	else
	{
		level._perkmachinenetworkchoke ++;
	}

	for ( i = 0; i < level._perkmachinenetworkchoke; i ++ )
	{
		wait_network_frame();
	}


	self thread maps\_zombiemode_audio::perks_a_cola_jingle_timer();

	perk_hum = spawn( "script_origin", self.origin );
	perk_hum playloopsound( "zmb_perks_machine_loop" );
	self thread maps\_zombiemode_perks::check_player_has_perk( perk );

	cost = level.zombie_vars["zombie_perk_cost"];

	switch ( perk )
	{
		case "specialty_armorvest_upgrade":
		case "specialty_armorvest":
			cost = 2500;
			self SetHintString( &"ZOMBIE_PERK_JUGGERNAUT", cost );
			break;

		case "specialty_quickrevive_upgrade":
		case "specialty_quickrevive":
			if ( solo )
			{
				cost = 500;
				self SetHintString( &"ZOMBIE_PERK_QUICKREVIVE_SOLO", cost );
			}
			else
			{
				cost = 1500;
				self SetHintString( &"ZOMBIE_PERK_QUICKREVIVE", cost );
			}

			break;

		case "specialty_fastreload_upgrade":
		case "specialty_fastreload":
			cost = 3000;
			self SetHintString( &"ZOMBIE_PERK_FASTRELOAD", cost );
			break;

		case "specialty_rof_upgrade":
		case "specialty_rof":
			cost = 2000;
			self SetHintString( &"ZOMBIE_PERK_DOUBLETAP", cost );
			break;

		case "specialty_longersprint_upgrade":
		case "specialty_longersprint":
			cost = 2000;
			self SetHintString( &"ZOMBIE_PERK_MARATHON", cost );
			break;

		case "specialty_flakjacket_upgrade":
		case "specialty_flakjacket":
			cost = 2000;
			self SetHintString( &"ZOMBIE_PERK_DIVETONUKE", cost );
			break;

		case "specialty_deadshot_upgrade":
		case "specialty_deadshot":
			cost = 1500;
			self SetHintString( &"ZOMBIE_PERK_DEADSHOT", cost );
			break;

		default:
			self SetHintString( perk + " Cost: " + level.zombie_vars["zombie_perk_cost"] );
	}

	for ( ;; )
	{
		self waittill( "trigger", player );

		index = maps\_zombiemode_weapons::get_player_index( player );

		if ( player maps\_laststand::player_is_in_laststand() || is_true( player.intermission ) )
		{
			continue;
		}

		if ( player in_revive_trigger() )
		{
			continue;
		}

		if ( player isThrowingGrenade() )
		{
			wait( 0.1 );
			continue;
		}

		if ( player isSwitchingWeapons() )
		{
			wait( 0.1 );
			continue;
		}

		if ( player is_drinking() )
		{
			wait( 0.1 );
			continue;
		}

		if ( player HasPerk( perk ) )
		{
			cheat = false;

			if ( cheat != true )
			{

				self playsound( "deny" );
				player maps\_zombiemode_audio::create_and_play_dialog( "general", "perk_deny", undefined, 1 );

				continue;
			}
		}

		if ( player.score < cost )
		{

			self playsound( "evt_perk_deny" );
			player maps\_zombiemode_audio::create_and_play_dialog( "general", "perk_deny", undefined, 0 );
			continue;
		}

		if ( player.num_perks >= 4 )
		{

			self playsound( "evt_perk_deny" );

			player maps\_zombiemode_audio::create_and_play_dialog( "general", "sigh" );
			continue;
		}

		sound = "evt_bottle_dispense";
		playsoundatposition( sound, self.origin );
		player maps\_zombiemode_score::minus_to_player_score( cost );
		player.perk_purchased = perk;





		switch ( perk )
		{
			case "specialty_armorvest_upgrade":
			case "specialty_armorvest":
				sound = "mus_perks_jugger_sting";
				break;

			case "specialty_quickrevive_upgrade":
			case "specialty_quickrevive":
				sound = "mus_perks_revive_sting";
				break;

			case "specialty_fastreload_upgrade":
			case "specialty_fastreload":
				sound = "mus_perks_speed_sting";
				break;

			case "specialty_rof_upgrade":
			case "specialty_rof":
				sound = "mus_perks_doubletap_sting";
				break;

			case "specialty_longersprint_upgrade":
			case "specialty_longersprint":
				sound = "mus_perks_phd_sting";
				break;

			case "specialty_flakjacket_upgrade":
			case "specialty_flakjacket":
				sound = "mus_perks_stamin_sting";
				break;

			case "specialty_deadshot_upgrade":
			case "specialty_deadshot":
				sound = "mus_perks_jugger_sting";
				break;

			default:
				sound = "mus_perks_jugger_sting";
				break;
		}

		self thread maps\_zombiemode_audio::play_jingle_or_stinger ( self.script_label );




		gun = player maps\_zombiemode_perks::perk_give_bottle_begin( perk );
		player waittill_any( "fake_death", "death", "player_downed", "weapon_change_complete" );

		player maps\_zombiemode_perks::perk_give_bottle_end( gun, perk );


		if ( player maps\_laststand::player_is_in_laststand() || is_true( player.intermission ) )
		{
			continue;
		}

		if ( isDefined( level.perk_bought_func ) )
		{
			player [[ level.perk_bought_func ]]( perk );
		}

		player.perk_purchased = undefined;
		player maps\_zombiemode_perks::give_perk( perk, true );

		bbPrint( "zombie_uses: playername %s playerscore %d teamscore %d round %d cost %d name %s x %f y %f z %f type perk",
		    player.playername, player.score, level.team_pool[ player.team_num ].score, level.round_number, cost, perk, self.origin );
	}
}

all_players_connected()
{
	while ( get_players().size == 0 )
	{
		wait 0.05;
	}

	while(1)
	{
		num_con = getnumconnectedplayers(); 
		num_exp = getnumexpectedplayers();	
		println( "all_players_connected(): getnumconnectedplayers=", num_con, "getnumexpectedplayers=", num_exp );	

		if(num_con == num_exp && (num_exp != 0))
		{
			flag_set( "all_players_connected" );
			// CODER_MOD: GMJ (08/28/08): Setting dvar for use by code
			SetDvar( "all_players_are_connected", "1" ); 
			return;
		}

		wait( 0.05 );
	}
}