#Version 8
#BeginDescription
Last modified by: Anno Sportel (as@hsb-cad.com)
16.07.2009  -  version 1.4

This TSL places nailing on the facade of the element. It Nails the Underbräda and the Lockläkt on the Spikregel.





#End
#Type O
#NumBeamsReq 0
#NumPointsGrip 0
#DxaOut 1
#ImplInsert 1
#FileState 1
#MajorVersion 1
#MinorVersion 4
#KeyWords 
#BeginContents
/*
*  COPYRIGHT
*  ---------------
*  Copyright (C) 2006 by
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
* date: 23.01.2007
* version 1.0: 	Pilot version
* date: 23.10.2008
* version 1.1: 	Add CL wall (vertical spikregel, with split of zone 3)
* date: 24.10.2008
* version 1.2: 	Delete tsl when element is regerated
* date: 15.07.2009
* version 1.3: 	Use coordsys of individual sheets, offset tools for horizontal sheets in zone 4
* date: 16.07.2009
* version 1.4: 	Add offset for CF walls; draw in display representation
*
*/

int nToolingIndex = 1;

// filter GenBeams with label
PropString sFilterLabel(0,"",T("Filter sheets with label"));
String sFLabel = sFilterLabel + ";";
String arSFLabel[0];
int nIndexLabel = 0; 
int sIndexLabel = 0;
while(sIndexLabel < sFLabel.length()-1){
	String sTokenLabel = sFLabel.token(nIndexLabel);
	nIndexLabel++;
	if(sTokenLabel.length()==0){
		sIndexLabel++;
		continue;
	}
	sIndexLabel = sFilterLabel.find(sTokenLabel,0);

	arSFLabel.append(sTokenLabel);
}

PropDouble dToEdgeZn02(0, U(0), T("Distance to edge of spikregel"));
PropDouble dToEdgeZn03(1, U(25), T("Distance to edge of underbräda"));
PropDouble dToEdgeZn04(2, U(25), T("Distance to edge of lockläkt"));

PropDouble dDistBetweenNailsZn03(3, U(0), T("Distance between underbräda nails (0 = 1 nail)"));
PropDouble dDistBetweenNailsZn04(4, U(0), T("Distance between lockläkt nails (0 = 1 nail)"));

//Display representation to draw the obejct in
PropString sDispRep(1, _ThisInst.dispRepNames(), T("|Draw in display representation|"));

if( _bOnInsert ){
	_Element.append(getElement(T("Select an element")));
	showDialogOnce("|_Default|");
	return;
}

if( _bOnElementDeleted || _Element.length()==0 ){
	eraseInstance();
	return;
}

ElementWallSF el = (ElementWallSF)_Element[0];
if( !el.bIsValid() )return;

//CoordSys element
CoordSys csEl = el.coordSys();
Vector3d vxEl = csEl.vecX();
Vector3d vyEl = csEl.vecY();
Vector3d vzEl = csEl.vecZ();

//CoordSys spikregel
String arSFMaterial[0];
String arSVerticalElement[] = {
	"CL"
};
if( arSVerticalElement.find(el.code()) != -1 ){
	dToEdgeZn03.set(U(17));
	arSFMaterial.append("Spikregel P464");
}

//Offset for CF walls
double dOffsetXEl = 0;
if( el.code() == "CF" )
	dOffsetXEl = -U(38) + U(25);


//Debug - Preview zones that are important for this tsl.
if( _bOnDebug ){
	int arNValidZones[] = {0, 1, 2, 3, 4};
	GenBeam arGBm[] = el.genBeam();
	Display dp(-1);
	for( int i=0;i<arGBm.length();i++ ){
		GenBeam gBm = arGBm[i];
		if( arNValidZones.find(gBm.myZoneIndex()) != -1 ){
			dp.color(gBm.color());
			dp.draw(gBm.realBody());
		}
	}
}

Sheet arSh[] = el.sheet();
Sheet arShZn02[0];
Sheet arShZn03[0];
Sheet arShZn04[0];

