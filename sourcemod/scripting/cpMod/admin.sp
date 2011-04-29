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
	//call the method
	CpAdminPanel(client); 
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
			GetClientAbsOrigin(param1,cpsetbcords);
			CpSetterTimer = CreateTimer(0.1, CpSetTimer, param1, TIMER_REPEAT);
			CpAdminPanelStart(param1);
		}else{ //stop
			GetClientAbsOrigin(param1,cpsetbcords);
			CpSetterTimer = CreateTimer(0.1, CpSetTimer, param1, TIMER_REPEAT);
			CpAdminPanelStop(param1);
		}
	}else if(action == MenuAction_End)
		CloseHandle(menu);
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
		if(CpSetterTimer != INVALID_HANDLE)
			CloseHandle(CpSetterTimer);
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
		if(CpSetterTimer != INVALID_HANDLE)
			CloseHandle(CpSetterTimer);
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
		GetClientAbsOrigin(client,cpsetecords);
		
		//initialize tempoary variables bottom front
		decl Float:leftbottomfront[3];
		leftbottomfront[0] = cpsetbcords[0];
		leftbottomfront[1] = cpsetbcords[1];
		leftbottomfront[2] = cpsetecords[2];
		decl Float:rightbottomfront[3];
		rightbottomfront[0] = cpsetecords[0];
		rightbottomfront[1] = cpsetbcords[1];
		rightbottomfront[2] = cpsetecords[2];
		
		//initialize tempoary variables bottom back
		decl Float:leftbottomback[3];
		leftbottomback[0] = cpsetbcords[0];
		leftbottomback[1] = cpsetecords[1];
		leftbottomback[2] = cpsetecords[2];
		decl Float:rightbottomback[3];
		rightbottomback[0] = cpsetecords[0];
		rightbottomback[1] = cpsetecords[1];
		rightbottomback[2] = cpsetecords[2];
		
		//initialize tempoary variables top front
		decl Float:lefttopfront[3];
		lefttopfront[0] = cpsetbcords[0];
		lefttopfront[1] = cpsetbcords[1];
		lefttopfront[2] = cpsetbcords[2]+100;
		decl Float:righttopfront[3];
		righttopfront[0] = cpsetecords[0];
		righttopfront[1] = cpsetbcords[1];
		righttopfront[2] = cpsetbcords[2]+100;
		
		//initialize tempoary variables top back
		decl Float:lefttopback[3];
		lefttopback[0] = cpsetbcords[0];
		lefttopback[1] = cpsetecords[1];
		lefttopback[2] = cpsetbcords[2]+100;
		decl Float:righttopback[3];
		righttopback[0] = cpsetecords[0];
		righttopback[1] = cpsetecords[1];
		righttopback[2] = cpsetbcords[2]+100;
		
		//create the box
		TE_SetupBeamPoints(leftbottomfront,rightbottomfront,BeamSpriteFollow,0,0,0,0.1,3.0,3.0,10,0.0,{0,255,0,255},0);TE_SendToAll();
		TE_SetupBeamPoints(leftbottomfront,leftbottomback,BeamSpriteFollow,0,0,0,0.1,3.0,3.0,10,0.0,{0,255,0,255},0);TE_SendToAll();
		TE_SetupBeamPoints(leftbottomfront,lefttopfront,BeamSpriteFollow,0,0,0,0.1,3.0,3.0,10,0.0,{0,255,0,255},0);TE_SendToAll();
		
		TE_SetupBeamPoints(lefttopfront,righttopfront,BeamSpriteFollow,0,0,0,0.1,3.0,3.0,10,0.0,{0,255,0,255},0);TE_SendToAll();
		TE_SetupBeamPoints(lefttopfront,lefttopback,BeamSpriteFollow,0,0,0,0.1,3.0,3.0,10,0.0,{0,255,0,255},0);TE_SendToAll();
		TE_SetupBeamPoints(righttopback,lefttopback,BeamSpriteFollow,0,0,0,0.1,3.0,3.0,10,0.0,{0,255,0,255},0);TE_SendToAll();
		TE_SetupBeamPoints(righttopback,righttopfront,BeamSpriteFollow,0,0,0,0.1,3.0,3.0,10,0.0,{0,255,0,255},0);TE_SendToAll();
		
		TE_SetupBeamPoints(rightbottomback,leftbottomback,BeamSpriteFollow,0,0,0,0.1,3.0,3.0,10,0.0,{0,255,0,255},0);TE_SendToAll();
		TE_SetupBeamPoints(rightbottomback,rightbottomfront,BeamSpriteFollow,0,0,0,0.1,3.0,3.0,10,0.0,{0,255,0,255},0);TE_SendToAll();
		TE_SetupBeamPoints(rightbottomback,righttopback,BeamSpriteFollow,0,0,0,0.1,3.0,3.0,10,0.0,{0,255,0,255},0);TE_SendToAll();
		
		TE_SetupBeamPoints(rightbottomfront,righttopfront,BeamSpriteFollow,0,0,0,0.1,3.0,3.0,10,0.0,{0,255,0,255},0);TE_SendToAll();
		TE_SetupBeamPoints(leftbottomback,lefttopback,BeamSpriteFollow,0,0,0,0.1,3.0,3.0,10,0.0,{0,255,0,255},0);TE_SendToAll();
	}else //no valid player
		CloseHandle(CpSetterTimer);
}


//------------------------//
// stet timer cords methd //
//------------------------//
public SetTimerCords(client, pos){
	decl String:bcords[38];
	decl String:ecords[38];
	
	//format the coordinates in string buffers
	Format(bcords, 38, "%f:%f:%f",cpsetbcords[0],cpsetbcords[1],cpsetbcords[2]-50);
	Format(ecords, 38, "%f:%f:%f",cpsetecords[0],cpsetecords[1],cpsetecords[2]+50);
	
	//update the coordinates in the database
	db_updateMapStartStop(client, bcords, ecords, pos);
	//do not update the box anymore
	CloseHandle(CpSetterTimer);
	
	EmitSoundToClient(client,"buttons/blip1.wav",client);
}


//--------------------------//
// admin purge players hook //
//--------------------------//
public Action:Admin_PurgePlayers(client, args){
	//if not enough arguments
	if (args < 2){
		ReplyToCommand(client, "[SM] Usage: sm_cp_purgeplayer <days>");
		return Plugin_Handled;
	}
	
	//create the database query
	decl String:szdays[8];
	GetCmdArg(1, szdays, 8);
	db_purgePlayer(client, szdays);
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
