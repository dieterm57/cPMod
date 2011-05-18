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


/*
[cP mod]
- version 2.0.4

This plugin allows users to save their location and teleport later.
It further provides some features for non skilled bHopper like low gravity or a scout.
Noblock, player transparency, spawn health and healing of falldamage are also included.
In the latest release some new feautes for trix maps like anti flash and auto flash giving.
Also a bhop / climb timer was added that saves the best time into a database.
The last active checkpoint will be added to database aswell to avoid timeouts.
Admins can get a special sprite tracing them.

http://www.game-monitor.com/search.php?search=cPMod_version&type=variable

Cmds:
!clear - Erases all checkpoints
!cp    - Opens teleportmenu
!next  - Next checkpoint
!prev  - Previous checkpoint
!save  - Saves a checkpoint
!tele  - Teleports you to last checkpoint

!help       - Displays the help menu
!block      - Toogles blocking
!scout      - Spawns a scout
!lowgrav    - Sets player gravity to low
!normalgrav - Sets player gravity to default

!record     - Displays your record
!restart    - Restarts your timer
!stop       - Stops the timer
!wr         - Displays the record on the current map


Cvars:
sm_cp_enabled      - <1|0> Enable/Disable the plugin.
sm_cp_timer        - <1|0> Enable/Disable map based timer.
sm_cp_restore      - <1|0> Enable/Disable automatic saving of checkpoints to database.
sm_cp_noblock      - <1|0> Enable/Disable player blocking.
sm_cp_alpha        - <1|0> Enable/Disable player alpha.
sm_cp_autoflash    - <1|0> Enable/Disable auto flashbang giver.
sm_cp_tracer       - <1|0> Enable/Disable admin tracer.
sm_cp_scoutlimit   - <0|10> Sets the scout limit for each player.
sm_cp_gravity      - <1|0> Enable/Disable player gravity.
sm_cp_healclient   - <1|0> Enable/Disable healing of falldamage.
sm_cp_hintsound    - <1|0> Enable/Disable playing sound on popup.
sm_cp_chatvisible  - <1|0> Sets chat output visible to all or not.
sm_cp_recordsound  - <"quake/holyshit.mp3"> Sets the sound that is played on new record.
sm_cp_speedunit    - <1|0> Changes the unit of speed displayed in timerpanel [0=default] [1=kmh].

Admin:
sm_cp_cpadmin        - Displays the admin menu
sm_cp_resetcp        - Resets checkpoints of all players.
sm_cp_purgecp <days> - Purges checkpoints.
sm_cp_resettimer     - Resets timers of all players

Versions
1.0
    - Public release
1.1
    - Added angle support for saved checkpoints
    - Added player transparency
    - Added simple NoBlock
    - Fixed minor bugs...
1.2
    - Removed some redundancy
    - Avoided re-indexing of arrays
    - Fixed cvar issues
1.3
    - Added effects on save / teleport
    - Fixed spectator glitch
1.4
    - Translations added
1.5
    - Added !block command
    - Fixed tracer
    - Fixed nodamage
1.6
    - Added Database support
    - Added Timer
    - Added AutoFlashbang
    - Performance increased
1.7
    - Added !stop command
    - Added !restart command
    - Added debuginfo for start/end-coordinates
    - Disabled saving while in the air
    - Fixed !tele glitch on timer running
    - Performance increased
1.8
    - Visualisized coordinate menu
    - Fixed buggy admin tracer
    - Simplyfied code
    - Reorganized whole code
1.9
    - Added playerblock cvar to control !block usage
    - Added restarting timer on entering start area
    - Added control over annoying sound played on popup display
    - Added cvar to specify a sound played on new record
2.0.0
    - Added MySQL support
    - Added records for every player on each map
    - Moved to seperate database due to size
    - Added adminflag required for !cpadmin
    - Added removing weapons on ground
    - Added recordtypes (record for time or jumps)
    - Added reset ability
    - Added variable for unit of speed
    - Added added console cmds instead of parsing chat
    - Fixed adding of start/stop zones
    - Fixed special chars in player names
    - Increased stability & performance
2.0.1
    - Enabled saving while timer running
    - Fixed cp not being restored if it was the first
    - Simplyfied admin flag setting
2.0.2
    - Fixed respawn error on some machines
    - PrintToChat after !restart
    - Commented whole source
    - Added licensing
2.0.3
    - Added ranking output
    - Added chat visibility variable
    - Fixed records being overwritten
    - Cleaned up unnecessary database queries
2.0.4
    - Fixed quakesound not being downloaded
    - Fixed admincommands being executed as regular users
    - Changed cp menu order
*/

