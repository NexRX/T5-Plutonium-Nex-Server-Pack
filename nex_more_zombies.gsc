#include maps\_utility;
#include common_scripts\utility;
#include maps\_zombiemode_utility;

increaseZombiesLimit(number)
{
    for (;;) {
    if( isDefined(number) ) {
        number = 31; // max
    }

    level.zombie_ai_limit = number;
    level.zombie_actor_limit = number;
    wait 1;
    }
}