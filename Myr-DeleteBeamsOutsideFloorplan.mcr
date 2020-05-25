#Version 8
#BeginDescription
Last modified by: Anno Sportel (as@hsb-cad.com)
01.02.2018  -  version 1.02
#End
#Type O
#NumBeamsReq 0
#NumPointsGrip 0
#DxaOut 1
#ImplInsert 1
#FileState 0
#MajorVersion 1
#MinorVersion 2
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
* date: 23.01.2008
* version 1.0: First version
*
* Modify by: Anno Sportel (as@hsb-cad.com)
* date: 09.02.2009
* version 1.01: Use proof brutto instead of netto
*
* Modify by: Robert Pol (robert.pol@hsbcad.com)
* date: 01.02.2018
* version 1.02: Change insert so it can be added to element generation
*
*/

if( _bOnInsert ){
	if( insertCycleCount() > 1 ){
		eraseInstance();
		return;
	}
	PrEntity ssE(T("Select a set of floor elements"), ElementRoof());
	if( ssE.go() ){
		_Element.append(ssE.elementSet());
	}
	_Map.setInt("ManualInserted", true);
	return;
}
if (_bOnElementConstructed || _Map.getInt("ManualInserted"))
{
	PlaneProfile ppFloorPlan;
	Beam arAllBm[0];
	for ( int e = 0; e < _Element.length(); e++) {
		Element el = _Element[e];
		//only horizontal elements
		if ( ! el.vecZ().isParallelTo(_ZW) ) {
			continue;
		}
		PlaneProfile ppEl = el.profBrutto(0);
		ppFloorPlan.unionWith(ppEl);
		
		Beam arBm[] = el.beam();
		arAllBm.append(arBm);
	}
	
	ppFloorPlan.shrink(U(-10));
	ppFloorPlan.shrink(U(10));
	
	for ( int i = 0; i < arAllBm.length(); i++) {
		Beam bm = arAllBm[i];
		Point3d ptBm = bm.ptCen();
		
		if ( ppFloorPlan.pointInProfile(ptBm) == _kPointOutsideProfile ) {
			bm.dbErase();
		}
	}
	
	eraseInstance();
	return;
}
#End
#BeginThumbnail



#End