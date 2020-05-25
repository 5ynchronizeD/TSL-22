#Version 8
#BeginDescription
Last modified by: Anno Sportel (as@hsb-cad.com)
14.07.2009  -  version 1.7



#End
#Type O
#NumBeamsReq 0
#NumPointsGrip 0
#DxaOut 1
#ImplInsert 1
#FileState 1
#MajorVersion 1
#MinorVersion 7
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
* date: 25.11.2008
* version 1.0: 	Pilot version
* date: 26.11.2008
* version 1.1:	Add recalctriggers
* date: 27.11.2008
* version 1.2:	Add display representations
* date: 28.11.2008
* version 1.3:	Add "<>" to manual insert
* date: 02.12.2008
* version 1.4:	Add readdirection
* date: 05.02.2009
* version 1.5:	Mid- & end text as properties
*				text optional removed from manual insert
*				assign to floorgroup
* date: 03.03.2009
* version 1.6:	Text controlled by properties
* date: 14.07.2009
* version 1.7:	Don't check for txtMiddle and txtEnd in _Map anymore
*
*/

double dEps = Unit(.01, "mm");

//Dimension style
PropString sDimStyle(0, _DimStyles, T("|Dimension style|"));

//Show in display representation
PropString sShowInDispRep(1, _ThisInst.dispRepNames() , T("Show in display representation"));

//Used to set the side of the text.
String sArDeltaOnTop[]={T("|Above|"),T("|Below|")};
int bArDeltaOnTop[]={TRUE,FALSE};
PropString sDeltaOnTop(2,sArDeltaOnTop,T("|Side of delta dimension|"),0);

//Start of dimension line (start point for cummulative dimensioning)
String sArStartDim[]={T("Left"),T("Right")};
int nArStartDim[]={1,-1};
PropString sStartDim(3,sArStartDim,T("Start dimensionsing"));

//Used to set the display modus
String sArDisplayModus[] =	{	T("Delta perpendicular"),
									T("Delta parallel"),
									T("Cummulative perpendicular"),
									T("Cummalative parallel"),
									T("Both perpendicular"),
									T("Both parallel"),
									T("Delta parallel, Cummalative perpendicular"),
									T("Delta perpendicular, Cummalative parallel")
								};
int nArDisplayModusMiddle[] = {_kDimPerp, _kDimPar,_kDimNone,_kDimNone,_kDimPerp,_kDimPar,_kDimPar,_kDimPerp};
int nArDisplayModusEnd[] = {_kDimNone,_kDimNone,_kDimPerp, _kDimPar,_kDimPerp,_kDimPar,_kDimPerp,_kDimPar};
PropString sDisplayModus(4,sArDisplayModus,T("Display modus"));


PropString sTxtMiddle(5, "<>", T("|Text at middle of dimension line|"));
PropString sTxtEnd(6, "<>", T("|Text at end of dimension line|"));

//Assign to floorgroup
String arSNameFloorGroup[0];
Group arFloorGroup[0];
Group arAllGroups[] = Group().allExistingGroups();
for( int i=0;i<arAllGroups.length();i++ ){
	Group grp = arAllGroups[i];
	if( grp.namePart(2) == "" && grp.namePart(1) != ""){
		arSNameFloorGroup.append(grp.name());
		arFloorGroup.append(grp);
	}
}
PropString sNameFloorGroup(7, arSNameFloorGroup, T("|Floorgroup|"));

if( _bOnInsert ){
	_Pt0 = getPoint(T("|Select an insertion point|"));
	
	//Select a point for the direction
	while( TRUE ){
		PrPoint ssP2(TN("|Select point for direction|"),_Pt0);
		if (ssP2.go()==_kOk) { // do the actual query
			Point3d ptDirection = ssP2.value(); // retrieve the selected point
			Vector3d vxDimLine(ptDirection - _Pt0);
			vxDimLine.normalize();
	
			_Map.setVector3d("vxDim", vxDimLine);
			_Map.setVector3d("vyDim", _ZW.crossProduct(vxDimLine));
		
			break; // out of infinite while
		}
	}
	
	while( TRUE ){
		PrPoint ssP2("\nSelect dimension point(s)"); 
		if (ssP2.go()==_kOk) { // do the actual query
			Point3d pt = ssP2.value(); // retrieve the selected point
			_PtG.append(pt); // append the selected points to the list of grippoints _PtG
		}
		else { // no proper selection
			break; // out of infinite while
		}
	}
	
	//Store the location of _Pt0 as an absolute value
	_Map.setPoint3d("Pt0", _Pt0, _kAbsolute);
	
	//0 = insert, 1 = default, 2 = request recalc
	_Map.setInt("ExecutionMode", 0);
	
	//Read direction
	_Map.setVector3d("ReadDirection", -_XW + _YW);
	
	//Store the original points
	_Map.setPoint3dArray("OriginalPoints", _PtG);
	
	//showDialog
	showDialog();
	return;
}

