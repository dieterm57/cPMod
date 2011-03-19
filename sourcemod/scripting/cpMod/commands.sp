public Action:Client_Block(client, args){
	ToogleBlock(client); 
	return Plugin_Handled;
}
public Action:Client_Lowgrav(client, args){
	ClientGravity(client,0.5); 
	return Plugin_Handled;
}
public Action:Client_Normalgrav(client, args){
	ClientGravity(client,1.0); 
	return Plugin_Handled;
}
public Action:Client_Scout(client, args){
	ScoutClient(client); 
	return Plugin_Handled;
}

public Action:Client_Next(client, args){
	TeleClient(client,1);
	return Plugin_Handled;
}
public Action:Client_Prev(client, args){
	TeleClient(client,-1);
	return Plugin_Handled;
}
public Action:Client_Save(client, args){
	SaveClientLocation(client)
	return Plugin_Handled;
}
public Action:Client_Tele(client, args){
	TeleClient(client,0);
	return Plugin_Handled;
}
public Action:Client_Cp(client, args){
	TeleMenu(client);
	return Plugin_Handled;
}
public Action:Client_Clear(client, args){
	ClearClient(client);
	return Plugin_Handled;
}
public Action:Client_Help(client, args){
	HelpPanel(client);
	return Plugin_Handled;
}

public Action:Client_Record(client, args){
	RecordPanel(client);
	return Plugin_Handled;
}
public Action:Client_Restart(client, args){
	RestartTimer(client);
	return Plugin_Handled;
}
public Action:Client_Stop(client, args){
	StopTimer(client);
	return Plugin_Handled;
}
public Action:Client_Wr(client, args){
	TopRecordPanel(client);
	return Plugin_Handled;
}


public RecordPanel(client){
	db_selectRecord(client);
}

public TopRecordPanel(client){
	if(g_RecordType == RECORD_TIME)
		db_selectTopRecordTime(client);
	else
		db_selectTopRecordJump(client);
}

public StopTimer(client){
	if(g_Timer){
		//if(MapTimer[client] != INVALID_HANDLE){
			racing[client] = false;
			//CloseHandle(MapTimer[client]);
			//MapTimer[client] = INVALID_HANDLE;
			
			PrintToChat(client, "%t", "TimerStopped", YELLOW,LIGHTGREEN,YELLOW,GREEN,YELLOW);
		//}
	}else
		PrintToChat(client, "%t", "TimerDisabled", YELLOW,LIGHTGREEN,YELLOW);
}

public RestartTimer(client){
	if(g_Timer){
		//if(MapTimer[client] != INVALID_HANDLE){
			racing[client] = false;
			//CloseHandle(MapTimer[client]);
			//MapTimer[client] = INVALID_HANDLE;
		//}
		
		//CreateTimer(2.0, ActionRestartTimer, client);
		
		SDKCall(h_Respawn, client);
	} else
		PrintToChat(client, "%t", "TimerDisabled", YELLOW,LIGHTGREEN,YELLOW);
}

public ToogleBlock(client){
	if(g_Noblock && g_PlayerBlock && GetClientTeam(client) != 0){
		if(blocking[client]){
			SetEntData(client, FindSendPropOffs("CBaseEntity", "m_CollisionGroup"), 2, 4, true);
			blocking[client] = false;
			PrintToChat(client, "%t", "BlockingDisabled", YELLOW,LIGHTGREEN,YELLOW,GREEN,YELLOW);
		}else{
			SetEntData(client, FindSendPropOffs("CBaseEntity", "m_CollisionGroup"), 5, 4, true);
			blocking[client] = true;
			PrintToChat(client, "%t", "BlockingEnabled", YELLOW,LIGHTGREEN,YELLOW,GREEN,YELLOW);
		}
	}else
		PrintToChat(client, "%t", "NoblockDisabled", YELLOW,LIGHTGREEN,YELLOW);
}

public ScoutClient(client){
	if(scouts[client] < g_Scoutlimit){
		GivePlayerItem(client, "weapon_scout");
		scouts[client] ++;
		PrintToChat(client, "%t", "ScoutGiven", YELLOW,LIGHTGREEN,YELLOW);
	}else
		PrintToChat(client, "%t", "ScoutLimit", YELLOW,LIGHTGREEN,YELLOW);
}

public ClientGravity(client,Float:amount){
	if(g_Gravity && GetClientTeam(client) != 0){
		SetEntityGravity(client, amount);
		if(amount>=1.0)
			PrintToChat(client, "%t", "GravityNormal", YELLOW,LIGHTGREEN,YELLOW,GREEN,YELLOW);
		else
			PrintToChat(client, "%t", "GravityLow", YELLOW,LIGHTGREEN,YELLOW,GREEN,YELLOW);
	}else
		PrintToChat(client, "%t", "GravityDisabled", YELLOW,LIGHTGREEN,YELLOW);
}

public SaveClientLocation(client){
	if(g_Enabled){
		if(!racing[client]){
			if(GetEntDataEnt2(client, FindSendPropOffs("CBasePlayer", "m_hGroundEntity")) != -1){
				new whole = wholecp[client];
				
				if(whole < CPLIMIT){
					GetClientAbsOrigin(client,playercords[client][whole]);
					GetClientAbsAngles(client,playerangles[client][whole]);
					
					currentcp[client] = wholecp[client];
					wholecp[client] ++;
					
					PrintToChat(client, "%t", "CpSaved", YELLOW,LIGHTGREEN,YELLOW,GREEN,whole+1,whole+1,YELLOW);
					
					EmitSoundToClient(client,"buttons/blip1.wav",client);
					TE_SetupBeamRingPoint(playercords[client][whole],10.0,200.0,BeamSpriteRing1,0,0,10,1.0,50.0,0.0,{255,255,255,255},0,0);
					TE_SendToClient(client);
				} else
					PrintToChat(client, "%t", "CpLimit", YELLOW,LIGHTGREEN,YELLOW,GREEN,YELLOW);
			} else
				PrintToChat(client, "%t", "NotOnGround", YELLOW,LIGHTGREEN,YELLOW);
		} else
			PrintToChat(client, "%t", "TimerActiveProtection", YELLOW,LIGHTGREEN,YELLOW,GREEN,YELLOW);
	} else
		PrintToChat(client, "%t", "PluginDisabled", YELLOW,LIGHTGREEN,YELLOW);
}

