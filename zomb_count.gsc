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
	level thread zombiesleft_hud(); //Zombie Counter
	
	level thread game_end(); //Destory HUDs when the game ends
	
	thread thread_restarter();

	level thread upon_player_connection();
}

upon_player_connection()
{
	for(;;)
	{
		level waittill("connecting", player);
		player thread upon_player_spawned();
	}
}

upon_player_spawned()
{
	self endon("disconnect");
	for(;;)
	{
		self waittill( "spawned_player" );
		
		self.num_perks = -5; //Remove Perk limit - should work now
		level.solo_lives_given = -7; //Can use quick revive 10 times before it disappears
		//self maps\_zombiemode_score::add_to_player_score( 94500 ); //For testing purposes of course
	}
}

//HUDS
zombiesleft_hud()
{   
	self endon( "disconnect" );
	level endon("game_ended");
	
	
	Remaining = create_simple_hud();
  	Remaining.horzAlign = "center";
  	Remaining.vertAlign = "middle";
   	Remaining.alignX = "Left";
   	Remaining.alignY = "middle";
   	Remaining.y = 193;
   	Remaining.x = 37.5;
   	Remaining.foreground = 1;
   	Remaining.fontscale = 1.35;
   	Remaining.alpha = 1;
   	//Remaining.color = ( 0.423, 0.004, 0 );


   	ZombiesLeft = create_simple_hud();
   	ZombiesLeft.horzAlign = "center";
   	ZombiesLeft.vertAlign = "middle";
   	ZombiesLeft.alignX = "center";
   	ZombiesLeft.alignY = "middle";
   	ZombiesLeft.y = 193;
   	ZombiesLeft.x = -1;
   	ZombiesLeft.foreground = 1;
   	ZombiesLeft.fontscale = 1.35;
   	ZombiesLeft.alpha = 1;
   	//ZombiesLeft.color = ( 0.423, 0.004, 0 );
   	ZombiesLeft SetText("^1Zombies Left: ");

	while(1)
	{
		remainingZombies = get_enemy_count() + level.zombie_total;
		Remaining SetValue(remainingZombies);
		if(remainingZombies == 0 )
		{
			Remaining.alpha = 0;
			ZombiesLeft.alpha = 0;
			while(1)
			{
				remainingZombies = get_enemy_count() + level.zombie_total;
				if(remainingZombies != 0 )
				{
					Remaining.alpha = 1;
					ZombiesLeft.alpha = 1;
					break;
				}
				wait 0.05;
			}
		}
	wait 0.05;

	}	
}

game_end()
{
	level endon("end_game" );

	level.hud_destory = 0;
	
	level waittill( "end_game" );

	level.hud_destory = 1;
	
}

thread_restarter() //In dedi servers, the trigger thread breaks in random reasons. This ensures every 3.5 seconds the thread restarts automatically
{
	wait 5;
	for(;;)
	{
		wait 0.05;
		level notify("notifier_1");
		wait 3.5;
		level notify("notifier_2");
	}
}