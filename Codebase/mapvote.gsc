/*
======================================================================
|                         Game: Plutonium T5 	                     |
|                   Description : Let players vote                   |
|              for a map and mode at the end of each game            |
|                            Author: Resxt                           |
======================================================================
|   https://github.com/Resxt/Plutonium-T5-Scripts/tree/main/mapvote  |
======================================================================
*/

#include maps\_hud_util;
#include maps\_utility;
#include common_scripts\utility;
#include maps\_zombiemode_utility;
//#include maps\_zombiemode;

#include scripts\overflowFix;

/* Entry point */

Init()
{
    //if (GetDvarInt("mapvote_enable"))
    //{
        level thread mapvoteStart();
        level thread InitMapvote();
        level thread onPlayerConnect();
        
        set_zombie_var( "zombie_intermission_time", GetDvarInt("mapvote_vote_time") );
    //}
}
onPlayerConnect()
{
    
    replaceFunc( maps\_zombiemode::end_game, ::end_game_wrapper );
    for (;;)
    {
        level waittill("connected", player);
    }
}

end_game_wrapper()
{
    level waittill ( "end_game" );
    maps\_zombiemode::intermission();

	wait( level.zombie_vars["zombie_intermission_time"] );

	level notify( "stop_intermission" );

    wait(2);
    ExitLevel( );
}

mapvoteStart()
{
    for(;;)
    {
        
	    level waittill( "end_game" );
        
        //level.systemLink = false;
        //level.intermission = false;
        level thread StartVote();
        level thread ListenForEndVote();
    }
}

/* Init section */

InitMapvote()
{
    InitDvars();
    InitVariables();

    if (GetDvarInt("mapvote_debug"))
    {
        Print("[MAPVOTE] Debug mode is ON");
        wait 3;
        level thread StartVote();
        level thread ListenForEndVote();
    }
    else
    {
        // Starting the mapvote normally is handled in mp\mapvote_mp_extend.gsc and zm\mapvote_zm_extend.gsc
    }
}

InitDvars()
{
    SetDvarIfNotInitialized("mapvote_debug", false);

    SetDvarIfNotInitialized("mapvote_maps", "Mario64:Killhouse:Cryogenic:Leviathan v1.2:MW2 Rust:Stairway To Hell:Dead Ship:Zombies Overrun");
    SetDvarIfNotInitialized("mapvote_limits_maps", 0);
    SetDvarIfNotInitialized("mapvote_sounds_menu_enabled", 1);
    SetDvarIfNotInitialized("mapvote_sounds_timer_enabled", 1);
    SetDvarIfNotInitialized("mapvote_limits_max", 5);
    SetDvarIfNotInitialized("mapvote_colors_selected", "cyan");
    SetDvarIfNotInitialized("mapvote_colors_unselected", "white");
    SetDvarIfNotInitialized("mapvote_colors_timer", "cyan");
    SetDvarIfNotInitialized("mapvote_colors_timer_low", "red");
    SetDvarIfNotInitialized("mapvote_colors_help_text", "white");
    SetDvarIfNotInitialized("mapvote_colors_help_accent", "cyan");
    SetDvarIfNotInitialized("mapvote_colors_help_accent_mode", "standard");
    SetDvarIfNotInitialized("mapvote_vote_time", 30);
    SetDvarIfNotInitialized("mapvote_blur_level", 2.5);
    SetDvarIfNotInitialized("mapvote_horizontal_spacing", 75);
    SetDvarIfNotInitialized("mapvote_display_wait_time", 1);
}

InitVariables()
{
    mapsArray = StrTok(GetDvar("mapvote_maps"), ":");
    voteLimits = [];

    if (GetDvarInt("mapvote_limits_maps") == 0 )
    {
        voteLimits = GetVoteLimits(mapsArray.size);
    }
    else if (GetDvarInt("mapvote_limits_maps") > 0 )
    {
        voteLimits = GetVoteLimits(GetDvarInt("mapvote_limits_maps"));
    }

    level.mapvote["limit"]["maps"] = voteLimits["maps"];

    SetMapvoteData("map");

    level.mapvote["vote"]["maps"] = [];
    level.mapvote["hud"]["maps"] = [];
}



/* Player section */

