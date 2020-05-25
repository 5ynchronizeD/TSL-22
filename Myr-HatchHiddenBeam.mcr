#Version 8
#BeginDescription
Last modified by: Anno Sportel (as@hsb-cad.com)
16.01.2009  -  version 1.0
#End
#Type O
#NumBeamsReq 0
#NumPointsGrip 0
#DxaOut 1
#ImplInsert 1
#FileState 1
#MajorVersion 1
#MinorVersion 0
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
* date: 16.01.2009
* version 1.0: 	Pilot version
*
*/

PropString sHatchPattern(0,_HatchPatterns,T("|Hatch Style|"));
PropDouble dHatchScale(0, U(5),T("|Hatch Scale|"));
PropInt nHatchColor(0, 1, T("|Hatch Color|"));

if( _bOnInsert ){
	_Viewport.append(getViewport(T("|Select a viewport|")));
	
	showDialog();
	return;
}

if( _Viewport.length() == 0 ){
	eraseInstance();
	return;
}

//Selected viewport
Viewport vp = _Viewport[0];
//Element in viewport
Element el = vp.element();

//If invalid no element is set to this viewport: return.
if( !el.bIsValid() )return;

//Display
Display dp(nHatchColor);
Hatch hatch(sHatchPattern, dHatchScale);

//Coordsys of element
CoordSys csEl = el.coordSys();
Vector3d vxEl = csEl.vecX();
Vector3d vyEl = csEl.vecY();
Vector3d vzEl = csEl.vecZ();

//Point in center of zone 0
Point3d ptCenterZn0 = csEl.ptOrg() - vzEl * .5 * el.zone(0).dH();
//Plane used to find a shadowprofile of the beam which needs to be hatched
Plane pnElZ(csEl.ptOrg(), vzEl);

//Transformation matrices
CoordSys ms2ps = vp.coordSys();
CoordSys ps2ms = ms2ps; ps2ms.invert();

//Beams from element
Beam arBm[] = el.beam();

for( int i=0;i<arBm.length();i++ ){
	Beam bm = arBm[i];
	
	if( vzEl.dotProduct(bm.ptCen() - ptCenterZn0) < 0 ){
		//hatch beam
		Body bdBm = bm.realBody();
		//planeprofile of beam
		PlaneProfile ppBm = bdBm.shadowProfile(pnElZ);

		//transform to paperspace
		ppBm.transformBy(ms2ps);
		dp.draw(ppBm, hatch);
	}
}

#End
#BeginThumbnail

#End
