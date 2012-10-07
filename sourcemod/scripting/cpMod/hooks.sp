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
 * FOR A PARTICULAR PURPOSE. See the GNU General Public License for more
 * details.
 *
 * You should have received a copy of the GNU General Public License along with
 * this program. If not, see <http://www.gnu.org/licenses/>.
 *
 * As a special exception, AlliedModders LLC gives you permission to link the
 * code of this program (as well as its derivative 1works) to "Half-Life 2," the
 * "Source Engine," the "SourcePawn JIT," and any Game MODs that run on software
 * by the Valve Corporation. You must obey the GNU General Public License in
 * all respects for all other code used. Additionally, AlliedModders LLC grants
 * this exception to all derivative works. AlliedModders LLC defines further
 * exceptions, found in LICENSE.txt,
 * or <http://www.sourcemod.net/license.php>.
 *
 *
 */

//-------------------//
// player spawn hook //
//-------------------//
public Action:Event_player_spawn(Handle:event, const String:name[], bool:dontBroadcast){
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	
	//if valid player (not teamless/spectator)
	if(client != 0 && (GetClientTeam(client) > 1)){
		//if noblock enabled
		if(g_bNoBlock){
			//disable g_bBlocking
			SetEntData(client, FindSendPropOffs("CBaseEntity", "m_CollisionGroup"), 2, 4, true);
			g_bBlocking[client] = false;
		}
		
		//set player translucent
		SetEntityRenderMode(client, RENDER_TRANSCOLOR);
		SetEntityRenderColor(client, 255,255,255,g_Alpha);
		
		//if auto flash enabled
		if(g_bAutoFlash)
			//give the player a first flash
			GivePlayerItem(client, "weapon_flashbang");
		
		//if player healing enabled
		if(g_bHealClient)
			//set the initial health
			SetEntData(client, FindSendPropOffs("CBasePlayer", "m_iHealth"), 500);
		
		//if map run timer enabled and not allready started
		if(g_bTimer && g_hMapTimer[client] == INVALID_HANDLE) {
			//create the timer for the player
			g_hMapTimer[client] = CreateTimer(0.1, Action_MapTimer, client, TIMER_REPEAT);
		}
		
		new AdminId:aid = GetUserAdmin(client);
		//if the player is an admin
		if(aid != INVALID_ADMIN_ID && GetAdminFlag(aid, Admin_Generic)){
			//if player tracer enabled and not allready started
			if(g_bTracer && g_hTraceTimer[client] == INVALID_HANDLE)
				//give him a nice tracer
				g_hTraceTimer[client] = CreateTimer(1.0, ActionTraceTimer, client, TIMER_REPEAT);
			
			//if the timer is enabled and the cords are not set
			if(g_bTimer && (g_bStartCordsSet == false || g_bStopCordsSet == false)){
				//give him the chance to set them
				PrintToChat(client, "%t", "CordsNotSet", YELLOW,LIGHTGREEN,YELLOW,GREEN,YELLOW);
				CpAdminPanel(client);
			}
		}
	}
}
//------------------//
// player hurt hook //
//------------------//
public Action:Event_player_hurt(Handle:event, const String:name[], bool:dontBroadcast){
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	new damage = GetEventInt(event, "damage");
	//set the player health to 500 + what he would have lost
	SetEntData(client, FindSendPropOffs("CBasePlayer", "m_iHealth"), 500+damage);
}
//------------------//
// player jump hook //
//------------------//
public Action:Event_player_jump(Handle:event,const String:name[],bool:dontBroadcast){
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	//increase the runjumps stats by one
	g_RunJumps[client]++;
}
//-------------------------//
// flashbang detonate hook //
//-------------------------//
public Action:Event_flashbang_detonate(Handle:event,const String:name[],bool:dontBroadcast){
	new client = GetClientOfUserId(GetEventInt(event,"userid"));
	//remove the flash
	SetEntDataFloat(client,FindSendPropOffs("CCSPlayer", "m_flFlashMaxAlpha"),0.0);
}
//------------------//
// weapon fire hook //
//------------------//
public Action:Event_weapon_fire(Handle:event,const String:name[],bool:dontBroadcast){
	decl String:szWeaponName[32];
	GetEventString(event, "weapon", szWeaponName, 32);
	new client = GetClientOfUserId(GetEventInt(event,"userid"));
	
	//if the fired weapon is a flashbang
	if(StrEqual(szWeaponName,"flashbang"))
		//give the player a flashbang back
		GivePlayerItem(client, "weapon_flashbang");
}

