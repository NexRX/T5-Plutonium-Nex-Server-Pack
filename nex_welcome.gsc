#include maps\_utility;
#include common_scripts\utility;
#include maps\_zombiemode_utility;

init()
{  
	if (!scripts\sp\zom\nex_script_master::isManagedServer())
    {
		messages = [];
		messages[0] = welcomeMessageStruct("^2Welcome to my server.");
		messages[1] = welcomeMessageStruct("^1E^2n^3j^4o^5y");

		manualInit(messages);
   	}
}

manualInit(messages)
{
	onPlayerConnect(messages);
}

onPlayerConnect(messages)
{
	for(;;)
	{
		level waittill( "connected", player );
		player thread onPlayerSpawned(messages);
	}
}

onPlayerSpawned(messages)
{
	self endon("disconnect");
	
	for (i = 0; i < messages.size; i++) {
		message = messages[i];
		wait message.delay;
		self iprintlnbold(message.content);
	}
}

welcomeMessageStruct(message, delay)
{
	welcomeMessage = spawnStruct();
	welcomeMessage.content = message;

	if ( !isDefined(delay) )
	{
		welcomeMessage.delay = 1.5;
	}
	welcomeMessage.delay = delay;

	return welcomeMessage;
}