#include <sourcemod>
#include <sdktools>

#undef REQUIRE_EXTENSIONS
#include <cstrike>
#define REQUIRE_EXTENSIONS

//this variable defines how many checkpoints/player there will be
#define CPLIMIT 10

//this variable defines who is allowed to execute admin commands
#define ADMIN_LEVEL ADMFLAG_UNBAN

//-----------------------------//
// nothing to change over here //
//-----------------------------//
//...
#define VERSION "2.0.3"

#define YELLOW 0x01
#define TEAMCOLOR 0x02
#define LIGHTGREEN 0x03
#define GREEN 0x04

#define POS_START 0
#define POS_STOP 1

#define RECORD_TIME 0
#define RECORD_JUMP 1

#define MYSQL 0
#define SQLITE 1

//-------------------//
// many variables :) //
//-------------------//
new g_dbtype;
new Handle:db = INVALID_HANDLE;

new Handle:cvarEnable = INVALID_HANDLE;
new bool:g_Enabled = false;

//new Handle:cvarAdminLevel = INVALID_HANDLE;
//new ADMIN_LEVEL;

//new Handle:cvarCpLimit = INVALID_HANDLE;
//new g_CpLimit = 0;

//new Handle:h_GameConf;
//new Handle:h_Respawn;

new Handle:cvarCleanupGuns = INVALID_HANDLE;
new bool:g_CleanupGuns = false;
new g_WeaponParent;

new Handle:cvarTimer = INVALID_HANDLE;
new bool:g_Timer = false;
new Handle:cvarRecordType = INVALID_HANDLE;
new g_RecordType = RECORD_TIME;

new bool:g_CordsSet = false;
new Handle:cvarRestore = INVALID_HANDLE;
new bool:g_Restore = false;

new Handle:cvarNoblock = INVALID_HANDLE;
new bool:g_Noblock = false;
new Handle:cvarPlayerBlock = INVALID_HANDLE;
new bool:g_PlayerBlock = false;
new Handle:cvarAlpha = INVALID_HANDLE;
new bool:g_Alpha = false;
new Handle:cvarAutoFlash = INVALID_HANDLE
new bool:g_AutoFlash = false;
new Handle:cvarTracer = INVALID_HANDLE;
new bool:g_Tracer = false;
new Handle:cvarScoutLimit = INVALID_HANDLE;
new g_Scoutlimit = 0;
new Handle:cvarGravity = INVALID_HANDLE;
new bool:g_Gravity = false;
new Handle:cvarHealClient = INVALID_HANDLE;
new bool:g_HealClient = false;
new Handle:cvarHintSound = INVALID_HANDLE;
new bool:g_HintSound = false;
new Handle:cvarRecordSound = INVALID_HANDLE;
new bool:g_Speedunit = false;
new Handle:cvarSpeedunit = INVALID_HANDLE;
new bool:g_ChatVisible = false;
new Handle:cvarChatVisible = INVALID_HANDLE;

new Handle:TraceTimer[MAXPLAYERS+1];
new Handle:MapTimer[MAXPLAYERS+1];
new bool:racing[MAXPLAYERS+1];
new Handle:CleanTimer = INVALID_HANDLE;
new Handle:CpSetterTimer = INVALID_HANDLE;
new Float:cpsetbcords[3];
new Float:cpsetecords[3];
new Float:maptimer_start0_cords[3];
new Float:maptimer_start1_cords[3];
new Float:maptimer_end0_cords[3];
new Float:maptimer_end1_cords[3];

new Float:playercords[MAXPLAYERS+1][CPLIMIT][3];
new Float:playerangles[MAXPLAYERS+1][CPLIMIT][3];


new currentcp[MAXPLAYERS+1];
new wholecp[MAXPLAYERS+1];
new bool:blocking[MAXPLAYERS+1];
new scouts[MAXPLAYERS+1];
new runtime[MAXPLAYERS+1];
new runjumps[MAXPLAYERS+1];
new String:mapname[32];

new recordjumps;
new recordtime;

new String:recordSound[32];

new BeamSpriteFollow,BeamSpriteRing1,BeamSpriteRing2;


//----------//
// includes //
//----------//
#include "cPMod/admin.sp"
#include "cPMod/commands.sp"
#include "cPMod/hooks.sp"
#include "cPMod/sql.sp"


