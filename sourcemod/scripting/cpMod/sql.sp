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
new String:sql_createMap[] = "CREATE TABLE IF NOT EXISTS map (mapname VARCHAR(32) PRIMARY KEY, start0 VARCHAR(38) NOT NULL DEFAULT '0:0:0', start1 VARCHAR(38) NOT NULL DEFAULT '0:0:0', end0 VARCHAR(38) NOT NULL DEFAULT '0:0:0', end1 VARCHAR(38) NOT NULL DEFAULT '0:0:0');";
new String:sql_createPlayer[] = "CREATE TABLE IF NOT EXISTS player (steamid VARCHAR(32), mapname VARCHAR(32), name VARCHAR(32), cords VARCHAR(38) NOT NULL DEFAULT '0:0:0', angle VARCHAR(38) NOT NULL DEFAULT '0:0:0', jumps INT(12) NOT NULL DEFAULT '-1', runtime INT(12) NOT NULL DEFAULT '-1', date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP, PRIMARY KEY(steamid,mapname));";
new String:sql_createMeta[] = "CREATE TABLE meta (version VARCHAR(8) NOT NULL);";
new String:sql_initMeta[] = "INSERT INTO meta VALUES('2.0.8')";

new String:sql_insertMap[] = "INSERT INTO map (mapname) VALUES('%s');";
new String:sql_insertPlayer[] = "INSERT INTO player (steamid, mapname, name) VALUES('%s', '%s', '%s');";

new String:sql_updateMapStart[] = "UPDATE map SET start0 = '%s', start1 = '%s' WHERE mapname = '%s';";
new String:sql_updateMapEnd[] = "UPDATE map SET end0 = '%s', end1 = '%s' WHERE mapname = '%s';";

new String:sql_updatePlayerCheckpoint[] = "UPDATE player SET name = '%s', cords = '%s', angle = '%s', date = CURRENT_TIMESTAMP WHERE steamid = '%s' AND mapname = '%s';";
new String:sql_updateRecord[] = "UPDATE player SET name = '%s', jumps = '%d', runtime = '%d', date = CURRENT_TIMESTAMP WHERE steamid = '%s' AND mapname = '%s';";

new String:sql_selectMapStartStop[] = "SELECT start0, start1, end0, end1 FROM map WHERE mapname = '%s'";
new String:sql_selectCheckpoint[] = "SELECT cords, angle FROM player WHERE steamid = '%s' AND mapname = '%s';";
new String:sql_selectWorldRecordTime[] = "SELECT jumps, runtime FROM player WHERE mapname = '%s' AND jumps NOT LIKE '-1' AND runtime NOT LIKE '-1' ORDER BY runtime ASC LIMIT 1;";
new String:sql_selectWorldRecordJump[] = "SELECT jumps, runtime FROM player WHERE mapname = '%s' AND jumps NOT LIKE '-1' AND runtime NOT LIKE '-1' ORDER BY jumps ASC LIMIT 1;";

new String:sql_selectPlayer[] = "SELECT date FROM player WHERE steamid = '%s' AND mapname = '%s';";
new String:sql_selectRecord[] = "SELECT mapname, steamid, name, jumps, runtime, date  FROM player WHERE steamid = '%s' AND mapname = '%s' AND jumps NOT LIKE '-1' AND runtime NOT LIKE '-1';";
new String:sql_selectPlayerRecord[] = "SELECT steamid FROM player WHERE name LIKE '%s' AND mapname = '%s' AND jumps NOT LIKE '-1' AND runtime NOT LIKE '-1';";
new String:sql_selectPlayerCount[] = "SELECT name FROM player WHERE mapname = '%s' AND jumps NOT LIKE '-1' AND runtime NOT LIKE '-1';";
new String:sql_selectPlayerRankTime[] = "SELECT name FROM player WHERE runtime <= (SELECT runtime FROM player WHERE steamid = '%s' AND mapname = '%s' AND runtime NOT LIKE '-1') AND mapname = '%s' AND runtime NOT LIKE '-1' ORDER BY runtime;";
new String:sql_selectPlayerRankJump[] = "SELECT name FROM player WHERE jumps <= (SELECT jumps FROM player WHERE steamid = '%s' AND mapname = '%s' AND jumps NOT LIKE '-1') AND mapname = '%s' AND jumps NOT LIKE '-1' ORDER BY jumps;";

new String:sql_selectTimeWorldRecord[] = "SELECT name, runtime, jumps FROM player WHERE mapname = '%s' AND runtime NOT LIKE '-1' ORDER BY runtime ASC LIMIT 10;";
new String:sql_selectJumpWorldRecord[] = "SELECT name, jumps, runtime FROM player WHERE mapname = '%s' AND jumps NOT LIKE '-1' ORDER BY jumps ASC LIMIT 10;";

