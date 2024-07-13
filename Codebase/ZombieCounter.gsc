#include maps\_hud_util;
#include common_scripts\utility;
#include maps\_utility;
#include maps\_zombiemode_utility;
#include scripts\overflowFix;
//#include _mapvoting;


init()
{
    level thread onPlayerConnect();
    //level thread zombieCounter();

}

onPlayerConnect()
{
    for (;;)
    {
        level waittill("connected", player);
        //set_zombie_var( "zombie_between_round_time", 		2 );  
        if (!isDefined(level.Zombies))
        {
            level thread zombieCounter();
            
            level.Zombies thread destroyEleme();
        }
    }
}

zombieCounter()
{
    self endon("end_game");

    
    horzAlign = "center";
    vertAlign = "middle";
    alignX = "center";
    alignY = "middle";
    //zombie counter
    level.Zombies = self createElem(horzAlign, vertAlign, alignX, alignY, 0, 230, (1, 1, 1), true);
    //zomBar = self createBar( (0.999, 0.000, 0.00), 100, height );

    //zomBar setPoint(horzAlign, vertAlign, 0, 210);
    //Zombies thread unregisterElem();

	for(;;)
	{
        //if intermission is true then break and rem
        totalEnemies = level.zombie_total + get_enemy_count();
		queuedEnemies = level.zombie_total;
		spawnedEnemies = get_enemy_count();

        if (totalEnemies == 0)
        {
            level.Zombies set_safe_text( "^7Zombies: ^1" + "0");
        } else {
            if (queuedEnemies > 0 )
            {
                level.Zombies set_safe_text( "^7Zombies: ^1" + spawnedEnemies + "^7 (queued: ^3" + queuedEnemies + "^7)");
            } else {
                level.Zombies set_safe_text( "^7Zombies: ^1" + spawnedEnemies);
            }
        }
		wait(1);
	}
}


destroyEleme()
{
    self waittill("end_game");
    wait 1;
    self set_safe_text("");
    unregister_hud_overflow_fix_for_hudelem(self);
    self destroy();
}