/*
This is used instead of notifyonplayercommand("mapvote_up", "speed_throw") 
to fix an issue where players using toggle ads would have to press right click twice for it to register one right click.
With this instead it keeps scrolling every 0.25s until they right click again which is a better user experience
*/
ListenForRightClick()
{
    self endon("disconnect");

    while (true)
    {
        if (self AdsButtonPressed())
        {
            self notify("mapvote_up");
            wait 0.25;
        }

        wait 0.05;
    }
}

ListenForButtonPressed()
{
    self endon("disconnect");

    for(;;)
    {
        
		if (self AdsButtonPressed())
        {
            self notify("mapvote_up");
            wait(0.25);
        }
        else if (self AttackButtonPressed())
        {
            self notify("mapvote_down");
            wait(0.25);
        }
        else if (self UseButtonPressed())
        {
            self notify("mapvote_select");
            wait(0.25);
        }
        else if (self MeleeButtonPressed())
        {
            self notify("mapvote_unselect");
            wait(0.25);
        }
        wait(0.05);
    }
}

ListenForVoteInputs()
{
    self endon("disconnect");
    self thread ListenForButtonPressed();
    //self thread ListenForRightClick();
    //self thread ListenForAttack();

    //self notifyonplayercommand("mapvote_down", "+attack");
    //self notifyonplayercommand("mapvote_select", "+usereload");
    //self notifyonplayercommand("mapvote_select", "+activate");
    //self notifyonplayercommand("mapvote_unselect", "+melee");
    
    //if (GetDvarInt("mapvote_debug"))
    //{
        //self notifyonplayercommand("mapvote_debug", "+reload");
    //}

    while(true)
    {

        input = self waittill_any_return("mapvote_down", "mapvote_up", "mapvote_select", "mapvote_unselect", "mapvote_debug");
        //iPrintLnBold(input);

        section = self.mapvote["vote_section"];

        if (section == "end" && input != "mapvote_unselect" && input != "mapvote_debug")
        {
            continue; // stop/skip execution
        }

        if (input == "mapvote_down")
        {
            if (self.mapvote[section]["hovered_index"] < (level.mapvote[section + "s"]["by_index"].size - 1))
            {
                if (GetDvarInt("mapvote_sounds_menu_enabled"))
                {
                    self playlocalsound("uin_timer_wager_beep");
                }

                self UpdateSelection(section, (self.mapvote[section]["hovered_index"] + 1));
            }
        }
        else if (input == "mapvote_up")
        {
            if (self.mapvote[section]["hovered_index"] > 0)
            {
                if (GetDvarInt("mapvote_sounds_menu_enabled"))
                {
                    self playlocalsound("uin_timer_wager_beep");
                }

                self UpdateSelection(section, (self.mapvote[section]["hovered_index"] - 1));
            }
        }
        else if (input == "mapvote_select")
        {
            if (GetDvarInt("mapvote_sounds_menu_enabled"))
            {
                self playlocalsound("fly_equipment_pickup_plr");
            }

            self ConfirmSelection(section);
        }
        else if (input == "mapvote_unselect")
        {
            if (section != "map")
            {
                if (GetDvarInt("mapvote_sounds_menu_enabled"))
                {
                    self playlocalsound("mpl_flag_drop_plr");
                }

                self CancelSelection(section);
            }
        }

        wait 0.05;
    }
}

OnPlayerDisconnect()
{
    self waittill("disconnect");

    if (self.mapvote["map"]["selected_index"] != -1)
    {
        level.mapvote["vote"]["maps"][self.mapvote["map"]["selected_index"]] = (level.mapvote["vote"]["maps"][self.mapvote["map"]["selected_index"]] - 1);
        elemText = level.mapvote["hud"]["maps"][self.mapvote["map"]["selected_index"]].current_text;
        elemValue = level.mapvote["vote"]["maps"][self.mapvote["map"]["selected_index"]];
        level.mapvote["hud"]["maps"][self.mapvote["map"]["selected_index"]] set_safe_text(elemText, elemValue);
        //level.mapvote["hud"]["maps"][self.mapvote["map"]["selected_index"]] SetValue(level.mapvote["vote"]["maps"][self.mapvote["map"]["selected_index"]]);
    }
}


/* Vote section */