new String:sqlite_purgePlayers[] = "DELETE FROM players WHERE date < datetime('now', '-%d days');";
new String:sql_purgePlayers[] = "DELETE FROM players WHERE date < DATE_SUB(CURDATE(),INTERVAL %d DAY);";


new String:sqlite_dropMap[] = "DROP TABLE map; VACCUM";
new String:sql_dropMap[] = "DROP TABLE map;";
new String:sqlite_dropPlayer[] = "DROP TABLE player; VACCUM";
new String:sql_dropPlayer[] = "DROP TABLE player;";
new String:sql_resetMapTimer[] = "UPDATE map SET start0 = '0:0:0', start1 = '0:0:0', end0 = '0:0:0', end1 = '0:0:0' WHERE mapname LIKE '%s';"; 

new String:sql_resetCheckpoints[] = "UPDATE player SET cords = '0:0:0', angle = '0:0:0' WHERE name LIKE '%s' AND mapname LIKE '%s';";
new String:sql_resetRecords[] = "UPDATE player SET jumps = '-1', runtime = '-1' WHERE name LIKE '%s' AND mapname LIKE '%s';";


//upgrade scripts
new String:sql_selectVersion[] = "SELECT version FROM meta;";
new String:sql_updateVersion[] = "UPDATE meta SET version = '%s';";
new String:sql_upgrade2_1_0[] = "UPDATE player SET runtime = runtime*10 WHERE runtime != -1";

//-------------------------//
// database initialization //
//-------------------------//
public db_setupDatabase(){
	decl String:szError[255];
	g_hDb = SQL_Connect("cpmod", false, szError, 255);
	
	//if a connection canot be made
	if(g_hDb == INVALID_HANDLE){
		LogError("[cP Mod] Unable to connect to database (%s)", szError);
		return;
	}
	
	decl String:szIdent[8];
	SQL_ReadDriver(g_hDb, szIdent, 8);
	//select the driver depending on the settings (mysql/sqlite)
	if(strcmp(szIdent, "mysql", false) == 0){
		g_DbType = MYSQL;
	}else if(strcmp(szIdent, "sqlite", false) == 0){
		g_DbType = SQLITE;
	}else{
		LogError("[cP Mod] Invalid Database-Type");
		return;
	}
	
	//create the tables
	db_createTables();
	
	//check for updates
	db_performUpdates();
}

//-----------------------//
// table creation method //
//-----------------------//
public db_createTables(){
	SQL_LockDatabase(g_hDb);
	
	SQL_FastQuery(g_hDb, sql_createMap);
	SQL_FastQuery(g_hDb, sql_createPlayer);
	SQL_FastQuery(g_hDb, sql_createMeta);
	
	SQL_UnlockDatabase(g_hDb);
}

//------------------------//
// perform updates method //
//------------------------//
public db_performUpdates(){
	SQL_TQuery(g_hDb, SQL_CheckUpdateCallback, sql_selectVersion);
}
//----------//
// callback //
//----------//
public SQL_CheckUpdateCallback(Handle:owner, Handle:hndl, const String:error[], any:data){
	//if there is a result
	if(SQL_HasResultSet(hndl) && SQL_FetchRow(hndl)){
		decl String:szVersion[8];
		
		//get the result
		SQL_FetchString(hndl, 0, szVersion, 8);
		
		//check for 2.1.0 update
		new comparison = compareVersionStrings(szVersion, "2.1.0");
		if(comparison < 0){
			LogMessage("Performing 2.1.0 database update...");
			
			//perform 2.1.0 update
			SQL_TQuery(g_hDb, SQL_CheckCallback, sql_upgrade2_1_0);
			
			//update version in database
			db_updateVersion("2.1.0");
		}
	}else{ //init data
		SQL_TQuery(g_hDb, SQL_InitMetaCallback, sql_initMeta);
	}
}
//----------//
// callback //
//----------//
public SQL_InitMetaCallback(Handle:owner, Handle:hndl, const String:error[], any:data){
	//simply try the update again
	db_performUpdates();
}

//------------------------------//
// update version method //
//------------------------------//
public db_updateVersion(String:szVersion[]){
	decl String:szQuery[255];
	Format(szQuery, 255, sql_updateVersion, szVersion);
	
	SQL_TQuery(g_hDb, SQL_CheckCallback, szQuery);
}


//-------------------//
// insert map method //
//-------------------//
public db_insertMap(){
	decl String:szQuery[255];
	Format(szQuery, 255, sql_insertMap, g_szMapName);
		
	SQL_TQuery(g_hDb, SQL_CheckCallback, szQuery);
}

