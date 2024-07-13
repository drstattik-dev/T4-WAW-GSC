#include common_scripts\utility;
#include maps\_utility;

addExp( amount )
{
    if (!isInteger(amount))
    {
        return;
    }
    currentExp = int(json_get("Database.json", self getguid() + ".exp"));
    json_add("Database.json", self getguid() + ".exp", currentExp + int(amount));
}

getExp()
{
    return int(json_get("Database.json", self getguid() + ".exp"));
}

getRank()
{
    return int(json_get("Database.json", self getguid() + ".level"));
}

addRank()
{
    currentRank = int(json_get("Database.json", self getguid() + ".level"));
    json_add("Database.json", self getguid() + ".level", currentRank + 1);
    json_add("Database.json", self getguid() + ".exp", 0);
    //add skill points
    json_add("Database.json", self getguid() + ".skillpoints", int(json_get("Database.json", self getguid() + ".skillpoints")) + 1);
}

//setup player database
SetupPlayerDatabase()
{
    path = "Database.json";
    DefaultDatabase = "{}";

    fileExists = FS_Exists(path);

    if (fileExists == 0)
    {
        f = FS_FOpen(path, "write"); // can be "read" "write", or "append"

        FS_Write(f, DefaultDatabase);

        FS_FClose(f); // make sure to close it
    }
    
    if (json_exists("Database.json", self getguid()) == 0)
    {
        self thread CreatePlayerDatabase();
    }
    //assertEx(write_file( path, content ) != -1, "Could not write file. <file:" + path + ">");
}

//setup map database
SetupMapDatabase()
{
    path = "MapDatabase.json";
    DefaultDatabase = "{}";

    fileExists = FS_Exists(path);

    if (fileExists == 0)
    {
        f = FS_FOpen(path, "write"); // can be "read" "write", or "append"

        FS_Write(f, DefaultDatabase);

        FS_FClose(f); // make sure to close it
    }
    playerCount = GetRealPlayerCount();
    playerKey = Getdvar( "mapname" ) + "." + playerCount + "p";

    if (json_exists("MapDatabase.json", playerKey) == 0)
    {
        
        playerKey = Getdvar( "mapname" ) + "." + playerCount + "p";
        JSon_Add("MapDatabase.json", playerKey, "{}");
        //self thread CreateMapDatabase();
    }
}

//create player database
CreatePlayerDatabase()
{
    JSon_Add("Database.json", self getguid() + ".exp", 0);
    JSon_Add("Database.json", self getguid() + ".level", 0);
    JSon_Add("Database.json", self getguid() + ".money", 100000);
    JSon_Add("Database.json", self getguid() + ".skillpoints", 0);

    JSon_Add("Database.json", self getguid() + ".skills.health", 0);
    JSon_Add("Database.json", self getguid() + ".skills.speed", 0);
    JSon_Add("Database.json", self getguid() + ".skills.damage", 0);
    JSon_Add("Database.json", self getguid() + ".skills.multi", 0);
    JSon_Add("Database.json", self getguid() + ".skills.headshot", 0);
    JSon_Add("Database.json", self getguid() + ".skills.ammo", 0);
}

//get player count
GetRealPlayerCount() {
    players = 0;
    
    level endon("disconnect");
    for ( i = 0; i <  level.players.size; i++ ) {
        player = level.players[i];
        if (!player IsBot()) {
            players++;
        }
    }
    return players;
}

isInteger( value ) // Check if the value contains only numbers
{
    new_int = int(value);
    
    if (value != "0" && new_int == 0) // 0 means its invalid
        return 0;
    
    if(new_int > 0)
        return 1;
    else
        return 0;
}
