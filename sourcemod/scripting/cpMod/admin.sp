public Action:Admin_CpPanel(client, args){
	CpAdminPanel(client); 
	return Plugin_Handled;
}

public CpAdminPanel(client){
	new Handle:menu = CreateMenu(CpAdminPanelHandler);
	SetMenuTitle(menu, "byaaaaah's [cP Mod] - Maptimer");
	AddMenuItem(menu, "Set start area", "Set timer start");
	AddMenuItem(menu, "Set stop area", "Set timer stop");
	SetMenuExitButton(menu, true);
	SetMenuOptionFlags(menu, MENUFLAG_BUTTON_EXIT);
	DisplayMenu(menu, client, MENU_TIME_FOREVER);
}
public CpAdminPanelHandler(Handle:menu, MenuAction:action, param1, param2){
	if(action == MenuAction_Select){
		if(param2 == 0){
			GetClientAbsOrigin(param1,cpsetbcords);
			CpSetterTimer = CreateTimer(0.1, CpSetTimer, param1, TIMER_REPEAT);
			CpAdminPanelStart(param1);
		} else{
			GetClientAbsOrigin(param1,cpsetbcords);
			CpSetterTimer = CreateTimer(0.1, CpSetTimer, param1, TIMER_REPEAT);
			CpAdminPanelEnd(param1);
		}
	}else if(action == MenuAction_End)
		CloseHandle(menu);
}

public CpAdminPanelStart(client){
	new Handle:menu = CreateMenu(CpAdminPanelStartHandler);
	SetMenuTitle(menu, "byaaaaah's [cP Mod] - Startarea");
	AddMenuItem(menu, "Finish point", "Finish drawing startarea");
	SetMenuExitButton(menu, true);
	SetMenuOptionFlags(menu, MENUFLAG_BUTTON_EXIT);
	DisplayMenu(menu, client, MENU_TIME_FOREVER);
}
public CpAdminPanelStartHandler(Handle:menu, MenuAction:action, param1, param2){
	if(action == MenuAction_Select){
		if(param2 == 0){
			SetTimerCords(param1, POS_START);
			CpAdminPanel(param1);
		}
	}else if(action == MenuAction_End){
		if(CpSetterTimer != INVALID_HANDLE)
			CloseHandle(CpSetterTimer);
		CloseHandle(menu);
	}
}

public CpAdminPanelEnd(client){
	new Handle:menu = CreateMenu(CpAdminPanelEndHandler);
	SetMenuTitle(menu, "byaaaaah's [cP Mod] - Stoparea");
	AddMenuItem(menu, "Finish point", "Finish drawing stoparea");
	SetMenuExitButton(menu, true);
	SetMenuOptionFlags(menu, MENUFLAG_BUTTON_EXIT);
	DisplayMenu(menu, client, MENU_TIME_FOREVER);
}
public CpAdminPanelEndHandler(Handle:menu, MenuAction:action, param1, param2){
	if(action == MenuAction_Select){
		if(param2 == 0){
			SetTimerCords(param1, POS_STOP);
			CpAdminPanel(param1);
		}
	}else if(action == MenuAction_End){
		if(CpSetterTimer != INVALID_HANDLE)
			CloseHandle(CpSetterTimer);
		CloseHandle(menu);
	}
}


public Action:CpSetTimer(Handle:timer, any:client){
	if(client != 0 && IsClientInGame(client) && IsPlayerAlive(client)){
		GetClientAbsOrigin(client,cpsetecords);
		
		decl Float:leftbottomfront[3];
		leftbottomfront[0] = cpsetbcords[0];
		leftbottomfront[1] = cpsetbcords[1];
		leftbottomfront[2] = cpsetecords[2];
		decl Float:rightbottomfront[3];
		rightbottomfront[0] = cpsetecords[0];
		rightbottomfront[1] = cpsetbcords[1];
		rightbottomfront[2] = cpsetecords[2];
		
		decl Float:leftbottomback[3];
		leftbottomback[0] = cpsetbcords[0];
		leftbottomback[1] = cpsetecords[1];
		leftbottomback[2] = cpsetecords[2];
		decl Float:rightbottomback[3];
		rightbottomback[0] = cpsetecords[0];
		rightbottomback[1] = cpsetecords[1];
		rightbottomback[2] = cpsetecords[2];
		
		
		decl Float:lefttopfront[3];
		lefttopfront[0] = cpsetbcords[0];
		lefttopfront[1] = cpsetbcords[1];
		lefttopfront[2] = cpsetbcords[2]+100;
		decl Float:righttopfront[3];
		righttopfront[0] = cpsetecords[0];
		righttopfront[1] = cpsetbcords[1];
		righttopfront[2] = cpsetbcords[2]+100;
		
		decl Float:lefttopback[3];
		lefttopback[0] = cpsetbcords[0];
		lefttopback[1] = cpsetecords[1];
		lefttopback[2] = cpsetbcords[2]+100;
		decl Float:righttopback[3];
		righttopback[0] = cpsetecords[0];
		righttopback[1] = cpsetecords[1];
		righttopback[2] = cpsetbcords[2]+100;
		
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
	} else
		CloseHandle(CpSetterTimer);
}


public SetTimerCords(client, pos){
	decl String:bcords[38];
	decl String:ecords[38];
	
	Format(bcords, 38, "%f:%f:%f",cpsetbcords[0],cpsetbcords[1],cpsetbcords[2]-50);
	Format(ecords, 38, "%f:%f:%f",cpsetecords[0],cpsetecords[1],cpsetecords[2]+50);
	
	db_updateMapStartStop(client, bcords, ecords, pos);
	
	EmitSoundToClient(client,"buttons/blip1.wav",client);
}


public Action:Admin_PurgePlayers(client, args){
	if (args < 2){
		ReplyToCommand(client, "[SM] Usage: sm_cp_purgeplayer <days>");
		return Plugin_Handled;
	}

	decl String:szdays[8];
	GetCmdArg(1, szdays, 8);
	db_purgePlayer(client, szdays);
	return Plugin_Handled;
}

public Action:Admin_ResetMaps(client, args){
	db_resetMap(client);
	return Plugin_Handled;
}

public Action:Admin_ResetPlayers(client, args){
	db_resetPlayer(client);
	return Plugin_Handled;
}

public Action:Admin_ResetCheckpoints(client, args){
	db_resetCheckpoint(client);
	return Plugin_Handled;
}

public Action:Admin_ResetRecords(client, args){
	db_resetRecord(client);
	return Plugin_Handled;
}