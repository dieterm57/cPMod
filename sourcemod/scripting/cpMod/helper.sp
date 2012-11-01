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
// draw beam box method //
//----------------------//
public DrawBox(Float:fFrom[3], Float:fTo[3], Float:fLife, color[4], bool:flat){
	//initialize tempoary variables bottom front
	decl Float:fLeftBottomFront[3];
	fLeftBottomFront[0] = fFrom[0];
	fLeftBottomFront[1] = fFrom[1];
	if(flat)
		fLeftBottomFront[2] = fTo[2]-50;
	else
		fLeftBottomFront[2] = fTo[2];
	
	decl Float:fRightBottomFront[3];
	fRightBottomFront[0] = fTo[0];
	fRightBottomFront[1] = fFrom[1];
	if(flat)
		fRightBottomFront[2] = fTo[2]-50;
	else
		fRightBottomFront[2] = fTo[2];
	
	//initialize tempoary variables bottom back
	decl Float:fLeftBottomBack[3];
	fLeftBottomBack[0] = fFrom[0];
	fLeftBottomBack[1] = fTo[1];
	if(flat)
		fLeftBottomBack[2] = fTo[2]-50;
	else
		fLeftBottomBack[2] = fTo[2];
	
	decl Float:fRightBottomBack[3];
	fRightBottomBack[0] = fTo[0];
	fRightBottomBack[1] = fTo[1];
	if(flat)
		fRightBottomBack[2] = fTo[2]-50;
	else
		fRightBottomBack[2] = fTo[2];
	
	//initialize tempoary variables top front
	decl Float:lefttopfront[3];
	lefttopfront[0] = fFrom[0];
	lefttopfront[1] = fFrom[1];
	if(flat)
		lefttopfront[2] = fFrom[2]+50;
	else
		lefttopfront[2] = fFrom[2]+100;
	decl Float:righttopfront[3];
	righttopfront[0] = fTo[0];
	righttopfront[1] = fFrom[1];
	if(flat)
		righttopfront[2] = fFrom[2]+50;
	else
		righttopfront[2] = fFrom[2]+100;
	
	//initialize tempoary variables top back
	decl Float:fLeftTopBack[3];
	fLeftTopBack[0] = fFrom[0];
	fLeftTopBack[1] = fTo[1];
	if(flat)
		fLeftTopBack[2] = fFrom[2]+50;
	else
		fLeftTopBack[2] = fFrom[2]+100;
	decl Float:fRightTopBack[3];
	fRightTopBack[0] = fTo[0];
	fRightTopBack[1] = fTo[1];
	if(flat)
		fRightTopBack[2] = fFrom[2]+50;
	else
		fRightTopBack[2] = fFrom[2]+100;
	
	//create the box
	TE_SetupBeamPoints(fLeftBottomFront,fRightBottomFront,g_BeamSpriteFollow,0,0,0,fLife,3.0,3.0,10,0.0,color,0);TE_SendToAll(0.0);//TE_SendToClient(client, 0.0);
	TE_SetupBeamPoints(fLeftBottomFront,fLeftBottomBack,g_BeamSpriteFollow,0,0,0,fLife,3.0,3.0,10,0.0,color,0);TE_SendToAll(0.0);//TE_SendToClient(client, 0.0);
	TE_SetupBeamPoints(fLeftBottomFront,lefttopfront,g_BeamSpriteFollow,0,0,0,fLife,3.0,3.0,10,0.0,color,0);TE_SendToAll(0.0);//TE_SendToClient(client, 0.0);
	
	TE_SetupBeamPoints(lefttopfront,righttopfront,g_BeamSpriteFollow,0,0,0,fLife,3.0,3.0,10,0.0,color,0);TE_SendToAll(0.0);//TE_SendToClient(client, 0.0);
	TE_SetupBeamPoints(lefttopfront,fLeftTopBack,g_BeamSpriteFollow,0,0,0,fLife,3.0,3.0,10,0.0,color,0);TE_SendToAll(0.0);//TE_SendToClient(client, 0.0);
	TE_SetupBeamPoints(fRightTopBack,fLeftTopBack,g_BeamSpriteFollow,0,0,0,fLife,3.0,3.0,10,0.0,color,0);TE_SendToAll(0.0);//TE_SendToClient(client, 0.0);
	TE_SetupBeamPoints(fRightTopBack,righttopfront,g_BeamSpriteFollow,0,0,0,fLife,3.0,3.0,10,0.0,color,0);TE_SendToAll(0.0);//TE_SendToClient(client, 0.0);
	
	TE_SetupBeamPoints(fRightBottomBack,fLeftBottomBack,g_BeamSpriteFollow,0,0,0,fLife,3.0,3.0,10,0.0,color,0);TE_SendToAll(0.0);//TE_SendToClient(client, 0.0);
	TE_SetupBeamPoints(fRightBottomBack,fRightBottomFront,g_BeamSpriteFollow,0,0,0,fLife,3.0,3.0,10,0.0,color,0);TE_SendToAll(0.0);//TE_SendToClient(client, 0.0);
	TE_SetupBeamPoints(fRightBottomBack,fRightTopBack,g_BeamSpriteFollow,0,0,0,fLife,3.0,3.0,10,0.0,color,0);TE_SendToAll(0.0);//TE_SendToClient(client, 0.0);
	
	TE_SetupBeamPoints(fRightBottomFront,righttopfront,g_BeamSpriteFollow,0,0,0,fLife,3.0,3.0,10,0.0,color,0);TE_SendToAll(0.0);//TE_SendToClient(client, 0.0);
	TE_SetupBeamPoints(fLeftBottomBack,fLeftTopBack,g_BeamSpriteFollow,0,0,0,fLife,3.0,3.0,10,0.0,color,0);TE_SendToAll(0.0);//TE_SendToClient(client, 0.0);
}

