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

//----------------------//
// some client commands //
//----------------------//
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

//----------------------//
// more client commands //
//----------------------//
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

//------------------------------------//
// and even some more client commands //
//------------------------------------//
public Action:Client_Record(client, args){
	if(args == 1){
		decl String:szMapName[MAX_MAP_LENGTH];
		GetCmdArg(1, szMapName, MAX_NAME_LENGTH);
		
		RecordPanel(client, szMapName);
	}else
		RecordPanel(client, g_szMapName);
	
	return Plugin_Handled;
}
public Action:Client_Player_Record(client, args){
	//if not enough arguments
	if(args < 1){
		ReplyToCommand(client, "[SM] Usage: sm_precord <name>");
		return Plugin_Handled;
	}else if(args == 1){
		decl String:szPlayerName[MAX_NAME_LENGTH];
		GetCmdArg(1, szPlayerName, MAX_NAME_LENGTH);
		
		PlayerRecordPanel(client, szPlayerName, g_szMapName);
	}else if(args == 2){
		decl String:szPlayerName[MAX_NAME_LENGTH];
		decl String:szMapName[MAX_MAP_LENGTH];
		GetCmdArg(1, szPlayerName, MAX_NAME_LENGTH);
		GetCmdArg(2, szMapName, MAX_NAME_LENGTH);
		
		PlayerRecordPanel(client, szPlayerName, szMapName);
	}
	
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

//---------------------//
// record panel method //
//---------------------//
public RecordPanel(client, String:szPlayerName[MAX_MAP_LENGTH]){
	db_viewRecord(client, szPlayerName);
}

//----------------------------//
// player record panel method //
//----------------------------//
public PlayerRecordPanel(client, String:szPlayerName[MAX_NAME_LENGTH], String:szMapName[MAX_MAP_LENGTH]){
  db_viewPlayerRecord(client, szPlayerName, szMapName);
}

//-------------------------//
// top record panel method //
//-------------------------//
public TopRecordPanel(client){
	//depending on the record type
	if(g_bRecordType == RECORD_TIME)
		db_selectTimeWorldRecord(client);
	else
		db_selectJumpWorldRecord(client);
}

//-------------------//
// stop timer method //
//-------------------//
public StopTimer(client){
	//if no valid player
	if(!IsPlayerAlive(client) || GetClientTeam(client) == 1)
		return;
	
	//if timer enabled
	if(g_bTimer){
		//if g_hMapTimer running
		if(g_hMapTimer[client] != INVALID_HANDLE){
			//stop it
			CloseHandle(g_hMapTimer[client]);
			g_hMapTimer[client] = INVALID_HANDLE;
			g_bRacing[client] = false;
			
			PrintToChat(client, "%t", "TimerStopped", YELLOW,LIGHTGREEN,YELLOW,GREEN,YELLOW);
		}
	}else //timer disabled
		PrintToChat(client, "%t", "TimerDisabled", YELLOW,LIGHTGREEN,YELLOW);
}

//----------------------//
// restart timer method //
//----------------------//
public RestartTimer(client){
	//if no valid player
	if(!IsPlayerAlive(client) || GetClientTeam(client) == 1)
		return;
		
	//if timer enabled
	if(g_bTimer){
		g_bRacing[client] = false;
		
		/*//if g_hMapTimer running
		if(g_hMapTimer[client] != INVALID_HANDLE){
			//stop it
			CloseHandle(g_hMapTimer[client]);
			g_hMapTimer[client] = INVALID_HANDLE;
		}*/
		
		//@deprecated
		//seems to be superfluous
		//CreateTimer(2.0, ActionRestartTimer, client);
		//SDKCall(h_Respawn, client);
		
		//respawn player
		CS_RespawnPlayer(client);
		
		PrintToChat(client, "%t", "TimerRestarted", YELLOW,LIGHTGREEN,YELLOW);
	}else //timer disabled
		PrintToChat(client, "%t", "TimerDisabled", YELLOW,LIGHTGREEN,YELLOW);
}

//---------------------//
// toogle block method //
//---------------------//
public ToogleBlock(client){
	//if no valid player
	if(!IsPlayerAlive(client) || GetClientTeam(client) == 1)
		return;
	
	//if noblock enabled and player may choose blocking
	if(g_bNoBlock && g_bPlayerBlock){
		//depending on current blocking state
		if(g_bBlocking[client]){
			SetEntData(client, FindSendPropOffs("CBaseEntity", "m_CollisionGroup"), 2, 4, true);
			g_bBlocking[client] = false;
			PrintToChat(client, "%t", "BlockingDisabled", YELLOW,LIGHTGREEN,YELLOW,GREEN,YELLOW);
		}else{
			SetEntData(client, FindSendPropOffs("CBaseEntity", "m_CollisionGroup"), 5, 4, true);
			g_bBlocking[client] = true;
			PrintToChat(client, "%t", "BlockingEnabled", YELLOW,LIGHTGREEN,YELLOW,GREEN,YELLOW);
		}
	}else //noblock disabled
		PrintToChat(client, "%t", "NoblockDisabled", YELLOW,LIGHTGREEN,YELLOW);
}

//---------------------//
// scout client method //
//---------------------//
public ScoutClient(client){
	//if no valid player
	if(!IsPlayerAlive(client) || GetClientTeam(client) == 1)
		return;
		
	//if scounts given smaller than the limit
	if(g_Scouts[client] < g_ScoutLimit){
		//spawn a scout
		GivePlayerItem(client, "weapon_scout");
		g_Scouts[client] ++;
		PrintToChat(client, "%t", "ScoutGiven", YELLOW,LIGHTGREEN,YELLOW);
	}else //limit reached
		PrintToChat(client, "%t", "ScoutLimit", YELLOW,LIGHTGREEN,YELLOW);
}

//-----------------------//
// client gravity method //
//-----------------------//
public ClientGravity(client,Float:amount){
	//if no valid player
	if(!IsPlayerAlive(client) || GetClientTeam(client) == 1)
		return;
		
	//if player gravity is enabled
	if(g_bGravity){
		//set amount to the new value
		SetEntityGravity(client, amount);
		if(amount>=1.0)
			PrintToChat(client, "%t", "GravityNormal", YELLOW,LIGHTGREEN,YELLOW,GREEN,YELLOW);
		else
			PrintToChat(client, "%t", "GravityLow", YELLOW,LIGHTGREEN,YELLOW,GREEN,YELLOW);
	}else //gravity disabled
		PrintToChat(client, "%t", "GravityDisabled", YELLOW,LIGHTGREEN,YELLOW);
}

//-----------------------------//
// save player location method //
//-----------------------------//
public SaveClientLocation(client){
	//if no valid player
	if(!IsPlayerAlive(client) || GetClientTeam(client) == 1)
		return;
	
	//if plugin is enabled
	if(g_bEnabled){
		//if player on ground
		if(GetEntDataEnt2(client, FindSendPropOffs("CBasePlayer", "m_hGroundEntity")) != -1){
			new whole = g_WholeCp[client];
			
			//if player has less than limit checkpoints
			if(whole < CPLIMIT){
				//save some data
				GetClientAbsOrigin(client,g_fPlayerCords[client][whole]);
				GetClientAbsAngles(client,g_fPlayerAngles[client][whole]);
				
				//increase counters
				g_CurrentCp[client] = g_WholeCp[client];
				g_WholeCp[client] ++;
				
				PrintToChat(client, "%t", "CpSaved", YELLOW,LIGHTGREEN,YELLOW,GREEN,whole+1,whole+1,YELLOW);
				
				EmitSoundToClient(client,"buttons/blip1.wav",client);
				TE_SetupBeamRingPoint(g_fPlayerCords[client][whole],10.0,200.0,g_BeamSpriteRing1,0,0,10,1.0,50.0,0.0,{255,255,255,255},0,0);
				TE_SendToClient(client);
			}else //checkpoint limit
				PrintToChat(client, "%t", "CpLimit", YELLOW,LIGHTGREEN,YELLOW,GREEN,YELLOW);
		}else //not on ground
			PrintToChat(client, "%t", "NotOnGround", YELLOW,LIGHTGREEN,YELLOW);
	}else //disabled
		PrintToChat(client, "%t", "PluginDisabled", YELLOW,LIGHTGREEN,YELLOW);
}

//---------------------//
// tele player method //
//--------------------//
public TeleClient(client,pos){
	//if no valid player
	if(!IsPlayerAlive(client) || GetClientTeam(client) == 1)
		return;
	
	//if plugin is enabled
	if(g_bEnabled){
		if(!g_bRacing[client]){
			new current = g_CurrentCp[client];
			new whole = g_WholeCp[client];
			
			//if on last slot go to next
			if(current == whole-1 && pos == 1){
				//reset to first
				g_CurrentCp[client] = -1;
				current = -1;
			}
			//if on first slot and previous
			if(current == 0  && pos == -1){
				//reset to last
				g_CurrentCp[client] = whole;
				current = whole;
			}
			
			new actual = current+pos;
			
			//if not valid checkpoint
			if(actual < 0 || actual > whole || (g_fPlayerCords[client][actual][0] == 0.0 && g_fPlayerCords[client][actual][1] == 0.0 && g_fPlayerCords[client][actual][2] == 0.0)){
				PrintToChat(client, "%t", "CpNotFound", YELLOW,LIGHTGREEN,YELLOW);
			}else{ //valid
				TeleportEntity(client, g_fPlayerCords[client][actual],g_fPlayerAngles[client][actual],NULL_VECTOR);
				PrintToChat(client, "%t", "CpTeleported", YELLOW,LIGHTGREEN,YELLOW,GREEN,actual+1,whole,YELLOW);
				g_CurrentCp[client] += pos;
				
				EmitSoundToClient(client,"buttons/blip1.wav",client);
				TE_SetupBeamRingPoint(g_fPlayerCords[client][actual],10.0,200.0,g_BeamSpriteRing2,0,0,10,1.0,50.0,0.0,{255,255,255,255},0,0);
				TE_SendToClient(client);
			}
		}else //client is on a race
			PrintToChat(client, "%t", "TimerActiveProtection", YELLOW,LIGHTGREEN,YELLOW,GREEN,YELLOW);
	}else //plugin disabled
		PrintToChat(client, "%t", "PluginDisabled", YELLOW,LIGHTGREEN,YELLOW);
}

//------------------//
// tele menu method //
//------------------//
public TeleMenu(client){
	//if no valid player
	if(!IsPlayerAlive(client) || GetClientTeam(client) == 1)
		return;
	
	//if plugin is enabled
	if(g_bEnabled){
		//create panel
		new Handle:menu = CreateMenu(TeleMenuHandler);
		SetMenuTitle(menu, "byaaaaah's [cP Mod]");
		AddMenuItem(menu, "!save", "Saves a location");
		AddMenuItem(menu, "!tele", "Teleports you to last checkpoint");
		AddMenuItem(menu, "!next", "Next checkpoint");
		AddMenuItem(menu, "!prev", "Previous checkpoint");
		AddMenuItem(menu, "!clear", "Erase all checkpoints");
		SetMenuExitButton(menu, true);
		SetMenuOptionFlags(menu, MENUFLAG_BUTTON_EXIT);
		DisplayMenu(menu, client, MENU_TIME_FOREVER);
	}else //plugin disabled
		PrintToChat(client, "%t", "PluginDisabled", YELLOW,LIGHTGREEN,YELLOW);
}
//---------//
// handler //
//---------//
public TeleMenuHandler(Handle:menu, MenuAction:action, param1, param2){
	if(action == MenuAction_Select){
		switch(param2){
			case 0: SaveClientLocation(param1);
			case 1: TeleClient(param1,0);
			case 2: TeleClient(param1,1);
			case 3: TeleClient(param1,-1);
			case 4: ClearClient(param1);
		}
		TeleMenu(param1);
	}else if(action == MenuAction_End)
		CloseHandle(menu);
}

//---------------------//
// clear player method //
//---------------------//
public ClearClient(client){
	//if no valid player
	if(!IsPlayerAlive(client) || GetClientTeam(client) == 1)
		return;
	
	//if plugin is enabled
	if(g_bEnabled){
		//reset counters
		g_CurrentCp[client] = -1;
		g_WholeCp[client] = 0;
		
		//@deprecated
		/* superfluous
		for(new i = 0; i < CPLIMIT; i++){
			g_fPlayerCords[client][i][0]=0.0;
			g_fPlayerCords[client][i][1]=0.0;
			g_fPlayerCords[client][i][2]=0.0;
			g_fPlayerAngles[client][i][0]=0.0;
			g_fPlayerAngles[client][i][1]=0.0;
			g_fPlayerAngles[client][i][2]=0.0;
		}*/
		
		PrintToChat(client, "%t", "Cleared", YELLOW,LIGHTGREEN,YELLOW);
	}else //plugin disabled
		PrintToChat(client, "%t", "PluginDisabled", YELLOW,LIGHTGREEN,YELLOW);
}

//-------------------//
// help panel method //
//-------------------//
public HelpPanel(client){
	//create panel
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
//---------//
// handler //
//---------//
public HelpPanelHandler(Handle:menu, MenuAction:action, param1, param2){
}