public Plugin:myinfo = {
	name = "cPMod",
	author = "byaaaaah",
	description = "Bunnyhop / Surf / Tricks server modification",
	version = VERSION,
	url = "http://b-com.tk"
}

//----------------//
// initialization //
//----------------//
public OnPluginStart(){
	LoadTranslations("cpmod.phrases");
	HookEvent("player_spawn", Event_player_spawn);
	HookEvent("player_jump",Event_player_jump);
	
	db_setupDatabase();
	
	CreateConVar("cPMod_version", VERSION, "cP Mod version.", FCVAR_DONTRECORD|FCVAR_PLUGIN|FCVAR_SPONLY|FCVAR_REPLICATED|FCVAR_NOTIFY);
	cvarEnable     = CreateConVar("sm_cp_enabled", "1", "Enable/Disable the plugin.", FCVAR_PLUGIN|FCVAR_NOTIFY, true, 0.0, true, 1.0);
	g_Enabled      = GetConVarBool(cvarEnable);
	HookConVarChange(cvarEnable, OnSettingChanged);

	//cvarAdminLevel = CreateConVar("sm_cp_adminlevel", "ADMFLAG_ROOT", "Sets the access level for admins.", FCVAR_PLUGIN);
	//ADMIN_LEVEL = GetConVarInt(cvarAdminLevel);
	
	//todo: dynamic array resize to use a singel variable
	//cvarCpLimit = CreateConVar("sm_cp_cplimit", "10", "Sets the limit of checkpoints per player.", FCVAR_PLUGIN, true, 1.0, true, 255.0);
	//g_CpLimit   = GetConVarInt(cvarCpLimit);
	
	//playercords  = new Float:[MAXPLAYERS+1][g_CpLimit][3];
	//playerangles = new Float:[MAXPLAYERS+1][g_CpLimit][3];
	
	cvarCleanupGuns  = CreateConVar("sm_cp_cleanupguns", "1", "Enable/Disable automatic removal of weapons.", FCVAR_PLUGIN, true, 0.0, true, 1.0);
	HookConVarChange(cvarCleanupGuns, OnSettingChanged);
	g_CleanupGuns    = GetConVarBool(cvarCleanupGuns);
	g_WeaponParent   = FindSendPropOffs("CBaseCombatWeapon", "m_hOwnerEntity");
	
	cvarTimer      = CreateConVar("sm_cp_timer", "1", "Enable/Disable map based timer.", FCVAR_PLUGIN, true, 0.0, true, 1.0);
	g_Timer        = GetConVarBool(cvarTimer);
	HookConVarChange(cvarTimer, OnSettingChanged);
	cvarRecordType = CreateConVar("sm_cp_recordtype", "0", "Sets recordtype to time(0) or jumps(1).", FCVAR_PLUGIN, true, 0.0, true, 1.0);
	g_RecordType   = GetConVarInt(cvarRecordType);
	HookConVarChange(cvarRecordType, OnSettingChanged);
	
	cvarRestore    = CreateConVar("sm_cp_restore", "1", "Enable/Disable automatic saving of checkpoints to database.", FCVAR_PLUGIN, true, 0.0, true, 1.0);
	g_Restore      = GetConVarBool(cvarRestore);
	HookConVarChange(cvarRestore, OnSettingChanged);
	
	cvarNoblock    = CreateConVar("sm_cp_noblock", "1", "Enable/Disable player blocking.", FCVAR_PLUGIN, true, 0.0, true, 1.0);
	g_Noblock      = GetConVarBool(cvarNoblock);
	HookConVarChange(cvarNoblock, OnSettingChanged);
	
	cvarPlayerBlock = CreateConVar("sm_cp_playerblock", "1", "Enable/Disable player !block command.", FCVAR_PLUGIN, true, 0.0, true, 1.0);
	g_PlayerBlock   = GetConVarBool(cvarPlayerBlock);
	HookConVarChange(cvarPlayerBlock, OnSettingChanged);
	
	cvarAlpha      = CreateConVar("sm_cp_alpha", "1", "Enable/Disable player alpha.", FCVAR_PLUGIN, true, 0.0, true, 1.0);
	g_Alpha        = GetConVarBool(cvarAlpha);
	HookConVarChange(cvarAlpha, OnSettingChanged);
	cvarAutoFlash  = CreateConVar("sm_cp_autoflash", "0", "Enable/Disable auto flashbang giver.", FCVAR_PLUGIN, true, 0.0, true, 1.0);
	g_AutoFlash    = GetConVarBool(cvarAutoFlash);
	HookConVarChange(cvarAutoFlash, OnSettingChanged);
	if(cvarAutoFlash){
		HookEvent("player_blind" , Event_flashbang_detonate);
		HookEvent("weapon_fire" , Event_weapon_fire);
	}
	cvarTracer     = CreateConVar("sm_cp_tracer", "1", "Enable/Disable player Tracers.", FCVAR_PLUGIN, true, 0.0, true, 1.0);
	g_Tracer       = GetConVarBool(cvarTracer);
	HookConVarChange(cvarTracer, OnSettingChanged);
	
	cvarScoutLimit = CreateConVar("sm_cp_scoutlimit", "3", "Sets the scout limit for each player. 0 to disable." , FCVAR_PLUGIN, true, 0.0, true, 10.0);
	g_Scoutlimit   = GetConVarInt(cvarScoutLimit);
	HookConVarChange(cvarScoutLimit, OnSettingChanged);
	
	cvarGravity    = CreateConVar("sm_cp_gravity", "1", "Enable/Disable player gravity.", FCVAR_PLUGIN, true, 0.0, true, 1.0);
	g_Gravity      = GetConVarBool(cvarGravity);
	HookConVarChange(cvarGravity, OnSettingChanged);
	
	cvarHealClient = CreateConVar("sm_cp_healclient", "1", "Enable/Disable healing of damage.", FCVAR_PLUGIN, true, 0.0, true, 1.0);
	g_HealClient   = GetConVarBool(cvarHealClient);
	HookConVarChange(cvarHealClient, OnSettingChanged);
	if(cvarHealClient)
		HookEvent("player_hurt", Event_player_hurt);
	
	cvarHintSound = CreateConVar("sm_cp_hintsound", "0", "Enable/Disable playing sound on popup.", FCVAR_PLUGIN, true, 0.0, true, 1.0);
	g_HintSound   = GetConVarBool(cvarHintSound);
	HookConVarChange(cvarHintSound, OnSettingChanged);
	
	cvarChatVisible = CreateConVar("sm_cp_chatvisible", "1", "Sets chat output visible to all or not.", FCVAR_PLUGIN, true, 0.0, true, 1.0);
	g_ChatVisible   = GetConVarBool(cvarChatVisible);
	HookConVarChange(cvarChatVisible, OnSettingChanged);
	
	cvarRecordSound = CreateConVar("sm_cp_recourdsound", "quake/holyshit.mp3", "Sets the sound that is played on new record.", FCVAR_PLUGIN);
	GetConVarString(cvarRecordSound, recordSound, 32);
	
	cvarSpeedunit    = CreateConVar("sm_cp_speedunit", "0", "Changes the unit of speed displayed in timerpanel 0=default 1=kmh.", FCVAR_PLUGIN, true, 0.0, true, 1.0);
	g_Speedunit      = GetConVarBool(cvarSpeedunit);
	HookConVarChange(cvarSpeedunit, OnSettingChanged);
	
	//h_GameConf = LoadGameConfigFile("cPMod.gamedata");
	//StartPrepSDKCall(SDKCall_Player);
	//PrepSDKCall_SetFromConf(h_GameConf, SDKConf_Signature, "RoundRespawn");
	//h_Respawn = EndPrepSDKCall();
	
	// stops the plugin if any signature failed, otherwise it would
	// probably crash the server
	//if(h_Respawn == INVALID_HANDLE)
		//SetFailState("[cPMod] Signature Failed. Please contact the author.")
	
	RegConsoleCmd("sm_block", Client_Block, "Toogles blocking");
	RegConsoleCmd("sm_lowgrav", Client_Lowgrav, "Sets player gravity to low");
	RegConsoleCmd("sm_normalgrav", Client_Normalgrav, "Sets player gravity to default");
	RegConsoleCmd("sm_scout", Client_Scout, "Spawns a scout");
	
	RegConsoleCmd("sm_next", Client_Next, "Next checkpoint");
	RegConsoleCmd("sm_prev", Client_Prev, "Previous checkpoint");
	RegConsoleCmd("sm_save", Client_Save, "Saves a checkpoint");
	RegConsoleCmd("sm_tele", Client_Tele, "Teleports you to last checkpoint");
	RegConsoleCmd("sm_cp", Client_Cp, "Opens teleportmenu");
	RegConsoleCmd("sm_clear", Client_Clear, "Erases all checkpoints");
	RegConsoleCmd("sm_help", Client_Help, "Displays the help menu");
	
	RegConsoleCmd("sm_record", Client_Record, "Displays your record");
	RegConsoleCmd("sm_restart", Client_Restart, "Restarts your timer");
	RegConsoleCmd("sm_stop", Client_Stop, "Stops the timer");
	RegConsoleCmd("sm_wr", Client_Wr, "Displays the record on the current map");
	
	RegAdminCmd("sm_cpadmin", Admin_CpPanel, ADMIN_LEVEL, "Displays the admin panel.");
	RegAdminCmd("sm_purgeplayer", Admin_PurgePlayers, ADMIN_LEVEL, "Purges all old players.");
	RegAdminCmd("sm_resetmaps", Admin_ResetMaps, ADMIN_LEVEL, "Resets all stored map start/end points.");
	RegAdminCmd("sm_resetplayers", Admin_ResetPlayers, ADMIN_LEVEL, "Resets all players.");
	RegAdminCmd("sm_resetcheckpoints", Admin_ResetCheckpoints, ADMIN_LEVEL, "Resets all checkpoints.");
	RegAdminCmd("sm_resetrecords", Admin_ResetRecords, ADMIN_LEVEL, "Resets all records.");
	
	AutoExecConfig(true, "sm_cpmod");
}

