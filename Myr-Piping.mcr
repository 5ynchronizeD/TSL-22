#Version 7
#BeginDescription
Last modified by: Anno Sportel (as@hsb-cad.com)
20.12.2007  -  version 1.2



#End
#Type O
#NumBeamsReq 0
#NumPointsGrip 0
#DxaOut 1
#ImplInsert 1
#MajorVersion 1
#MinorVersion 2
#KeyWords 
#BeginContents
/*
*  COPYRIGHT
*  ---------------
*  Copyright (C) 2007 by
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
* Date: 05.09.2007
* Version 1.0: initial version
* Modified by: Anno Sportel (as@hsb-cad.com)
* date 20.12.2007
* version 1.1: Assign to tooling layer of element
* version 1.2: Add property to show drilling or not
*
*/

//Script uses mm
Unit(1,"mm");

//Properties
PropDouble dDiam(0,U(32),"Diameter");

String arSSide[] = {T("Front"), T("Center"), T("Back")};
int arNSide[] = {1, 0, -1};
PropString sSide(0, arSSide, T("Side"),1);
int nSide = arNSide[ arSSide.find(sSide,1) ];

String arSYesNo[] = {"Yes", "No"};
int arNYesNo[] = {_kYes, _kNo};
PropString sApplyDrilling(1, arSYesNo,"Apply drilling",1);
int bApplyDrilling = arNYesNo[arSYesNo.find(sApplyDrilling,1)];

//Insert
if( _bOnInsert ){
	_Entity.append(getEntPLine("Select a poly line"));
	_Element.append(getElement("Select an element"));
	
	showDialogOnce("|_Default|");
	
	return;
}

//Check if there are 2 entities selected
if( _Entity.length()!=2 ){
	reportNotice(T("Element or PLine no longer valid. TSL is removed from drawing!"));
	eraseInstance();
	return;
}

//Get the pline out of the selected entities
PLine pLine;
EntPLine entPl;
for( int i=0;i<_Entity.length();i++ ){
	entPl = (EntPLine)_Entity[i];
	
	if( entPl.bIsKindOf(EntPLine()) ){
		pLine = entPl.getPLine();
		break;
	}
}

setDependencyOnEntity(entPl);

//Get the element
Element el = _Element[0];
//Set _Pt0 to el.ptOrg()
_Pt0 = el.ptOrg();

//Usefull set of vectors
Vector3d vx = el.vecX();
Vector3d vy = el.vecY();
Vector3d vz = el.vecZ();

//Project pline to element
double dHZn0 = el.zone(0).dH();
Point3d ptEl( (el.ptOrg() - vz * ( 0.5 * dHZn0 - nSide * (0.5 * (dHZn0 - dDiam)) )) );
Point3d ptPl(pLine.ptStart());
Vector3d vTransformBy(vz * vz.dotProduct( ptEl - ptPl ));
entPl.transformBy(vTransformBy);

//Collect all beams
Beam arBm[] = el.beam();

//Points of pline
Point3d arPtPLine[] = pLine.vertexPoints(TRUE);

if( arPtPLine.length()==0 ){reportWarning("No points found in polyline"); return;}
Point3d ptPrev = arPtPLine[0];


for( int i=1;i<arPtPLine.length();i++ ){
	Point3d ptThis = arPtPLine[i];
	
	Drill drill(ptPrev, ptThis, 0.5*dDiam);
	
	if( bApplyDrilling ){	
		int nNrOfBeamsDrilled = drill.addMeToGenBeamsIntersect(arBm);
	}
	else{
		Display dp(-1);

		Body bdDrill = drill.cuttingBody();
		
		for( int i=0;i<arBm.length();i++ ){
			Beam bm = arBm[i];
			Body bdBm = bm.realBody();
			if( bdBm.hasIntersection(bdDrill) ){
				int bIntersectionFound = bdBm.intersectWith(bdDrill);
				dp.draw(bdBm);
			}
		}
	}
	
	ptPrev = ptThis;
}

Group grpEl = el.elementGroup();
Group grpPl = grpEl.namePart(0)+"\\Piping\\"+grpEl.namePart(2);
grpPl.dbCreate();

grpPl.addEntity(entPl, FALSE);
assignToElementGroup(el, FALSE, 0,'T');
entPl.assignToElementGroup(el, FALSE, 0,'T');




#End
#BeginThumbnail



#End
