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
	if(g_hcpSetterTimer == INVALID_HANDLE)
		CpAdminPanel(client);
	else{
		PrintToChat(client, "%t", "CpPanelInAccess", YELLOW,LIGHTGREEN,YELLOW);
		PrintToChat(client, "%i", g_hcpSetterTimer);
	}
	
	return Plugin_Handled;
}
//-------------------------//
// admin cp command method //
//-------------------------//
public CpAdminPanel(client){
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
		}else{ //stop
			GetClientAbsOrigin(param1,g_fCpSetBCords);
			g_hcpSetterTimer = CreateTimer(0.1, CpSetTimer, param1, TIMER_REPEAT);
			CpAdminPanelStop(param1);
		}
	}else if(action == MenuAction_End){
		CloseHandle(menu);
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
		CloseHandle(g_hcpSetterTimer);
		g_hcpSetterTimer = INVALID_HANDLE
			
		CloseHandle(menu);
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
		CloseHandle(g_hcpSetterTimer);
		g_hcpSetterTimer = INVALID_HANDLE
		
		CloseHandle(menu);
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
		
		//initialize tempoary variables bottom front
		decl Float:fLeftBottomFront[3];
		fLeftBottomFront[0] = g_fCpSetBCords[0];
		fLeftBottomFront[1] = g_fCpSetBCords[1];
		fLeftBottomFront[2] = g_fCpSetECords[2];
		decl Float:fRightBottomFront[3];
		fRightBottomFront[0] = g_fCpSetECords[0];
		fRightBottomFront[1] = g_fCpSetBCords[1];
		fRightBottomFront[2] = g_fCpSetECords[2];
		
		//initialize tempoary variables bottom back
		decl Float:fLeftBottomBack[3];
		fLeftBottomBack[0] = g_fCpSetBCords[0];
		fLeftBottomBack[1] = g_fCpSetECords[1];
		fLeftBottomBack[2] = g_fCpSetECords[2];
		decl Float:fRightBottomBack[3];
		fRightBottomBack[0] = g_fCpSetECords[0];
		fRightBottomBack[1] = g_fCpSetECords[1];
		fRightBottomBack[2] = g_fCpSetECords[2];
		
		//initialize tempoary variables top front
		decl Float:lefttopfront[3];
		lefttopfront[0] = g_fCpSetBCords[0];
		lefttopfront[1] = g_fCpSetBCords[1];
		lefttopfront[2] = g_fCpSetBCords[2]+100;
		decl Float:righttopfront[3];
		righttopfront[0] = g_fCpSetECords[0];
		righttopfront[1] = g_fCpSetBCords[1];
		righttopfront[2] = g_fCpSetBCords[2]+100;
		
		//initialize tempoary variables top back
		decl Float:fLeftTopBack[3];
		fLeftTopBack[0] = g_fCpSetBCords[0];
		fLeftTopBack[1] = g_fCpSetECords[1];
		fLeftTopBack[2] = g_fCpSetBCords[2]+100;
		decl Float:fRightTopBack[3];
		fRightTopBack[0] = g_fCpSetECords[0];
		fRightTopBack[1] = g_fCpSetECords[1];
		fRightTopBack[2] = g_fCpSetBCords[2]+100;
		
		//create the box
		TE_SetupBeamPoints(fLeftBottomFront,fRightBottomFront,g_BeamSpriteFollow,0,0,0,0.1,3.0,3.0,10,0.0,{0,0,255,255},0);TE_SendToAll();
		TE_SetupBeamPoints(fLeftBottomFront,fLeftBottomBack,g_BeamSpriteFollow,0,0,0,0.1,3.0,3.0,10,0.0,{0,0,255,255},0);TE_SendToAll();
		TE_SetupBeamPoints(fLeftBottomFront,lefttopfront,g_BeamSpriteFollow,0,0,0,0.1,3.0,3.0,10,0.0,{0,0,255,255},0);TE_SendToAll();
		
		TE_SetupBeamPoints(lefttopfront,righttopfront,g_BeamSpriteFollow,0,0,0,0.1,3.0,3.0,10,0.0,{0,0,255,255},0);TE_SendToAll();
		TE_SetupBeamPoints(lefttopfront,fLeftTopBack,g_BeamSpriteFollow,0,0,0,0.1,3.0,3.0,10,0.0,{0,0,255,255},0);TE_SendToAll();
		TE_SetupBeamPoints(fRightTopBack,fLeftTopBack,g_BeamSpriteFollow,0,0,0,0.1,3.0,3.0,10,0.0,{0,0,255,255},0);TE_SendToAll();
		TE_SetupBeamPoints(fRightTopBack,righttopfront,g_BeamSpriteFollow,0,0,0,0.1,3.0,3.0,10,0.0,{0,0,255,255},0);TE_SendToAll();
		
		TE_SetupBeamPoints(fRightBottomBack,fLeftBottomBack,g_BeamSpriteFollow,0,0,0,0.1,3.0,3.0,10,0.0,{0,0,255,255},0);TE_SendToAll();
		TE_SetupBeamPoints(fRightBottomBack,fRightBottomFront,g_BeamSpriteFollow,0,0,0,0.1,3.0,3.0,10,0.0,{0,0,255,255},0);TE_SendToAll();
		TE_SetupBeamPoints(fRightBottomBack,fRightTopBack,g_BeamSpriteFollow,0,0,0,0.1,3.0,3.0,10,0.0,{0,0,255,255},0);TE_SendToAll();
		
		TE_SetupBeamPoints(fRightBottomFront,righttopfront,g_BeamSpriteFollow,0,0,0,0.1,3.0,3.0,10,0.0,{0,0,255,255},0);TE_SendToAll();
		TE_SetupBeamPoints(fLeftBottomBack,fLeftTopBack,g_BeamSpriteFollow,0,0,0,0.1,3.0,3.0,10,0.0,{0,0,255,255},0);TE_SendToAll();
		
		TE_SendToClient(client, 0.0);
	}else{ //no valid player
		//close the box update timer if not closed before
		if(g_hcpSetterTimer != INVALID_HANDLE){
			CloseHandle(g_hcpSetterTimer);
			g_hcpSetterTimer = INVALID_HANDLE
		}
	}
}