//----------------------//
// insert player method //
//----------------------//
public db_insertPlayer(client){
	decl String:szQuery[255];
	decl String:szSteamId[32];
	decl String:szUName[MAX_NAME_LENGTH];
	//get some playerinformation
	GetClientAuthString(client, szSteamId, 32);
	GetClientName(client, szUName, MAX_NAME_LENGTH);
	
	decl String:szName[MAX_NAME_LENGTH*2+1];
	//escape some quote characters that could mess up the szQuery
	SQL_QuoteString(g_hDb, szUName, szName, MAX_NAME_LENGTH*2+1);
	
	Format(szQuery, 255, sql_insertPlayer, szSteamId, g_szMapName, szName);
	
	SQL_TQuery(g_hDb, SQL_CheckCallback, szQuery);
}

//------------------------------//
// update map start stop method //
//------------------------------//
public db_updateMapStartStop(client, String:szBCords[], String:szECords[], pos){
	decl String:szQuery[255];
	
	//depending on the pos variable
	if(pos == POS_START){
		Format(szQuery, 255, sql_updateMapStart, szBCords, szECords, g_szMapName);
		
		PrintToChat(client, "%t", "StartSet", YELLOW,LIGHTGREEN,YELLOW);
	}else{
		Format(szQuery, 255, sql_updateMapEnd, szBCords, szECords, g_szMapName);
		
		PrintToChat(client, "%t", "EndSet", YELLOW,LIGHTGREEN,YELLOW);
	}
	SQL_TQuery(g_hDb, SQL_CheckCallback, szQuery);
	
	//recalculate player spawn point
	setupPlayerSpawn();
}

//---------------------------------//
// update player checkpoint method //
//---------------------------------//
public db_updatePlayerCheckpoint(client, current){
	decl String:szQuery[255];
	decl String:szUName[MAX_NAME_LENGTH];
	decl String:szSteamId[32];
	//get some playerinformation
	GetClientName(client, szUName, MAX_NAME_LENGTH);
	GetClientAuthString(client, szSteamId, 32);
	
	decl String:szName[MAX_NAME_LENGTH*2+1];
	//escape some quote characters that could mess up the szQuery
	SQL_QuoteString(g_hDb, szUName, szName, MAX_NAME_LENGTH*2+1);
	
	Format(szQuery, 255, sql_insertPlayer, szSteamId, g_szMapName, szName);
	
	//write the coordinates in a string buffer
	decl String:szCords[38];
	Format(szCords, 38, "%f:%f:%f",g_fPlayerCords[client][current][0],g_fPlayerCords[client][current][1],g_fPlayerCords[client][current][2]);
	decl String:szAngles[255];
	Format(szAngles, 38, "%f:%f:%f",g_fPlayerAngles[client][current][0],g_fPlayerAngles[client][current][1],g_fPlayerAngles[client][current][2]);
	
	Format(szQuery, 255, sql_updatePlayerCheckpoint, szName, szCords, szAngles, szSteamId, g_szMapName);
	
	SQL_TQuery(g_hDb, SQL_CheckCallback, szQuery);
}

