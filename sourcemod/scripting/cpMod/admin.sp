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

//-----------------------//
// admin cp command hook //
//-----------------------//
public Action:Admin_CpPanel(client, args){
	//if someone else setting up a timer
	if(!g_bCpPanelOpen)
		CpAdminPanel(client);
	else
		PrintToChat(client, "%t", "CpPanelInAccess", YELLOW,LIGHTGREEN,YELLOW);
	return Plugin_Handled;
}
//-------------------------//
// admin cp command method //
//-------------------------//
public CpAdminPanel(client){
	//if no valid player
	if(client == 0 || !IsPlayerAlive(client) || GetClientTeam(client) == 1)
		return;

	g_bCpPanelOpen = true;
	//create the panel
	new Handle:menu = CreateMenu(CpAdminPanelHandler);
	SetMenuTitle(menu, "byaaaaah's [cP Mod] - Maptimer");
	AddMenuItem(menu, "Set start area", "Set timer start");
	AddMenuItem(menu, "Set stop area", "Set timer stop");
	SetMenuExitButton(menu, true);
	SetMenuOptionFlags(menu, MENUFLAG_BUTTON_EXIT);
	DisplayMenu(menu, client, MENU_TIME_FOREVER);
}
//---------//
// handler //
//---------//
public CpAdminPanelHandler(Handle:menu, MenuAction:action, param1, param2){
	if(action == MenuAction_Select){
		//depending on item selected
		if(param2 == 0){ //start
			GetClientAbsOrigin(param1,g_fCpSetBCords);
			g_hcpSetterTimer = CreateTimer(0.1, CpSetTimer, param1, TIMER_REPEAT);
			CpAdminPanelStart(param1);
			
			//stop map timer
			g_bRacing[param1] = false;
		}else{ //stop
			GetClientAbsOrigin(param1,g_fCpSetBCords);
			g_hcpSetterTimer = CreateTimer(0.1, CpSetTimer, param1, TIMER_REPEAT);
			CpAdminPanelStop(param1);
			
			//stop map timer
			g_bRacing[param1] = false;
		}
	}else if(action == MenuAction_End){
		CloseHandle(menu);
		g_bCpPanelOpen = false;
	}
}

//--------------------------//
// admin panel start method //
//--------------------------//
public CpAdminPanelStart(client){
	//create the panel
	new Handle:menu = CreateMenu(CpAdminPanelStartHandler);
	SetMenuTitle(menu, "byaaaaah's [cP Mod] - Startarea");
	AddMenuItem(menu, "Finish point", "Finish drawing startarea");
	SetMenuExitButton(menu, true);
	SetMenuOptionFlags(menu, MENUFLAG_BUTTON_EXIT);
	DisplayMenu(menu, client, MENU_TIME_FOREVER);
}
//---------//
// handler //
//---------//
public CpAdminPanelStartHandler(Handle:menu, MenuAction:action, param1, param2){
	if(action == MenuAction_Select){
		//depending on the item selected
		if(param2 == 0){ //finish
			SetTimerCords(param1, POS_START);
			CpAdminPanel(param1);
		}
	}else if(action == MenuAction_End){
		//close the box update timer
		if(g_hcpSetterTimer != INVALID_HANDLE){
			CloseHandle(g_hcpSetterTimer);
			g_hcpSetterTimer = INVALID_HANDLE
		}
		
		CloseHandle(menu);
		g_bCpPanelOpen = false;
	}
}

//-------------------------//
// admin panel stop method //
//-------------------------//
public CpAdminPanelStop(client){
	//create the panel
	new Handle:menu = CreateMenu(CpAdminPanelStopHandler);
	SetMenuTitle(menu, "byaaaaah's [cP Mod] - Stoparea");
	AddMenuItem(menu, "Finish point", "Finish drawing stoparea");
	SetMenuExitButton(menu, true);
	SetMenuOptionFlags(menu, MENUFLAG_BUTTON_EXIT);
	DisplayMenu(menu, client, MENU_TIME_FOREVER);
}
//---------//
// handler //
//---------//
public CpAdminPanelStopHandler(Handle:menu, MenuAction:action, param1, param2){
	if(action == MenuAction_Select){
		if(param2 == 0){ //finish
			SetTimerCords(param1, POS_STOP);
			CpAdminPanel(param1);
		}
	}else if(action == MenuAction_End){
		//close the box update timer
		if(g_hcpSetterTimer != INVALID_HANDLE){
			CloseHandle(g_hcpSetterTimer);
			g_hcpSetterTimer = INVALID_HANDLE
		}
		
		CloseHandle(menu);
		g_bCpPanelOpen = false;
	}
}

//---------------------//
// cp set timer action //
//---------------------//
public Action:CpSetTimer(Handle:timer, any:client){
	//if valid player
	if(client != 0 && IsClientInGame(client) && IsPlayerAlive(client)){
		//get position
		GetClientAbsOrigin(client,g_fCpSetECords);
		
		//draw blue box
		DrawBox(g_fCpSetBCords, g_fCpSetECords, 0.1, {0,0,255,255}, false);
		
	}else{ //no valid player
		//close the box update timer if not closed before
		if(g_hcpSetterTimer != INVALID_HANDLE){
			CloseHandle(g_hcpSetterTimer);
			g_hcpSetterTimer = INVALID_HANDLE;
		}
		g_bCpPanelOpen = false;
	}
}