CreateVoteMenu()
{
    spacing = 20;
    hudLastPosY = 0;

    hudLastPosY = 0 - (((level.mapvote["maps"]["by_index"].size  * spacing) / 2) - (spacing / 2));

    humanPlayers = GetHumanPlayers();
    //level iPrintLnBold("Players: " + humanPlayers.size);
    //level iPrintLnBold("Maps: " + level.mapvote["maps"]["by_index"].size);

    for (mapIndex = 0; mapIndex < level.mapvote["maps"]["by_index"].size; mapIndex++)
    {
        mapVotesHud = CreateHudText("", "left", "middle", GetDvarInt("mapvote_horizontal_spacing"), hudLastPosY, true, 0);
        mapVotesHud.color = GetGscColor(GetDvar("mapvote_colors_selected"));

        level.mapvote["hud"]["maps"][mapIndex] = mapVotesHud;

        for (i = 0; i < humanPlayers.size; i++)
        {
            mapName = level.mapvote["maps"]["by_index"][mapIndex];

            humanPlayers[i].mapvote["map"][mapIndex]["hud"] = humanPlayers[i] CreateHudText(mapName, "left", "middle", 0 - (GetDvarInt("mapvote_horizontal_spacing")), hudLastPosY);

            if (mapIndex == 0)
            {
                humanPlayers[i] UpdateSelection("map", 0);
            }
            else
            {
                SetElementUnselected(humanPlayers[i].mapvote["map"][mapIndex]["hud"]);
            }
        }

        hudLastPosY += spacing;
    }

    for (i = 0; i < humanPlayers.size; i++)
    {
        humanPlayers[i].mapvote["map"]["selected_index"] = -1;

        buttonsHelpMessage = "";

        // before: select gostand | unselect activate
    // after: select activate | unselect melee

        if (GetDvar("mapvote_colors_help_accent_mode") == "standard")
        {
            buttonsHelpMessage = GetChatColor(GetDvar("mapvote_colors_help_text")) + "Press " + GetChatColor(GetDvar("mapvote_colors_help_accent")) + "[{+attack}] " + GetChatColor(GetDvar("mapvote_colors_help_text")) + "to go down - Press " + GetChatColor(GetDvar("mapvote_colors_help_accent")) + "[{+speed_throw}] " + GetChatColor(GetDvar("mapvote_colors_help_text")) + "to go up - Press " + GetChatColor(GetDvar("mapvote_colors_help_accent")) + "[{+activate}] " + GetChatColor(GetDvar("mapvote_colors_help_text")) + "to select - Press " + GetChatColor(GetDvar("mapvote_colors_help_accent")) + "[{+melee}] " + GetChatColor(GetDvar("mapvote_colors_help_text")) + "to undo";
        }
        else if(GetDvar("mapvote_colors_help_accent_mode") == "max")
        {
            buttonsHelpMessage = GetChatColor(GetDvar("mapvote_colors_help_text")) + "Press " + GetChatColor(GetDvar("mapvote_colors_help_accent")) + "[{+attack}] " + GetChatColor(GetDvar("mapvote_colors_help_text")) + "to go " + GetChatColor(GetDvar("mapvote_colors_help_accent")) + "down " + GetChatColor(GetDvar("mapvote_colors_help_text")) + "- Press " + GetChatColor(GetDvar("mapvote_colors_help_accent")) + "[{+speed_throw}] " + GetChatColor(GetDvar("mapvote_colors_help_text")) + "to go " + GetChatColor(GetDvar("mapvote_colors_help_accent")) + "up " + GetChatColor(GetDvar("mapvote_colors_help_text")) + "- Press " + GetChatColor(GetDvar("mapvote_colors_help_accent")) + "[{+activate}] " + GetChatColor(GetDvar("mapvote_colors_help_text")) + "to " + GetChatColor(GetDvar("mapvote_colors_help_accent")) + "select " + GetChatColor(GetDvar("mapvote_colors_help_text")) + "- Press " + GetChatColor(GetDvar("mapvote_colors_help_accent")) + "[{+melee}] " + GetChatColor(GetDvar("mapvote_colors_help_text")) + "to " + GetChatColor(GetDvar("mapvote_colors_help_accent")) + "undo";
        }

        humanPlayers[i] CreateHudText(buttonsHelpMessage, "center", "middle", 0, 210);
    }
}

