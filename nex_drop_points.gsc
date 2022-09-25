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
	level.dropPointsAmount = 1000;
	level.dropPointsMaxAmount = 5000;
	level thread onPlayerConnect();
}

onPlayerConnect()
{
	for(;;)
	{
		level waittill("connected", player);
		player.hasDroppedPoints = false;
	}
}

dropPoints(isMax) {
	self endon("nex_drop_points_expired");

	powerName = "";
	if (!isDefined(isMax) || !isMax) 
	{
		powerName = "nex_drop_points";
		amount = level.dropPointsAmount;
	} else {
		powerName = "nex_drop_points_max";
		amount = level.dropPointsMaxAmount;
	}

	if ( !self.hasDroppedPoints && self.score >= amount ) {
		backwards = VectorNormalize( AnglesToForward( self.angles ) );
		origin = self.origin - vector_scale( backwards, -150 );

		self removePoints(amount);
		level thread maps\_zombiemode_powerups::specific_powerup_drop(powerName, origin );
		self.hasDroppedPoints = true;

		self thread notifyIfPointsExpire();
		level waittill("nex_drop_points_pickup");
		self.hasDroppedPoints = false;
	}
}

dropPointsMax() 
{
	dropPoints(true);
}

notifyIfPointsExpire() 
{
	level endon("nex_drop_points_pickup");
	wait 30;
	self notify("nex_drop_points_expired");
	self.hasDroppedPoints = false;
}

givePoints(amount)
{
	self.score+= amount;
}

givePointsDebug()
{
	givePoints(100000);
}

removePointsDebug()
{
	removePoints(100000);
}

removePoints(amount)
{
	self.score-= amount;
}