//--------------------------//
// executed on start of map //
//--------------------------//
public OnMapStart(){
	//precache some files
	BeamSpriteFollow = PrecacheModel("materials/sprites/laserbeam.vmt");
	BeamSpriteRing1 = PrecacheModel("materials/sprites/tp_beam001.vmt");
	BeamSpriteRing2 = PrecacheModel("materials/sprites/crystal_beam1.vmt");
	PrecacheSound("buttons/blip1.wav", true);
	
	PrecacheSound(recordSound, true);
	AddFileToDownloadsTable(recordSound);
	
	GetCurrentMap(mapname, 32);
	
	//reset player slots
	for(new i = 0; i <= MAXPLAYERS; i++){
		currentcp[i] = 0;
		wholecp[i] = 0;
		scouts[i] = 0;
		runtime[i] = 0;
		runjumps[i] = 0;
	}
	
	//if g_Timer active
	if(g_Timer){
		//query the timer start stop zones
		db_selectMapStartStop();
		
		//select record depending on record type
		if(g_RecordType == RECORD_TIME)
			db_selectWorldRecordTime();
		else
			db_selectWorldRecordJump();
	}
	
	//if g_CleanupGuns
	if(g_CleanupGuns)
		//create the cleanup timer
		CleanTimer = CreateTimer(10.0, ActionCleanTimer, _, TIMER_REPEAT);
}

