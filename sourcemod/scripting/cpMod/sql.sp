/**
 *
 * =============================================================================
 *
 * =============================================================================
 *
 * This program is free software; you can redistribute it and/or modify it under
 * the terms of the GNU General Public License, version 3.0, as published by the
 * Free Software Foundation.
 * 
 * This program is distributed in the hope that it will be useful, but WITHOUT
 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 * FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
 * details.
 *
 * You should have received a copy of the GNU General Public License along with
 * this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 * As a special exception, AlliedModders LLC gives you permission to link the
 * code of this program (as well as its derivative 1works) to "Half-Life 2," the
 * "Source Engine," the "SourcePawn JIT," and any Game MODs that run on software
 * by the Valve Corporation.  You must obey the GNU General Public License in
 * all respects for all other code used.  Additionally, AlliedModders LLC grants
 * this exception to all derivative works.  AlliedModders LLC defines further
 * exceptions, found in LICENSE.txt,
 * or <http://www.sourcemod.net/license.php>.
 *
 *
 */

//-------------------//
// many variables :) //
//-------------------//
new String:sqlite_createMap[] = "CREATE TABLE IF NOT EXISTS map (mapname VARCHAR(32) PRIMARY KEY, start0 VARCHAR(38) NOT NULL DEFAULT '0:0:0', start1 VARCHAR(38) NOT NULL DEFAULT '0:0:0', end0 VARCHAR(38) NOT NULL DEFAULT '0:0:0', end1 VARCHAR(38) NOT NULL DEFAULT '0:0:0');";
new String:sql_createMap[] = "CREATE TABLE IF NOT EXISTS map (mapname VARCHAR(32) PRIMARY KEY, start0 VARCHAR(38) NOT NULL DEFAULT '0:0:0', start1 VARCHAR(38) NOT NULL DEFAULT '0:0:0', end0 VARCHAR(38) NOT NULL DEFAULT '0:0:0', end1 VARCHAR(38) NOT NULL DEFAULT '0:0:0');";
new String:sqlite_createPlayer[] = "CREATE TABLE IF NOT EXISTS player (steamid VARCHAR(32), mapname VARCHAR(32), name VARCHAR(32), cords VARCHAR(38) NOT NULL DEFAULT '0:0:0', angle VARCHAR(38) NOT NULL DEFAULT '0:0:0', jumps INT(12) NOT NULL DEFAULT '-1', runtime INT(12) NOT NULL DEFAULT '-1', date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP, PRIMARY KEY(steamid,mapname));";
new String:sql_createPlayer[] = "CREATE TABLE IF NOT EXISTS player (steamid VARCHAR(32), mapname VARCHAR(32), name VARCHAR(32), cords VARCHAR(38) NOT NULL DEFAULT '0:0:0', angle VARCHAR(38) NOT NULL DEFAULT '0:0:0', jumps INT(12) NOT NULL DEFAULT '-1', runtime INT(12) NOT NULL DEFAULT '-1', date TIMESTAMP ON UPDATE CURRENT_TIMESTAMP, PRIMARY KEY(steamid,mapname);";

new String:sqlite_insertMap[] = "INSERT INTO map (mapname) VALUES('%s');";
new String:sql_insertMap[] = "INSERT INTO map (mapname) VALUES('%s');";
new String:sqlite_insertPlayer[] = "INSERT INTO player (steamid, mapname, name) VALUES('%s', '%s', '%s');";
new String:sql_insertPlayer[] = "INSERT INTO player (steamid, mapname, name) VALUES('%s', '%s', '%s');";

new String:sqlite_updateMapStart[] = "UPDATE map SET start0 = '%s', start1 = '%s' WHERE mapname = '%s';";
new String:sql_updateMapStart[] = "UPDATE map SET start0 = '%s', start1 = '%s' WHERE mapname = '%s';";
new String:sqlite_updateMapEnd[] = "UPDATE map SET end0 = '%s', end1 = '%s' WHERE mapname = '%s';";
new String:sql_updateMapEnd[] = "UPDATE map SET end0 = '%s', end1 = '%s' WHERE mapname = '%s';";

