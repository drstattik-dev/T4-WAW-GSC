#include maps\_hud_util;
#include common_scripts\utility;
#include maps\_utility;
#include maps\_zombiemode_utility;
#include scripts\overflowFix;
//#include _mapvoting;


init()
{
    level thread onPlayerConnect();
    //player thread initOverflowFix();
}

onPlayerConnect()
{
    for (;;)
    {
        level waittill("connected", player);
        
        player thread Health();
    }
}

Health()
{

    horzAlign = "center";
    vertAlign = "middle";
    alignX = "center";
    alignY = "middle";
    
    //player exp

    self.currentHealth = self createElem(horzAlign, vertAlign, alignX, alignY, 0, 220, (1, 1, 1));

    for(;;)
    {
        self.currentHealth set_safe_text(self.Health + " / " + self.MaxHealth);
        wait(0.1);
    }
}