//--------------------//
// view record method //
//---------------------//
public db_viewRecord(client, String:szSteamId[32], String:szMapName[MAX_MAP_LENGTH]){
	decl String:szQuery[255];
	Format(szQuery, 255, sql_selectRecord, szSteamId, szMapName);
	
	SQL_TQuery(g_hDb, SQL_ViewRecordCallback, szQuery, client);
}
//----------//
// callback //
//----------//
public SQL_ViewRecordCallback(Handle:owner, Handle:hndl, const String:error[], any:data){
	if(hndl == INVALID_HANDLE)
		LogError("[cP Mod] Error loading record (%s)", error);
	
	new client = data;
	
	//if there is a player record
	if(SQL_HasResultSet(hndl) && SQL_FetchRow(hndl)){
		decl String:szQuery[255];
		decl String:szMapName[MAX_MAP_LENGTH];
		decl String:szName[MAX_NAME_LENGTH];
		decl String:szSteamId[32];
		new jumps;
		new time;
		decl String:szDate[20];
		
		//get the result
		SQL_FetchString(hndl, 0, szMapName, MAX_MAP_LENGTH);
		SQL_FetchString(hndl, 1, szSteamId, MAX_NAME_LENGTH);
		SQL_FetchString(hndl, 2, szName, MAX_NAME_LENGTH);
		jumps = SQL_FetchInt(hndl, 3);
		time = SQL_FetchInt(hndl, 4);
		SQL_FetchString(hndl, 5, szDate, 20);
		
		if(g_bRecordType == RECORD_TIME)
			Format(szQuery, 255, sql_selectPlayerRankTime, szSteamId, szMapName, szMapName);
		else
			Format(szQuery, 255, sql_selectPlayerRankJump, szSteamId, szMapName, szMapName);
		
		
		new Handle:pack = CreateDataPack();
		WritePackCell(pack, client);
		WritePackString(pack, szMapName);
		WritePackString(pack, szSteamId);
		WritePackString(pack, szName);
		WritePackCell(pack, jumps);
		WritePackCell(pack, time);
		WritePackString(pack, szDate);
		
		SQL_TQuery(g_hDb, SQL_ViewRecordCallback2, szQuery, pack);
		
	}else{ //no valid record
		
		new Handle:panel = CreatePanel();
		DrawPanelText(panel, "byaaaaah's [cP Mod] - YourRecord");
		DrawPanelText(panel, " ");
		DrawPanelText(panel, "No record found...");
		DrawPanelItem(panel, "exit");
		SendPanelToClient(panel, client, RecordPanelHandler, 10);
		CloseHandle(panel);
	}
}
//----------//
// callback //
//----------//
public SQL_ViewRecordCallback2(Handle:owner, Handle:hndl, const String:error[], any:data){
	if(hndl == INVALID_HANDLE)
		LogError("[cP Mod] Error viewing record cb2 (%s)", error);
	
	//if there is a player record
	if(SQL_HasResultSet(hndl) && SQL_FetchRow(hndl)){
		decl String:szQuery[255];
		new rank = SQL_GetRowCount(hndl);
		
		//apend rank
		new Handle:pack = data;
		WritePackCell(pack, rank);
		
		ResetPack(pack);
		ReadPackCell(pack); //client
		decl String:szMapName[MAX_MAP_LENGTH];
		ReadPackString(pack, szMapName, MAX_NAME_LENGTH);
		
		Format(szQuery, 255, sql_selectPlayerCount, szMapName);
		
		SQL_TQuery(g_hDb, SQL_ViewRecordCallback3, szQuery, pack);
	}
}
//----------//
// callback //
//----------//
public SQL_ViewRecordCallback3(Handle:owner, Handle:hndl, const String:error[], any:data){
	if(hndl == INVALID_HANDLE)
		LogError("[cP Mod] Error viewing record cb3 (%s)", error);
	
	//if there is a player record
	if(SQL_HasResultSet(hndl) && SQL_FetchRow(hndl)){
		new count = SQL_GetRowCount(hndl);
		
		//retrieve all values
		new Handle:pack = data;
		ResetPack(pack);
		new client = ReadPackCell(pack);
		decl String:szMapName[MAX_MAP_LENGTH];
		ReadPackString(pack, szMapName, MAX_MAP_LENGTH);
		decl String:szSteamId[32];
		ReadPackString(pack, szSteamId, 32);
		decl String:szName[MAX_NAME_LENGTH];
		ReadPackString(pack, szName, MAX_NAME_LENGTH);
		new jumps = ReadPackCell(pack);
		new time = ReadPackCell(pack);
		decl String:szDate[20];
		ReadPackString(pack, szDate, 20);
		new rank = ReadPackCell(pack);
		
		CloseHandle(pack);
		
		new Handle:panel = CreatePanel();
		DrawPanelText(panel, "byaaaaah's [cP Mod] - Record");
		DrawPanelText(panel, " ");
		
		//display a panel
		decl String:szVrName[MAX_NAME_LENGTH];
		decl String:szVrMap[MAX_MAP_LENGTH];
		decl String:szVrJumps[16];
		decl String:szVrTime[20];
		decl String:szVrDate[32];
		decl String:szVrRank[16];
		Format(szVrName, MAX_NAME_LENGTH, "User: %s", szName);
		Format(szVrMap, MAX_MAP_LENGTH, "Map: %s", szMapName);
		Format(szVrJumps, 16, "Jumps: %d", jumps);  
		Format(szVrTime, 16, "Time: %02d:%02.1f", (time/600), ((time%600)/10.0));
		Format(szVrDate, 32, "Last Connect: %s", szDate); 
		Format(szVrRank, 32, "Rank: %d/%d", rank, count); 
		
		DrawPanelText(panel, szVrName);
		DrawPanelText(panel, szVrMap);
		DrawPanelText(panel, szVrJumps);
		DrawPanelText(panel, szVrTime);
		DrawPanelText(panel, szVrDate);
		DrawPanelText(panel, szVrRank);
		
		DrawPanelItem(panel, "exit");
		SendPanelToClient(panel, client, RecordPanelHandler, 10);
		CloseHandle(panel);
	}
}
public RecordPanelHandler(Handle:menu, MenuAction:action, param1, param2){
}