for( int i=0;i<arSh.length();i++ ){
	Sheet sh = arSh[i];
	if( arSFLabel.find(sh.label()) != -1 || arSFMaterial.find(sh.material()) != -1){
		
	}
	else if( sh.myZoneIndex() == 2 ){//Spikregel
		arShZn02.append(sh);
	}
	else if( sh.myZoneIndex() == 3 ){//Underbräda
		arShZn03.append(sh);
	}
	else if( sh.myZoneIndex() == 4 ){//Lockläkt
		arShZn04.append(sh);
	}
	else{
		
	}
}

Point3d arPtToNail[0];
int arNZoneIndexFromNail[0];

for( int i=0;i<arShZn02.length();i++ ){
	Sheet shZn02 = arShZn02[i];
	Body bdShZn02 = shZn02.realBody();
	
	//Coordsys of sheet in zone 2
	Point3d pt02 = shZn02.ptCen();
	Vector3d vx02 = shZn02.vecY();
	Vector3d vy02 = shZn02.vecX();
	if( bdShZn02.lengthInDirection(vx02) < bdShZn02.lengthInDirection(vy02) ){
		vx02 = shZn02.vecX();
		vy02 = shZn02.vecY();
	}
	Vector3d vz02 = vx02.crossProduct(vy02);
	CoordSys cs02(pt02, vx02, vy02, vz02);
	cs02.vis();
	
	Point3d ptMinShZn02 = bdShZn02.ptCen() - vx02 * (.5 * bdShZn02.lengthInDirection(vx02) - dToEdgeZn02); ptMinShZn02.vis(2);
	Point3d ptMaxShZn02 = bdShZn02.ptCen() + vx02 * (.5 * bdShZn02.lengthInDirection(vx02) - dToEdgeZn02); ptMaxShZn02.vis(3);
	Plane pnZn02(shZn02.ptCen(), vy02);
	
	for( int j=0;j<arShZn03.length();j++ ){
		Sheet shZn03 = arShZn03[j];
		Body bdShZn03 = shZn03.realBody();
		
		//Coordsys of sheet in zone 3
		Point3d pt03 = shZn03.ptCen();
		Vector3d vx03 = shZn03.vecY();
		Vector3d vy03 = shZn03.vecX();
		if( bdShZn03.lengthInDirection(vx03) < bdShZn03.lengthInDirection(vy03) ){
			vx03 = shZn03.vecX();
			vy03 = shZn03.vecY();
		}
		Vector3d vz03 = vx03.crossProduct(vy03);
		CoordSys cs03(pt03, vx03, vy03, vz03);
		cs03.vis();
		
		if( vx03.isPerpendicularTo(vy02) )
			continue;
		
		Point3d arPtSh[] = bdShZn03.allVertices();
		Line lnY(shZn03.ptCen(), vx03);lnY.vis();
		Point3d arPtShY[] = lnY.projectPoints(arPtSh);
		arPtShY = lnY.orderPoints(arPtShY);
		if( arPtShY.length() < 2 ){
			reportWarning(TN("|Invalid sheet!|"));
			eraseInstance();
			return;
		}
	
		Point3d ptMinShZn03 = arPtShY[0] + vx03 * dToEdgeZn03;//bdShZn03.ptCen() - vy02 * (.5 * bdShZn03.lengthInDirection(vy02) - dToEdgeZn03);
		ptMinShZn03.vis(4);
		Point3d ptMaxShZn03 = arPtShY[arPtShY.length() - 1] - vx03 * dToEdgeZn03;//bdShZn03.ptCen() + vy02 * (.5 * bdShZn03.lengthInDirection(vy02) - dToEdgeZn03);
		ptMaxShZn03.vis(5);

		Line lnShZn03(shZn03.ptCen() + vzEl * .5 * el.zone(3).dH() + vxEl * .5 * dOffsetXEl, vx03);
		
		Point3d ptThisIntersection = lnShZn03.intersect(pnZn02,0);
		Point3d ptIntersect;
//		double dMin = abs( vx03.dotProduct(ptThisIntersection - ptMinShZn03) );
//		double dMax = abs( vx03.dotProduct(ptThisIntersection - ptMaxShZn03) );
		if( abs( vx03.dotProduct(ptMinShZn03 - ptThisIntersection) - dToEdgeZn03 ) < U(.5) ){
			ptIntersect = ptThisIntersection + vx02 * (dToEdgeZn03 + U(.5));
		}
		else if( abs( vx03.dotProduct(ptThisIntersection - ptMaxShZn03) - dToEdgeZn03 ) < U(.5) ){
			ptIntersect = ptThisIntersection - vx03 * (dToEdgeZn03 + U(.5));
		}
		else{
			ptIntersect = ptThisIntersection;
		}
		
		
		if( (vx03.dotProduct(ptMinShZn03 - ptIntersect) * vx03.dotProduct(ptMaxShZn03 - ptIntersect)) > 0 )continue;
		
		
		if( dDistBetweenNailsZn03 > 0 ){
			Point3d ptNail01(ptIntersect - vy03 * .5 * dDistBetweenNailsZn03);
			if( (vx02.dotProduct(ptMinShZn02 - ptNail01) * vy03.dotProduct(ptMaxShZn02 - ptNail01)) < 0 ){
				arPtToNail.append(ptNail01);
				arNZoneIndexFromNail.append(3);
			}
			Point3d ptNail02(ptIntersect + vy03 * .5 * dDistBetweenNailsZn03);
			if( (vy03.dotProduct(ptMinShZn02 - ptNail02) * vy03.dotProduct(ptMaxShZn02 - ptNail02)) < 0 ){
				arPtToNail.append(ptNail02);
				arNZoneIndexFromNail.append(3);
			}
		}
		else{
			if( (vx02.dotProduct(ptMinShZn02 - ptIntersect) * vx02.dotProduct(ptMaxShZn02 - ptIntersect)) < 0 ){
				arPtToNail.append(ptIntersect);
				arNZoneIndexFromNail.append(3);
			}
		}
	}
	
	for( int j=0;j<arShZn04.length();j++ ){
		Sheet shZn04 = arShZn04[j];
		Body bdShZn04 = shZn04.realBody();
		
		double dBetweenNailsZn04 = dDistBetweenNailsZn04;
		
		//Coordsys of sheet in zone 4
		Point3d pt04 = shZn04.ptCen();
		Vector3d vx04 = shZn04.vecY();
		Vector3d vy04 = shZn04.vecX();
		if( bdShZn04.lengthInDirection(vx04) < bdShZn04.lengthInDirection(vy04) ){
			vx04 = shZn04.vecX();
			vy04 = shZn04.vecY();
		}
		Vector3d vz04 = vx04.crossProduct(vy04);
		CoordSys cs04(pt04, vx04, vy04, vz04);
		cs04.vis();
		
		if( vx04.isPerpendicularTo(vy02) )
			continue;

	
		Point3d ptMinShZn04 = bdShZn04.ptCen() - vx04 * (.5 * bdShZn04.lengthInDirection(vx04) - dToEdgeZn04); ptMinShZn04.vis(6);
		Point3d ptMaxShZn04 = bdShZn04.ptCen() + vx04 * (.5 * bdShZn04.lengthInDirection(vx04)- dToEdgeZn04); ptMaxShZn04.vis(7);


		double dOffsetYEl = 0;
		if( vy04.isParallelTo(vyEl) ){
			dOffsetYEl = -U(50) + U(25);
			dBetweenNailsZn04 = U(70);
		}
		Line lnShZn04(shZn04.ptCen() + vzEl * .5 * el.zone(4).dH() + vyEl * .5 * dOffsetYEl + vxEl * .5 * dOffsetXEl, vx04);
		
		Point3d ptIntersect = lnShZn04.intersect(pnZn02,0);
		if( (vx04.dotProduct(ptMinShZn04 - ptIntersect) * vx04.dotProduct(ptMaxShZn04 - ptIntersect)) > 0 )continue;
		
		if( (vx02.dotProduct(ptMinShZn02 - ptIntersect) * vx02.dotProduct(ptMaxShZn02 - ptIntersect)) < 0 ){
			if( dDistBetweenNailsZn04 > 0 ){
				arPtToNail.append(ptIntersect - vy04 * .5 * dBetweenNailsZn04);
				arNZoneIndexFromNail.append(4);
				arPtToNail.append(ptIntersect + vy04 * .5 * dBetweenNailsZn04);
				arNZoneIndexFromNail.append(4);
			}
			else{
				arPtToNail.append(ptIntersect);
				arNZoneIndexFromNail.append(4);
			}
		}
	}
}

