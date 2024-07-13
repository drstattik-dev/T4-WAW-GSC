#include common_scripts\utility;
#include maps\_utility;



init()
{
    level thread onPlayerConnect();
}

onPlayerConnect()
{
    for (;;)
    {
        level waittill("connected", player);
        player thread onPlayerConnected();
    }
}

onPlayerConnected()
{
    self endon("disconnect");
    for(;;)
    {
        self waittill("spawned_player");
        self thread oneGunFix();
    }
}

oneGunFix()
{
    self endon("disconnect");
    for (;;)
    {  
        currentGuns = self getWeaponsListPrimaries();
        if (currentGuns.size > 1)
            break;

        for (i=0; i<currentGuns.size; i++)
        {
            if (isDefined(self.prevWeapons) && self.prevWeapons[i] != currentGuns[i])
            {
                //using GiveWeapon give the player their weapon back
                self iPrintln("Missing gun detected!");
                self GiveWeapon(self.prevWeapons[i]);
                
                //self switchToWeapon(self.prevCurGun);
                break;
            }
            else
                break;
        }

        self.prevWeapons = self getWeaponsListPrimaries();
	    self.prevCurGun = self GetCurrentWeapon();

        wait(1);

    }
}