new String:sqlite_updatePlayerCheckpoint[] = "UPDATE player SET name = '%s', cords = '%s', angle = '%s', date = datetime('now') WHERE steamid = '%s' AND mapname = '%s';";
new String:sql_updatePlayerCheckpoint[] = "UPDATE player SET name = '%s', cords = '%s', angle = '%s', date = CURRENT_TIMESTAMP WHERE steamid = '%s' AND mapname = '%s';";
new String:sqlite_updatePlayerRecord[] = "UPDATE player SET name = '%s', jumps = '%i', runtime = '%i', date = datetime('now') WHERE steamid = '%s' AND mapname = '%s';";
new String:sql_updatePlayerRecord[] = "UPDATE player SET name = '%s', jumps = '%i', runtime = '%i', date = CURRENT_TIMESTAMP WHERE steamid = '%s' AND mapname = '%s';";

new String:sqlite_selectMapStartStop[] = "SELECT start0, start1, end0, end1 FROM map WHERE mapname = '%s'";
new String:sql_selectMapStartStop[] = "SELECT start0, start1, end0, end1 FROM map WHERE mapname = '%s'";
new String:sqlite_selectCheckpoint[] = "SELECT cords, angle FROM player WHERE steamid = '%s' AND mapname = '%s';";
new String:sql_selectCheckpoint[] = "SELECT cords, angle FROM player WHERE steamid = '%s' AND mapname = '%s';";
new String:sqlite_selectWorldRecordTime[] = "SELECT jumps, runtime FROM player WHERE mapname = '%s' AND jumps NOT LIKE '-1' AND runtime NOT LIKE '-1' ORDER BY runtime ASC LIMIT 1;";
new String:sql_selectWorldRecordTime[] = "SELECT jumps, runtime FROM player WHERE mapname = '%s' AND jumps NOT LIKE '-1' AND runtime NOT LIKE '-1' ORDER BY runtime ASC LIMIT 1;";
new String:sqlite_selectWorldRecordJump[] = "SELECT jumps, runtime FROM player WHERE mapname = '%s' AND jumps NOT LIKE '-1' AND runtime NOT LIKE '-1' ORDER BY jumps ASC LIMIT 1;";
new String:sql_selectWorldRecordJump[] = "SELECT jumps, runtime FROM player WHERE mapname = '%s' AND jumps NOT LIKE '-1' AND runtime NOT LIKE '-1' ORDER BY jumps ASC LIMIT 1;";

new String:sqlite_selectRecord[] = "SELECT name, jumps, runtime, date FROM player WHERE steamid = '%s' AND mapname = '%s';";
new String:sql_selectRecord[] = "SELECT name, jumps, runtime, date FROM player WHERE steamid = '%s' AND mapname = '%s';";

new String:sqlite_selectTopRecordTime[] = "SELECT name, runtime FROM player WHERE mapname = '%s' AND runtime NOT LIKE '-1' ORDER BY runtime ASC LIMIT 10;";
new String:sql_selectTimeWorldRecord[] = "SELECT name, runtime FROM player WHERE mapname = '%s' AND runtime NOT LIKE '-1' ORDER BY runtime ASC LIMIT 10;";
new String:sqlite_selectJumpWorldRecord[] = "SELECT name, jumps FROM player WHERE mapname = '%s' AND jumps NOT LIKE '-1' ORDER BY jumps ASC LIMIT 10;";
new String:sql_selectJumpWorldRecord[] = "SELECT name, jumps FROM player WHERE mapname = '%s' AND jumps NOT LIKE '-1' ORDER BY jumps ASC LIMIT 10;";

new String:sqlite_purgePlayers[] = "DELETE FROM players WHERE date < datetime('now', '-%i days');";
new String:sql_purgePlayers[] = "DELETE FROM players WHERE date < DATE_SUB(CURDATE(),INTERVAL %i DAY);";

