#Version 8
#BeginDescription
Last modified by: Anno Sportel (anno.sportel@itwindustry.nl)
02.09.2010  -  version 1.08


This tsl displays information for the openings in the layouts







#End
#Type O
#NumBeamsReq 0
#NumPointsGrip 0
#DxaOut 1
#ImplInsert 1
#FileState 1
#MajorVersion 1
#MinorVersion 8
#KeyWords 
#BeginContents
/// <summary Lang=en>
/// This tsl places information of the openings inside the openings of the element in the selected viewport.
/// </summary>

/// <insert>
/// Select a viewport
/// </insert>

/// <remark Lang=en>
/// 
/// </remark>

/// <version  value="1.08" date="02.09.2010"></version>

///<history>
/// AJ - 1.00 - 21.01.2009 - Pilot version
/// AJ - 1.03 - 10.02.2009 - Show information when insert the TSL on outside view of the opening
/// AS - 1.04 - 14.05.2009 - Get openings from single element references if it is an MultiWall
/// AS - 1.05 - 20.05.2009 - Change text height for text on second line
/// AS - 1.06 - 28.05.2009 - Change text height when display is set to outside
/// AS - 1.07 - 01.06.2009 - Name taken from subLabel(3) io subLabel(11)
/// AS - 1.08 - 02.09.2010 - No longer using openings from the element, but grouping beams with same subLabel2 and use that as opening
///</history>

//Script uses mm
double dEps = U(.01,"mm");

//Textheight
double dTxtHeightName = U(3.5);
double dTxtHeightDescription = U(2.5);
double dTxtHeightPlate = U(3.0);

PropString sDimStyle(0, _DimStyles, T("|Dimension style|"));

String arSOptions[] = {T("Inside"), T("Outside")};
PropString sInfoType(1, arSOptions, T("Display"));
int nInfoType = arSOptions.find(sInfoType,0);

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

//Coordsys of element
CoordSys csEl = el.coordSys();
Vector3d vxEl = csEl.vecX();
Vector3d vyEl = csEl.vecY();
Vector3d vzEl = csEl.vecZ();

//Transformation matrices
CoordSys ms2ps = vp.coordSys();
CoordSys ps2ms = ms2ps; ps2ms.invert();

//Display
Display dpTmp(-1);
dpTmp.addViewDirection(-_ZW);

Display dpName(-1);
dpName.dimStyle(sDimStyle, ps2ms.scale());
dpName.textHeight(dTxtHeightName);

Display dpDescription(-1);
dpDescription.dimStyle(sDimStyle, ps2ms.scale());
dpDescription.textHeight(dTxtHeightDescription);

Display dpPlate(-1);
dpPlate.dimStyle(sDimStyle, ps2ms.scale());
dpPlate.textHeight(dTxtHeightPlate);

//Openings from element
Opening arOp[] = el.opening();

ElementMulti elMulti = (ElementMulti)el;
if( elMulti.bIsValid() ){
	SingleElementRef arSingleEl[] = elMulti.singleElementRefs();
	for( int i=0;i<arSingleEl.length();i++ ){
		SingleElementRef singleEl = arSingleEl[i];
		
		Entity arEnt[] = singleEl.entitiesFromMultiElementBuild();
		for( int j=0;j<arEnt.length();j++ ){
			Entity ent = arEnt[j];
			Opening op = (Opening)ent;
			
			if( op.bIsValid() )
				arOp.append(op);
		}
	}
}

//Beams of element
Beam arBm[] = el.beam();

String arSOpening[0];
Point3d arPtOpening[0];
int arNNrOfPoints[0];

for( int i=0;i<arBm.length();i++ ){
	Beam bm = arBm[i];
	if( bm.subLabel2() == "" )
		continue;
	
	if( bm.grade() != "Del-Regel Hor" )
		continue;
	
	String sSubLabel2 = bm.subLabel2();
	int nIndex = arSOpening.find(sSubLabel2);
	if( nIndex == -1 ){
		arSOpening.append(sSubLabel2);
		arPtOpening.append(bm.ptCen());
		arNNrOfPoints.append(1);
	}
	else{
		arPtOpening[nIndex] += bm.ptCen();
		arNNrOfPoints[nIndex] ++;
	}
}

//Get the information of each element
for( int i=0;i<arSOpening.length();i++ ){
	String sSubLabel2 = arSOpening[i];
	Point3d ptOpening = arPtOpening[i];
	int nDevidePointBy = arNNrOfPoints[i];
	
	if( nDevidePointBy == 1 )
		ptOpening -= vyEl * U(500);
	else
		ptOpening /= nDevidePointBy;
	
	Point3d ptOpCenPS = ptOpening; ptOpCenPS.transformBy(ms2ps);ptOpCenPS.vis(1);
	if (nInfoType==0) // Wall from Inside
	{	
		String sDescription = sSubLabel2.token(11);
		String sName = sSubLabel2.token(3);
		
		dpName.draw(" ", ptOpCenPS, _XW, _YW, 0, 0);
		dpName.draw(sName, ptOpCenPS, _XW, _YW, 0, 2);
		dpDescription.draw(sDescription, ptOpCenPS, _XW, _YW, 0, -2);		
	}
	else if (nInfoType==1) // Wall from Inside
	{
		String sToDisplay;
		String sValue=sSubLabel2.token(7);
		if (sValue!="Plåt")
			sToDisplay = sValue;
		
		dpPlate.draw(sToDisplay, ptOpCenPS, _XW, _YW, 0, -6);
	}
}








#End
#BeginThumbnail








#End
