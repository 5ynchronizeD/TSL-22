#Version 8
#BeginDescription
Last modified by: Anno Sportel (as@hsb-cad.com)
17.07.2009  -  version 1.0




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
* date: 12.03.2008
* version 0.1: 	Pilot version
* version 0.2: 	Set dependancy on truss tsl's
* date: 17.07.2009
* version 1.0: 	Project points to dimLine
*
*/

//Script uses mm
double dEps = Unit(.01,"mm");

//Dimension style
PropString sDimStyle(0, _DimStyles, T("Dimension style"));

if( _bOnInsert ){
	//Select startpoint for distribution
	Point3d ptInsertDimension = getPoint(T("Select insert point of dimension line"));
	PrPoint ssPtDirection(T("Select point for direction of dimension line"), ptInsertDimension);
	Point3d ptDirection;
	if( ssPtDirection.go() == _kOk ){
		ptDirection = ssPtDirection.value();
	}
	Vector3d vecDirection(ptDirection - ptInsertDimension);
	vecDirection.normalize();
	
	//Coordsys of distribution
	Vector3d vx = vecDirection;
	Vector3d vy = _ZW.crossProduct(vecDirection);
	Vector3d vz = _ZW;

	_Map.setPoint3d("ptOrg", ptInsertDimension);
	_Map.setVector3d("vecX", vx);
	_Map.setVector3d("vecY", vy);
	_Map.setVector3d("vecZ", vz);
	
	//Select the truss tsls
	PrEntity ssE(T("Select the trusses"), TslInst());
	if( ssE.go() ){
		Entity arEnt[] = ssE.set();
		for( int i=0;i<arEnt.length();i++ ){
			Entity ent = arEnt[i];
			TslInst tsl = (TslInst)ent;
			if( tsl.bIsValid() && tsl.scriptName() == "Myr-Truss" ){
				_Entity.append(tsl);
			}
		}
	}

	showDialog();
	return;
}

//Check if there are entities selected.
if( _Entity.length() == 0 ){
	eraseInstance();
	return;
}

//Check content of the _Map
if( !(_Map.hasPoint3d("ptOrg") && _Map.hasVector3d("vecX") && _Map.hasVector3d("vecY") &&  _Map.hasVector3d("vecZ")) ){
	eraseInstance();
	return;
}

CoordSys csTruss(_Map.getPoint3d("ptOrg"), _Map.getVector3d("vecX"), _Map.getVector3d("vecY"), _Map.getVector3d("vecZ"));
_Pt0 = csTruss.ptOrg();
Vector3d vx = csTruss.vecX();
Vector3d vy = csTruss.vecY();
Vector3d vz = csTruss.vecZ();
vx.vis(_Pt0, 1);
vy.vis(_Pt0, 3);
vz.vis(_Pt0, 150);

Vector3d vyDim = vy;
if( vyDim.dotProduct(-_XW + _YW) < 0 )
	vyDim = -vy;
Vector3d vxDim = vyDim.crossProduct(_ZW);

Point3d arPtTruss[0];
Point3d ptExtensionLines;
int nGripIndex;
for( int e=0;e<_Entity.length();e++ ){
	Entity ent = _Entity[e];
	TslInst tsl = (TslInst)ent;
	if( tsl.bIsValid() && tsl.scriptName() == "Myr-Truss" ){
		setDependencyOnEntity(tsl);
		arPtTruss.append(tsl.ptOrg());
		
		if( arPtTruss.length() == 1 ){
			ptExtensionLines = tsl.gripPoint(1);
			nGripIndex = 1;
			Point3d ptGrip0 = tsl.gripPoint(0);
			if( (_Pt0 - ptExtensionLines).length() > (_Pt0 - ptGrip0).length() ){
				ptExtensionLines = ptGrip0;
				nGripIndex = 0;
			}
		}
		else{
			Point3d ptGrip = tsl.gripPoint(nGripIndex);
			
			if( abs(vyDim.dotProduct(ptGrip - _Pt0)) < abs(vyDim.dotProduct(ptExtensionLines - _Pt0)) )
				ptExtensionLines = ptGrip;
		}		
	}
}


Line lnX(ptExtensionLines, vxDim);
arPtTruss = lnX.orderPoints(arPtTruss);
arPtTruss = lnX.projectPoints(arPtTruss);
DimLine dimLine(_Pt0, vxDim, vyDim);
Dim dim(dimLine, arPtTruss, "<>", "<>", _kDimPar, _kDimNone);
Display dp(-1);
dp.dimStyle(sDimStyle);
dp.draw(dim);



#End
#BeginThumbnail




#End
