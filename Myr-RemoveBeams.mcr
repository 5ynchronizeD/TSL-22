#Version 8
#BeginDescription
Last modified by: Anno Sportel (as@hsb-cad.com)
01.02.2018  -  version 1.3



#End
#Type O
#NumBeamsReq 0
#NumPointsGrip 0
#DxaOut 1
#ImplInsert 1
#FileState 1
#MajorVersion 1
#MinorVersion 3
#KeyWords 
#BeginContents
/*
*  COPYRIGHT
*  ---------------
*  Copyright (C) 2008 by
*  hsbSOFT N.V.
*  THE NETHERLANDS
*
*  The program may be used and/or copied only with the written
*  permission from hsbSOFT N.V., or in accordance with
*  the terms and conditions stipulated in the agreement/contract
*  under which the program has been supplied.
*
*  All rights reserved.
*
* REVISION HISTORY
* -------------------------
*
* Created by: Anno Sportel (as@hsb-cad.com)
* date: 02.12.2008
* version 1.0: 	Pilot version
* version 1.1: 	Add option to remove material
* date: 18.02.2009
* version 1.2: 	Remove from the edge
* version 1.1: 	Add option to remove material
* date: 01.02.2018
* version 1.3 	Add support for adding to element generation
*
*/

//delete mode
String arSDeleteMode[] = {T("|Codes & Materials|"), T("|Beam lengths|"), T("|Element edges|")};
PropString sDeleteMode(0, arSDeleteMode, T("|Delete mode|"));

//List of beam codes to delete
PropString sListOfBmCodesToRemove(1,"BKK1",T("|List of beamcodes to remove|"));

//List of materials to delete
PropString sListOfMaterialsToRemove(2,"DELETE",T("|List of materials to remove|"));

//Maximum length
PropDouble dMaximumLength(0, U(200), T("|Maximum length of beams to remove|"));

//Remove beams closer to the edge
PropDouble dEraseFromEdge(1, U(550), T("|Remove beams closer to the edge of element|"));

//Side
String arSEdge[] = {T("|Left|"), T("|Right|"), T("|Bottom|"), T("|Top|")};
PropString sEdge(3, arSEdge, T("|Distance measured from edge|"));

//Insert
if( _bOnInsert ){
	//Erase after 1 cycle
	if( insertCycleCount() > 1 ){
		eraseInstance();
		return;
	}
	
	showDialogOnce();
	
	//Select beam(s) and insertion point
	PrEntity ssE(T("|Select one or more elements|"), Element());
	if (ssE.go()) {
		Element arSelectedElements[] = ssE.elementSet();

		String strScriptName = "Myr-RemoveBeams"; // name of the script
		Vector3d vecUcsX(1,0,0);
		Vector3d vecUcsY(0,1,0);
		Beam lstBeams[0];
		Element lstElements[1];
		
		Point3d lstPoints[0];
		int lstPropInt[0];
		double lstPropDouble[0];
		String lstPropString[0];
		Map mapTsl;
		mapTsl.setInt("MasterToSatellite", TRUE);
		mapTsl.setInt("ManualInserted", true);
		setCatalogFromPropValues("MasterToSatellite");
		
		for( int i=0;i<arSelectedElements.length();i++ ){
			Element selectedEl = arSelectedElements[i];
			
			lstElements[0] = selectedEl;
			
			TslInst tsl;
			tsl.dbCreate(strScriptName, vecUcsX,vecUcsY,lstBeams, lstElements, lstPoints, lstPropInt, lstPropDouble, lstPropString, _kModelSpace, mapTsl);
		}
	}
	
	return;
}

if( _Map.hasInt("MasterToSatellite") ){
	int bMasterToSatellite = _Map.getInt("MasterToSatellite");
	if( bMasterToSatellite ){
		int bPropertiesSet = _ThisInst.setPropValuesFromCatalog("MasterToSatellite");
		_Map.removeAt("MasterToSatellite", TRUE);
	}
}

