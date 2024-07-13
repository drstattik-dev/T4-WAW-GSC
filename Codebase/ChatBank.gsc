#include common_scripts\utility;
#include maps\_utility;
#include scripts\Database;


/*
kills = self scripts\persistence::statGet("kills");
self iPrintLnBold("Kills: " + kills);

self scripts\persistence::statSet("kills", 69);
*/


init()
{
    level thread onPlayerConnect();
    level thread onPlayerSay();
}

onPlayerConnect()
{
    for (;;)
    {
        level waittill("connecting", player);
        player thread SetupPlayerDatabase();
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
                case "deposit":
                case "d":
                    doDeposit(player, args);
                    break;

                case "withdraw":
                case "w":
                    doWhitdraw(player, args);
                    break;

                case "autodeposit":
                case "ad":
                    player thread autoDeposit(player, args);
                    break;

                case "balance":
                case "b":
                    if (getDvarIntDefault("sv_allowchatbank", 1) == 1)
                    {
                        storedMoney = json_get("Database.json", player getguid() + ".money");

                        player iPrintLnBold("Your balance is ^2$^7" + storedMoney);
                    }
                    break;
            }
        }
    }
}

//while player.autodeposit is enabled then run a loop to check money and deposit it
autoDeposit(player, args)
{
    if (!isDefined(player.autodeposit))
    {
        player.autodeposit = true;

        //if args[1] is a number then set it as deposit amount else set it to 1000
        if (isDefined(args[1]) && isInteger(args[1]) && int(args[1]) > 0)
            player.depositAmount = int(args[1]);
        else
            player.depositAmount = 1000;

        //if args[2] is a number then set it as keep amount else set it to 1000
        if (isDefined(args[2]) && isInteger(args[2]) && int(args[2]) > 0)
            player.keepAmount = int(args[2]);
        else
            player.keepAmount = 1000;
    }
    else 
    {
        if (isDefined(args[1]) && isInteger(args[1]) && int(args[1]) > 0)
            player.depositAmount = int(args[1]);
        if (isDefined(args[2]) && isInteger(args[2]) && int(args[2]) > 0)
            player.keepAmount = int(args[2]);

        //if either args are defined then enable autodeposit else toggle it
        if (!isDefined(args[1]))
            player.autodeposit = !player.autodeposit;
        else
            player.autodeposit = true;
    }
    
    if (player.autodeposit)
    {
        player iPrintLnBold("Auto deposit enabled: Depositing ^2$^7" + player.depositAmount + " from ^2$^7" + (player.depositAmount + player.keepAmount));
    }
    else
    {
        player iPrintLnBold("Auto deposit disabled");
    }

    for (;;)
    {
        if (!player.autodeposit)
            break;
        if (player.autodeposit && player.score >= (player.depositAmount + player.keepAmount))
        {
            storedMoney = json_get("Database.json", player getguid() + ".money");
            JSon_Add("Database.json", player getguid() + ".money", (int(storedMoney) + int(player.depositAmount)));

            player.score = player.score - int(player.depositAmount);
            player iPrintLn("^2$^7" + valueToString(player.depositAmount) + " auto deposited");
        }
        wait(1);
    }
}

doWhitdraw(player, args)
{
    if (getDvarIntDefault("sv_allowchatbank", 1) == 0)
    {
    }
    else if ((isDefined(player.whos_who_effects_active) && player.whos_who_effects_active) || (isDefined(player.fake_death) && player.fake_death))
    {
        player iPrintLnBold("Command disable during last stand with WhosWho perk");
    }
    else
    {
        if (isDefined(args[1]))
        {
            if (args[1] == "all")
            {
                storedMoney = json_get("Database.json", player getguid() + ".money");

                player.score = player.score + int(storedMoney);
                player iPrintLnBold("^2$^7" + storedMoney + " withdrawn");
                
                JSon_Add("Database.json", player getguid() + ".money", 0);
            }
            else
            {
                storedMoney = json_get("Database.json", player getguid() + ".money");
                if (isInteger(args[1]) && int(args[1]) > 0 && int(storedMoney) >= int(args[1]))
                {
                    player.score = player.score + int(args[1]);
                    JSon_Add("Database.json", player getguid() + ".money", (int(storedMoney) - int(args[1])));

                    player iPrintLnBold("^2$^7" + valueToString(args[1]) + " withdrawn");
                }
                else
                {
                    player iPrintLnBold("Invalid ammount");
                }
            }
        }
        else
        {
            player iPrintLnBold("Missing ammount");
        }
    }
}

doDeposit(player, args)
{
    if (getDvarIntDefault("sv_allowchatbank", 1) == 0)
    {
    }
    else
    {
        if (isDefined(args[1]))
        {
            if (args[1] == "all")
            {
                storedMoney = json_get("Database.json", player getguid() + ".money");
                score = player.score;
                JSon_Add("Database.json", player getguid() + ".money", (int(storedMoney) + int(score)));

                player.score = 0;
                player iPrintLnBold("^2$^7" + valueToString(score) + " deposited");
            }
            else
            {
                if (isInteger(args[1]) && player.score >= int(args[1]))
                {
                    storedMoney = json_get("Database.json", player getguid() + ".money");
                    JSon_Add("Database.json", player getguid() + ".money", (int(storedMoney) + int(args[1])));

                    player.score = player.score - int(args[1]);
                    player iPrintLnBold("^2$^7" + valueToString(args[1]) + " deposited");
                }
                else
                {
                    player iPrintLnBold("Invalid ammount");
                }
            }
        }
        else
        {
            player iPrintLnBold("Missing ammount");
        }
    }
}

valueToString(value) // Convert an integer to a better intger rappresentation, like 10025 to 10'025
{
    return value;
}

getDvarIntDefault(dvar, value)
{
    if(dvar == "")
        return getDvarInt(dvar);
    else
        return value;
}