new String:sqlite_resetMap[] = "DROP TABLE map; VACCUM";
new String:sql_resetMap[] = "DROP TABLE map;";
new String:sqlite_resetPlayer[] = "DROP TABLE player; VACCUM";
new String:sql_resetPlayer[] = "DROP TABLE player;";
new String:sqlite_resetPlayerCheckpoint[] = "UPDATE player SET cords = '0:0:0', angle = '0:0:0';";
new String:sql_resetPlayerCheckpoint[] = "UPDATE player SET cords = '0:0:0', angle = '0:0:0';";
new String:sqlite_resetPlayerRecord[] = "UPDATE player SET jumps = '-1', runtime = '-1';";
new String:sql_resetPlayerRecord[] = "UPDATE player SET jumps = '-1', runtime = '-1';";


//-------------------------//
// database initialization //
//-------------------------//
public db_setupDatabase(){
	decl String:error[255];
	db = SQL_Connect("cpmod", false, error, 255);
	
	//if a connection canot be made
	if(db == INVALID_HANDLE){
		LogError("[cP Mod] Unable to connect to database (%s)", error);
		return;
	}
	
	decl String:ident[8];
	SQL_ReadDriver(db, ident, 8);
	//select the driver depending on the settings (mysql/sqlite)
	if(strcmp(ident, "mysql", false) == 0){
		g_dbtype = MYSQL;
	} else if(strcmp(ident, "sqlite", false) == 0){
		g_dbtype = SQLITE;
	} else {
		LogError("[cP Mod] Invalid Database-Type");
		return;
	}
	
	//create the tables
	db_createTables();
}

//-----------------------//
// table creation method //
//-----------------------//
public db_createTables(){
	SQL_LockDatabase(db);
	
	//execute queries depending on driver
	if(g_dbtype == MYSQL){
		SQL_FastQuery(db, sql_createMap);
		SQL_FastQuery(db, sql_createPlayer);
	} else{
		SQL_FastQuery(db, sqlite_createMap);
		SQL_FastQuery(db, sqlite_createPlayer);
	}
	
	SQL_UnlockDatabase(db);
}

//-------------------//
// insert map method //
//-------------------//
public db_insertMap(){
	decl String:query[255];
	
	if(g_dbtype == MYSQL)
		Format(query, 255, sql_insertMap, mapname);
	else
		Format(query, 255, sqlite_insertMap, mapname);
		
	SQL_TQuery(db, SQL_CheckCallback, query);
}

//----------------------//
// insert player method //
//----------------------//
public db_insertPlayer(client){
	decl String:query[255];
	decl String:steamid[32];
	decl String:uname[MAX_NAME_LENGTH];
	//get some playerinformation
	GetClientAuthString(client, steamid, 32);
	GetClientName(client, uname, MAX_NAME_LENGTH);
	
	decl String:name[MAX_NAME_LENGTH*2+1];
	//escape some quote characters that could mess up the query
	SQL_QuoteString(db, uname, name, MAX_NAME_LENGTH*2+1);
	
	if(g_dbtype == MYSQL)
		Format(query, 255, sql_insertPlayer, steamid, mapname, name);
	else
		Format(query, 255, sqlite_insertPlayer, steamid, mapname, name);
		
	SQL_TQuery(db, SQL_CheckCallback, query);
}

//------------------------------//
// update map start stop method //
//------------------------------//
public db_updateMapStartStop(client, String:bcords[], String:ecords[], pos){
	decl String:query[255];
	
	//depending on the pos variable
	if(pos == POS_START){
		//depending on the driver
		if(g_dbtype == MYSQL)
			Format(query, 255, sql_updateMapStart, bcords, ecords, mapname);
		else
			Format(query, 255, sqlite_updateMapStart, bcords, ecords, mapname);
		
		PrintToChat(client, "%t", "StartSet", YELLOW,LIGHTGREEN,YELLOW);
	}else{
		//depending on the driver
		if(g_dbtype == MYSQL)
			Format(query, 255, sql_updateMapEnd, bcords, ecords, mapname);
		else
			Format(query, 255, sqlite_updateMapEnd, bcords, ecords, mapname);
		
		PrintToChat(client, "%t", "EndSet", YELLOW,LIGHTGREEN,YELLOW);
	}
	SQL_TQuery(db, SQL_CheckCallback, query);
}

