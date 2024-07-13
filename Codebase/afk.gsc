#include common_scripts\utility;
#include maps\_utility;
#include scripts\Database;



init()
{
    level thread onPlayerSay();
    level.afkCooldowntime = 60*20;
    level.afkTime = 60*45;
}

onPlayerSay()
{
    level endon("disconnect");
   
    prefix = ".";
    for (;;)
    {
        level waittill("say", message, player);
        message = toLower(message);
        if(!level.intermission && message[0] == prefix)
        {
            args = strTok(message, " ");
            command = getSubStr(args[0], 1);
            switch(command) {
                case "afk":
                    player thread AFK();
                    break;
            }
        }
    }
}

//doStartAFK(player)
AFK()
{
    if (isDefined(self.afkCooldown) && self.afkCooldown)
    {
        self iPrintLnBold("^1You can't use the AFK command yet.");
        return;
    }
    if (!level.afkCooldown && !self.afk )
    {
        self endon("noafk");
        self.afk = true;
        self.ignoreme = true; 
        self.godmode = true;
        self freezeControls( true );
        self iPrintLnBold("^2You are now AFK.");
        while(self.afk)
        {
            wait(level.afkTime);
            self iPrintLnBold("^1You ran out of afk time.");
            self thread AFK();
            break;
        }
    }
    else
    {
        self notify("noafk");
        self.afk = false;
        self freezeControls( false );
        
        if (!level.afkCooldown)
        {
            self iPrintLnBold("^1You are no longer AFK.");

            self.afkCooldown = true;
            self thread doWaitAFK();
        }
        wait(5);
        self.ignoreme = false;
        self.godmode = false;
    }
}

//doWaitAFK(player)
doWaitAFK()
{
    wait(level.afkCooldowntime);
    self iPrintLnBold("^2AFK coooldown over.");
    self.afkCooldown = false;
    self.afk = false;
    self.ignoreme = false;
    self.godmode = false;
    self freezeControls( false );
}