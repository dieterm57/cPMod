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
// player spawn hook //
//-------------------//
public Action:Event_player_spawn(Handle:event, const String:name[], bool:dontBroadcast){
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	//if noblock enabled
	if(g_Noblock){
		//disable blocking
		SetEntData(client, FindSendPropOffs("CBaseEntity", "m_CollisionGroup"), 2, 4, true);
		blocking[client] = false;
	}
	//if player alpha enabled
	if(g_Alpha){
		//set player translucent
		SetEntityRenderMode(client, RENDER_TRANSCOLOR);
		SetEntityRenderColor(client, 255,255,255,70);
	}
	//if auto flash enabled
	if(g_AutoFlash)
		//give the player a first flash
		GivePlayerItem(client, "weapon_flashbang");
	
	//if player healing enabled
	if(g_HealClient)
		//set the initial health
		SetEntData(client, FindSendPropOffs("CBasePlayer", "m_iHealth"), 500);
	
	//if map run timer enabled
	if(g_Timer)
		//create the timer for the player
		MapTimer[client] = CreateTimer(1.0, ActionMapTimer, client, TIMER_REPEAT);
	
	new AdminId:aid = GetUserAdmin(client);
	//if the player is an admin
	if(aid != INVALID_ADMIN_ID && GetAdminFlag(aid, Admin_Generic)){
		//if player tracer enabled
		if(g_Tracer)
			//give him a nice tracer
			TraceTimer[client] = CreateTimer(1.0, ActionTraceTimer, client, TIMER_REPEAT);
		
		//if the timer is enabled end the cords are not set
		if(g_Timer && !g_CordsSet){
			//give him the chance to set them
			PrintToChat(client, "%t", "CordsNotSet", YELLOW,LIGHTGREEN,YELLOW,GREEN,YELLOW);
			CpAdminPanel(client);
		}
	}
}
//--------------------//
// player hurt hook //
//--------------------//
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
	runjumps[client]++;
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
	decl String:weaponname[32];
	GetEventString(event, "weapon", weaponname, 200);
	new client = GetClientOfUserId(GetEventInt(event,"userid"));
	//if the fired weapon is a flashbang
	if(StrEqual(weaponname,"flashbang"))
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
			if((StrContains(name, "weapon_") != -1 || StrContains(name, "item_") != -1 ) && GetEntDataEnt2(i, g_WeaponParent) == -1)
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
		TE_SetupBeamFollow(client,BeamSpriteFollow,0,1.0,5.0,50.0,70,{255,255,255,100});TE_SendToAll();
		return Plugin_Continue;
	}else //not valid
		return Plugin_Stop;
}

//----------------------//
// restart timer action //
//----------------------//
//@deprecated
public Action:ActionRestartTimer(Handle:timer, any:client){
	MapTimer[client] = CreateTimer(1.0, ActionMapTimer, client, TIMER_REPEAT);
}


//--------------------------//
// player inside box method //
//--------------------------//
public IsInsideBox(Float: pcords[3], pos){
	new Float:px=pcords[0];
	new Float:py=pcords[1];
	new Float:pz=pcords[2];
	
	decl Float:bsx;
	decl Float:bsy;
	decl Float:bsz;
	decl Float:bex;
	decl Float:bey;
	decl Float:bez;
	
	//set variables depending on the zone
	if(pos == POS_START){
		bsx=maptimer_start0_cords[0];
		bsy=maptimer_start0_cords[1];
		bsz=maptimer_start0_cords[2];
		bex=maptimer_start1_cords[0];
		bey=maptimer_start1_cords[1];
		bez=maptimer_start1_cords[2];
	}else{
		bsx=maptimer_end0_cords[0];
		bsy=maptimer_end0_cords[1];
		bsz=maptimer_end0_cords[2];
		bex=maptimer_end1_cords[0];
		bey=maptimer_end1_cords[1];
		bez=maptimer_end1_cords[2];
	}
	
	new bool:x=false;
	new bool:y=false;
	new bool:z=false;
	
	//check all possibilities
	if(bsx>bex && px<=bsx && px>=bex)
		x=true;
	else if(bsx<bex && px>=bsx && px<=bex)
		x=true;
	
	if(bsy>bey && py<=bsy && py>=bey)
		y=true;
	else if(bsy<bey && py>=bsy && py<=bey)
		y=true;
		
	if(bsz>bez && pz <= bsz && pz>=bez)
		z=true;
	else if(bsz<bez && pz>=bsz && pz<=bez)
		z=true;
	
	if(x&&y&&z)
		return true;

	return false;
}

