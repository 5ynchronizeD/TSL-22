#Version 8
#BeginDescription
Last modified by: Anno Sportel (anno.sportel@itwindustry.nl)
13.06.2012  -  version 1.02

This tsl displays information for the openings in the layouts



#End
#Type O
#NumBeamsReq 0
#NumPointsGrip 0
#DxaOut 1
#ImplInsert 1
#FileState 1
#MajorVersion 1
#MinorVersion 2
#KeyWords 
#BeginContents
/// <summary Lang=en>
/// This tsl places structural or loadbearing information of the wall in the selected viewport.
/// </summary>

/// <insert>
/// Select a viewport
/// </insert>

/// <remark Lang=en>
/// 
/// </remark>

/// <version  value="1.02" date="13.06.2012"></version>

/// <history>
/// 1.00 - 06.02.2009 - Pilot version
/// 1.01 - 20.02.2009 - Switch 1 and 2
/// 1.02 - 13.06.2012 - Add offsets as a property
/// </history>


//Script uses mm
double dEps = U(.01,"mm");

PropString sDimStyle(0, _DimStyles, T("|Dimension style|"));

//double dTxtHeight(0, U(100), T("|Textheight|"));

PropDouble dxOffset(0, U(100), T("X-|Offset|"));
PropDouble dzOffset(1, U(100), T("Z-|Offset|"));

PropDouble dRadiusCircel(2, U(100), T("|Radius circle|"));

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
Element elInVP = vp.element();
ElementWallSF el = (ElementWallSF)elInVP;

//If invalid no element is set to this viewport: return.
if( !el.bIsValid() )return;

//Is it loadBearing?
if( !el.loadBearing() )return;

//Coordsys of element
CoordSys csEl = el.coordSys();
Vector3d vxEl = csEl.vecX();
Vector3d vyEl = csEl.vecY();
Vector3d vzEl = csEl.vecZ();

//Transformation matrices
CoordSys ms2ps = vp.coordSys();
CoordSys ps2ms = ms2ps; ps2ms.invert();

double dVpScale = ps2ms.scale();

//Display
Display dp(-1);
dp.dimStyle(sDimStyle, dVpScale);
double dTxtHeight = dp.textHeightForStyle("HSB", sDimStyle)/dVpScale;
dp.textHeight(dTxtHeight);

//Element length
LineSeg lnSeg = el.segmentMinMax();
double dElLength = abs(vxEl.dotProduct(lnSeg.ptEnd() - lnSeg.ptStart()));

//1
Point3d ptTxt01 = el.ptOrg() + vxEl * (dElLength + dxOffset) - vzEl * dzOffset;
ptTxt01.transformBy(ms2ps);
dp.draw("1", ptTxt01, _XW, _YW, 0, 0);
//Circle
PLine plCircle01(_ZW);
plCircle01.createCircle(ptTxt01, _ZW, dRadiusCircel/dVpScale);
dp.draw(plCircle01);

//2
Point3d ptTxt02 = el.ptOrg() - vxEl * dxOffset + vzEl * dzOffset;
ptTxt02.transformBy(ms2ps);
dp.draw("2", ptTxt02, _XW, _YW, 0, 0);
//Circle
PLine plCircle02(_ZW);
plCircle02.createCircle(ptTxt02, _ZW, dRadiusCircel/dVpScale);
dp.draw(plCircle02);




#End
#BeginThumbnail


#End