CreateVoteTimer()
{
	soundFX = spawn("script_origin", (0,0,0));
	soundFX hide();
	
	timerhud = thread CreateTimer(GetDvarInt("mapvote_vote_time"), "Vote ends in: ", "center", "middle", 0, -210);		
    timerhud.color = GetGscColor(GetDvar("mapvote_colors_timer"));
	for (i = GetDvarInt("mapvote_vote_time"); i > 0; i--)
	{	
		if(i <= 5) 
		{
			timerhud.color = GetGscColor(GetDvar("mapvote_colors_timer_low"));

            if (GetDvarInt("mapvote_sounds_timer_enabled"))
            {
                soundFX playSound( "mpl_ui_timer_countdown" );
            }
		}
		wait(1);
	}	
	level notify("mapvote_vote_end");
}



StartVote()
{
    level endon("end_game");

    for (i = 0; i < level.mapvote["maps"]["by_index"].size; i++)
    {
        level.mapvote["vote"]["maps"][i] = 0;
    }

    level thread CreateVoteMenu();
    level thread CreateVoteTimer();

    //level.game_over delete();
    //level.survived delete();
    
    humanPlayers = GetHumanPlayers();

    for (i = 0; i < humanPlayers.size; i++)
    {
        humanPlayers[i].ignoreme = true; 
        humanPlayers[i].godmode = true;
        humanPlayers[i] freezeControls( true );
        //humanPlayers[i] FreezeControlsAllowLook(1);
        //humanPlayers[i] SetBlur(GetDvarInt("mapvote_blur_level"), GetDvarInt("mapvote_blur_fade_in_time"));
	   humanPlayers[i] SetClientDvar("r_blur", GetDvarInt("mapvote_blur_level"));

        humanPlayers[i] thread ListenForVoteInputs();
        humanPlayers[i] thread OnPlayerDisconnect();
    }
}

ListenForEndVote()
{
    level endon("end_game");
    level waittill("mapvote_vote_end");

    mostVotedMapIndex = 0;
    mostVotedMapVotes = 0;

    mapsArrayKeys = GetArrayKeys(level.mapvote["vote"]["maps"]);

    for (i = 0; i < mapsArrayKeys.size; i++)
    {
        if (level.mapvote["vote"]["maps"][mapsArrayKeys[i]] > mostVotedMapVotes)
        {
            mostVotedMapIndex = mapsArrayKeys[i];
            mostVotedMapVotes = level.mapvote["vote"]["maps"][mapsArrayKeys[i]];
        }
    }

    if (mostVotedMapVotes == 0)
    {
        mostVotedMapIndex = GetRandomElementInArray(GetArrayKeys(level.mapvote["vote"]["maps"]));

        if (GetDvarInt("mapvote_debug"))
        {
            Print("[MAPVOTE] No vote for map. Chosen random map index: " + mostVotedMapIndex);
        }
    }
    else
    {
        if (GetDvarInt("mapvote_debug"))
        {
            Print("[MAPVOTE] Most voted map has " + mostVotedMapVotes + " votes. Most voted map index: " + mostVotedMapIndex);
        }
    }

    mapName = GetMapCodeName(level.mapvote["maps"]["by_index"][mostVotedMapIndex]);

    SetDvar("sv_maprotationcurrent", "");
    SetDvar("sv_maprotation", mapName);
}

SetMapvoteData(type)
{
    limit = level.mapvote["limit"][type + "s"];

    availableElements = StrTok(GetDvar("mapvote_" + type + "s"), ":");

    if (availableElements.size < limit)
    {
        limit = availableElements.size;
    }

    if (type == "map")
    {
        level.mapvote["maps"]["by_index"] = GetRandomUniqueElementsInArray(availableElements, limit);
    }
}

/*
Gets the amount of maps to display on screen
This is used to get default values if the limits dvars are not set
It will dynamically adjust the amount of maps to show
*/
GetVoteLimits(mapsAmount)
{
    maxLimit = GetDvarInt("mapvote_limits_max");
    limits = [];

    if ((mapsAmount) <= maxLimit)
    {
        limits["maps"] = mapsAmount;
    }
    else
    {
        if (mapsAmount >= maxLimit)
        {

            limits["maps"] = maxLimit;
        }
    }
    
    return limits;
}



