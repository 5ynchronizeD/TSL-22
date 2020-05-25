#Version 8
#BeginDescription
Last modified by: Anno Sportel (as@hsb-cad.com)
26.03.2008  -  version 1.2


















#End
#Type O
#NumBeamsReq 0
#NumPointsGrip 0
#DxaOut 1
#ImplInsert 1
#FileState 1
#MajorVersion 1
#MinorVersion 1
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
* date: 09.12.2008
* version 1.0: 	Pilot version
* date: 20.01.2009
* version 1.1: 	Hide the symbol: define a dispaly
* date: 26.03.2009
* version 1.2: 	Only split SY beams
*
*/
double dEps = U(.1,"mm");

//Insert
if( _bOnInsert ){
	//Erase after 1 cycle
	if( insertCycleCount() > 1 ){
		eraseInstance();
		return;
	}
	
	//Select beam(s) and insertion point
	PrEntity ssE(T("|Select one or more elements|"), ElementWallSF());
	if (ssE.go()) {
		Element arSelectedElements[] = ssE.elementSet();

		String strScriptName = "Myr-CutBottomPlate"; // name of the script
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

//Number of elements
if( _Element.length() == 0 ){
	eraseInstance();
	return;
}

//Element UCS
Element el = _Element[0];
CoordSys csEl = el.coordSys();
Vector3d vxEl = csEl.vecX();
Vector3d vyEl = csEl.vecY();
Vector3d vzEl = csEl.vecZ();
_Pt0 = el.ptOrg();

//Lines to sort
Line lnX(el.ptOrg(),  vxEl);
Line lnY(el.ptOrg(),  vyEl);

//Beams
Beam arBm[] = el.beam();
//Find bottom plates
Beam arBmBottomPlate[0];
for( int i=0;i<arBm.length();i++ ){
	Beam bm = arBm[i];
	if( bm.beamCode().token(0) == "BP-I" ){
		arBmBottomPlate.append(bm);
	}
}

//Openings
Opening arOp[] = el.opening();
//Cut out opening in bottom plates
for( int i=0;i<arOp.length();i++ ){
	OpeningSF op = (OpeningSF)arOp[i];
	
	//Check type
	String sType = op.type().token(0);
	if( sType.makeUpper() != "DOOR" ) continue;
	
	//Collect points
	Point3d arPtOp[] = op.plShape().vertexPoints(TRUE);
	//Order points
	//X
	Point3d arPtOpX[] = lnX.orderPoints(arPtOp);
	arPtOpX = lnX.projectPoints(arPtOpX);
	
	//Size
	double dOpW = op.width();
	double dOpH = op.height();
	
	//Pick points left and right of opening
	Point3d ptFrom = arPtOpX[0];
	Point3d ptTo = arPtOpX[arPtOpX.length() -1];
	for( int j=0;j<arBmBottomPlate.length();j++ ){
		Beam bmBottomPlate = arBmBottomPlate[j];
		
		//Beam extremes
		Body bdBmBottomPlate = bmBottomPlate.realBody();
		Point3d ptBmMin = bdBmBottomPlate.ptCen() - bmBottomPlate.vecX() * .5 * bdBmBottomPlate.lengthInDirection(bmBottomPlate.vecX());
		Point3d ptBmMax = bdBmBottomPlate.ptCen() + bmBottomPlate.vecX() * .5 * bdBmBottomPlate.lengthInDirection(bmBottomPlate.vecX());
		
		//Swap ptTo and from if needed
		Vector3d vxBm = bmBottomPlate.vecX();
		if( vxBm.dotProduct(ptTo - ptFrom) > 0 ){
			Point3d ptTmp = ptTo;
			ptTo = ptFrom;
			ptFrom = ptTmp;
		}
		ptTo.vis(1);
		ptFrom.vis(3);
		
		//Apply split or beamcut
		if( 	(vxEl.dotProduct(ptFrom - ptBmMin) * vxEl.dotProduct(ptFrom - ptBmMax)) < 0 &&
			(vxEl.dotProduct(ptTo - ptBmMin) * vxEl.dotProduct(ptTo - ptBmMax)) < 0 ){
			//Split beam
			Beam bmSplitted = bmBottomPlate.dbSplit(ptFrom, ptTo);
			arBmBottomPlate.append(bmSplitted);
		}
		else{
			BeamCut bmCut(ptTo, vxEl, vyEl, vzEl, dOpW, dOpH, U(500), 1, 0, 0);
			bmBottomPlate.addToolStatic(bmCut);
		}
	}
}

Display dp(-1);

//Delete tsl when the element is generated
if( _bOnElementConstructed )
	eraseInstance();



#End
#BeginThumbnail

#End
