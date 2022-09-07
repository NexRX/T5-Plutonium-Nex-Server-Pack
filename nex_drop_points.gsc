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
	scripts\sp\zom\nex_script_master
		::addFeatureForKey(0, "", ::givePoints);
	level thread onPlayerConnect();
}

onPlayerConnect()
{
	for(;;)
	{
		level waittill("connecting", player);
		player thread scripts\sp\zom\nex_script_master
						::trackAlive();
	}
}

givePoints()
{
	if (self.isAlive)
	{
		self.pointsToGive = 1000; 
		self.score+= self.pointsToGive;
	}
}