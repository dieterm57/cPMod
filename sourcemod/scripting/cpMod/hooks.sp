public Action:Event_player_spawn(Handle:event, const String:name[], bool:dontBroadcast){
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	if(g_Noblock){
		SetEntData(client, FindSendPropOffs("CBaseEntity", "m_CollisionGroup"), 2, 4, true);
		blocking[client] = false;
	}
	if(g_Alpha){
		SetEntityRenderMode(client, RENDER_TRANSCOLOR);
		SetEntityRenderColor(client, 255,255,255,70);
	}
	if(g_AutoFlash)
		GivePlayerItem(client, "weapon_flashbang");
    
	if(g_HealClient)
		SetEntData(client, FindSendPropOffs("CBasePlayer", "m_iHealth"), 500);
	
	if(g_Timer)
		MapTimer[client] = CreateTimer(1.0, ActionMapTimer, client, TIMER_REPEAT);
		
	if(GetUserAdmin(client) != INVALID_ADMIN_ID){
		if(g_Tracer)
			TraceTimer[client] = CreateTimer(1.0, ActionTraceTimer, client, TIMER_REPEAT);
		
		if(g_Timer && !g_CordsSet){
			PrintToChat(client, "%t", "CordsNotSet", YELLOW,LIGHTGREEN,YELLOW,GREEN,YELLOW);
			CpAdminPanel(client);
		}
	}
}
public Action:Event_player_hurt(Handle:event, const String:name[], bool:dontBroadcast){
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	new damage = GetEventInt(event, "damage");
	SetEntData(client, FindSendPropOffs("CBasePlayer", "m_iHealth"), 500+damage);
} 
public Action:Event_player_jump(Handle:event,const String:name[],bool:dontBroadcast){
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	runjumps[client]++;
}

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

public Action:ActionTraceTimer(Handle:timer, any:client){
	if(client != 0 && IsClientInGame(client) && IsPlayerAlive(client)){
		TE_SetupBeamFollow(client,BeamSpriteFollow,0,1.0,5.0,50.0,70,{255,255,255,100});TE_SendToAll();
		return Plugin_Continue;
	}else
		return Plugin_Stop;
}

public Action:ActionRestartTimer(Handle:timer, any:client){
	MapTimer[client] = CreateTimer(1.0, ActionMapTimer, client, TIMER_REPEAT);
	PrintToChatAll("created timer");
}


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

public Action:ActionMapTimer(Handle:timer, any:client){
	if(client != 0 && IsClientInGame(client) && IsPlayerAlive(client)){
		decl Float:pcords[3];
		GetClientAbsOrigin(client,pcords);
		decl String:time[16];
		decl String:jumps[16];
		
		if(racing[client] == false){
			if(IsInsideBox(pcords, POS_START)){
				racing[client] = true;
				runtime[client] = 1;
				runjumps[client] = 0;
				PrintToChat(client, "%t", "TimerStarted", YELLOW,LIGHTGREEN,YELLOW,GREEN,YELLOW);
			}
		} else{
			if(IsInsideBox(pcords, POS_START)){
				runtime[client] = 1;
				runjumps[client] = 0;
				PrintToChat(client, "%t", "TimerRestarted", YELLOW,LIGHTGREEN,YELLOW,GREEN,YELLOW);
			} else{
				new minutes = runtime[client]/60;
				new seconds = runtime[client]%60;
				Format(time, 16, "%im %is", minutes, seconds);
				Format(jumps, 16, "%i", runjumps[client]);
				decl Float:velocity[3];
				GetEntPropVector(client, Prop_Data, "m_vecVelocity", velocity);
				
				new speed = RoundToFloor(SquareRoot(Pow(velocity[0],2.0)+Pow(velocity[1],2.0)+Pow(velocity[2],2.0)));
				if(g_Speedunit){
					speed *= 0.06858;
					PrintHintText(client,"Your time: %s\nJumps: %s\nSpeed: %i Km/h",time,jumps,speed);
				} else
					PrintHintText(client,"Your time: %s\nJumps: %s\nSpeed: %i units",time,jumps,speed);
				
				if(g_HintSound == false)
					StopSound(client, SNDCHAN_STATIC, "UI/hint.wav");
				
				runtime[client]++;
				
				if(IsInsideBox(pcords, POS_STOP)){
					if(g_RecordType == RECORD_TIME){
						if(runtime[client] < recordtime){
							decl String:name[MAX_NAME_LENGTH];
							GetClientName(client, name, MAX_NAME_LENGTH);
							
							PrintToChatAll("%t", "TimerRecord", YELLOW,LIGHTGREEN,YELLOW,GREEN,name,YELLOW,LIGHTGREEN,time,YELLOW);
							EmitSoundToAll(recordSound,client);
						}else
							PrintToChat(client, "%t", "TimerFinished", YELLOW,LIGHTGREEN,YELLOW,GREEN,YELLOW,GREEN,YELLOW);
					} else{
						if(runjumps[client] < recordjumps){
							decl String:name[MAX_NAME_LENGTH];
							GetClientName(client, name, MAX_NAME_LENGTH);
							
							PrintToChatAll("%t", "TimerRecord", YELLOW,LIGHTGREEN,YELLOW,GREEN,name,YELLOW,LIGHTGREEN,jumps,YELLOW);
							EmitSoundToAll(recordSound,client);
						}else
							PrintToChat(client, "%t", "TimerFinished", YELLOW,LIGHTGREEN,YELLOW,GREEN,YELLOW,GREEN,YELLOW);
					}
					
					db_updatePlayerRecord(client);
					
					MapTimer[client] = INVALID_HANDLE;
					racing[client] = false;
					
					return Plugin_Stop;
				}
			}
		}
		return Plugin_Continue;
	} else{
		MapTimer[client] = INVALID_HANDLE;
		racing[client] = false;
		
		return Plugin_Stop;
	}
}

public Action:Event_flashbang_detonate(Handle:event,const String:name[],bool:dontBroadcast){
	new client = GetClientOfUserId(GetEventInt(event,"userid"));
	SetEntDataFloat(client,FindSendPropOffs("CCSPlayer", "m_flFlashMaxAlpha"),0.0);
}
public Action:Event_weapon_fire(Handle:event,const String:name[],bool:dontBroadcast){
	decl String:weaponname[32];
	GetEventString(event, "weapon", weaponname, 200);
	new client = GetClientOfUserId(GetEventInt(event,"userid"));
	if(StrEqual(weaponname,"flashbang"))
		GivePlayerItem(client, "weapon_flashbang");
}