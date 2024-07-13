#include maps\_hud_util;
#include common_scripts\utility;
#include maps\_utility;
#include maps\_zombiemode_utility;
#include scripts\overflowFix;
//#include _mapvoting;


init()
{
    
    level thread createRainbowColor();
    horzAlign = "center";
    vertAlign = "top";
    alignX = "center";
    alignY = "top";

    Advert = level createElem(horzAlign, vertAlign, alignX, alignY, 0, 0, (1, 1, 1), true);

    Advert thread set_safe_text("Join the Discord: 9uk6U9zc");

    Advert thread doRainbow();
}

createRainbowColor()
{
    x = 0; y = 0;
    r = 0; g = 0; b = 0;
    level.rainbowColour = (0, 0, 0);
    
    while(true)
    {
        if (y >= 0 && y < 255) {
            r = 255;
            g = 0;
            b = x;
        }
        else if (y >= 255 && y < 510) {
            r = 255 - x;
            g = 0;
            b = 255;
        }
        else if (y >= 510 && y < 765) {
            r = 0;
            g = x;
            b = 255;
        }
        else if (y >= 765 && y < 1020) {
            r = 0;
            g = 255;
            b = 255 - x;
        }
        else if (y >= 1020 && y < 1275) {
            r = x;
            g = 255;
            b = 0;
        }
        else if (y >= 1275 && y < 1530) {
            r = 255;
            g = 255 - x;
            b = 0;
        }

        x += 0.5; //increase this value to switch colors faster
        if (x >= 255)
            x = 0;

        y += 0.5; //increase this value to switch colors faster
        if (y > 1530)
            y = 0;

        level.rainbowColour = rgb(r, g, b);
        wait .05;
    }
}

rgb(r, g, b)
{
    return (r/255, g/255, b/255);
}

doRainbow()
{
    level endon ( "disconnect" );
    while(IsDefined( self ))
    {
        self fadeOverTime(.05); 
        self.color = level.rainbowColour;
        wait(.05);
    }
}