//---------------------------//
// view player record method //
//---------------------------//
public db_viewPlayerRecord(client, String:szPlayerName[MAX_NAME_LENGTH], String:szMapName[MAX_MAP_LENGTH]){
	decl String:szQuery[255];
	
	//escape some quote characters that could mess up the szQuery
	decl String:szName[MAX_NAME_LENGTH*2+1];
	SQL_QuoteString(g_hDb, szPlayerName, szName, MAX_NAME_LENGTH*2+1);
	
	Format(szQuery, 255, sql_selectPlayerRecord, szName, szMapName);
	
	new Handle:pack = CreateDataPack();
	WritePackCell(pack, client);
	WritePackString(pack, szMapName);
	
	SQL_TQuery(g_hDb, SQL_ViewPlayerRecordCallback, szQuery, pack);
}
//----------//
// callback //
//----------//
public SQL_ViewPlayerRecordCallback(Handle:owner, Handle:hndl, const String:error[], any:data){
	if(hndl == INVALID_HANDLE)
		LogError("[cP Mod] Error loading player record (%s)", error);
	
	//if there is a player record
	if(SQL_HasResultSet(hndl) && SQL_FetchRow(hndl)){
		new Handle:pack = data;
		ResetPack(pack);
		
		new client = ReadPackCell(pack);
		decl String:szMapName[MAX_MAP_LENGTH];
		ReadPackString(pack, szMapName, MAX_MAP_LENGTH);
		
		CloseHandle(pack);
		
		decl String:szSteamId[32];
		
		//get the result
		SQL_FetchString(hndl, 0, szSteamId, 32);
		
		db_viewRecord(client, szSteamId, szMapName);
	}
}

//----------------------//
// update record method //
//----------------------//
public db_updateRecord(client){
	decl String:szQuery[255];
	decl String:szSteamId[32];
	GetClientAuthString(client, szSteamId, 32);
	
	Format(szQuery, 255, sql_selectRecord, szSteamId, g_szMapName);
	
	SQL_TQuery(g_hDb, SQL_UpdateRecordCallback, szQuery, client);
}
//----------//
// callback //
//----------//
public SQL_UpdateRecordCallback(Handle:owner, Handle:hndl, const String:error[], any:data){
	if(hndl == INVALID_HANDLE)
		LogError("[cP Mod] Error loading record (%s)", error);
	
	new client = data;
	//if there is a player record
	if(SQL_HasResultSet(hndl) && SQL_FetchRow(hndl)){
		
		//if recordtime is type of time
		if(g_bRecordType == RECORD_TIME){
			new time;
			time = SQL_FetchInt(hndl, 4);
			
			//if the new record beats the old one
			if(g_RunTime[client] <= time)
				db_updateRecord2(client);
		}else{ //type of jump
			new jumps;
			jumps = SQL_FetchInt(hndl, 5);
			
			//if the new record beats the old one
			if(g_RunJumps[client] <= jumps)
				db_updateRecord2(client);
		}
	//no record found, update (insert)!
	}else
		db_updateRecord2(client);
}

//-------------------------------//
// update player record 2 method //
//-------------------------------//
public db_updateRecord2(client){
	decl String:szQuery[255];
	decl String:szUName[MAX_NAME_LENGTH];
	decl String:szSteamId[32];
	//get some playerinformation
	GetClientName(client, szUName, MAX_NAME_LENGTH);
	GetClientAuthString(client, szSteamId, 32);
	
	decl String:szName[MAX_NAME_LENGTH*2+1];
	//escape some quote characters that could mess up the szQuery
	SQL_QuoteString(g_hDb, szUName, szName, MAX_NAME_LENGTH*2+1);
	
	Format(szQuery, 255, sql_updateRecord, szUName, g_RunJumps[client], g_RunTime[client], szSteamId, g_szMapName);
	
	SQL_TQuery(g_hDb, SQL_CheckCallback, szQuery);
	
	//display record panel
	db_viewRecord(client, szSteamId, g_szMapName);
}