// add special context menu action to trigger the regeneration of the constuction
String sTriggerAddNailZn03 = T("Add nail to zone 3");
addRecalcTrigger(_kContext, sTriggerAddNailZn03 );
String sTriggerAddNailZn04 = T("Add nail to zone 4");
addRecalcTrigger(_kContext, sTriggerAddNailZn04 );
String sTriggerRemoveNail = T("Remove nail");
addRecalcTrigger(_kContext, sTriggerRemoveNail );

if( _kExecuteKey==sTriggerAddNailZn03 ){
	_PtG.append(getPoint(T("Select a point to add to zone 3")));
	_Map.setInt((_PtG.length() - 1), 3);
}

if( _kExecuteKey==sTriggerAddNailZn04 ){
	_PtG.append(getPoint(T("Select a point to add to zone 4")));
	_Map.setInt((_PtG.length() - 1), 4);
}

if( _kExecuteKey==sTriggerRemoveNail ){
	Point3d ptToRemove = getPoint(T("Select a point to remove"));
	
	if( !_Map.hasInt( String(_PtG.length()-1) ) ){
		reportError(T("\nInternal error!\nIndexes don't match grippoints"));
	}
	
	Point3d arPtNailTmp[0];
	int arNZoneIndexFromNailTmp[0];
	for( int i=0;i<_PtG.length();i++ ){
		Point3d pt = _PtG[i];
		if( !_Map.hasInt(String(i)) )reportError(T("\nInternal error!\nIndex not found in map"));
		int nZone = _Map.getInt(String(i));
//		if( nZone != 3 ){
//			arPtNailTmp.append(pt);
//			arNZoneIndexFromNailTmp.append(nZone);
//			continue;
//		}
		
		if( Vector3d(pt - (ptToRemove + vzEl * vzEl.dotProduct(pt - ptToRemove))).length() > U(5) ){
			arPtNailTmp.append(pt);
			arNZoneIndexFromNailTmp.append(nZone);
		}
		else{
			//Point to remove is found
			
		}
	}
	
	_PtG.setLength(0);
	_PtG.append(arPtNailTmp);
	
	_Map = Map();
	for( int i=0;i<arNZoneIndexFromNailTmp.length();i++ ){
		_Map.setInt(String(i), arNZoneIndexFromNailTmp[i]);
	}
}
 