//------------------------//
// executed on end of map //
//------------------------//
public OnMapEnd(){
	//for all of the players
	for(new i = 0; i <= MAXPLAYERS; i++){
		//if a timer still active: close it!
		if(g_Timer && MapTimer[i] != INVALID_HANDLE){
			CloseHandle(MapTimer[i]);
			MapTimer[i] = INVALID_HANDLE;
		}
		//if a tracer still active: close it!
		if(g_Tracer && TraceTimer[i] != INVALID_HANDLE){
			CloseHandle(TraceTimer[i]);
			TraceTimer[i] = INVALID_HANDLE;
		}
	}
	
	//also close the cleanup timer
	if(g_CleanupGuns && CleanTimer != INVALID_HANDLE){
		CloseHandle(CleanTimer);
		CleanTimer = INVALID_HANDLE;
	}
}

//-----------------------------------//
// hook executed on changed settings //
//-----------------------------------//
public OnSettingChanged(Handle:convar, const String:oldValue[], const String:newValue[]){
	if(convar == cvarEnable){
		if(newValue[0] == '1')
			g_Enabled = true;
		else
			g_Enabled = false;
	}else if(convar == cvarTimer){
		
		if(newValue[0] == '1'){
			g_Timer = true;
			for(new i = 0; i <= MAXPLAYERS; i++){
				if(MapTimer[i] != INVALID_HANDLE){
					CloseHandle(MapTimer[i]);
					MapTimer[i] = INVALID_HANDLE;
				}
				runtime[i] = 0;
				runjumps[i] = 0;
			}
		}else{
			g_Timer = false;
			for(new i = 0; i <= MAXPLAYERS; i++){
				if(MapTimer[i] != INVALID_HANDLE){
					CloseHandle(MapTimer[i]);
					MapTimer[i] = INVALID_HANDLE;
				}
			}
		}
		
	}else if(convar == cvarRecordType){
		g_RecordType = newValue[0];
	}else if(convar == cvarCleanupGuns){
		if(newValue[0] == '1'){
			g_CleanupGuns = true;
			//seems to be obsolent
			//CleanTimer = CreateTimer(10.0, ActionCleanTimer, _, TIMER_REPEAT);
		}else{
			g_CleanupGuns = false;
			CloseHandle(CleanTimer);
			CleanTimer = INVALID_HANDLE;
		}
	}else if(convar == cvarRestore){
		if(newValue[0] == '1')
			g_Restore = true;
		else
			g_Restore = false;
	}else if(convar == cvarNoblock){
		if(newValue[0] == '1')
			g_Noblock = true;
		else
			g_Noblock = false;
	}else if(convar == cvarPlayerBlock){
		if(newValue[0] == '1')
			g_PlayerBlock = true;
		else
			g_PlayerBlock = false;
	}else if(convar == cvarAlpha){
		if(newValue[0] == '1')
			g_Alpha = true;
		else
			g_Alpha = false;
	}else if(convar == cvarAutoFlash){
		if(newValue[0] == '1'){
			g_AutoFlash = true;
			HookEvent("player_blind" , Event_flashbang_detonate);
			HookEvent("weapon_fire" , Event_weapon_fire);
		}else{
			g_AutoFlash = false;
			UnhookEvent("player_blind" , Event_flashbang_detonate);
			UnhookEvent("weapon_fire" , Event_weapon_fire);
		}
	}else if(convar == cvarTracer){
		if(newValue[0] == '1')
			g_Tracer = true;
		else
		g_Tracer = false;
	}else if(convar == cvarScoutLimit){
		g_Scoutlimit = newValue[0];
	}else if(convar == cvarGravity){
		if(newValue[0] == '1')
			g_Gravity = true;
		else
			g_Gravity = false;
	}else if(convar == cvarHealClient){
		if(newValue[0] == '1'){
			HookEvent("player_hurt", Event_player_hurt);
			g_HealClient = true;
		}else{
			g_HealClient = false;
			UnhookEvent("player_hurt", Event_player_hurt, EventHookMode_Post);
		}
	}else if(convar == cvarHintSound){
		if(newValue[0] == '1')
			g_HintSound = true;
		else
			g_HintSound = false;
	}else if(convar == cvarChatVisible){
		if(newValue[0] == '1')
			g_ChatVisible = true;
		else
			g_ChatVisible = false;
	}else if(convar == cvarSpeedunit){
		if(newValue[0] == '1')
			g_Speedunit = true;
		else
			g_Speedunit = false;
	}
}

