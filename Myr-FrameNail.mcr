#Version 8
#BeginDescription
Last modified by: Anno Sportel (as@hsb-cad.com)
24.02.2009  -  version 1.6





#End
#Type T
#NumBeamsReq 2
#NumPointsGrip 0
#DxaOut 1
#ImplInsert 0
#FileState 1
#MajorVersion 1
#MinorVersion 6
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
* date: 21.02.2008
* version 0.1: Pilot version
* date: 02.07.2008
* version 0.2: Change layer to T1
* date: 20.10.2008
* version 1.3: Change visualisation of outside nail
* date: 21.11.2008
* version 1.4: Add beamcodes for index 4
* date: 24.11.2008
* version 1.5: Set property Tooling Index to 4 when beamcode is found in the list arSBmCodeIndex4 
* date: 24.02.2009
* version 1.6: Only give nail index 4 when bm.dD(elZ) == 95 and has a valid beamcode
*
*/


int arNIndex[] = {1,12,13,14,2,3,4};
PropInt nIndex(0, arNIndex, T("Tooling index"),3);

Display dp(-1);

Element el = _Beam0.element();
_Pt0.visualize();

//beamcodes for ToolIndex 4
String arSBmCodeIndex4[] = {
	"DRV"
};

if( arSBmCodeIndex4.find(_Beam0.name("beamCode").token(0)) != -1  && _Beam0.dD(el.vecZ()) == U(95)){
	nIndex.set(4);
}

Map itemMap = Map();
itemMap.setInt("INDEX",nIndex);
itemMap.setString("VERSION", "v1.0");
ElemItem elemItem(0, T("HSB_FRAMENAIL"), _Pt0, el.vecZ(), itemMap);
elemItem.setShow(_kNo);
el.addTool(elemItem);

int arNIndexInside[] = {1,12,13,14};
int arNIndexOutside[] = {2,3,4,12,13,14};
double arDNailOutside[] = {U(105), U(70), U(35), U(105), U(70), U(35)};
int nIndexOutside = arNIndexOutside.find(nIndex);
Point3d arPtNail[0];
if( arNIndexInside.find(nIndex) != -1 ){
	arPtNail.append( _Pt0 + _Z1 * U(54) + el.vecZ() * el.vecZ().dotProduct( (el.ptOrg() - el.vecZ() * U(35)) - _Pt0 ) );
}
if( nIndexOutside != -1 ){
	double dNailOutside = arDNailOutside[nIndexOutside];
	arPtNail.append( _Pt0 + _Z1 * U(54) + el.vecZ() * el.vecZ().dotProduct( (el.ptOrg() - el.vecZ() * (el.zone(0).dH() - dNailOutside)) - _Pt0 ) );
}

for( int i=0;i<arPtNail.length(); i++ ){
	Point3d ptNail = arPtNail[i];
	
	PLine plNail1(ptNail - (_X1 + _Y1) * U(10), ptNail +(_X1 + _Y1) * U(10));
	PLine plNail2(ptNail - (_X1 - _Y1) * U(10), ptNail + (_X1 - _Y1) * U(10));
	PLine plNail3(ptNail , ptNail - _X0 * U(100));
	dp.draw(plNail2);
	dp.draw(plNail1);
	dp.draw(plNail3);
}

assignToElementGroup(el,TRUE,1,'T');







#End
#BeginThumbnail
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
F5A]Y'4JR]N0>WOT/:H:CEB650&R",[6!P5)&,@]CS6<H)E)G_]D`
`

#End