//-------------------------//
// stet timer cords method //
//-------------------------//
public SetTimerCords(client, pos){
	decl String:szBCords[38];
	decl String:szECords[38];
	
	//update global variables if timer enabled
	if(g_bTimer){
		if(pos == POS_START){
			//add a little offset
			g_fCpSetBCords[2] -= 50;
			g_fCpSetECords[2] += 50;
			g_fMapTimer_start0_cords = g_fCpSetBCords;
			g_fMapTimer_start1_cords = g_fCpSetECords;
			
			//set start coordinates set to true
			g_bStartCordsSet = true;
			
			//calculate player spawn point
			setupPlayerSpawn();
		}else{
			//add a little offset
			g_fCpSetBCords[2] -= 50;
			g_fCpSetECords[2] += 50;
			g_fMapTimer_end0_cords = g_fCpSetBCords;
			g_fMapTimer_end1_cords = g_fCpSetECords;
			
			
			//set stop coordinates set to true
			g_bStopCordsSet = true;
		}
	}
	
	//format the coordinates in string buffers
	Format(szBCords, 38, "%f:%f:%f",g_fCpSetBCords[0],g_fCpSetBCords[1],g_fCpSetBCords[2]);
	Format(szECords, 38, "%f:%f:%f",g_fCpSetECords[0],g_fCpSetECords[1],g_fCpSetECords[2]);
	
	//update the coordinates in the database
	db_updateMapStartStop(client, szBCords, szECords, pos);
	
	//do not update the box anymore
	if(g_hcpSetterTimer != INVALID_HANDLE){
		CloseHandle(g_hcpSetterTimer);
		g_hcpSetterTimer = INVALID_HANDLE
	}
	
	EmitSoundToClient(client,"buttons/blip1.wav",client);
}

//--------------------------//
// admin purge players hook //
//--------------------------//
public Action:Admin_PurgePlayer(client, args){
	//if not correct arguments
	if(args != 1){
		ReplyToCommand(client, "[SM] Usage: sm_purgeplayer <days>");
		return Plugin_Handled;
	}
	
	//create the database query
	decl String:szDays[8];
	GetCmdArg(1, szDays, 8);
	db_purgePlayer(client, szDays);
	return Plugin_Handled;
}

//----------------------//
// admin drop maps hook //
//----------------------//
public Action:Admin_DropMap(client, args){
	db_dropMap(client);
	return Plugin_Handled;
}

//-------------------------//
// admin drop players hook //
//-------------------------//
public Action:Admin_DropPlayer(client, args){
	db_dropPlayer(client);
	return Plugin_Handled;
}

//------------------------//
// admin reset timer hook //
//------------------------//
public Action:Admin_ResetMapTimer(client, args){
	//if not correct arguments
	if(args != 1){
		ReplyToCommand(client, "[SM] Usage: sm_resetmaptimer <mapname>");
		return Plugin_Handled;
	}
	
	//create the database query
	decl String:szMapName[MAX_MAP_LENGTH];
	GetCmdArg(1, szMapName, MAX_MAP_LENGTH);
	db_resetMapTimer(client, szMapName);
	return Plugin_Handled;
}

//-------------------------------------//
// admin reset player checkpoints hook //
//-------------------------------------//
public Action:Admin_ResetCheckpoints(client, args){
	//if not enough arguments
	if(args < 1){
		ReplyToCommand(client, "[SM] Usage: sm_resetplayercheckpoints <playername> [<mapname>]");
		return Plugin_Handled;
	}else if(args == 1){
		decl String:szPlayerName[MAX_NAME_LENGTH];
		GetCmdArg(1, szPlayerName, MAX_NAME_LENGTH);
		
		db_resetPlayerCheckpoints(client, szPlayerName, g_szMapName);
	}else if(args == 2){
		decl String:szPlayerName[MAX_NAME_LENGTH];
		decl String:szMapName[MAX_MAP_LENGTH];
		GetCmdArg(1, szPlayerName, MAX_NAME_LENGTH);
		GetCmdArg(2, szMapName, MAX_NAME_LENGTH);
		
		db_resetPlayerCheckpoints(client, szPlayerName, szMapName);
	}
	return Plugin_Handled;
}

//---------------------------------//
// admin reset player records hook //
//---------------------------------//
public Action:Admin_ResetRecords(client, args){
	//if not enough arguments
	if(args < 1){
		ReplyToCommand(client, "[SM] Usage: sm_resetrecords <playername> [<mapname>]");
		return Plugin_Handled;
	}else if(args == 1){
		decl String:szPlayerName[MAX_NAME_LENGTH];
		GetCmdArg(1, szPlayerName, MAX_NAME_LENGTH);
		
		db_resetPlayerRecords(client, szPlayerName, g_szMapName);
	}else if(args == 2){
		decl String:szPlayerName[MAX_NAME_LENGTH];
		decl String:szMapName[MAX_MAP_LENGTH];
		GetCmdArg(1, szPlayerName, MAX_NAME_LENGTH);
		GetCmdArg(2, szMapName, MAX_NAME_LENGTH);
		
		db_resetPlayerRecords(client, szPlayerName, szMapName);
	}
	return Plugin_Handled;
}