//------------------------------------//
// executed on client post admincheck //
//------------------------------------//
public OnClientPostAdminCheck(client){
	//if g_Enabled and client valid
	if(g_Enabled && IsClientInGame(client) && !IsFakeClient(client)){
		//reset some settings
		TraceTimer[client] = INVALID_HANDLE;
		MapTimer[client] = INVALID_HANDLE;
		currentcp[client] = -1;
		
		//select the last checkpoint
		//(also creates a new entry in the database, if checkpoint not found)
		db_selectPlayerCheckpoint(client);
		
		//display the help panel
		HelpPanel(client);
	}
}

//-------------------------------//
// executed on player disconnect //
//-------------------------------//
public OnClientDisconnect(client){
	if(g_Enabled){
		//cleanup the timer
		if(g_Timer && MapTimer[client] != INVALID_HANDLE){
				CloseHandle(MapTimer[client]);
				MapTimer[client] = INVALID_HANDLE;
		}
		//cleanup the tracer
		if(g_Tracer && TraceTimer[client] != INVALID_HANDLE){
				CloseHandle(TraceTimer[client]);
				TraceTimer[client] = INVALID_HANDLE;
		}
		
		new current = currentcp[client];
		//if g_Restore and valid checkpoint
		if(g_Restore && current != -1){
			//if(playercords[client][current][0] != 0.0 && playercords[client][current][1] != 0.0 && playercords[client][current][0] != 0.0)
				//update the checkpoint in the database
				db_updatePlayerCheckpoint(client, current);
		}
	}
}
