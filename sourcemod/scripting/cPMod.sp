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
- version 2.0.5

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

!record <map>         - Displays your record
!precord <name> <map> - Displays the record of a given player
!restart              - Restarts your timer
!stop                 - Stops the timer
!wr                   - Displays the record on the current map


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
sm_cp_RecordSound  - <"quake/holyshit.mp3"> Sets the sound that is played on new record.
sm_cp_speedunit    - <1|0> Changes the unit of speed displayed in timerpanel [0=default] [1=kmh].

Admin:
sm_cpadmin            - Displays the admin panel.
sm_purgeplayer <days> - Purges all old players.
sm_resetmaps          - Resets all stored map start/end points.
sm_resetplayers       - Resets all players.
sm_resetcheckpoints   - Resets all checkpoints.
sm_resetrecords       - Resets all records.
	

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
    - Fixed invalid handle spaming
    - Changed cp menu order
2.0.5
    - Fixed cPAdmin being able to open twice
    - Changed all variable names to a single standard
    - Changed start/stop setup boxes visibility to admin only
    - No need to restart the map after setting timer cords
    - Added quakesound available check
    - Added precord <name> <mapname> command
    - Enhanced record command to record <mapname>
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
#define VERSION "2.0.5b"

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
new g_DbType;
new Handle:g_hDb = INVALID_HANDLE;

new Handle:g_hcvarEnable = INVALID_HANDLE;
new bool:g_bEnabled = false;

new Handle:g_hcvarCleanupGuns = INVALID_HANDLE;
new bool:g_bCleanupGuns = false;
new g_WeaponParent;

new Handle:g_hcvarTimer = INVALID_HANDLE;
new bool:g_bTimer = false;
new Handle:g_hcvarRecordType = INVALID_HANDLE;
new g_bRecordType = RECORD_TIME;

new bool:g_bCordsSet = false;
new Handle:g_hcvarRestore = INVALID_HANDLE;
new bool:g_bRestore = false;

new Handle:g_hcvarNoBlock = INVALID_HANDLE;
new bool:g_bNoBlock = false;
new Handle:g_hcvarPlayerBlock = INVALID_HANDLE;
new bool:g_bPlayerBlock = false;
new Handle:g_hcvarAlpha = INVALID_HANDLE;
new bool:g_bAlpha = false;
new Handle:g_hcvarAutoFlash = INVALID_HANDLE
new bool:g_bAutoFlash = false;
new Handle:g_hcvarTracer = INVALID_HANDLE;
new bool:g_bTracer = false;
new Handle:g_hcvarScoutLimit = INVALID_HANDLE;
new g_ScoutLimit = 0;
new Handle:g_hcvarGravity = INVALID_HANDLE;
new bool:g_bGravity = false;
new Handle:g_hcvarHealClient = INVALID_HANDLE;
new bool:g_bHealClient = false;
new Handle:g_hcvarHintSound = INVALID_HANDLE;
new bool:g_bHintSound = false;

new Handle:g_hcvarRecordSound = INVALID_HANDLE;
new String:g_szRecordSound[PLATFORM_MAX_PATH];
new bool:g_bRecordSound = false;

new bool:g_bSpeedUnit = false;
new Handle:g_hcvarSpeedUnit = INVALID_HANDLE;
new bool:g_bChatVisible = false;
new Handle:g_hcvarChatVisible = INVALID_HANDLE;

new Handle:g_hTraceTimer[MAXPLAYERS+1];
new Handle:g_hMapTimer[MAXPLAYERS+1];
new bool:g_bRacing[MAXPLAYERS+1];
new Handle:g_hCleanTimer = INVALID_HANDLE;
new Handle:g_hcpSetterTimer = INVALID_HANDLE;
new Float:g_fCpSetBCords[3];
new Float:g_fCpSetECords[3];
new Float:g_fMapTimer_start0_cords[3];
new Float:g_fMapTimer_start1_cords[3];
new Float:g_fMapTimer_end0_cords[3];
new Float:g_fMapTimer_end1_cords[3];

new Float:g_fPlayerCords[MAXPLAYERS+1][CPLIMIT][3];
new Float:g_fPlayerAngles[MAXPLAYERS+1][CPLIMIT][3];


new g_CurrentCp[MAXPLAYERS+1];
new g_WholeCp[MAXPLAYERS+1];
new bool:g_bBlocking[MAXPLAYERS+1];
new g_Scouts[MAXPLAYERS+1];
new g_RunTime[MAXPLAYERS+1];
new g_RunJumps[MAXPLAYERS+1];
new String:g_szMapName[32];

new g_RecordJumps;
new g_RecordTime;