//---------------------------------//
// update player checkpoint method //
//---------------------------------//
public db_updatePlayerCheckpoint(client, current){
	decl String:query[255];
	decl String:uname[MAX_NAME_LENGTH];
	decl String:steamid[32];
	//get some playerinformation
	GetClientName(client, uname, MAX_NAME_LENGTH);
	GetClientAuthString(client, steamid, 32);
	
	decl String:name[MAX_NAME_LENGTH*2+1];
	//escape some quote characters that could mess up the query
	SQL_QuoteString(db, uname, name, MAX_NAME_LENGTH*2+1);
	
	if(g_dbtype == MYSQL)
		Format(query, 255, sql_insertPlayer, steamid, mapname, name);
	else
		Format(query, 255, sqlite_insertPlayer, steamid, mapname, name);
	
	//write the coordinates in a string buffer
	decl String:cords[38];
	Format(cords, 38, "%f:%f:%f",playercords[client][current][0],playercords[client][current][1],playercords[client][current][2]);
	decl String:angles[255];
	Format(angles, 38, "%f:%f:%f",playerangles[client][current][0],playerangles[client][current][1],playerangles[client][current][2]);
	
	if(g_dbtype == MYSQL)
		Format(query, 255, sql_updatePlayerCheckpoint, name, cords, angles, steamid, mapname);
	else
		Format(query, 255, sqlite_updatePlayerCheckpoint, name, cords, angles, steamid, mapname);
	
	SQL_TQuery(db, SQL_CheckCallback, query);
}

//-----------------------------//
// update player record method //
//-----------------------------//
public db_updatePlayerRecord(client){
	decl String:query[255];
	decl String:uname[MAX_NAME_LENGTH];
	decl String:steamid[32];
	//get some playerinformation
	GetClientName(client, uname, MAX_NAME_LENGTH);
	GetClientAuthString(client, steamid, 32);
	
	decl String:name[MAX_NAME_LENGTH*2+1];
	//escape some quote characters that could mess up the query
	SQL_QuoteString(db, uname, name, MAX_NAME_LENGTH*2+1);
	
	if(g_dbtype == MYSQL)
		Format(query, 255, sql_updatePlayerRecord, name, runjumps[client], runtime[client], steamid, mapname);
	else
		Format(query, 255, sqlite_updatePlayerRecord, name, runjumps[client], runtime[client], steamid, mapname);
	
	SQL_TQuery(db, SQL_CheckCallback, query);
}