//---------------------------------//
// select time world record method //
//---------------------------------//
public db_selectTimeWorldRecord(client){
	decl String:szQuery[255];
	Format(szQuery, 255, sql_selectTimeWorldRecord, g_szMapName);
	
	SQL_TQuery(g_hDb, SQL_SelectTimeWRCallback, szQuery, client);
}
//----------//
// callback //
//----------//
public SQL_SelectTimeWRCallback(Handle:owner, Handle:hndl, const String:error[], any:data){
	if(hndl == INVALID_HANDLE)
		LogError("[cP Mod] Error loading toprecordtime (%s)", error);
	
	new client = data;
	decl String:szValue[64];
	decl String:szName[MAX_NAME_LENGTH];
	new time;
	new jumps;
	
	new Handle:panel = CreatePanel();
	DrawPanelText(panel, "byaaaaah's [cP Mod] - TimeWorldRecord");
	DrawPanelText(panel, " ");
	
	//if there is already a entry
	if(SQL_HasResultSet(hndl)){
		new i = 1;
		//loop all results
		while (SQL_FetchRow(hndl)){
			//fetch and format
			SQL_FetchString(hndl, 0, szName, MAX_NAME_LENGTH);
			time = SQL_FetchInt(hndl, 1);
			jumps = SQL_FetchInt(hndl, 2);
			Format(szValue, 64, "%d. %02d:%02.1f - %s (%d jumps)", i, (time/600), ((time%600)/10.0), szName, jumps);
			
			DrawPanelText(panel, szValue);
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
//---------//
// handler //
//---------//
public TimeWorldRecordPanelHandler(Handle:menu, MenuAction:action, param1, param2){
}

//---------------------------------//
// select jump world record method //
//---------------------------------//
public db_selectJumpWorldRecord(client){
	decl String:szQuery[255];
	Format(szQuery, 255, sql_selectJumpWorldRecord, g_szMapName);
	
	SQL_TQuery(g_hDb, SQL_SelectJumpWRCallback, szQuery, client);
}
//----------//
// callback //
//----------//
public SQL_SelectJumpWRCallback(Handle:owner, Handle:hndl, const String:error[], any:data){
	if(hndl == INVALID_HANDLE)
		LogError("[cP Mod] Error loading toprecordjump (%s)", error);
	
	new client = data;
	decl String:szValue[64];
	decl String:szName[MAX_NAME_LENGTH];
	new jumps;
	new time;
	
	new Handle:panel = CreatePanel();
	DrawPanelText(panel, "byaaaaah's [cP Mod] - JumpWorldRecord");
	DrawPanelText(panel, " ");
	
	//if there is already a entry
	if(SQL_HasResultSet(hndl)){
		new i = 1;
		//loop all results
		while (SQL_FetchRow(hndl)){
			//fetch and format
			SQL_FetchString(hndl, 0, szName, MAX_NAME_LENGTH);
			jumps = SQL_FetchInt(hndl, 1);
			time = SQL_FetchInt(hndl, 2);
			Format(szValue, 64, "%d. %02d:%02.1f - %s (%d jumps)", i, (time/600), ((time%600)/10.0), szName, jumps);
			DrawPanelText(panel, szValue);
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
//---------//
// handler //
//---------//
public JumpWorldRecordPanelHandler(Handle:menu, MenuAction:action, param1, param2){
}

//---------------------//
// select plyer method //
//---------------------//
public db_selectPlayer(client){
	decl String:szQuery[255];
	decl String:szSteamId[32];
	GetClientAuthString(client, szSteamId, 32);
	
	Format(szQuery, 255, sql_selectPlayer, szSteamId, g_szMapName);
	
	SQL_TQuery(g_hDb, SQL_SelectPlayerCallback, szQuery, client);
}
//----------//
// callback //
//----------//
public SQL_SelectPlayerCallback(Handle:owner, Handle:hndl, const String:error[], any:data){
	if(hndl == INVALID_HANDLE)
		LogError("[cP Mod] Error loading player (%s)", error);
	
	new client = data;
	//if there is a player entry
	if(SQL_HasResultSet(hndl) && SQL_FetchRow(hndl) && IsClientInGame(client)){
		//do nothing
	}else
		db_insertPlayer(client);
}

//----------------------------------//
// select top map start stop method //
//----------------------------------//
public db_selectMapStartStop(){
	decl String:szQuery[255];
	Format(szQuery, 255, sql_selectMapStartStop, g_szMapName);
	
	SQL_TQuery(g_hDb, SQL_SelectMapStartStopCallback, szQuery);
}
//----------//
// callback //
//----------//
public SQL_SelectMapStartStopCallback(Handle:owner, Handle:hndl, const String:error[], any:data){
	if(hndl == INVALID_HANDLE)
		LogError("[cP Mod] Error loading mapstartstop (%s)", error);
	
	//if there is a map start stop area
	if(SQL_HasResultSet(hndl) && SQL_FetchRow(hndl)){
		decl String:szStart0_cords[38];
		decl String:szStart1_cords[38];
		decl String:szEnd0_cords[38];
		decl String:szEnd1_cords[38];
		
		//fetch the results
		SQL_FetchString(hndl, 0, szStart0_cords, 38);
		SQL_FetchString(hndl, 1, szStart1_cords, 38);
		SQL_FetchString(hndl, 2, szEnd0_cords, 38);
		SQL_FetchString(hndl, 3, szEnd1_cords, 38);
		
		//if not a valid result
		if(StrEqual(szStart0_cords, "0:0:0") || StrEqual(szStart1_cords, "0:0:0") || StrEqual(szEnd0_cords, "0:0:0") || StrEqual(szEnd1_cords, "0:0:0")){
			g_bStartCordsSet = false;
			g_bStopCordsSet = false;
		}else{ //valid
			//parse the result into string buffers
			decl String:szCBuff[3][38]
			ExplodeString(szStart0_cords, ":", szCBuff, 3, 38);
			g_fMapTimer_start0_cords[0] = StringToFloat(szCBuff[0]);
			g_fMapTimer_start0_cords[1] = StringToFloat(szCBuff[1]);
			g_fMapTimer_start0_cords[2] = StringToFloat(szCBuff[2]);
			
			ExplodeString(szStart1_cords, ":", szCBuff, 3, 38);
			g_fMapTimer_start1_cords[0] = StringToFloat(szCBuff[0]);
			g_fMapTimer_start1_cords[1] = StringToFloat(szCBuff[1]);
			g_fMapTimer_start1_cords[2] = StringToFloat(szCBuff[2]);
			g_bStartCordsSet = true;
			
			ExplodeString(szEnd0_cords, ":", szCBuff, 3, 38);
			g_fMapTimer_end0_cords[0] = StringToFloat(szCBuff[0]);
			g_fMapTimer_end0_cords[1] = StringToFloat(szCBuff[1]);
			g_fMapTimer_end0_cords[2] = StringToFloat(szCBuff[2]);
			
			ExplodeString(szEnd1_cords, ":", szCBuff, 3, 38);
			g_fMapTimer_end1_cords[0] = StringToFloat(szCBuff[0]);
			g_fMapTimer_end1_cords[1] = StringToFloat(szCBuff[1]);
			g_fMapTimer_end1_cords[2] = StringToFloat(szCBuff[2]);
			g_bStopCordsSet = true;
			
			//calculate player spawn point
			setupPlayerSpawn();
		}
	}else //no map start stop area, so insert the map
		db_insertMap();
}

//---------------------------------//
// select player checkpoint method //
//---------------------------------//
public db_selectPlayerCheckpoint(client){
	decl String:szQuery[255];
	decl String:szSteamId[32];
	GetClientAuthString(client, szSteamId, 32);
	
	Format(szQuery, 255, sql_selectCheckpoint, szSteamId, g_szMapName);
	
	SQL_TQuery(g_hDb, SQL_SelectCheckpointCallback, szQuery, client);
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
		decl String:szCords[38];
		decl String:szAngles[38];
		
		//fetch the results
		SQL_FetchString(hndl, 0, szCords, 38);
		SQL_FetchString(hndl, 1, szAngles, 38);
		
		//if checkpoint not valid
		if(StrEqual(szCords, "0:0:0") || StrEqual(szCords, "0.000000:0.000000:0.000000") || StrEqual(szAngles, "0:0:0") || StrEqual(szAngles, "0.000000:0.000000:0.000000")){
			g_CurrentCp[client] = -1;
			g_WholeCp[client] = 0;
		}else{ //valid
			//parse the result into string buffers
			decl String:szCBuff[3][38]
			ExplodeString(szCords, ":", szCBuff, 3, 38);
			g_fPlayerCords[client][0][0] = StringToFloat(szCBuff[0]);
			g_fPlayerCords[client][0][1] = StringToFloat(szCBuff[1]);
			g_fPlayerCords[client][0][2] = StringToFloat(szCBuff[2]);
			
			ExplodeString(szAngles, ":", szCBuff, 3, 38);
			g_fPlayerAngles[client][0][0] = StringToFloat(szCBuff[0]);
			g_fPlayerAngles[client][0][1] = StringToFloat(szCBuff[1]);
			g_fPlayerAngles[client][0][2] = StringToFloat(szCBuff[2]);
			//add a checkpoint
			g_WholeCp[client] = 1;
			//set the current checkpoint to the first
			g_CurrentCp[client] = 0;
			
			PrintToChat(client, "%t", "CheckpointRestored", YELLOW,LIGHTGREEN,YELLOW,GREEN,YELLOW);
		}
	}
}

//---------------------------------//
// select world record time method //
//---------------------------------//
public db_selectWorldRecordTime(){
	decl String:szQuery[255];
	Format(szQuery, 255, sql_selectWorldRecordTime, g_szMapName);
	
	SQL_TQuery(g_hDb, SQL_SelectWRTimeCallback, szQuery);
}
//----------//
// callback //
//----------//
public SQL_SelectWRTimeCallback(Handle:owner, Handle:hndl, const String:error[], any:data){
	if(hndl == INVALID_HANDLE)
		LogError("[cP Mod] Error loading worldrecordtime (%s)", error);
	
	//if there is a world record
	if(SQL_HasResultSet(hndl) && SQL_FetchRow(hndl)){
		g_RecordJumps = SQL_FetchInt(hndl, 0);
		g_RecordTime = SQL_FetchInt(hndl, 1);
	}else{ //no record, so set them very easy to beat ;)
		g_RecordJumps = 2147483647;
		g_RecordTime = 2147483647;
	}
}
//---------------------------------//
// select world record jump method //
//---------------------------------//
public db_selectWorldRecordJump(){
	decl String:szQuery[255];
	Format(szQuery, 255, sql_selectWorldRecordJump, g_szMapName);
	
	SQL_TQuery(g_hDb, SQL_SelectWRJumpCallback, szQuery);
}
//----------//
// callback //
//----------//
public SQL_SelectWRJumpCallback(Handle:owner, Handle:hndl, const String:error[], any:data){
	if(hndl == INVALID_HANDLE)
		LogError("[cP Mod] Error loading worldrecordjump (%s)", error);
	
	//if there is a world record
	if(SQL_HasResultSet(hndl) && SQL_FetchRow(hndl)){
		g_RecordJumps = SQL_FetchInt(hndl, 0);
		g_RecordTime = SQL_FetchInt(hndl, 1);
	}else{ //no record, so set them very easy to beat ;)
		g_RecordJumps = 999999;
		g_RecordTime = 999999;
	}
}


//---------------------//
// purge player method //
//---------------------//
public db_purgePlayer(client, String:szdays[]){
	decl String:szQuery[255];
	new days = StringToInt(szdays);
	
	if(g_DbType == MYSQL)
		Format(szQuery, 255, sql_purgePlayers, days);
	else
		Format(szQuery, 255, sqlite_purgePlayers, days);
	
	SQL_LockDatabase(g_hDb);
	SQL_FastQuery(g_hDb, szQuery);
	SQL_UnlockDatabase(g_hDb);
	
	PrintToConsole(client, "PlayerDatabase purged.");
	LogMessage("PlayerDatabase purged.");
}

//-----------------//
// drop map method //
//------------------//
public db_dropMap(client){
	SQL_LockDatabase(g_hDb);
	
	if(g_DbType == MYSQL)
		SQL_FastQuery(g_hDb, sql_dropMap);
	else
		SQL_FastQuery(g_hDb, sqlite_dropMap);
	
	SQL_UnlockDatabase(g_hDb);
	
	PrintToConsole(client, "MapTable dropped. Please restart the server!");
	LogMessage("MapTable dropped.");
}
//--------------------//
// drop player method //
//--------------------//
public db_dropPlayer(client){
	SQL_LockDatabase(g_hDb);
	
	if(g_DbType == MYSQL)
		SQL_FastQuery(g_hDb, sql_dropPlayer);
	else
		SQL_FastQuery(g_hDb, sqlite_dropPlayer);
	
	SQL_UnlockDatabase(g_hDb);
	
	PrintToConsole(client, "PlayerTable dropped. Please restart the server!");
	LogMessage("PlayerTable dropped.");
}
//--------------------//
// reset timer method //
//--------------------//
public db_resetMapTimer(client, String:szMapName[MAX_MAP_LENGTH]){
	decl String:szQuery[255];
	Format(szQuery, 255, sql_resetMapTimer, g_szMapName);
	
	SQL_LockDatabase(g_hDb);
	SQL_FastQuery(g_hDb, szQuery);
	SQL_UnlockDatabase(g_hDb);
	
	PrintToConsole(client, "Maptimer resettet.");
	LogMessage("Maptimer resettet.");
}

//---------------------------------//
// reset player checkpoints method //
//---------------------------------//
public db_resetPlayerCheckpoints(client, String:szPlayerName[MAX_NAME_LENGTH], String:szMapName[MAX_MAP_LENGTH]){
	decl String:szQuery[255];
	
	//escape some quote characters that could mess up the szQuery
	decl String:szName[MAX_NAME_LENGTH*2+1];
	SQL_QuoteString(g_hDb, szPlayerName, szName, MAX_NAME_LENGTH*2+1);
	
	Format(szQuery, 255, sql_resetCheckpoints, szName, szMapName);
	
	SQL_LockDatabase(g_hDb);
	SQL_FastQuery(g_hDb, szQuery);
	SQL_UnlockDatabase(g_hDb);
	
	PrintToConsole(client, "PlayerCheckpointsTable cleared (%s on %s).",szPlayerName, szMapName);
	LogMessage("PlayerCheckpointsTable cleared (%s on %s).", szPlayerName, szMapName);
}

//-----------------------------//
// reset player records method //
//-----------------------------//
public db_resetPlayerRecords(client, String:szPlayerName[MAX_NAME_LENGTH], String:szMapName[MAX_MAP_LENGTH]){
	decl String:szQuery[255];
	
	//escape some quote characters that could mess up the szQuery
	decl String:szName[MAX_NAME_LENGTH*2+1];
	SQL_QuoteString(g_hDb, szPlayerName, szName, MAX_NAME_LENGTH*2+1);
	
	Format(szQuery, 255, sql_resetRecords, szPlayerName, szMapName);
	
	SQL_LockDatabase(g_hDb);
	SQL_FastQuery(g_hDb, szQuery);
	SQL_UnlockDatabase(g_hDb);
	
	PrintToConsole(client, "PlayerRecordTable cleared (%s on %s).", szPlayerName, szMapName);
	LogMessage("PlayerRecordTable cleared (%s on %s).", szPlayerName, szMapName);
	
	//maybe there is a "new" record
	if(g_bRecordType == RECORD_TIME)
		db_selectWorldRecordTime();
	else
		db_selectWorldRecordJump();
}

//-----------------//
// global callback //
//-----------------//
public SQL_CheckCallback(Handle:owner, Handle:hndl, const String:error[], any:data){
	if(hndl == INVALID_HANDLE)
		LogError("[cP Mod] Error inserting into database (%s).", error);
}