new g_BeamSpriteFollow, g_BeamSpriteRing1,g_BeamSpriteRing2;


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
	g_hcvarEnable     = CreateConVar("sm_cp_enabled", "1", "Enable/Disable the plugin.", FCVAR_PLUGIN|FCVAR_NOTIFY, true, 0.0, true, 1.0);
	g_bEnabled      = GetConVarBool(g_hcvarEnable);
	HookConVarChange(g_hcvarEnable, OnSettingChanged);
	
	g_hcvarCleanupGuns  = CreateConVar("sm_cp_cleanupguns", "1", "Enable/Disable automatic removal of weapons.", FCVAR_PLUGIN, true, 0.0, true, 1.0);
	HookConVarChange(g_hcvarCleanupGuns, OnSettingChanged);
	g_bCleanupGuns    = GetConVarBool(g_hcvarCleanupGuns);
	g_WeaponParent   = FindSendPropOffs("CBaseCombatWeapon", "m_hOwnerEntity");
	
	g_hcvarTimer      = CreateConVar("sm_cp_timer", "1", "Enable/Disable map based timer.", FCVAR_PLUGIN, true, 0.0, true, 1.0);
	g_bTimer          = GetConVarBool(g_hcvarTimer);
	HookConVarChange(g_hcvarTimer, OnSettingChanged);
	g_hcvarRecordType = CreateConVar("sm_cp_recordtype", "0", "Sets recordtype to time(0) or jumps(1).", FCVAR_PLUGIN, true, 0.0, true, 1.0);
	g_bRecordType     = GetConVarInt(g_hcvarRecordType);
	HookConVarChange(g_hcvarRecordType, OnSettingChanged);
	
	g_hcvarRestore    = CreateConVar("sm_cp_restore", "1", "Enable/Disable automatic saving of checkpoints to database.", FCVAR_PLUGIN, true, 0.0, true, 1.0);
	g_bRestore        = GetConVarBool(g_hcvarRestore);
	HookConVarChange(g_hcvarRestore, OnSettingChanged);
	
	g_hcvarNoBlock    = CreateConVar("sm_cp_noblock", "1", "Enable/Disable player blocking.", FCVAR_PLUGIN, true, 0.0, true, 1.0);
	g_bNoBlock        = GetConVarBool(g_hcvarNoBlock);
	HookConVarChange(g_hcvarNoBlock, OnSettingChanged);
	
	g_hcvarPlayerBlock = CreateConVar("sm_cp_playerblock", "1", "Enable/Disable player !block command.", FCVAR_PLUGIN, true, 0.0, true, 1.0);
	g_bPlayerBlock     = GetConVarBool(g_hcvarPlayerBlock);
	HookConVarChange(g_hcvarPlayerBlock, OnSettingChanged);
	
	g_hcvarAlpha      = CreateConVar("sm_cp_alpha", "1", "Enable/Disable player alpha.", FCVAR_PLUGIN, true, 0.0, true, 1.0);
	g_bAlpha          = GetConVarBool(g_hcvarAlpha);
	HookConVarChange(g_hcvarAlpha, OnSettingChanged);
	g_hcvarAutoFlash  = CreateConVar("sm_cp_autoflash", "0", "Enable/Disable auto flashbang giver.", FCVAR_PLUGIN, true, 0.0, true, 1.0);
	g_bAutoFlash      = GetConVarBool(g_hcvarAutoFlash);
	HookConVarChange(g_hcvarAutoFlash, OnSettingChanged);
	if(g_hcvarAutoFlash){
		HookEvent("player_blind" , Event_flashbang_detonate);
		HookEvent("weapon_fire" , Event_weapon_fire);
	}
	g_hcvarTracer     = CreateConVar("sm_cp_tracer", "0", "Enable/Disable admin Tracers.", FCVAR_PLUGIN, true, 0.0, true, 1.0);
	g_bTracer         = GetConVarBool(g_hcvarTracer);
	HookConVarChange(g_hcvarTracer, OnSettingChanged);
	
	g_hcvarScoutLimit = CreateConVar("sm_cp_scoutlimit", "3", "Sets the scout limit for each player. 0 to disable.", FCVAR_PLUGIN, true, 0.0, true, 10.0);
	g_ScoutLimit      = GetConVarInt(g_hcvarScoutLimit);
	HookConVarChange(g_hcvarScoutLimit, OnSettingChanged);
	
	g_hcvarGravity    = CreateConVar("sm_cp_gravity", "1", "Enable/Disable player gravity.", FCVAR_PLUGIN, true, 0.0, true, 1.0);
	g_bGravity        = GetConVarBool(g_hcvarGravity);
	HookConVarChange(g_hcvarGravity, OnSettingChanged);
	
	g_hcvarHealClient = CreateConVar("sm_cp_healclient", "1", "Enable/Disable healing of damage.", FCVAR_PLUGIN, true, 0.0, true, 1.0);
	g_bHealClient     = GetConVarBool(g_hcvarHealClient);
	HookConVarChange(g_hcvarHealClient, OnSettingChanged);
	if(g_hcvarHealClient)
		HookEvent("player_hurt", Event_player_hurt);
	
	g_hcvarHintSound = CreateConVar("sm_cp_hintsound", "0", "Enable/Disable playing sound on popup.", FCVAR_PLUGIN, true, 0.0, true, 1.0);
	g_bHintSound     = GetConVarBool(g_hcvarHintSound);
	HookConVarChange(g_hcvarHintSound, OnSettingChanged);
	
	g_hcvarChatVisible = CreateConVar("sm_cp_chatvisible", "1", "Sets chat output visible to all or not.", FCVAR_PLUGIN, true, 0.0, true, 1.0);
	g_bChatVisible     = GetConVarBool(g_hcvarChatVisible);
	HookConVarChange(g_hcvarChatVisible, OnSettingChanged);
	
	g_hcvarRecordSound = CreateConVar("sm_cp_recourdsound", "quake/holyshit.mp3", "Sets the sound that is played on new record.", FCVAR_PLUGIN);
	GetConVarString(g_hcvarRecordSound, g_szRecordSound, PLATFORM_MAX_PATH);
	
	g_hcvarSpeedUnit    = CreateConVar("sm_cp_speedunit", "0", "Changes the unit of speed displayed in timerpanel 0=default 1=kmh.", FCVAR_PLUGIN, true, 0.0, true, 1.0);
	g_bSpeedUnit        = GetConVarBool(g_hcvarSpeedUnit);
	HookConVarChange(g_hcvarSpeedUnit, OnSettingChanged);
	
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
	RegConsoleCmd("sm_precord", Client_Player_Record, "Displays the record of a given player");
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
	g_BeamSpriteFollow = PrecacheModel("materials/sprites/laserbeam.vmt");
	g_BeamSpriteRing1 = PrecacheModel("materials/sprites/tp_beam001.vmt");
	g_BeamSpriteRing2 = PrecacheModel("materials/sprites/crystal_beam1.vmt");
	PrecacheSound("buttons/blip1.wav", true);
	
	//if string not empty
	if(strlen(g_szRecordSound) != 0){
		decl String:szDownloadFile[PLATFORM_MAX_PATH];
		Format(szDownloadFile, PLATFORM_MAX_PATH, "sound/%s", g_szRecordSound);
		AddFileToDownloadsTable(szDownloadFile);
	
		PrecacheSound(g_szRecordSound, true);
		g_bRecordSound = true;
	}
	
	GetCurrentMap(g_szMapName, 32);
	
	//reset player slots
	for(new i = 0; i <= MAXPLAYERS; i++){
		g_CurrentCp[i] = 0;
		g_WholeCp[i] = 0;
		g_Scouts[i] = 0;
		g_RunTime[i] = 0;
		g_RunJumps[i] = 0;
	}
	
	//if map timer active
	if(g_bTimer){
		//query the timer start stop zones
		db_selectMapStartStop();
		
		//select record depending on record type
		if(g_bRecordType == RECORD_TIME)
			db_selectWorldRecordTime();
		else
			db_selectWorldRecordJump();
	}
	
	//if cleanup timer active
	if(g_bCleanupGuns)
		//create the cleanup timer
		g_hCleanTimer = CreateTimer(10.0, ActionCleanTimer, _, TIMER_REPEAT);
}