int bDeltaOnTop = bArDeltaOnTop[sArDeltaOnTop.find(sDeltaOnTop,0)];

int nStartDim = nArStartDim[sArStartDim.find(sStartDim,0)];

int nDisplayModusMiddle = nArDisplayModusMiddle[sArDisplayModus.find(sDisplayModus,0)];
int nDisplayModusEnd = nArDisplayModusEnd[sArDisplayModus.find(sDisplayModus,0)];



//0 = insert, 1 = default, 2 = request recalc
_Map.setInt("ExecutionMode", 1);

//Reset grippoints to the original position if _Pt0 is moved.
if( !_Map.hasPoint3d("Pt0") ){
	//Store the location of _Pt0 as an absolute value if its not already in
	_Map.setPoint3d("Pt0", _Pt0, _kAbsolute);
}
//Get the previous _Pt0
Point3d pt0 = _Map.getPoint3d("Pt0");
//Reset the points
for( int i=0;i<_PtG.length();i++ )
	_PtG[i].transformBy(Vector3d(pt0-_Pt0));
//Store the position again.
_Map.setPoint3d("Pt0", _Pt0, _kAbsolute);

Entity entParent = _Map.getEntity("Parent");

//Vectors use for the dimenion line.
Vector3d vxDim = _Map.getVector3d("vxDim");
Vector3d vyDim = _Map.getVector3d("vyDim");
Vector3d vzDim = vxDim.crossProduct(vyDim);

if( abs(vzDim.length() - 1) > dEps ){
	reportWarning(TN(vzDim.length()+"|Invalid coordinate system for dimension line|"));
	eraseInstance();
	return;
}

Vector3d vReadDirection = -_XW + _YW;
if( _Map.hasVector3d("ReadDirection") ){
	vReadDirection = _Map.getVector3d("ReadDirection");
}

//Add some custom actions
// add special context menu action to trigger the regeneration of the dimensionline
String sTriggerAddPoint = T("Add point(s)");
addRecalcTrigger(_kContext, sTriggerAddPoint );
String sTriggerRemovePoint = T("Remove point(s)");
addRecalcTrigger(_kContext, sTriggerRemovePoint );
String sTriggerRequestRecalc = T("Restore original dimension line");
addRecalcTrigger(_kContext, sTriggerRequestRecalc );

//Add points
if( _kExecuteKey==sTriggerAddPoint ){
	while( TRUE ){
		PrPoint ssP2("\nSelect dimension point(s) to add"); 
		if (ssP2.go()==_kOk) { // do the actual query
			Point3d ptToAdd = ssP2.value(); // retrieve the selected point
			_PtG.append(ptToAdd); // append the selected points to the list of grippoints _PtG
		}
		else { // no proper selection
			break; // out of infinite while
		}
	}
}

//Remove points
if( _kExecuteKey==sTriggerRemovePoint ){
	while( TRUE ){
		PrPoint ssP2("\nSelect dimension point(s) to remove"); 
		if (ssP2.go()==_kOk) { // do the actual query
			Point3d ptToRemove = ssP2.value(); // retrieve the selected point
			Point3d arPtDim[0];
			arPtDim.append(_PtG);
			
			_PtG.setLength(0);
			
			for( int i=0;i<arPtDim.length();i++ ){
				Point3d ptDim = arPtDim[i];
				if( abs(vxDim.dotProduct(ptDim - ptToRemove)) < U(1) ) continue;
				
				_PtG.append(ptDim);
			}
		}
		else { // no proper selection
			break; // out of infinite while
		}
	}
}

//Remove points
if( _kExecuteKey==sTriggerRequestRecalc ){
	_Map.setInt("ExecutionMode", 2);
	
	if( entParent.bIsValid() ){
		entParent.transformBy(_XW*0);
	}
	else if( _Map.hasPoint3dArray("OriginalPoints") ){
		_PtG.setLength(0);
		_PtG.append(_Map.getPoint3dArray("OriginalPoints"));
	}
};
	
//Define dimension line
DimLine dimLine(_Pt0, vxDim, vyDim);
//Order points
Line lnDirection(_Pt0, vxDim * nStartDim);
_PtG = lnDirection.orderPoints(_PtG);
//Create dimension
Dim dim(dimLine, _PtG, sTxtMiddle, sTxtEnd, nDisplayModusMiddle, nDisplayModusEnd);
//Set delta on top
dim.setDeltaOnTop(bDeltaOnTop);
//Set readDirection
dim.setReadDirection(vReadDirection);

//Draw dimension
Display dp(-1);
dp.dimStyle(sDimStyle);
dp.showInDispRep(sShowInDispRep);
dp.draw(dim);

//assign to floorgroup
Group grpFloor = arFloorGroup[arSNameFloorGroup.find(sNameFloorGroup)];
grpFloor.addEntity(_ThisInst);

#End
#BeginThumbnail




#End