//----------------------//
// select record method //
//----------------------//
public db_selectRecord(client){
	decl String:query[255];
	decl String:steamid[32];
	GetClientAuthString(client, steamid, 32);
	
	if(g_dbtype == MYSQL)
		Format(query, 255, sql_selectRecord, steamid, mapname);
	else
		Format(query, 255, sqlite_selectRecord, steamid, mapname);
	
	SQL_TQuery(db, SQL_SelectRecordCallback, query, client);
}
//----------//
// callback //
//----------//
public SQL_SelectRecordCallback(Handle:owner, Handle:hndl, const String:error[], any:data){
	if(hndl == INVALID_HANDLE)
		LogError("[cP Mod] Error loading record (%s)", error);
	
	new client = data;
	//if there is a player record
	if(SQL_HasResultSet(hndl) && SQL_FetchRow(hndl)){
		
		decl String:name[MAX_NAME_LENGTH];
		new jumps;
		new time;
		decl String:date[20];
		
		//get the result
		SQL_FetchString(hndl, 0, name, MAX_NAME_LENGTH);
		jumps = SQL_FetchInt(hndl, 1);
		time = SQL_FetchInt(hndl, 2);
		SQL_FetchString(hndl, 3, date, 20);
		
		//display a panel
		new String:vrname[MAX_NAME_LENGTH];
		new String:vrjumps[16];
		new String:vrtime[20];
		new String:vrdate[32];
		Format(vrname, MAX_NAME_LENGTH, "User: %s", name);
		Format(vrjumps, 16, "Jumps: %i", jumps);  
		Format(vrtime, 16, "Time: %im %is", time/60, time%60);
		Format(vrdate, 32, "Date: %s", date); 
		
		new Handle:panel = CreatePanel();
		DrawPanelText(panel, "byaaaaah's [cP Mod] - YourRecord");
		DrawPanelText(panel, " ");
		
		//if it is a valid record
		if(jumps != -1 && time != -1){
			DrawPanelText(panel, vrname);
			DrawPanelText(panel, vrjumps);
			DrawPanelText(panel, vrtime);
			DrawPanelText(panel, vrdate);
		}else
			DrawPanelText(panel, "No record found...");

		DrawPanelItem(panel, "exit");
		SendPanelToClient(panel, client, RecordPanelHandler, 10);
		CloseHandle(panel);
	} else if(IsClientInGame(client)) //no valid player, so insert one
		db_insertPlayer(client);
}
public RecordPanelHandler(Handle:menu, MenuAction:action, param1, param2){
}

//---------------------------------//
// select time world record method //
//---------------------------------//
public db_SelectTimeWorldRecord(client){
	decl String:query[255];
	
	if(g_dbtype == MYSQL)
		Format(query, 255, sql_selectTimeWorldRecord, mapname);
	else
		Format(query, 255, sqlite_selectTopRecordTime, mapname);
	
	SQL_TQuery(db, SQL_SelectTimeWorldRecordCallback, query, client);
}
//----------//
// callback //
//----------//
public SQL_SelectTimeWorldRecordCallback(Handle:owner, Handle:hndl, const String:error[], any:data){
	if(hndl == INVALID_HANDLE)
		LogError("[cP Mod] Error loading toprecordtime (%s)", error);
	
	new client = data;
	decl String:value[64];
	decl String:name[MAX_NAME_LENGTH];
	new time;
	new String:vrtime[16];
	
	new Handle:panel = CreatePanel();
	DrawPanelText(panel, "byaaaaah's [cP Mod] - TimeWorldRecord");
	DrawPanelText(panel, " ");
	
	//if there is allready a entry
	if(SQL_HasResultSet(hndl)){
		new i = 1;
		//loop all results
		while (SQL_FetchRow(hndl)){
			//fetch and format
			SQL_FetchString(hndl, 0, name, MAX_NAME_LENGTH);
			time = SQL_FetchInt(hndl, 1);
			Format(vrtime, 16, "%im %is", time/60, time%60);
			Format(value, 64, "%i. %s - %s", i, name, vrtime);
			DrawPanelText(panel, value);
			i++;
		}
		//still no record :/
		if(i == 1)
			DrawPanelText(panel, "No record found...");
	}
	
	
	DrawPanelItem(panel, "exit");
	SendPanelToClient(panel, client, TimeWorldRecordPanelHandler, 10);
	CloseHandle(panel);
}
//----------//
// callback //
//----------//
public TimeWorldRecordPanelHandler(Handle:menu, MenuAction:action, param1, param2){
}