/* HUD section */

UpdateSelection(type, index)
{
    if (type == "map")
    {
        if (!IsDefined(self.mapvote[type]["hovered_index"]))
        {
            self.mapvote[type]["hovered_index"] = 0;
        }

        self.mapvote["vote_section"] = type;

        SetElementUnselected(self.mapvote[type][self.mapvote[type]["hovered_index"]]["hud"]); // Unselect previous element
        SetElementSelected(self.mapvote[type][index]["hud"]); // Select new element

        self.mapvote[type]["hovered_index"] = index; // Update the index
    }
    else if (type == "end")
    {
        self.mapvote["vote_section"] = "end";
    }
}

ConfirmSelection(type)
{
    self.mapvote[type]["selected_index"] = self.mapvote[type]["hovered_index"];
    level.mapvote["vote"][type + "s"][self.mapvote[type]["selected_index"]] = (level.mapvote["vote"][type + "s"][self.mapvote[type]["selected_index"]] + 1);
    elemText = level.mapvote["hud"][type + "s"][self.mapvote[type]["selected_index"]].current_text;
    elemValue = level.mapvote["vote"][type + "s"][self.mapvote[type]["selected_index"]];
    level.mapvote["hud"][type + "s"][self.mapvote[type]["selected_index"]] set_safe_text(elemText, elemValue);
    //level.mapvote["hud"][type + "s"][self.mapvote[type]["selected_index"]] SetValue(level.mapvote["vote"][type + "s"][self.mapvote[type]["selected_index"]]);

    if (type == "map")
    {
        self UpdateSelection("end");
    }
}

CancelSelection(type)
{
    typeToCancel = "";

    if (type == "end")
    {
        typeToCancel = "map";
    }

    level.mapvote["vote"][typeToCancel + "s"][self.mapvote[typeToCancel]["selected_index"]] = (level.mapvote["vote"][typeToCancel + "s"][self.mapvote[typeToCancel]["selected_index"]] - 1);
    elemText = level.mapvote["hud"][typeToCancel + "s"][self.mapvote[typeToCancel]["selected_index"]].current_text;
    elemValue = level.mapvote["vote"][typeToCancel + "s"][self.mapvote[typeToCancel]["selected_index"]];
    level.mapvote["hud"][typeToCancel + "s"][self.mapvote[typeToCancel]["selected_index"]] set_safe_text(elemText, elemValue);
    //level.mapvote["hud"][typeToCancel + "s"][self.mapvote[typeToCancel]["selected_index"]] SetValue(level.mapvote["vote"][typeToCancel + "s"][self.mapvote[typeToCancel]["selected_index"]]);

    self.mapvote[typeToCancel]["selected_index"] = -1;

    if (type == "end")
    {
        self.mapvote["vote_section"] = "map";
    } else
    {
        self.mapvote["vote_section"] = "map";
    }
}

SetElementSelected(element)
{
    element.color = GetGscColor(GetDvar("mapvote_colors_selected"));
}

SetElementUnselected(element)
{
    element.color = GetGscColor(GetDvar("mapvote_colors_unselected"));
}

CreateHudText(text, relativeToX, relativeToY, relativeX, relativeY, isServer, value)
{
    
    horzAlign = "center";
    vertAlign = "middle";

    //hudText = level createElem(horzAlign, vertAlign, relativeToX, relativeToY, relativeX, relativeY, (1, 1, 1), true);



    //hudText = "";

    if (IsDefined(isServer) && isServer)
    {
        hudText = level createElem(horzAlign, vertAlign, relativeToX, relativeToY, relativeX, relativeY, (1, 1, 1), true);
        hudText.fontScale = 1.25;
        //hudText = CreateServerFontString( font, fontScale );
    }
    else
    {
        hudText = self createElem(horzAlign, vertAlign, relativeToX, relativeToY, relativeX, relativeY, (1, 1, 1));
        hudText.fontScale = 1.25;
        //hudText = CreateFontString( font, fontScale );
    }

    if (IsDefined(value))
    {
        
        hudText set_safe_text(text, value);
        //hudText.label = text;
        //hudText SetValue(value);
    }
    else
    {
        hudText set_safe_text(text);
        //hudText SetText(text);
    }

    //hudText SetPoint(relativeToX, relativeToY, relativeX, relativeY);
    
    hudText.hideWhenInMenu = 1;
    hudText.glowAlpha = 0;

    return hudText;
}