//-------------------------------//
// player inside box test method //
//-------------------------------//
public IsInsideBox(Float:fPCords[3], pos){
	new Float:fpx=fPCords[0];
	new Float:fpy=fPCords[1];
	new Float:fpz=fPCords[2];
	
	decl Float:fbsx;
	decl Float:fbsy;
	decl Float:fbsz;
	decl Float:fbex;
	decl Float:fbey;
	decl Float:fbez;
	
	//set variables depending on the zone
	if(pos == POS_START){
		fbsx=g_fMapTimer_start0_cords[0];
		fbsy=g_fMapTimer_start0_cords[1];
		fbsz=g_fMapTimer_start0_cords[2];
		fbex=g_fMapTimer_start1_cords[0];
		fbey=g_fMapTimer_start1_cords[1];
		fbez=g_fMapTimer_start1_cords[2];
	}else{
		fbsx=g_fMapTimer_end0_cords[0];
		fbsy=g_fMapTimer_end0_cords[1];
		fbsz=g_fMapTimer_end0_cords[2];
		fbex=g_fMapTimer_end1_cords[0];
		fbey=g_fMapTimer_end1_cords[1];
		fbez=g_fMapTimer_end1_cords[2];
	}
	
	new bool:bX=false;
	new bool:bY=false;
	new bool:bZ=false;
	
	//check all possibilities
	if(fbsx>fbex && fpx<=fbsx && fpx>=fbex)
		bX=true;
	else if(fbsx<fbex && fpx>=fbsx && fpx<=fbex)
		bX=true;
	
	if(fbsy>fbey && fpy<=fbsy && fpy>=fbey)
		bY=true;
	else if(fbsy<fbey && fpy>=fbsy && fpy<=fbey)
		bY=true;
	
	if(fbsz>fbez && fpz <= fbsz && fpz>=fbez)
		bZ=true;
	else if(fbsz<fbez && fpz>=fbsz && fpz<=fbez)
		bZ=true;
	
	if(bX&&bY&&bZ)
		return true;
	
	return false;
}


//---------------------------//
// setup player spawn method //
//---------------------------//
public setupPlayerSpawn(){
	//some simple vector calculations :)
	
	g_fMapTimer_spawn_cords[0] = (g_fMapTimer_start0_cords[0] + g_fMapTimer_start1_cords[0]) / 2.0;
	g_fMapTimer_spawn_cords[1] = (g_fMapTimer_start0_cords[1] + g_fMapTimer_start1_cords[1]) / 2.0;
	g_fMapTimer_spawn_cords[2] = (g_fMapTimer_start0_cords[2] + g_fMapTimer_start1_cords[2]) / 2.0;
}

//---------------------------//
// setup start sound method //
//---------------------------//
public setupStartSound(){
	//if string not empty
	new length = strlen(g_szStartSound);
	if(length != 0){
		decl String:szDownloadFile[PLATFORM_MAX_PATH];
		Format(szDownloadFile, PLATFORM_MAX_PATH, "sound/%s", g_szStartSound);
		AddFileToDownloadsTable(szDownloadFile);
	
		PrecacheSound(g_szStartSound, true);
		g_bStartSound = true;
	}else
		//simply ignore empty variable
		g_bStartSound = false;
}

//---------------------------//
// setup finish sound method //
//---------------------------//
public setupFinishSound(){
	//if string not empty
	new length = strlen(g_szFinishSound);
	if(length != 0){
		decl String:szDownloadFile[PLATFORM_MAX_PATH];
		Format(szDownloadFile, PLATFORM_MAX_PATH, "sound/%s", g_szFinishSound);
		AddFileToDownloadsTable(szDownloadFile);
	
		PrecacheSound(g_szFinishSound, true);
		g_bFinishSound = true;
	}else
		//simply ignore empty variable
		g_bFinishSound = false;
}

//---------------------------//
// setup record sound method //
//---------------------------//
public setupRecordSound(){
	//if string not empty
	new length = strlen(g_szRecordSound);
	if(length != 0){
		decl String:szDownloadFile[PLATFORM_MAX_PATH];
		Format(szDownloadFile, PLATFORM_MAX_PATH, "sound/%s", g_szRecordSound);
		AddFileToDownloadsTable(szDownloadFile);
	
		PrecacheSound(g_szRecordSound, true);
		g_bRecordSound = true;
	}else
		//simply ignore empty variable
		g_bRecordSound = false;
}

//---------------------------//
// setup record sound method //
//---------------------------//
public compareVersionStrings(String:szVersion1[], String:szVersion2[]){
	//explode first version
	decl String:szCBuff1[3][6]
	ExplodeString(szVersion1, ".", szCBuff1, 3, 6);
	
	//explode second version
	decl String:szCBuff2[3][6]
	ExplodeString(szVersion2, ".", szCBuff2, 3, 6);
	
	//major version
	new res = strncmp(szCBuff1[0], szCBuff2[0], 5);
	if(res == 0){
		//minor version
		res = strncmp(szCBuff1[1], szCBuff2[1], 5);
		if(res == 0){
			//bugfix version
			res = strncmp(szCBuff1[2], szCBuff2[2], 5);
		}
	}
	
	return res;
}

public get