//---------------------------------//
// select jump world record method //
//---------------------------------//
public db_SelectJumpWorldRecord(client){
	decl String:query[255];
	
	if(g_dbtype == MYSQL)
		Format(query, 255, sql_selectJumpWorldRecord, mapname);
	else
		Format(query, 255, sqlite_selectJumpWorldRecord, mapname);
	
	SQL_TQuery(db, SQL_SelectJumpWorldRecordCallback, query, client);
}
//----------//
// callback //
//----------//
public SQL_SelectJumpWorldRecordCallback(Handle:owner, Handle:hndl, const String:error[], any:data){
	if(hndl == INVALID_HANDLE)
		LogError("[cP Mod] Error loading toprecordjump (%s)", error);
	
	new client = data;
	decl String:value[64];
	decl String:name[MAX_NAME_LENGTH];
	new jumps;
	
	new Handle:panel = CreatePanel();
	DrawPanelText(panel, "byaaaaah's [cP Mod] - JumpWorldRecord");
	DrawPanelText(panel, " ");
	
	//if there is allready a entry
	if(SQL_HasResultSet(hndl)){
		new i = 1;
		//loop all results
		while (SQL_FetchRow(hndl)){
			//fetch and format
			SQL_FetchString(hndl, 0, name, MAX_NAME_LENGTH);
			jumps = SQL_FetchInt(hndl, 1);
			Format(value, 64, "%i. %s - %i Jumps", i, name, jumps);
			DrawPanelText(panel, value);
			i++;
		}
		//still no record :/
		if(i == 1)
			DrawPanelText(panel, "No record found...");
	} 
	
	
	DrawPanelItem(panel, "exit");
	SendPanelToClient(panel, client, JumpWorldRecordPanelHandler, 10);
	CloseHandle(panel);
}
//----------//
// callback //
//----------//
public JumpWorldRecordPanelHandler(Handle:menu, MenuAction:action, param1, param2){
}

//----------------------------------//
// select top map start stop method //
//----------------------------------//
public db_selectMapStartStop(){
	decl String:query[255];
	
	if(g_dbtype == MYSQL)
		Format(query, 255, sql_selectMapStartStop, mapname);
	else
		Format(query, 255, sqlite_selectMapStartStop, mapname);
	
	SQL_TQuery(db, SQL_SelectMapStartStopCallback, query);
}
//----------//
// callback //
//----------//
public SQL_SelectMapStartStopCallback(Handle:owner, Handle:hndl, const String:error[], any:data){
	if(hndl == INVALID_HANDLE)
		LogError("[cP Mod] Error loading mapstartstop (%s)", error);
	
	//if there is a map start stop area
	if(SQL_HasResultSet(hndl) && SQL_FetchRow(hndl)){
		decl String:start0_cords[32];
		decl String:start1_cords[32];
		decl String:end0_cords[32];
		decl String:end1_cords[32];
		
		//fetch the results
		SQL_FetchString(hndl, 0, start0_cords, 32);
		SQL_FetchString(hndl, 1, start1_cords, 32);
		SQL_FetchString(hndl, 2, end0_cords, 32);
		SQL_FetchString(hndl, 3, end1_cords, 32);
		
		//if not a valid result
		if(StrEqual(start0_cords, "0:0:0") || StrEqual(start1_cords, "0:0:0") || StrEqual(end0_cords, "0:0:0") || StrEqual(end1_cords, "0:0:0")){
			g_CordsSet = false;
		}else{ //valid
			//parse the result into string buffers
			decl String:cbuff[3][32]
			ExplodeString(start0_cords, ":", cbuff, 3, 32);
			maptimer_start0_cords[0] = StringToFloat(cbuff[0]);
			maptimer_start0_cords[1] = StringToFloat(cbuff[1]);
			maptimer_start0_cords[2] = StringToFloat(cbuff[2]);
			
			ExplodeString(start1_cords, ":", cbuff, 3, 32);
			maptimer_start1_cords[0] = StringToFloat(cbuff[0]);
			maptimer_start1_cords[1] = StringToFloat(cbuff[1]);
			maptimer_start1_cords[2] = StringToFloat(cbuff[2]);
			
			ExplodeString(end0_cords, ":", cbuff, 3, 32);
			maptimer_end0_cords[0] = StringToFloat(cbuff[0]);
			maptimer_end0_cords[1] = StringToFloat(cbuff[1]);
			maptimer_end0_cords[2] = StringToFloat(cbuff[2]);
			
			ExplodeString(end1_cords, ":", cbuff, 3, 32);
			maptimer_end1_cords[0] = StringToFloat(cbuff[0]);
			maptimer_end1_cords[1] = StringToFloat(cbuff[1]);
			maptimer_end1_cords[2] = StringToFloat(cbuff[2]);
			g_CordsSet = true;
		}
	} else //no map start stop area, so insert the map
		db_insertMap();
}