CreateTimer(time, label, relativeToX, relativeToY, relativeX, relativeY)
{
    horzAlign = "center";
    vertAlign = "middle";

    timer = level createElem(horzAlign, vertAlign, relativeToX, relativeToY, relativeX, relativeY, (1, 1, 1), true);
    timer.fontScale = 1.25;

	//timer = createServerTimer(font, fontScale);	
	//timer setpoint(relativeToX, relativeToY, relativeX, relativeY);
	//timer.label = label; 
    timer.hideWhenInMenu = 1;
    timer.glowAlpha = 0;
	//timer setTimer(time);
    timer thread startTimerCountdown(label, time);
	
	return timer;
}

startTimerCountdown(label, time)
{
    t = 0;
    for(;;)
    {
        if (t >= time)
        {
            break;
        }
        t++;
        self set_safe_text(label + ": " + (time-t));
        wait(1);
    }
}

/* Utils section */

SetDvarIfNotInitialized(dvar, value)
{
	if (!IsInitialized(dvar))
    {
        SetDvar(dvar, value);
    }
}

IsInitialized(dvar)
{
	result = GetDvar(dvar);
	return result != "";
}

IsBot()
{
    return IsDefined(self.pers["isBot"]) && self.pers["isBot"];
}

GetHumanPlayers()
{
    return get_players();
}

GetRandomElementInArray(array)
{
    return array[GetArrayKeys(array)[randomint(array.size)]];
}

GetRandomUniqueElementsInArray(array, limit)
{
    finalElements = [];

    for (i = 0; i < limit; i++)
    {
        findElement = true;

        while (findElement)
        {
            randomElement = GetRandomElementInArray(array);

            if (!ArrayContainsValue(finalElements, randomElement))
            {
                finalElements = AddElementToArray(finalElements, randomElement);

                findElement = false;
            }
        }
    }

    return finalElements;
}

ArrayContainsValue(array, valueToFind)
{
    if (array.size == 0)
    { 
        return false;
    }

    for (i = 0; i < array.size; i++)
    {
        if (array[i] == valueToFind)
        {
            return true;
        }
    }

    return false;
}

AddElementToArray(array, element)
{
    array[array.size] = element;
    return array;
}

GetMapCodeName(mapName)
{
    formattedMapName = ToLower(mapName);
    
    switch(formattedMapName)
    {
        case "mario64":
        return "loadmod mods/SuperMario64 map mario";

        case "killhouse":
        return "loadmod mods/IWKillHouse map killhouse";

        case "cryogenic":
        return "loadmod mods/Cryogenic map Cryogenic";

        case "stairway to hell":
        return "loadmod mods/Return_To_Stairway_To_Hell map rtsth1";

        case "leviathan v1.2":
        return "loadmod mods/nazi_zombie_leviathan_v1.2 map nazi_zombie_leviathan";

        case "mw2 rust":
        return "loadmod mods/mw2rust map mw2rust";

        case "dead ship":
        return "loadmod mods/dead_ship map dead_ship";

        case "zombies overrun":
        return "loadmod mods/nazi_zombie_overrun map nazi_zombie_overrun";

    }
}

GetGscColor(colorName)
{
    switch (colorName)
	{
        case "red":
        return (1, 0, 0.059);

        case "green":
        return (0.549, 0.882, 0.043);

        case "yellow":
        return (1, 0.725, 0);

        case "blue":
        return (0, 0.553, 0.973);

        case "cyan":
        return (0, 0.847, 0.922);

        case "purple":
        return (0.427, 0.263, 0.651);

        case "white":
        return (1, 1, 1);

        case "grey":
        case "gray":
        return (0.137, 0.137, 0.137);

        case "black":
        return (0, 0, 0);
	}
}

GetChatColor(colorName)
{
    switch(colorName)
    {
        case "red":
        return "^1";

        case "green":
        return "^2";

        case "yellow":
        return "^3";

        case "blue":
        return "^4";

        case "cyan":
        return "^5";

        case "purple":
        return "^6";

        case "white":
        return "^7";

        case "grey":
        return "^0";

        case "black":
        return "^0";
    }
}