//------------------------//
// stet timer cords methd //
//------------------------//
public SetTimerCords(client, pos){
	decl String:szBCords[38];
	decl String:szECords[38];
	
	//update global variables if timer enabled
	if(g_bTimer){
		if(pos == POS_START){
			g_fMapTimer_start0_cords = g_fCpSetBCords;
			g_fMapTimer_start1_cords = g_fCpSetECords;
		}else{
			g_fMapTimer_end0_cords = g_fCpSetBCords;
			g_fMapTimer_end1_cords = g_fCpSetECords;
		}
	}
	
	//format the coordinates in string buffers
	Format(szBCords, 38, "%f:%f:%f",g_fCpSetBCords[0],g_fCpSetBCords[1],g_fCpSetBCords[2]-50);
	Format(szECords, 38, "%f:%f:%f",g_fCpSetECords[0],g_fCpSetECords[1],g_fCpSetECords[2]+50);
	
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
public Action:Admin_PurgePlayers(client, args){
	//if not enough arguments
	if (args < 2){
		ReplyToCommand(client, "[SM] Usage: sm_purgeplayer <days>");
		return Plugin_Handled;
	}
	
	//create the database query
	decl String:szDays[8];
	GetCmdArg(1, szDays, 8);
	db_purgePlayer(client, szDays);
	return Plugin_Handled;
}

//-----------------------//
// admin reset maps hook //
//-----------------------//
public Action:Admin_ResetMaps(client, args){
	db_resetMap(client);
	return Plugin_Handled;
}

//--------------------------//
// admin reset players hook //
//--------------------------//
public Action:Admin_ResetPlayers(client, args){
	db_resetPlayer(client);
	return Plugin_Handled;
}

//------------------------------//
// admin reset checkpoints hook //
//------------------------------//
public Action:Admin_ResetCheckpoints(client, args){
	db_resetCheckpoint(client);
	return Plugin_Handled;
}

//--------------------------//
// admin reset records hook //
//--------------------------//
public Action:Admin_ResetRecords(client, args){
	db_resetRecord(client);
	return Plugin_Handled;
}