//------------------------//
// executed on end of map //
//------------------------//
public OnMapEnd(){
	//for all of the players
	for(new i = 0; i <= MAXPLAYERS; i++){
		//if a timer still active: close it!
		if(g_bTimer && g_hMapTimer[i] != INVALID_HANDLE){
			CloseHandle(g_hMapTimer[i]);
			g_hMapTimer[i] = INVALID_HANDLE;
		}
		//if a tracer still active: close it!
		if(g_bTracer && g_hTraceTimer[i] != INVALID_HANDLE){
			CloseHandle(g_hTraceTimer[i]);
			g_hTraceTimer[i] = INVALID_HANDLE;
		}
	}
	
	//also close the cleanup timer
	if(g_bCleanupGuns && g_hCleanTimer != INVALID_HANDLE){
		CloseHandle(g_hCleanTimer);
		g_hCleanTimer = INVALID_HANDLE;
	}
}

//-----------------------------------//
// hook executed on changed settings //
//-----------------------------------//
public OnSettingChanged(Handle:convar, const String:oldValue[], const String:newValue[]){
	if(convar == g_hcvarEnable){
		if(newValue[0] == '1')
			g_bEnabled = true;
		else
			g_bEnabled = false;
	}else if(convar == g_hcvarTimer){
		
		if(newValue[0] == '1'){
			g_bTimer = true;
			for(new i = 0; i <= MAXPLAYERS; i++){
				if(g_hMapTimer[i] != INVALID_HANDLE){
					CloseHandle(g_hMapTimer[i]);
					g_hMapTimer[i] = INVALID_HANDLE;
				}
				g_RunTime[i] = 0;
				g_RunJumps[i] = 0;
			}
		}else{
			g_bTimer = false;
			for(new i = 0; i <= MAXPLAYERS; i++){
				if(g_hMapTimer[i] != INVALID_HANDLE){
					CloseHandle(g_hMapTimer[i]);
					g_hMapTimer[i] = INVALID_HANDLE;
				}
			}
		}
		
	}else if(convar == g_hcvarRecordType){
		g_bRecordType = newValue[0];
	}else if(convar == g_hcvarCleanupGuns){
		if(newValue[0] == '1'){
			g_bCleanupGuns = true;
			//seems to be obsolent
			//g_hCleanTimer = CreateTimer(10.0, ActionCleanTimer, _, TIMER_REPEAT);
		}else{
			g_bCleanupGuns = false;
			CloseHandle(g_hCleanTimer);
			g_hCleanTimer = INVALID_HANDLE;
		}
	}else if(convar == g_hcvarRestore){
		if(newValue[0] == '1')
			g_bRestore = true;
		else
			g_bRestore = false;
	}else if(convar == g_hcvarNoBlock){
		if(newValue[0] == '1')
			g_bNoBlock = true;
		else
			g_bNoBlock = false;
	}else if(convar == g_hcvarPlayerBlock){
		if(newValue[0] == '1')
			g_bPlayerBlock = true;
		else
			g_bPlayerBlock = false;
	}else if(convar == g_hcvarAlpha){
		if(newValue[0] == '1')
			g_bAlpha = true;
		else
			g_bAlpha = false;
	}else if(convar == g_hcvarAutoFlash){
		if(newValue[0] == '1'){
			g_bAutoFlash = true;
			HookEvent("player_blind" , Event_flashbang_detonate);
			HookEvent("weapon_fire" , Event_weapon_fire);
		}else{
			g_bAutoFlash = false;
			UnhookEvent("player_blind" , Event_flashbang_detonate);
			UnhookEvent("weapon_fire" , Event_weapon_fire);
		}
	}else if(convar == g_hcvarTracer){
		if(newValue[0] == '1')
			g_bTracer = true;
		else
		g_bTracer = false;
	}else if(convar == g_hcvarScoutLimit){
		g_ScoutLimit = newValue[0];
	}else if(convar == g_hcvarGravity){
		if(newValue[0] == '1')
			g_bGravity = true;
		else
			g_bGravity = false;
	}else if(convar == g_hcvarHealClient){
		if(newValue[0] == '1'){
			g_bHealClient = true;
			HookEvent("player_hurt", Event_player_hurt);
		}else{
			g_bHealClient = false;
			UnhookEvent("player_hurt", Event_player_hurt, EventHookMode_Post);
		}
	}else if(convar == g_hcvarHintSound){
		if(newValue[0] == '1')
			g_bHintSound = true;
		else
			g_bHintSound = false;
	}else if(convar == g_hcvarChatVisible){
		if(newValue[0] == '1')
			g_bChatVisible = true;
		else
			g_bChatVisible = false;
	}else if(convar == g_hcvarSpeedUnit){
		if(newValue[0] == '1')
			g_bSpeedUnit = true;
		else
			g_bSpeedUnit = false;
	}
}