//--------------------//
// clean timer action //
//--------------------//
public Action:ActionCleanTimer(Handle:timer, any:client){
	//By Kigen (c) 2008 - Please give me credit. :) //there u are :)
	new maxent = GetMaxEntities(), String:name[64];
	for(new i=GetMaxClients(); i<maxent; i++){
		if(IsValidEdict(i) && IsValidEntity(i)){
			GetEdictClassname(i, name, sizeof(name));
			//if((StrContains(name, "weapon_") != -1 || StrContains(name, "item_") != -1 ) && GetEntDataEnt2(i, g_WeaponParent) == -1)
			if((StrContains(name, "weapon_scout") != -1 || StrContains(name, "weapon_usp") != -1 || StrContains(name, "item_") != -1 ) && GetEntDataEnt2(i, g_WeaponParent) == -1)
				//segmentation error if map end??
				RemoveEdict(i);
		}
	}
}

//--------------------//
// trace timer action //
//--------------------//
public Action:ActionTraceTimer(Handle:timer, any:client){
	//if valid player
	if(client != 0 && IsClientInGame(client) && IsPlayerAlive(client)){
		TE_SetupBeamFollow(client,g_BeamSpriteFollow,0,1.0,5.0,50.0,70,{255,255,255,100});TE_SendToAll();
		return Plugin_Continue;
	}else{ //not valid
		g_hTraceTimer[client] = INVALID_HANDLE;
		
		return Plugin_Stop;
	}
}

//------------------------//
// draw zone timer action //
//------------------------//
public Action:ActionDrawZoneTimer(Handle:timer, any:client){
	//draw start yellow
	DrawBox(g_fMapTimer_start0_cords, g_fMapTimer_start1_cords, 1.0, {255,255,0,255}, true);
	//draw finish green
	DrawBox(g_fMapTimer_end0_cords, g_fMapTimer_end1_cords, 1.0, {0,255,0,255}, true);
	return Plugin_Continue;
}

//------------------------//
// player visibility hook //
//------------------------//
public Action:SetTransmit(entity, client){
		if(client != entity && (0 < entity <= MaxClients) && g_bHidden[client])
			return Plugin_Handled;
		return Plugin_Continue;
}