//---------------------------------//
// select player checkpoint method //
//---------------------------------//
public db_selectPlayerCheckpoint(client){
	decl String:query[255];
	decl String:steamid[32];
	GetClientAuthString(client, steamid, 32);
	
	if(g_dbtype == MYSQL)
		Format(query, 255, sql_selectCheckpoint, steamid, mapname);
	else
		Format(query, 255, sqlite_selectCheckpoint, steamid, mapname);
	
	SQL_TQuery(db, SQL_SelectCheckpointCallback, query, client);
}
//----------//
// callback //
//----------//
public SQL_SelectCheckpointCallback(Handle:owner, Handle:hndl, const String:error[], any:data){
	if(hndl == INVALID_HANDLE)
		LogError("[cP Mod] Error loading checkpoint (%s)", error);
	
	new client = data;
	//if there is a checkpoint entry
	if(SQL_HasResultSet(hndl) && SQL_FetchRow(hndl) && IsClientInGame(client)){
		decl String:cords[32];
		decl String:angles[32];
		
		//fetch the results
		SQL_FetchString(hndl, 0, cords, 32);
		SQL_FetchString(hndl, 1, angles, 32);
		
		//if(StrEqual(cords, "0:0:0") || StrEqual(cords, "0.000000:0.000000:0.000000") || StrEqual(angles, "0:0:0") || StrEqual(angles, "0.000000:0.000000:0.000000")){
		//if checkpoint not valid
		if(StrEqual(cords, "0:0:0") || StrEqual(angles, "0:0:0")){
			currentcp[client] = 0;
			wholecp[client] = 0;
		} else{ //valid
			//parse the result into string buffers
			decl String:cbuff[3][255]
			ExplodeString(cords, ":", cbuff, 3, 32);
			playercords[client][0][0] = StringToFloat(cbuff[0]);
			playercords[client][0][1] = StringToFloat(cbuff[1]);
			playercords[client][0][2] = StringToFloat(cbuff[2]);
			
			ExplodeString(angles, ":", cbuff, 3, 32);
			playerangles[client][0][0] = StringToFloat(cbuff[0]);
			playerangles[client][0][1] = StringToFloat(cbuff[1]);
			playerangles[client][0][2] = StringToFloat(cbuff[2]);
			//add a checkpoint
			wholecp[client] = 1;
			//set the current checkpoint to the first
			currentcp[client] = 0;
			
			PrintToChat(client, "%t", "CheckpointRestored", YELLOW,LIGHTGREEN,YELLOW,GREEN,YELLOW);
		}
	} else if(IsClientInGame(client)) //no checkpoint, so insert the player
		db_insertPlayer(client);
}

