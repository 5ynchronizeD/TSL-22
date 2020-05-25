#Version 7
#BeginDescription









#End
#Type O
#NumBeamsReq 0
#NumPointsGrip 0
#DxaOut 0
#ImplInsert 1
#MajorVersion 1
#MinorVersion 4
#KeyWords 
#BeginContents
/*
*  COPYRIGHT
*  ---------
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
*
* REVISION HISTORY
* ----------------
*
* Revised: Arnoud Pol 080122
* Change: First revision
*
*
*/


Unit (1,"mm");

PropDouble dZone1(0, U(13), T("Thickness Zone 1"));
PropDouble dZone2(1, U(0), T("Thickness Zone 2"));
PropDouble dZone3(2, U(0), T("Thickness Zone 3"));

PropDouble dZone6(3, U(13), T("Thickness Zone 6"));
PropDouble dZone7(4, U(0), T("Thickness Zone 7"));
PropDouble dZone8(5, U(0), T("Thickness Zone 8"));

if( _bOnInsert ){
	if( insertCycleCount()>1 ){eraseInstance(); return;}
	PrEntity ssE("\nSelect a set of elements",ElementWallSF());
	if(ssE.go()){
		_Element.append(ssE.elementSet());
	}
	showDialogOnce("_Default");
	return;
}

if( _Element.length()==0 ){eraseInstance();return;}

for( int e=0;e<_Element.length();e++ ){
	ElementWallSF el = (ElementWallSF)_Element[e];
	if( !el.bIsValid() )continue;
	if(el.number().left(1)=="D"){
		ElemZone ez; 
		//reportNotice (el.number().left(1));
	ez.setCode("HSB-PL02");
	ez.setMaterial("Gipsskiva");
	ez.setStrVar("width","900"); 
      ez.setStrVar("height sheet","2500"); 
//----zone 1
	ez.setStrVar("color","2"); 
	ez.setDH(dZone1);
	el.setZone(1,ez);
//----zone 1
	ez.setStrVar("color","6"); 
	ez.setDH(dZone2);
	el.setZone(2,ez);
//----zone 1
	ez.setStrVar("color","3"); 
	ez.setDH(dZone3);
	el.setZone(3,ez);
//----zone 1
	ez.setStrVar("color","2"); 
	ez.setDH(dZone6);
	el.setZone(-1,ez);
//----zone 1
	ez.setStrVar("color","6"); 
	ez.setDH(dZone7);
	el.setZone(-2,ez);
//----zone 1
	ez.setStrVar("color","3"); 
	ez.setDH(dZone8);
	el.setZone(-3,ez);
		//reportNotice(el.zone(1).dH());
	}
}

eraseInstance();



#End
#BeginThumbnail






#End