//------------------//
// map timer action //
//------------------//
public Action:ActionMapTimer(Handle:timer, any:client){
	//if this is a valid player
	if(client != 0 && IsClientInGame(client) && IsPlayerAlive(client)){
		decl Float:pcords[3];
		GetClientAbsOrigin(client,pcords);
		decl String:time[16];
		decl String:jumps[16];
		
		//if player is allready racing
		if(racing[client] == false){
			//if player is in start zone
			if(IsInsideBox(pcords, POS_START)){
				//set variables for racing
				racing[client] = true;
				runtime[client] = 1;
				runjumps[client] = 0;
				PrintToChat(client, "%t", "TimerStarted", YELLOW,LIGHTGREEN,YELLOW,GREEN,YELLOW);
			}
		}else{ //not racing
			//if player is still in start zone
			if(IsInsideBox(pcords, POS_START)){
				//set variables for racing again
				runtime[client] = 1;
				runjumps[client] = 0;
				PrintToChat(client, "%t", "TimerRestarted", YELLOW,LIGHTGREEN,YELLOW,GREEN,YELLOW);
			}else{ //racing
				//calculate time, jumps and speed
				new minutes = runtime[client]/60;
				new seconds = runtime[client]%60;
				Format(time, 16, "%im %is", minutes, seconds);
				Format(jumps, 16, "%i", runjumps[client]);
				decl Float:velocity[3];
				GetEntPropVector(client, Prop_Data, "m_vecVelocity", velocity);
				
				new speed = RoundToFloor(SquareRoot(Pow(velocity[0],2.0)+Pow(velocity[1],2.0)+Pow(velocity[2],2.0)));
				//display km/h or just units
				if(g_Speedunit){
					speed *= 0.06858;
					PrintHintText(client,"Your time: %s\nJumps: %s\nSpeed: %i Km/h",time,jumps,speed);
				} else
					PrintHintText(client,"Your time: %s\nJumps: %s\nSpeed: %i units",time,jumps,speed);
				
				//if playing hint sound disabled
				if(g_HintSound == false)
					//stop the hintsound
					StopSound(client, SNDCHAN_STATIC, "UI/hint.wav");
				
				//increase the runtime seconds
				runtime[client]++;
				
				//if player is in end zone
				if(IsInsideBox(pcords, POS_STOP)){
					//depending on recordtype
					if(g_RecordType == RECORD_TIME){
						//check for new time record
						if(runtime[client] < recordtime){
							decl String:name[MAX_NAME_LENGTH];
							GetClientName(client, name, MAX_NAME_LENGTH);
							
							if(g_ChatVisible){
								PrintToChatAll("%t", "TimerRecord", YELLOW,LIGHTGREEN,YELLOW,GREEN,name,YELLOW,LIGHTGREEN,time,YELLOW);
								EmitSoundToAll(recordSound, client);
							}else{
								PrintToChat(client, "%t", "TimerRecord", YELLOW,LIGHTGREEN,YELLOW,GREEN,name,YELLOW,LIGHTGREEN,time,YELLOW);
								EmitSoundToClient(client, recordSound, client);
							}
							
							//update the temporary variables
							recordtime = runtime[client];							
						}else //no new record
							PrintToChat(client, "%t", "TimerFinished", YELLOW,LIGHTGREEN,YELLOW,GREEN,YELLOW,GREEN,YELLOW);
					}else{
						//check for new jump record
						if(runjumps[client] < recordjumps){
							decl String:name[MAX_NAME_LENGTH];
							GetClientName(client, name, MAX_NAME_LENGTH);
							
							if(g_ChatVisible){
								PrintToChatAll("%t", "TimerRecord", YELLOW,LIGHTGREEN,YELLOW,GREEN,name,YELLOW,LIGHTGREEN,jumps,YELLOW);
								EmitSoundToAll(recordSound, client);
							}else{
								PrintToChat(client, "%t", "TimerRecord", YELLOW,LIGHTGREEN,YELLOW,GREEN,name,YELLOW,LIGHTGREEN,jumps,YELLOW);
								EmitSoundToClient(client, recordSound, client);
							}
							
							//update the temporary variables
							recordjumps = jumps[client];
						}else //no new record
							PrintToChat(client, "%t", "TimerFinished", YELLOW,LIGHTGREEN,YELLOW,GREEN,YELLOW,GREEN,YELLOW);
					}
					
					//update the player record in the database
					db_updateRecord(client);
					
					//clean up
					MapTimer[client] = INVALID_HANDLE;
					racing[client] = false;
					
					return Plugin_Stop;
				}
			}
		}
		return Plugin_Continue;
	}else{ //no valid player
		MapTimer[client] = INVALID_HANDLE;
		racing[client] = false;
		
		return Plugin_Stop;
	}
}