if (_bOnElementConstructed || _Map.getInt("ManualInserted"))
{
	//Subtract beamCodes from ; separated string
	String sBmCode = sListOfBmCodesToRemove + ";";
	sBmCode.makeUpper();
	String arSBmCodeToRemove[0];
	int nIndexBmCode = 0;
	int sIndexBmCode = 0;
	while (sIndexBmCode < sBmCode.length() - 1) {
		String sTokenBC = sBmCode.token(nIndexBmCode);
		nIndexBmCode++;
		if (sTokenBC.length() == 0) {
			sIndexBmCode++;
			continue;
		}
		sIndexBmCode = sBmCode.find(sTokenBC, 0);
		arSBmCodeToRemove.append(sTokenBC);
	}
	
	//Subtract materials from ; separated string
	String sMaterial = sListOfMaterialsToRemove + ";";
	sMaterial.makeUpper();
	String arSMaterialToRemove[0];
	int nIndexMaterial = 0;
	int sIndexMaterial = 0;
	while (sIndexMaterial < sMaterial.length() - 1) {
		String sTokenMat = sMaterial.token(nIndexMaterial);
		nIndexMaterial++;
		if (sTokenMat.length() == 0) {
			sIndexMaterial++;
			continue;
		}
		sIndexMaterial = sMaterial.find(sTokenMat, 0);
		arSMaterialToRemove.append(sTokenMat);
	}
	
	//Delete mode
	int nDeleteMode = arSDeleteMode.find(sDeleteMode);
	
	//Number of elements
	if ( _Element.length() == 0 ) {
		eraseInstance();
		return;
	}
	
	//Selected element
	Element el = _Element[0];
	
	//Coordsys
	CoordSys csEl = el.coordSys();
	Vector3d vxEl = csEl.vecX();
	Vector3d vyEl = csEl.vecY();
	Vector3d vzEl = csEl.vecZ();
	
	//Lines to order points
	Line lnX(csEl.ptOrg(), vxEl);
	Line lnY(csEl.ptOrg(), vyEl);
	
	//Points of element
	Point3d arPtEl[] = el.plEnvelope().vertexPoints(TRUE);
	//Extreme points
	Point3d arPtElX[] = lnX.orderPoints(arPtEl);
	Point3d arPtElY[] = lnY.orderPoints(arPtEl);
	
	//Extreme points
	Point3d ptB = arPtElY[0];
	Point3d ptT = arPtElY[arPtElY.length() - 1];
	Point3d ptL = arPtElX[0];
	Point3d ptR = arPtElX[arPtElX.length() - 1];
	
	//Edge vector and point
	Vector3d arVEdge[] = { vxEl, - vxEl, vyEl, - vyEl};
	Point3d arPtEdge[] = { ptL, ptR, ptB, ptT};
	Vector3d vEdge = arVEdge[arSEdge.find(sEdge, 0)];
	Point3d ptEdge = arPtEdge[arSEdge.find(sEdge, 0)];
	
	//Remove ...
	//...beams
	Beam arBm[] = el.beam();
	for ( int i = 0; i < arBm.length(); i++) {
		Beam bm = arBm[i];
		
		int bEraseBm = FALSE;
		String sBmCode = bm.name("beamCode").token(0);
		if ( arSBmCodeToRemove.find(sBmCode) != -1 ) {
			if ( nDeleteMode == 0 ) //Codes & Materials
			{
				bEraseBm = TRUE;
			}
			else if ( nDeleteMode == 1 ) {//Beam lengts
				if ( (bm.solidLength() < dMaximumLength) || (dMaximumLength == 0) ) {
					bEraseBm = TRUE;
				}
			}
			else if ( nDeleteMode == 2 ) {//Edges
				if ( vEdge.dotProduct(bm.ptCen() - ptEdge) < dEraseFromEdge ) {
					bEraseBm = TRUE;
				}
			}
		}
		
		//erase beam
		if ( bEraseBm ) {
			bm.dbErase();
		}
	}
	
	//...genbeams
	GenBeam arGBm[] = el.genBeam();
	for ( int i = 0; i < arGBm.length(); i++) {
		GenBeam gBm = arGBm[i];
		
		String sMaterial = gBm.material();
		if ( arSMaterialToRemove.find(sMaterial) != -1 ) {
			if ( (gBm.solidLength() < dMaximumLength) || (dMaximumLength == 0) ) {
				gBm.dbErase();
			}
		}
	}
	
	//Job done
	eraseInstance();
	return;
}


#End
#BeginThumbnail




#End