public TeleClient(client,pos){
	if(g_Enabled){
		if(!racing[client]){
			new current = currentcp[client];
			new whole = wholecp[client];
			
			if(current == whole-1 && pos == 1){
				currentcp[client] = -1;
				current = -1;
			}
			if(current == 0  && pos == -1){
				currentcp[client] = whole;
				current = whole;
			}
			
			new actual = current+pos;
			
			if((playercords[client][actual][0] == 0) && (playercords[client][actual][1] == 0) && (playercords[client][actual][2] == 0)){
				PrintToChat(client, "%t", "CpNotFound", YELLOW,LIGHTGREEN,YELLOW);
			}else{
				TeleportEntity(client, playercords[client][actual],playerangles[client][actual],NULL_VECTOR);
				PrintToChat(client, "%t", "CpTeleported", YELLOW,LIGHTGREEN,YELLOW,GREEN,actual+1,whole,YELLOW);
				currentcp[client] += pos;
				
				EmitSoundToClient(client,"buttons/blip1.wav",client);
				TE_SetupBeamRingPoint(playercords[client][actual],10.0,200.0,BeamSpriteRing2,0,0,10,1.0,50.0,0.0,{255,255,255,255},0,0);
				TE_SendToClient(client);
			}
		} else
			PrintToChat(client, "%t", "TimerActiveProtection", YELLOW,LIGHTGREEN,YELLOW,GREEN,YELLOW);
	} else
		PrintToChat(client, "%t", "PluginDisabled", YELLOW,LIGHTGREEN,YELLOW);
}

public TeleMenu(client){
	if(g_Enabled){
		new Handle:menu = CreateMenu(TeleMenuHandler);
		SetMenuTitle(menu, "byaaaaah's [cP Mod]");
		AddMenuItem(menu, "!clear", "Erase all checkpoints");
		AddMenuItem(menu, "!next", "Next checkpoint");
		AddMenuItem(menu, "!prev", "Previous checkpoint");
		AddMenuItem(menu, "!save", "Saves a location");
		AddMenuItem(menu, "!tele", "Teleports you to last checkpoint");
		SetMenuExitButton(menu, true);
		SetMenuOptionFlags(menu, MENUFLAG_BUTTON_EXIT);
		DisplayMenu(menu, client, MENU_TIME_FOREVER);
	} else
		PrintToChat(client, "%t", "PluginDisabled", YELLOW,LIGHTGREEN,YELLOW);
}
public TeleMenuHandler(Handle:menu, MenuAction:action, param1, param2){
	if(action == MenuAction_Select){
		switch(param2){
			case 0: ClearClient(param1);
			case 1: TeleClient(param1,1);
			case 2: TeleClient(param1,-1);
			case 3: SaveClientLocation(param1);
			case 4: TeleClient(param1,0);
		}
		TeleMenu(param1);
	}else if(action == MenuAction_End)
	CloseHandle(menu);
}

public ClearClient(client){
	if(g_Enabled){
		currentcp[client] = 0;
		wholecp[client] = 0;
		
		for(new i = 0; i < CPLIMIT; i++){
			playercords[client][i][0]=0.0;
			playercords[client][i][1]=0.0;
			playercords[client][i][2]=0.0;
			playerangles[client][i][0]=0.0;
			playerangles[client][i][1]=0.0;
			playerangles[client][i][2]=0.0;
		}
		PrintToChat(client, "%t", "Cleared", YELLOW,LIGHTGREEN,YELLOW);
	} else
		PrintToChat(client, "%t", "PluginDisabled", YELLOW,LIGHTGREEN,YELLOW);
}

public HelpPanel(client){
	new Handle:panel = CreatePanel();
	DrawPanelText(panel, "byaaaaah's [cP Mod]");
	DrawPanelText(panel, " ");
	DrawPanelText(panel, "!help - Displays this menu");
	DrawPanelText(panel, "!cp - Opens teleportmenu");
	DrawPanelText(panel, " ");
	DrawPanelText(panel, "!clear - Erase all checkpoints");
	DrawPanelText(panel, "!next - Next checkpoint");
	DrawPanelText(panel, "!prev - Previous checkpoint");
	DrawPanelText(panel, "!save - Saves a checkpoint");
	DrawPanelText(panel, "!tele - Teleports you to last checkpoint");
	DrawPanelText(panel, " ");
	DrawPanelText(panel, "!block - Toogles your blocking");
	DrawPanelText(panel, "!lowgrav - Lowers your gravity");
	DrawPanelText(panel, "!normalgrav - Normals your gravity");
	DrawPanelText(panel, "!record - Displays your record");
	DrawPanelText(panel, "!restart - Restarts your timer");
	DrawPanelText(panel, "!scout - Gives you a scout");
	DrawPanelText(panel, "!stop - Stops the timer");
	DrawPanelText(panel, "!wr - Displays the record of this map");
	DrawPanelItem(panel, "exit");
	SendPanelToClient(panel, client, HelpPanelHandler, 10);
	CloseHandle(panel);
}
public HelpPanelHandler(Handle:menu, MenuAction:action, param1, param2){
}