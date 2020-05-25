#Version 8
#BeginDescription
Last modified by: Anno Sportel (as@hsb-cad.com)
01.07.2009  -  version 1.04






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
/// <summary Lang=en>
/// This tsl draws objects in a specified display representation
/// </summary>

/// <insert>
/// Specify the object to draw
/// Differs per object
/// </insert>

/// <remark Lang=en>
/// 
/// </remark>

/// <version  value="1.04" date="01.07.2009"></version>

/// <history>
/// AS - 1.00 - 22.01.2009 - Pilot version
/// AS - 1.01 - 22.01.2009 - Add toolpalette code
/// AS - 1.02 - 22.01.2009 - Add to group, selected through properties
/// AS - 1.03 - 12.03.2009 - List of available blocknames added to the block name property (available from 13.6.10 or 14.0.63)
/// AS - 1.04 - 01.07.2009 - Object to draw picked from list.
/// </history>


//Script uses mm
double dEps = U(.001,"mm");

//Object to draw... a readonly property
String arSObject[] = {
	"Pline",
	"Circle",
	"Rectangle",
	"Block",
	"Text"
};
String arSObjectChar[] = {
	"P",
	"C",
	"R",
	"B",
	"T"
};
PropString sObjectToDraw(0, arSObject, T("|Object|"));

//Display representation to draw the obejct in
PropString sDispRep(1, _ThisInst.dispRepNames(), T("|Draw in display representation|"));

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
PropString sNameFloorGroup(2, arSNameFloorGroup, T("|Floorgroup|"));

//Line color
PropInt nLineColor(0, -1, T("|Line color|"));

//BLOCK
PropString sBlockProps(3, "", "___________BLOCK___________");
sBlockProps.setReadOnly(TRUE);
PropString sBlockName(4, _BlockNames, T("|Block name|"));
PropDouble dBlockScale(0, 1, T("|Scale|"));

//TEXT
PropString sTextProps(5, "", "___________TEXT___________");
sTextProps.setReadOnly(TRUE);
//Text
PropString sLine1(6, "", T("|Line 1|"));
PropString sLine2(7, "", T("|Line 2|"));
PropString sLine3(8, "", T("|Line 3|"));
//Layout
PropString sDimStyle(9, _DimStyles, T("|Dimension/Text style|"));
PropInt nTextColor(1, -1, T("|Text color|"));
PropDouble dTxtHeight(1, U(50), T("|Textheight|"));

//Execute from toolpalette
if (_bOnDbCreated) setPropValuesFromCatalog(_kExecuteKey);


if( _bOnInsert ){
	if( insertCycleCount() > 1 ){
		eraseInstance();
		return;
	}
	
	if( _kExecuteKey == "" ){
		showDialog("|_Default|");
	}
	else{
		setPropValuesFromCatalog(_kExecuteKey);
	}
	
	//Get the object
	String sObject = arSObjectChar[arSObject.find(sObjectToDraw,0)];

	String sSelectedObject = sObject;
	sSelectedObject.makeUpper();
	
	if( sSelectedObject == "P" ){
		EntPLine arEntPLine[0];
		
		_Pt0 = getPoint(TN("Select start point|"));
		PLine plAux(_ZU);
		plAux.addVertex(_Pt0);
		
		Point3d ptLast = _Pt0;
		while( TRUE ){
			PrPoint ssP2(TN("|Select next point|"),ptLast); 
			if (ssP2.go()==_kOk) { // do the actual query
				ptLast = ssP2.value(); // retrieve the selected point
				_PtG.append(ptLast); // append the selected points to the list of grippoints _PtG
				
				plAux.addVertex(ptLast);
				EntPLine entPLine;
				entPLine.dbCreate(plAux);
				arEntPLine.append(entPLine);
			}
			else { // no proper selection
				break; // out of infinite while
			}
		}
		for( int i=0;i<arEntPLine.length();i++ ){
			arEntPLine[i].dbErase();
		}
	}
	else if( sSelectedObject == "C" ){
		_Pt0 = getPoint(TN("|Select centre of circle|"));
		Point3d ptLast = _Pt0;
		while( TRUE ){
			PrPoint ssP2(TN("|Select the edge|"),ptLast); 
			if (ssP2.go()==_kOk) { // do the actual query
				ptLast = ssP2.value(); // retrieve the selected point
				_PtG.append(ptLast); // append the selected points to the list of grippoints _PtG
				break;
			}
		}
	}
	else if( sSelectedObject == "R" ){
		_Pt0 = getPoint(TN("|Select lower lefthand corner of rectangle|"));
		Point3d ptLast = _Pt0;
		while( TRUE ){
			PrPoint ssP2(TN("|Select upper righthand corner|"),ptLast); 
			if (ssP2.go()==_kOk) { // do the actual query
				ptLast = ssP2.value(); // retrieve the selected point
				_PtG.append(ptLast); // append the selected points to the list of grippoints _PtG
				break;
			}
		}
	}
	else if( sSelectedObject == "B" || sSelectedObject == "T" ){
		_Pt0 = getPoint(T("|Select an insertion point|"));
	}
	else{
		reportMessage(TN("|No valid input received!|"));
		return;
	}
	
	return;	
}
//Get the object
String sObject = arSObjectChar[arSObject.find(sObjectToDraw,0)];

//Set property readonly
sObjectToDraw.setReadOnly(TRUE);


Display dp(-1);
dp.showInDispRep(sDispRep);
dp.dimStyle(sDimStyle);
dp.color(nLineColor);

String sSelectedObject = sObject;
sSelectedObject.makeUpper();
if( sSelectedObject == "P" ){
	PLine pl(_ZU);
	pl.addVertex(_Pt0);
	for( int i=0;i<_PtG.length();i++ ){
		pl.addVertex(_PtG[i]);
	}
	dp.draw(pl);
}
else if( sSelectedObject == "C" ){
	PLine plCircle(_ZU);
	double dRadiusCircle = Vector3d(_Pt0 - (_PtG[0] + _ZU * _ZU.dotProduct(_Pt0 - _PtG[0]))).length();
	plCircle.createCircle(_Pt0, _ZU, dRadiusCircle);
	dp.draw(plCircle);
}
else if( sSelectedObject == "R" ){
	PLine plRectangle(_ZU);
	plRectangle.createRectangle(LineSeg(_Pt0, _PtG[0]), _XU, _YU);
	dp.draw(plRectangle);
}
else if( sSelectedObject == "B" ){
	String sThisBlockName = sBlockName;
	if( sThisBlockName == "" )sThisBlockName = "hsbCAD block to insert";
	
	Block block(sThisBlockName);
	dp.draw(block, _Pt0, _XU/dBlockScale, _YU/dBlockScale, _ZU/dBlockScale);
}
else if( sSelectedObject == "T" ){
	dp.color(nTextColor);
	dp.textHeight(dTxtHeight);
	dp.draw(sLine1, _Pt0, _XU, _YU, 1, -1);
	dp.draw(sLine2, _Pt0, _XU, _YU, 1, -4);
	dp.draw(sLine3, _Pt0, _XU, _YU, 1, -7);
}
else{
	reportMessage(TN("|No valid input received!|"));
	return;
}

Group grpFloor = arFloorGroup[arSNameFloorGroup.find(sNameFloorGroup)];
grpFloor.addEntity(_ThisInst);






#End
#BeginThumbnail




#End