//---------------------------------//
// select world record time method //
//---------------------------------//
public db_selectWorldRecordTime(){
	decl String:query[255];
	
	if(g_dbtype == MYSQL)
		Format(query, 255, sql_selectWorldRecordTime, mapname);
	else
		Format(query, 255, sqlite_selectWorldRecordTime,mapname);
	
	SQL_TQuery(db, SQL_SelectWRTimeCallback, query);
}
//----------//
// callback //
//----------//
public SQL_SelectWRTimeCallback(Handle:owner, Handle:hndl, const String:error[], any:data){
	if(hndl == INVALID_HANDLE)
		LogError("[cP Mod] Error loading worldrecordtime (%s)", error);
	
	//if there is a world record
	if(SQL_HasResultSet(hndl) && SQL_FetchRow(hndl)){
		recordjumps = SQL_FetchInt(hndl, 0);
		recordtime = SQL_FetchInt(hndl, 1);
	}else{ //no record, so set them very easy to beat ;)
		recordjumps = 999999;
		recordtime = 999999;
	}
}
//---------------------------------//
// select world record jump method //
//---------------------------------//
public db_selectWorldRecordJump(){
	decl String:query[255];
	
	if(g_dbtype == MYSQL)
		Format(query, 255, sql_selectWorldRecordJump, mapname);
	else
		Format(query, 255, sqlite_selectWorldRecordJump,mapname);
	
	SQL_TQuery(db, SQL_SelectWRJumpCallback, query);
}
//----------//
// callback //
//----------//
public SQL_SelectWRJumpCallback(Handle:owner, Handle:hndl, const String:error[], any:data){
	if(hndl == INVALID_HANDLE)
		LogError("[cP Mod] Error loading worldrecordjump (%s)", error);
	
	//if there is a world record
	if(SQL_HasResultSet(hndl) && SQL_FetchRow(hndl)){
		recordjumps = SQL_FetchInt(hndl, 0);
		recordtime = SQL_FetchInt(hndl, 1);
	}else{ //no record, so set them very easy to beat ;)
		recordjumps = 999999;
		recordtime = 999999;
	}
}


//---------------------//
// purge player method //
//---------------------//
public db_purgePlayer(client, String:szdays[]){
	decl String:query[255];
	new days = StringToInt(szdays);
	
	if(g_dbtype == MYSQL)
		Format(query, 255, sql_purgePlayers, days);
	else
		Format(query, 255, sqlite_purgePlayers, days);
	
	SQL_LockDatabase(db);
	SQL_FastQuery(db, query);
	SQL_UnlockDatabase(db);
	
	PrintToConsole(client, "PlayerDatabase purged.");
	LogMessage("PlayerDatabase purged.");
}
//------------------//
// reset map method //
//------------------//
public db_resetMap(client){
	SQL_LockDatabase(db);
	
	if(g_dbtype == MYSQL)
		SQL_FastQuery(db, sql_resetMap);
	else
		SQL_FastQuery(db, sqlite_resetMap);
	
	SQL_UnlockDatabase(db);
	
	PrintToConsole(client, "MapDatabase cleared. Please restart the server!");
	LogMessage("MapDatabase cleared.");
}
//---------------------//
// reset player method //
//---------------------//
public db_resetPlayer(client){
	SQL_LockDatabase(db);
	
	if(g_dbtype == MYSQL)
		SQL_FastQuery(db, sql_resetPlayer);
	else
		SQL_FastQuery(db, sqlite_resetPlayer);
	
	SQL_UnlockDatabase(db);
	
	PrintToConsole(client, "PlayerDatabase cleared. Please restart the server!");
	LogMessage("PlayerDatabase cleared.");
}
//-------------------------//
// reset checkpoint method //
//-------------------------//
public db_resetCheckpoint(client){
	SQL_LockDatabase(db);
	
	if(g_dbtype == MYSQL)
		SQL_FastQuery(db, sql_resetPlayerCheckpoint);
	else
		SQL_FastQuery(db, sqlite_resetPlayerCheckpoint);
	
	SQL_UnlockDatabase(db);
  
	PrintToConsole(client, "CheckpointDatabase cleared. Please restart the server!");
	LogMessage("CheckpointDatabase cleared.");
}
//---------------------//
// reset record method //
//---------------------//
public db_resetRecord(client){
	SQL_LockDatabase(db);
	
	if(g_dbtype == MYSQL)
		SQL_FastQuery(db, sql_resetPlayerRecord);
	else
		SQL_FastQuery(db, sqlite_resetPlayerRecord);
	
	SQL_UnlockDatabase(db);
	
	PrintToConsole(client, "RecordDatabase cleared. Please restart the server!");
	LogMessage("RecordDatabase cleared.");
}


//-----------------//
// global callback //
//-----------------//
public SQL_CheckCallback(Handle:owner, Handle:hndl, const String:error[], any:data){
	if(hndl == INVALID_HANDLE)
		LogError("[cP Mod] Error inserting into database (%s)", error);
}