//------------------//
// map timer action //
//------------------//
public Action:Action_MapTimer(Handle:timer, any:client){
	//if this is a valid player and timer start & stop are set
	if(client != 0 && IsClientInGame(client) && IsPlayerAlive(client) && g_bStartCordsSet && g_bStopCordsSet){
		decl Float:fPCords[3];
		GetClientAbsOrigin(client,fPCords);
		decl String:szTime[16];
		decl String:szJumps[16];
		
		//if player is not yet racing
		if(g_bRacing[client] == false){
			//if player is in start zone
			if(IsInsideBox(fPCords, POS_START)){
				//disable lowgrav first if enabled
				SetEntityGravity(client, 1.0);
				
				//set variables for racing
				g_bRacing[client] = true;
				g_RunTime[client] = 1;
				g_RunJumps[client] = 0;
				PrintToChat(client, "%t", "TimerStarted", YELLOW,LIGHTGREEN,YELLOW,GREEN,YELLOW);
			}
		}else{ //racing?
			//if player is again in start zone
			if(IsInsideBox(fPCords, POS_START)){
				//set variables for racing again
				g_RunTime[client] = 0;
				g_RunJumps[client] = 0;
				//PrintToChat(client, "%t", "TimerRestarted", YELLOW,LIGHTGREEN,YELLOW,GREEN,YELLOW);
			}else{ //racing!
				//play startsound once
				if(g_RunTime[client] == 0 && g_RunJumps[client] == 0){
					//if a start sound is set
					if(g_bStartSound)
						EmitSoundToClient(client, g_szStartSound);
				}
				
				//increase the runtime
				g_RunTime[client]++;
				
				//calculate time, jumps and speed (gets called every 0.1 sec!)
				new minutes = g_RunTime[client]/600;
				new Float:seconds = (g_RunTime[client]-minutes*600)/10.0;
				Format(szTime, 16, "%dm %.1fs", minutes, seconds);
				Format(szJumps, 16, "%d", g_RunJumps[client]);
				decl Float:fVelocity[3];
				GetEntPropVector(client, Prop_Data, "m_vecVelocity", fVelocity);
				
				new speed = RoundToFloor(SquareRoot(Pow(fVelocity[0],2.0)+Pow(fVelocity[1],2.0)+Pow(fVelocity[2],2.0)));
				//display km/h or just units
				if(g_bSpeedUnit){
					speed = RoundToFloor(speed*0.06858);
					PrintHintText(client,"Your time: %s\nJumps: %s\nSpeed: %d Km/h",szTime,szJumps,speed);
				}else
					PrintHintText(client,"Your time: %s\nJumps: %s\nSpeed: %d units/s",szTime,szJumps,speed);
				
				//if playing hint sound disabled
				if(g_bHintSound == false)
					//stop the hintsound
					StopSound(client, SNDCHAN_STATIC, "UI/hint.wav");
				
				//if player is in end zone
				if(IsInsideBox(fPCords, POS_STOP)){
					//depending on recordtype
					if(g_bRecordType == RECORD_TIME){
					
						//check for new time record
						if(g_RunTime[client] < g_RecordTime){
							decl String:szName[MAX_NAME_LENGTH];
							GetClientName(client, szName, MAX_NAME_LENGTH);
							
							//if output to all
							if(g_bChatVisible){
								PrintToChatAll("%t", "TimerRecord", YELLOW,LIGHTGREEN,YELLOW,GREEN,szName,YELLOW,LIGHTGREEN,szTime,YELLOW);
								
								//if a record sound is set
								if(g_bRecordSound)
									EmitSoundToAll(g_szRecordSound, client);
									
							//client only output
							}else{
								PrintToChat(client, "%t", "TimerRecord", YELLOW,LIGHTGREEN,YELLOW,GREEN,szName,YELLOW,LIGHTGREEN,szTime,YELLOW);
								
								//if a record sound is set
								if(g_bRecordSound)
									EmitSoundToClient(client, g_szRecordSound);
							}
							
							//update the temporary variables
							g_RecordTime = g_RunTime[client];
						}else{ //no new record
							PrintToChat(client, "%t", "TimerFinished", YELLOW,LIGHTGREEN,YELLOW,LIGHTGREEN,szTime,YELLOW,GREEN,YELLOW);
							
							//if a finish sound is set
							if(g_bFinishSound)
								EmitSoundToClient(client, g_szFinishSound);
						}
						
					}else{
						//check for new jump record
						if(g_RunJumps[client] < g_RecordJumps){
							decl String:szName[MAX_NAME_LENGTH];
							GetClientName(client, szName, MAX_NAME_LENGTH);
							
							if(g_bChatVisible){
								PrintToChatAll("%t", "TimerRecord", YELLOW,LIGHTGREEN,YELLOW,GREEN,szName,YELLOW,LIGHTGREEN,szJumps,YELLOW);
								EmitSoundToAll(g_szRecordSound, client);
							}else{
								PrintToChat(client, "%t", "TimerRecord", YELLOW,LIGHTGREEN,YELLOW,GREEN,szName,YELLOW,LIGHTGREEN,szJumps,YELLOW);
								EmitSoundToClient(client, g_szRecordSound);
							}
							//TODO: add rank output like in phrases
							//update the temporary variables
							g_RecordJumps = g_RunJumps[client];
						}else{ //no new record
							PrintToChat(client, "%t", "TimerFinished", YELLOW,LIGHTGREEN,YELLOW,LIGHTGREEN,szJumps,YELLOW,GREEN,YELLOW);
							
							//if a finish sound is set
							if(g_bFinishSound)
								EmitSoundToClient(client, g_szFinishSound);
						}
						
					}
					
					//update the player record in the database
					db_updateRecord(client);
					
					//disable racing
					g_bRacing[client] = false;
					
					return Plugin_Continue;
				}
			}
		}
		return Plugin_Continue;
	}else{ //no valid player
		g_hMapTimer[client] = INVALID_HANDLE;
		g_bRacing[client] = false;
		
		return Plugin_Stop;
	}
}