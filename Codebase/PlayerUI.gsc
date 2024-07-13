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
        
        player thread initOverflowFix();
        
        player thread skillView();

        player.Skills thread destroyEleme();
    }
}

/*
"2479020": {
  "exp": "0",
  "level": "0",
  "money": "0",
  "skillpoints": "0",
  "skills": {
   "armor": "0",
   "damage": "0",
   "health": "0",
   "jump": "0",
   "regeneration": "0",
   "speed": "0",
   "stamina": "0"
  }
  */
initSkillsOnPlayer()
{
    self.SkillPoints = 0;
    self.Hlth = 0;
    self.Speed = 0;
    self.Damage = 0;
    self.Multi = 0;
    self.Headshot = 0;
    self.Ammo = 0;
    
    self thread startHealthSkill();
    self thread startSpeedSkill();
    self thread startDamageSkill();
}

//health skill adds 10 health per skill point
startHealthSkill()
{
    for(;;)
    {
        //self iPrintLnBold(GetDvarFloat("player_damageMultiplier"));
        if (self hasperk("specialty_armorvest"))
        {
            self.MaxHealth = 250 + (self.Hlth * 10);
        } else {
            self.MaxHealth = 100 + (self.Hlth * 10);
        }
        wait(1);
    }
}

//speed skill adds 0.10 to level.current_player_speed per skill point
startSpeedSkill()
{
    //wait for player to spawn
    self waittill("spawned_player");
    for(;;)
    {
        //if 
        //self setclientdvar("g_speed", (1.9 + (self.Speed * 0.10)) * 100);
        self SetMoveSpeedScale( 1.00 + (self.Speed * 0.10) );
        wait(0.05);
    }
}

startDamageSkill()
{
    for(;;)
    {
        enemies = [];
        enemies = GetAiSpeciesArray( "axis", "all" );

        //loop through all enemies and waittill damage and add multiplier
        for ( i = 0; i < enemies.size; i++ )
        {
            if (!isDefined(enemies[i].onDamaged))
            {
                enemies[i].onDamaged = true;
                level thread addDamageMultiplier(enemies[i], self);
            }
        }

        wait(1);
    }
}

addDamageMultiplier(zomb, plr)
{
    level endon("disconnect");

    for (;;)
    {

        zomb waittill("damage", damage, attacker, direction_vec, point, type, modelName, tagName, iDnum, weapon);
        zomb dodamage(attacker.Damage * 5, zomb.origin, plr);
    }
}

haveSkillsChanged()
{

    //if skills dont exist in self then create them
    if (!isDefined(self.SkillPoints) || !isDefined(self.Hlth) || !isDefined(self.Speed) || !isDefined(self.Damage) || !isDefined(self.Multi) || !isDefined(self.Headshot) || !isDefined(self.Ammo))
    {
        initSkillsOnPlayer();
    }
    if (self.SkillPoints != int(json_get("Database.json", self getguid() + ".skillpoints")) ||
        self.Hlth != int(json_get("Database.json", self getguid() + ".skills.health")) ||
        self.Speed != int(json_get("Database.json", self getguid() + ".skills.speed")) ||
        self.Damage != int(json_get("Database.json", self getguid() + ".skills.damage")) ||
        self.Multi != int(json_get("Database.json", self getguid() + ".skills.multi")) ||
        self.Headshot != int(json_get("Database.json", self getguid() + ".skills.headshot")) ||
        self.Ammo != int(json_get("Database.json", self getguid() + ".skills.ammo")))
    {
        return true;
    }
    return false;

}

skillView()
{
    self endon("end_game");
    self endon("disconnect");
    
    horzAlign = "center";
    vertAlign = "top";
    alignX = "center";
    alignY = "middle";
    
    //player skills
    self.Skills = self createElem(horzAlign, vertAlign, alignX, alignY, 0, 17, (1, 1, 1));

	for(;;)
	{
        //player stats vars
        if (haveSkillsChanged())
        {
            self.SkillPoints = int(json_get("Database.json", self getguid() + ".skillpoints"));
            self.Hlth = int(json_get("Database.json", self getguid() + ".skills.health"));
            self.Speed = int(json_get("Database.json", self getguid() + ".skills.speed"));
            self.Damage = int(json_get("Database.json", self getguid() + ".skills.damage"));
            self.Headshot = int(json_get("Database.json", self getguid() + ".skills.headshot"));
            self.Multi = int(json_get("Database.json", self getguid() + ".skills.multi"));
            self.Ammo = int(json_get("Database.json", self getguid() + ".skills.ammo"));

        }
        self.Skills set_safe_text( "^7Skill Points: ^2" + self.SkillPoints + " ^7Health: ^3" + self.Hlth + " ^7Speed: ^3" + self.Speed + " ^7Damage: ^3" + self.Damage + " ^7Headshot: ^3" + self.Headshot + " ^7Multi: ^3" + self.Multi + " ^7Ammo: ^3" + self.Ammo);


		wait(3);
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