if( _PtG.length() == 0 ){
	_PtG.append(arPtToNail);

	_Map = Map();
	for( int i=0;i<arNZoneIndexFromNail.length();i++ ){
		_Map.setInt(String(i), arNZoneIndexFromNail[i]);
	}
}
else{
	_Pt0 = _PtG[0];
}

Point3d arPtToNailZn03[0];
Point3d arPtToNailZn04[0];

Display dp03(-1);
dp03.elemZone(el, 3, 'E');
dp03.textHeight(U(10));
dp03.showInDispRep(sDispRep);

Display dp04(-1);
dp04.elemZone(el, 4, 'E');
dp04.textHeight(U(10));
dp04.showInDispRep(sDispRep);

for( int i=0;i<_PtG.length();i++ ){
	Point3d pt = _PtG[i];
	if( !_Map.hasInt(String(i)) )reportError(T("\nInternal error!\nIndex not found in map"));
	int nIndex = _Map.getInt(String(i));

//	int nIndex = arNZoneIndexFromNail[i];
	
	if( nIndex==3 ){
		arPtToNailZn03.append(pt);
		dp03.draw("3", pt, vxEl, vyEl, 0, 0, _kDevice);
	}
	else if( nIndex==4 ){
		arPtToNailZn04.append(pt);
		dp04.draw("4", pt, vxEl, vyEl, 0, 0, _kDevice);
	}
	else{
		reportError(T("\nPoint at wrong zone"));
	}
}

if( arPtToNailZn03.length() > 0 ){
	ElemNailCluster elNailClusterForZn03( 3, arPtToNailZn03, nToolingIndex );
	el.addTool(elNailClusterForZn03);
}

if( arPtToNailZn04.length() > 0 ){
	ElemNailCluster elNailClusterForZn04( 4, arPtToNailZn04, nToolingIndex );
	el.addTool(elNailClusterForZn04);
}

assignToElementGroup(el,TRUE,0,'E');







#End
#BeginThumbnail






#End