//------------------------------------//
// executed on client post admincheck //
//------------------------------------//
public OnClientPostAdminCheck(client){
	//if g_Enabled and client valid
	if(g_bEnabled && IsClientInGame(client) && !IsFakeClient(client)){
		//reset some settings
		g_hTraceTimer[client] = INVALID_HANDLE;
		g_hMapTimer[client] = INVALID_HANDLE;
		g_CurrentCp[client] = -1;
		
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
	if(g_bEnabled){
		//cleanup the timer
		if(g_bTimer && g_hMapTimer[client] != INVALID_HANDLE){
				CloseHandle(g_hMapTimer[client]);
				g_hMapTimer[client] = INVALID_HANDLE;
		}
		//cleanup the tracer
		if(g_bTracer && g_hTraceTimer[client] != INVALID_HANDLE){
				CloseHandle(g_hTraceTimer[client]);
				g_hTraceTimer[client] = INVALID_HANDLE;
		}
		
		new current = g_CurrentCp[client];
		//if g_bRestore and valid checkpoint
		if(g_bRestore && current != -1){
			//if(g_fPlayerCords[client][current][0] != 0.0 && g_fPlayerCords[client][current][1] != 0.0 && g_fPlayerCords[client][current][0] != 0.0)
				//update the checkpoint in the database
				db_updatePlayerCheckpoint(client, current);
		}
	}
}
