#include common_scripts\utility;
#include maps\_utility;
#include scripts\Database;
#include scripts\overflowFix;


init()
{
    level thread onPlayerSay();
    level thread onPlayerConnect();
    level.defaultExpEarned = 15;
}

onPlayerConnect()
{
    for (;;)
    {
        level waittill("connected", player);
        
        player thread expPopUp();

    }
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
                case "addskill":
                    thread doAddSkill(player, args);
                    break;
            }
        }
    }
}

doAddSkill(player, args)
{
    SkillPointsAvailable = int(json_get("Database.json", player getguid() + ".skillpoints"));
    if (json_exists("Database.json", player getguid() + ".skills." + args[1]))
    {
        if (int(args[2]) > 0)
        {
            if (int(args[2]) <= SkillPointsAvailable)
            {
                existingPoints = int(json_get("Database.json", player getguid() + ".skills." + args[1]));
                json_add("Database.json", player getguid() + ".skills." + args[1], existingPoints + int(args[2]));
                json_add("Database.json", player getguid() + ".skillpoints", SkillPointsAvailable - int(args[2]));
                player iPrintLnBold("You have added " + args[2] + " points to " + args[1] + ".");
                return;
            }
            else
            {
                player iPrintLnBold("You dont have enough points.");
                return;
            }
        }
        else
        {
            player iPrintLnBold("Invalid amount.");
            return;
        }
        return;
    }
    else
    {
        player iPrintLnBold("Invalid skill.");
        return;
    }
}

getExpRequired() {

    switch(self getRank()) {
        case 0:
            return 5000;
        case 1:
            return 8000;
        case 2:
            return 10000;
        case 3:
            return 12000;
        case 4:
            return 14000;
        case 5:
            return 17000;
        case 6:
            return 20000;
    }
    return int((self getRank() * 5000) - 10000);

}

waitForZombieKill()
{
    for(;;)
    {
        self waittill("zom_kill");
        self notify("add_exp");
    }
}

expPopUp()
{
    self endon("disconnect");
    self thread waitForZombieKill();

    horzAlign = "center";
    vertAlign = "middle";
    alignX = "center";
    alignY = "middle";
    
    //player exp

    self.expEarned = self createElem(horzAlign, vertAlign, alignX, alignY, 0, -25, (1, 1, 1));
    self.expEarned.fontScale = 1.35;
    self.curExpEarned = 0;
    

    vertAlign = "top";
    alignY = "top";
    alignX = "left";

    self.expDisp = self createElem(horzAlign, vertAlign, alignX, alignY, 70, 0, (1, 1, 1));

    
    self.expDisp set_safe_text("(" + self getRank() + ") " + self getExp() + " / " + self getExpRequired());

    for(;;)
    {
        self waittill("add_exp");
        
        self addExp( level.defaultExpEarned );

        self thread removeExp();

        self.curExpEarned = self.curExpEarned + level.defaultExpEarned;
        
        if (self getExp() >= self getExpRequired())
        {
            self addRank();
            self.expDisp set_safe_text("(" + self getRank() + ") " + self getExp() + " / " + self getExpRequired());
            self.expEarned set_safe_text("+", self.curExpEarned);
            continue;
        } else {
            self.expDisp set_safe_text("(" + self getRank() + ") " + self getExp() + " / " + self getExpRequired());
            self.expEarned set_safe_text("+", self.curExpEarned);
        }

    }
}

removeExp()
{
    self endon("add_exp");

    wait(1.5);
    while(self.curExpEarned > 0)
    {
        wait 0.05;
        self.curExpEarned = self.curExpEarned - 1;
        self.expEarned set_safe_text("+", self.curExpEarned);
    }
    wait(0.5);
    self.curExpEarned = 0;
    self.expEarned set_safe_text("");
}