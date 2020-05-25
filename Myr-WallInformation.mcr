#Version 8
#BeginDescription
Last modified by: OBOS
OR - 1.11 - 23.10.19 - Get sublabel from the first module beam


























#End
#Type O
#NumBeamsReq 0
#NumPointsGrip 0
#DxaOut 1
#ImplInsert 1
#FileState 1
#MajorVersion 1
#MinorVersion 11
#KeyWords BOM, labels in paperspace
#BeginContents
/// <summary Lang=en>
/// Show the information of a Wall.
/// </summary>

/// <insert>
/// Select a viewport and a point
/// </insert>

/// <remark Lang=en>
/// .
/// </remark>

/// <version  value="1.11" date="23.10.2019"></version>

/// <history>
/// AJ - 1.00 - 22.01.2009 - Pilot version
/// AJ - 1.01 - 22.01.2009 - Add toolpalette code
/// AJ - 1.02 - 10.02.2009 - Set the Values needed
/// AJ - 1.03 - 10.02.2009 - Add option to Show Manual Information and Plate Information
/// AS - 1.04- 20.05.2009 - Add project information
/// AS - 1.05 - 25.05.2009 - Get openings from single element references if it is an MultiWall
/// AS - 1.06 - 28.05.2009 - Add multiwall name as option
/// AS - 1.07 - 02.06.2009 - Also show plate color when subElement is "A2"
/// AS - 1.08 - 29.09.2009 - Extend tsl: option added to show single element names
/// AS - 1.09 - 02.09.2010 - Add paint information
/// OR - 1.10 - 25.9.2019 - Remove Opening function due to crash
/// OR - 1.11 - 23.10.19 - Get sublabel from the first module beam
/// </history>


Unit (1,"mm");//script uses mm

//Select dimstyle
PropString sDimStyle(0, _DimStyles, T("Dimension style"));

String arSOptions[] = {T("Wall Information"), T("Manual Information"), T("Plate Information"), T("|Project Information|"), T("|Multiwall name|"), T("|Single Element names|"), T("|Paint Information|")};
PropString sDetailType(1, arSOptions, T("Display"));

PropString sComment(2, "", T("Information to Show"));

//Size of the Text
double dTxtHeight=4.5;
int nColor=-1;

if (_bOnDbCreated) setPropValuesFromCatalog(_kExecuteKey);

if( _bOnInsert )
{
	//Erase after 1 cycle
	if( insertCycleCount() > 1 ){
		eraseInstance();
		return;
	}
	

	
	_Viewport.append(getViewport(T("Select the viewport that holds the element.")));
	_Pt0 = getPoint(T("Select a point to where the information is going to be shown."));
	
	if (_kExecuteKey=="")
		showDialog();
		
	return;
}

// resolve variables
int nDetailType = arSOptions.find(sDetailType,0);

if(_Viewport.length()==0){eraseInstance();return;}

Viewport vp = _Viewport[0];
// check if the viewport has hsb data
if (!vp.element().bIsValid()) return;

CoordSys ms2ps = vp.coordSys();
CoordSys ps2ms = ms2ps; ps2ms.invert();


Display dpContent(nColor);
dpContent.dimStyle(sDimStyle, ps2ms.scale());
dpContent.textHeight(dTxtHeight);

Element el = vp.element();

//If invalid no element is set to this viewport: return.
if( !el.bIsValid() )return;

//Coordsys of element
CoordSys csEl = el.coordSys();
Vector3d vx = csEl.vecX();
Vector3d vy = csEl.vecY();
Vector3d vz = csEl.vecZ();

String sToDisplay;
String sSubLabel2;

//Get the information of the Plates from the opening
//Openings from element
Opening arOp[] = el.opening();

ElementMulti elMulti = (ElementMulti)el;
SingleElementRef arSingleEl[0];
if( elMulti.bIsValid() ){
	arSingleEl.append(elMulti.singleElementRefs());
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

//regionOpeningFunction

for (int b=0;b<arBm.length();b++){ 
	Beam b = arBm[b];
	
	if(b.name("module") != "")
	{
		
		sSubLabel2 = b.subLabel2().token(8);
		
		if(sSubLabel2 != "" && sSubLabel2 != "-")
		{
			sSubLabel2 = b.subLabel2();
			break;
		}
		
	}
}
	
	
//Get the information of each element
//for( int i=0;i<arOp.length();i++ ){
//	Opening op = arOp[i];
//	
//	//Centre point of the opening
//	Point3d ptOpCen = Body(op.plShape(), vz).ptCen();
//	
//	//Find beam on righthand side and get information from that one
//	Beam arBmRight[] = Beam().filterBeamsHalfLineIntersectSort(arBm, ptOpCen, vx);
//	if( arBmRight.length() == 0 )continue;
//	
//	//Beam on righthand side
//	Beam bmRight = arBmRight[0];
//	
//	sSubLabel2 = bmRight.subLabel2();
//	
//}


//endregionOpeningFunction

//Get the information from the element that needs to be shown
String sElCode = el.code();
String sElNumber = el.number();
String sDescription = el.definition();
String sProject = projectNumber();

//String sToDisplay=sElCode + " - " + sElNumber + " / " + sInformation + " ** " + sComment;

if (nDetailType==0) // Show element Information
{
	sToDisplay=sElCode + " = "  + sDescription;
}
else if (nDetailType==1) // Show Manual Information
{
	sToDisplay = sComment;
}
else if (nDetailType==2) // Show Plate Information
{
	String sValue=sSubLabel2.token(7);
	if (sValue=="Plåt" || sValue=="A2")
		sToDisplay = "Plåt = "+sSubLabel2.token(8);
	else
		sToDisplay = "";
}
else if( nDetailType == 3 ){
	sToDisplay = "AVTAL: "+sProject;
}
else if( nDetailType == 4 ){
	dpContent.textHeight(U(8));
	sToDisplay = "T"+sElNumber.right(2);
}
else if( nDetailType == 5 ){
	for( int i=0;i<arSingleEl.length();i++ ){
		SingleElementRef singleEl = arSingleEl[i];
		String sNumber = singleEl.number();
		
		// point to display text
		LineSeg lnSegMinMax = singleEl.segmentMinMax();
		Point3d ptText = lnSegMinMax.ptMid();
		ptText.transformBy(ms2ps);
		// project to height of _Pt0
		ptText += _YW * _YW.dotProduct(_Pt0 - ptText);
		
		//draw text
		dpContent.draw(sNumber, ptText, _XW, _YW, 0, 1, _kDevice);
	}
	return;
}
else if( nDetailType == 6 ){
	String sPaintColor = sSubLabel2.token(5);
	if( sPaintColor == "" )
		sPaintColor = sComment;
	
	sToDisplay = "Panel Färg = " + sPaintColor;	
}



dpContent.draw(sToDisplay, _Pt0, _XW, _YW, 1, 1);






#End
#BeginThumbnail










#End
#BeginMapX
<?xml version="1.0" encoding="utf-16"?>
<Hsb_Map>
  <lst nm="TslIDESettings">
    <lst nm="HostSettings">
      <dbl nm="PreviewTextHeight" ut="L" vl="1" />
    </lst>
    <lst nm="{E1BE2767-6E4B-4299-BBF2-FB3E14445A54}">
      <lst nm="BreakPoints" />
    </lst>
  </lst>
  <lst nm="TslInfo">
    <lst nm="TSLINFO">
      <lst nm="TSLINFO">
        <lst nm="TSLINFO" />
      </lst>
    </lst>
  </lst>
  <unit ut="L" uv="millimeter" />
  <unit ut="A" uv="radian" />
</Hsb_Map>
#End