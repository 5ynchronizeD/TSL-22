#Version 8
#BeginDescription
Last modified by: Anno Sportel (as@hsb-cad.com)
01.09.2010  -  version 2.7




















#End
#Type O
#NumBeamsReq 0
#NumPointsGrip 0
#DxaOut 1
#ImplInsert 1
#FileState 0
#MajorVersion 2
#MinorVersion 7
#KeyWords 
#BeginContents
/*
*  COPYRIGHT
*  ---------
*  Copyright (C) 2004 by
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
* Revised: Anno Sportel 040303
* Change:  First revision
*
* Revised: Anno Sportel 040304
* Change: Correct dim. outline on sloped elements. - Update gootklos en overstek filteren uit bemating
*		     Workaround for wrong ptOrg
* 
* Revised: Anno Sportel 040305
* Change: Correct textside right in combination with vertical alignment - Add prop: switch text: left right
*		     Add text offset. property - Update bemating element
*
* Revised: Anno Sportel 040310
* Change: Add some dimension styles
*
* Revised: Anno Sportel 040317
* Change: Update diagonal dimensioning - PtOrg is in the lower left corner --> update TSL
*		     Add prop to define start of cumm. dimensioning
*
* Revised: Anno Sportel 040318
* Change: Update element dimensioning
*
* Revised: Anno Sportel 040329
* Change: Make tsl independent of representation of element in viewport
*
* Revised: Anno Sportel 040420
* Change: Make sloped dimensioning a separate TSL.
*
* Revised: Anno Sportel 040427
* Change: Project dimpoints to the edge of the element - Update sorting of points
*
* Revised: Anno Sportel 040428
* Change: Update text for tsl dimensioning - Place correct text (TSL dimensioning)
*		     Add a property for what tsl to dimension - Add dimensioning of TSL's
*
* Revised: Anno Sportel 040507
* Change: Update reference-zone dimensioning
*
* Revised: Anno Sportel 040510
* Change: Update translatable strings
*
* Revised: Anno Sportel 040513
* Change: Add beamcode filter
*		     Dimension extreme vertices of beams and sheets if bm/sh.vecX is parallel to vDimX (if object == zone)
*
* Revised: Anno Sportel 040526
* Change: Add point on the right side of the element as well (reference zone) 
*		     Add toggle for extension lines - Update sheet dimensioning
*
* Revised: Anno Sportel 040607
* Change: Dim shortest or longest side of beams on the edge of the element.
*
* Revised: Anno Sportel 040701
* Change: Add filter on label. Dim gripppoints of TSL's also.
*
* Revised: Anno Sportel 040903
* Change: Check beamcode in a different way.
*
* Revised: Anno Sportel 050125
* Change: Its possible to select all dimstyles available in the drawing.
*
* Revised: Anno Sportel 050503
* Change: Add perimeter as dimension object.
*
* Revised: Anno Sportel 050824
* Change: Add dimensioning of beam with specific beamcode.
*
* Revised: Anno Sportel 050914
* Change: Update filtering.
*
* Revised: Anno Sportel 051031
* Change: Draw nothing if the number of dimpoints is less then 2
*
* Revised: Anno Sportel 060220
* Change: Filter 0 dims
*
* Revised: Anno Sportel 070413
* Change: Filter on materials added
*
* Revised: Anno Sportel 070712
* Change: 	Beams can also be part of a zone. 
*			Add option to dimension entities based on labels
*
* Revised: Anno Sportel 070718
* Change: 	Add option to dimension entities based on names
*
* Revised: Anno Sportel 080403 (v2.0)
* Change: 	if no points added on tsl dim: return
*
* date: 29.08.2008
* version 2.1:	Store available list of tsl's in _Map
* date: 01.12.2008
* version 2.2:	Add side dimensioning for beamcode dimensioning
*				Add rafters as a reference
*				Make it case-insensitive
* date: 17.02.2010
* version 2.3:	Add property for readdirection
* version 2.4:	Add option for specials
* date: 04.06.2010
* version 2.5:	Hide dimline if there are no points for beamcode dimensioning found (only when dimensionObject is set to DimBeamCodes)
* date: 08.06.2010
* version 2.6:	Add link to the HSB-Section (PS) tsl.
* date: 01.09.2010
* version 2.7:	Update perimeter dimensioning
*
*/

//PropString Index = 16

double dEps = U(0.01,"mm"); // script uses mm

//Used to set the distance to the element.
PropDouble dDimOff(0,U(300),T("Distance dimension line to element"));
PropDouble dTextOff(1,U(100),T("Distance text"));

//Used to set the side of the text.
String sArDeltaOnTop[]={T("Above"),T("Below")};
int nArDeltaOnTop[]={TRUE,FALSE};
PropString sDeltaOnTop(0,sArDeltaOnTop,T("Side of delta dimensioning"),0);
int nDeltaOnTop = nArDeltaOnTop[sArDeltaOnTop.find(sDeltaOnTop,0)];

String arSReadDirection[] = {T("|Top-left|"), T("|Bottom-right|")};
PropString sReadDirection(17, arSReadDirection, T("|Read direction|"));

String sArTextSide[]={T("Left"),T("Right")};
int nArTextSide[]={1,-1};
PropString sTextSide(1,sArTextSide,T("Side of dimensioning text"),0);
int nTextSide = nArTextSide[sArTextSide.find(sTextSide,0)];

String sArStartDim[]={T("Left"),T("Right")};
int nArStartDim[]={1,-1};
PropString sStartDim(2,sArStartDim,T("Start dimensionsing"));
int nStartDim = nArStartDim[sArStartDim.find(sStartDim,0)];

//Used to define what needs tobe dimensioned
String sArObject[]={T("|Element|"),T("|Zone|"),T("|TSL|"), T("|Perimeter|"), T("|Beam with beamcode|"), T("|Label/Name|")};
PropString sObject(3,sArObject,T("|Dimension object|"));

PropString sDimBeamCode(4, "", T("Dimension beam with beamcode"));
String sDimBC = sDimBeamCode + ";";
sDimBC.makeUpper();
String arSDimBC[0];
int nIndexDimBC = 0; 
int sIndexDimBC = 0;
while(sIndexDimBC < sDimBC.length()-1){
	String sTokenBC = sDimBC.token(nIndexDimBC);
	nIndexDimBC++;
	if(sTokenBC.length()==0){
		sIndexDimBC++;
		continue;
	}
	sIndexDimBC = sDimBC.find(sTokenBC,0);

	arSDimBC.append(sTokenBC);
}

PropString sDimLabel(16, "", T("Dimension beam/sheets with label/name"));
String sDimLbl = sDimLabel + ";";
sDimLbl.makeUpper();
String arSDimLbl[0];
int nIndexDimLbl = 0; 
int sIndexDimLbl = 0;
while(sIndexDimLbl < sDimLbl.length()-1){
	String sTokenLbl = sDimLbl.token(nIndexDimLbl);
	nIndexDimLbl++;
	if(sTokenLbl.length()==0){
		sIndexDimLbl++;
		continue;
	}
	sIndexDimLbl = sDimLbl.find(sTokenLbl,0);

	arSDimLbl.append(sTokenLbl);
}

// filter beams with beamcode
PropString sFilterBC(5,"",T("Filter beams with beamcode"));
String sFBC = sFilterBC + ";";
sFBC.makeUpper();
String arSFBC[0];
int nIndexBC = 0; 
int sIndexBC = 0;
while(sIndexBC < sFBC.length()-1){
	String sTokenBC = sFBC.token(nIndexBC);
	nIndexBC++;
	if(sTokenBC.length()==0){
		sIndexBC++;
		continue;
	}
	sIndexBC = sFBC.find(sTokenBC,0);
	sTokenBC.trimLeft();
	sTokenBC.trimRight();
	arSFBC.append(sTokenBC);
}



// filter GenBeams with label
PropString sFilterLabel(6,"",T("Filter beams/sheets with label/material"));
String sFLabel = sFilterLabel + ";";
sFLabel.makeUpper();
String arSFLabel[0];
int nIndexLabel = 0; 
int sIndexLabel = 0;
while(sIndexLabel < sFLabel.length()-1){
	String sTokenLabel = sFLabel.token(nIndexLabel);
	nIndexLabel++;
	if(sTokenLabel.length()==0){
		sIndexLabel++;
		continue;
	}
	sIndexLabel = sFilterLabel.find(sTokenLabel,0);

	arSFLabel.append(sTokenLabel);
}

//Used as a reference
String sArReference[] = {
	T("Origin of element") + " + " + T("Dimension object"),
	T("Origin of zone") + " + " + T("Dimension object"),
	T("Dimension object"), 
	T("Origin of rafters") + " + " + T("Dimension object")
};
PropString sReference(7,sArReference,T("Reference"));
int nReference = sArReference.find(sReference,0);
//Use these types for rafters as refernce points
int arNBmTypeRafter[] = {
	_kDakCenterJoist,
	_kDakLeftEdge,
	_kDakRightEdge
};

//Used to set the dimension line to specific side of the element.
String sArAlignment[] = {
	T("Vertical left"),
	T("Vertical right"),
	T("Horizontal bottom"),
	T("Horizontal top")
};
PropString sAlignment(8,sArAlignment,T("Alignment"));
int nAlignment = sArAlignment.find(sAlignment,0);

//Used to set the dimension style
String sArDimStyle[] ={
	T("Delta perpendicular"),
	T("Delta parallel"),
	T("Cummulative perpendicular"),
	T("Cummalative parallel"),
	T("Both perpendicular"),
	T("Both parallel"),
	T("Delta parallel, Cummalative perpendicular"),
	T("Delta perpendicular, Cummalative parallel")
};
PropString sDimStyle(9,sArDimStyle,T("Dimension style"));
int nArDimStyleDelta[] = {_kDimPerp, _kDimPar,_kDimNone,_kDimNone,_kDimPerp,_kDimPar,_kDimPar,_kDimPerp};
int nArDimStyleCum[] = {_kDimNone,_kDimNone,_kDimPerp, _kDimPar,_kDimPerp,_kDimPar,_kDimPerp,_kDimPar};
int nDimStyleDelta = nArDimStyleDelta[sArDimStyle.find(sDimStyle,0)];
int nDimStyleCum = nArDimStyleCum[sArDimStyle.find(sDimStyle,0)];

//Used to set the dimensioning side. Which side of the entity's in the element is dimensioned.
String sArSide[]={T("Left"),T("Center"),T("Right"), T("Left & Right")};
int nArSide[]={_kLeft, _kCenter, _kRight, _kLeftAndRight};
PropString sSide(10,sArSide,T("Dimensioning side"));
int nSide = nArSide[sArSide.find(sSide,0)];

//Used to set the dimensioning layout.
PropString sDimLayout(11,_DimStyles,"Dimension layout",1);

int arZone[]={-5,-4,-3,-2,-1,0,1,2,3,4,5};
PropInt nZone(1,arZone,T("Zone Dimensioning object"),5); // index 5 is default
PropInt nZoneRef(2,arZone,T("Reference-zone"),5); // index 5 is default
PropInt nDimColor(3,1,T("Color"));
if (nDimColor < 0 || nDimColor > 255) nDimColor.set(0);

String sArTrueFalse[] = {T("Yes"), T("No")};
int nArTrueFalse[] = {TRUE, FALSE};
PropString sExtLines(12,sArTrueFalse,T("Place extension lines"),1);
int nExtLines = nArTrueFalse[sArTrueFalse.find(sExtLines,1)];

String sArSideParBms[]={T("Upper"),T("Center"),T("Lower")};
double dArSideParBms[]={1, 0.5, 0};
PropString sSideParBms(13,sArSideParBms,T("Dim side of beams parallel to dimline"),2);
double dSideParBms = dArSideParBms[sArSideParBms.find(sSideParBms,2)];

PropString sDescription(14, "", T("Overrule description"));

PropString sSpecial(18, "", T("|Special|"));

if (_bOnInsert) {
	Viewport vp = getViewport(T("Select a viewport.")); // select viewport
	_Viewport.append(vp);
}

// do something for the last appended viewport only
if (_Viewport.length()==0) return; // _Viewport array has some elements
Viewport vp = _Viewport[_Viewport.length()-1]; // take last element of array
_Viewport[0] = vp; // make sure the connection to the first one is lost

// check if the viewport has hsb data
if (!vp.element().bIsValid()) return;

CoordSys ms2ps = vp.coordSys();
CoordSys ps2ms = ms2ps; ps2ms.invert(); // take the inverse of ms2ps
Element el = vp.element();
CoordSys csEl = el.coordSys();
Point3d ptEl = csEl.ptOrg();
Vector3d vxEl = csEl.vecX();
Vector3d vyEl = csEl.vecY();
Vector3d vzEl = csEl.vecZ();

Line lnY(ptEl, vyEl);
Plane pnBack(ptEl - vzEl * el.zone(0).dH(), vzEl);

Map mapTslScriptNames = _Map.getMap("ScriptNames");
//mapTslScriptNames = Map();
if( mapTslScriptNames.length() == 0 ){
	mapTslScriptNames.setString("All", "All");
}
TslInst arTsl[] = el.tslInst();
for( int i=0;i<arTsl.length();i++){
	TslInst tsl = arTsl[i];
	String sScriptName = tsl.scriptName();
	
	if( !mapTslScriptNames.hasString(sScriptName) ){
		mapTslScriptNames.setString(sScriptName, sScriptName);
	}
}
_Map.setMap("ScriptNames", mapTslScriptNames);

String arSTsl[0];
for( int i=0;i<mapTslScriptNames.length();i++ ){
	arSTsl.append(mapTslScriptNames.getString(i));
}
PropString sTsl(15,arSTsl,T("Tsl - name"));

if(_bOnInsert){
  showDialogOnce();
  return;
}

int nReadDirection = arSReadDirection.find(sReadDirection);

// set the diameter of the 3 circles, shown during dragging
setMarbleDiameter(U(4));
Display dp(nDimColor);
dp.dimStyle(sDimLayout, ps2ms.scale()); // dimstyle was adjusted for display in paper space, sets textHeight


//Determine in which direction the element is shown in the viewport. Act accordingly.
Vector3d vx;
Vector3d vy;
Vector3d vz;
Vector3d vxTemp = csEl.vecX();
vxTemp.transformBy(ms2ps);
vxTemp.normalize();
Vector3d vyTemp = csEl.vecY();
vyTemp.transformBy(ms2ps);
vyTemp.normalize();
Vector3d vzTemp = csEl.vecZ();
vzTemp.transformBy(ms2ps);
vzTemp.normalize();
if( _XW.isParallelTo(vxTemp) ){
  vx = csEl.vecX();
  if( !_XW.isCodirectionalTo(vxTemp) ){
    vx = -csEl.vecX();
  }
  if( _YW.isParallelTo(vyTemp) ){
    vy = csEl.vecY();
    if( !_YW.isCodirectionalTo(vyTemp) ){
      vy = -csEl.vecY();
    }
    vz = csEl.vecZ();
  }
  else{
    vy = csEl.vecZ();
    if( !_YW.isCodirectionalTo(vzTemp) ){
      vy = -csEl.vecZ();
    }
    vz = csEl.vecY();
  }
}
else if( _XW.isParallelTo(vyTemp) ){
  vx = csEl.vecY();
  if( !_XW.isCodirectionalTo(vyTemp) ){
    vx = -csEl.vecY();
  }
  if( _YW.isParallelTo(vxTemp) ){
    vy = csEl.vecX();
    if( !_YW.isCodirectionalTo(vxTemp) ){
      vy = -csEl.vecX();
    }
    vz = csEl.vecZ();
  }
  else{
    vy = csEl.vecZ();
    if( !_YW.isCodirectionalTo(vzTemp) ){
      vy = -csEl.vecZ();
    }
    vz = csEl.vecX();
  }
}
else if( _XW.isParallelTo(vzTemp) ){
  vx = csEl.vecZ();
  if( !_XW.isCodirectionalTo(vzTemp) ){
    vx = -csEl.vecZ();
  }
  if( _YW.isParallelTo(vxTemp) ){
    vy = csEl.vecX();
    if( !_YW.isCodirectionalTo(vxTemp) ){
      vy = -csEl.vecX();
    }
    vz = csEl.vecY();
  }
  else{
    vy = csEl.vecY();
    if( !_YW.isCodirectionalTo(vyTemp) ){
      vy = -csEl.vecY();
    }
    vz = csEl.vecX();
  }
}
else{
  reportNotice("Error!\nVectors not aligned.");
  return;
}
//Vectors are set.


Vector3d vxps = vx; vxps.transformBy(ms2ps);
Vector3d vyps = vy; vyps.transformBy(ms2ps);
Vector3d vzps = vz; vzps.transformBy(ms2ps);

Entity arEntTslPS[] = Group().collectEntities(true, TslInst(), _kMySpace);
TslInst tslSection;
for( int i=0;i<arEntTslPS.length();i++ ){
	TslInst tsl = (TslInst)arEntTslPS[i];
	
	Map mapTsl = tsl.map();
	String vpHandle = mapTsl.getString("VPHANDLE");
	
	if( tsl.scriptName() == "HSB-Section (PS)" && vpHandle == vp.viewData().viewHandle() ){
		tslSection = tsl;
		break;
	}
}

GenBeam arGBeamsTmp[0];
if( !tslSection.bIsValid() )
	arGBeamsTmp = el.genBeam(); // collect all
else{
	Map mapTsl = tslSection.map();
	for( int i=0;i<mapTsl.length();i++ ){
		if( mapTsl.keyAt(i) == "GENBEAM" ){
			Entity entGBm = mapTsl.getEntity(i);
			arGBeamsTmp.append((GenBeam)entGBm);
		}
	}
}

GenBeam arGBeams[0];
for(int i=0;i<arGBeamsTmp.length();i++){
	if( arGBeamsTmp[i].bIsDummy() )continue;
	if( 	(arSFBC.find(arGBeamsTmp[i].name("beamcode").token(0).makeUpper()) == -1) && 
			(arSFLabel.find(arGBeamsTmp[i].label().makeUpper()) == -1) && 
			(arSFLabel.find(arGBeamsTmp[i].hsbId().makeUpper()) == -1) && 
			(arSFLabel.find(arGBeamsTmp[i].material().makeUpper()) == -1))
	{
		arGBeams.append(arGBeamsTmp[i]);
	}
}

// ***
// Start finding the points for diagonal dimensioning.
// ***
Beam arBms[0];
Beam arBmRafter[0];
Point3d arPtRafter[0];
for(int i=0;i<arGBeams.length();i++){
	GenBeam gBm = arGBeams[i];
	Beam bm = (Beam)gBm;
	
	if( !bm.bIsValid() )continue;
	if( bm.bIsDummy() )continue;
	if( bm.myZoneIndex() != 0 )continue;
	if( 	(arSFBC.find(bm.name("beamcode").token(0).makeUpper()) == -1) && 
			(arSFLabel.find(bm.label().makeUpper()) == -1) && 
			(arSFLabel.find(bm.hsbId().makeUpper()) == -1) && 
			(arSFLabel.find(bm.material().makeUpper()) == -1))
	{
		arBms.append(bm);
		
		if( arNBmTypeRafter.find(bm.type()) != -1 ){
			arBmRafter.append(bm);
			arPtRafter.append(bm.realBody().allVertices());
		}
	}
}

if(_bOnDebug){
  Sheet arShs4[] = el.sheet(4);
  Sheet arShs5[] = el.sheet(5);
  Sheet arShs6[] = el.sheet(-1);
  for(int i=0;i<arBms.length();i++){
    Body bd = arBms[i].realBody();
    bd.transformBy(ms2ps);
    dp.color(32);
    dp.draw(bd);
  }
  for(int i=0;i<arShs4.length();i++){
    Body bdSh4 = arShs4[i].realBody();
    bdSh4.transformBy(ms2ps);
    dp.color(6);
//    dp.draw(bdSh4);
  }
  for(int i=0;i<arShs5.length();i++){
    Body bdSh5 = arShs5[i].realBody();
    bdSh5.transformBy(ms2ps);
    dp.color(3);
//    dp.draw(bdSh5);
  }
  for(int i=0;i<arShs6.length();i++){
    Body bdSh6 = arShs6[i].realBody();
    bdSh6.transformBy(ms2ps);
    dp.color(5);
//    dp.draw(bdSh6);
  }
  dp.color(1);
}   

Body arBd[0];
for(int i=0;i<arBms.length();i++){
  //if(! (arBms[i].vecX().isPerpendicularTo(vx) || arBms[i].vecX().isPerpendicularTo(vy)) ){
    arBd.append(arBms[i].realBody());// collect diagonal beams.
  //}
}

Point3d ptsMinX[0];
Point3d ptsMaxX[0];
Point3d ptsMinY[0];
Point3d ptsMaxY[0];

double dMinX;
double dMaxX;
double dMinY;
double dMaxY;

int boundXSet = FALSE;  
int boundYSet = FALSE;
for (int i=0; i<arBd.length();i++){
  /*  
  if (_bOnDebug) {
    Body drBd = arBd[i];
    drBd.transformBy(ms2ps);
    dp.color(3);
    dp.draw(drBd);
  }
  */
  Point3d pts[] = arBd[i].allVertices();
  for (int j=0;j<pts.length();j++){
    //Place all points in the same plane
    double dCorr = vz.dotProduct(pts[j]-el.ptOrg());
    pts[j] = pts[j]-dCorr*vz;
    
    double dDist = vx.dotProduct(pts[j]-el.ptOrg());
    if(!boundXSet){
      boundXSet = TRUE;
      dMinX = dDist;
      dMaxX = dDist;
      ptsMinX.append(pts[j]);
      ptsMaxX.append(pts[j]);
    }
    else{
      if( (dDist - dMinX)<=0.05 && (dDist - dMinX)>=-0.05 ){ //is dDist between -0.05 and 0.05?
        ptsMinX.append(pts[j]);
      }
      else if( (dDist - dMaxX)<=0.05 && (dDist -dMaxX)>=-0.05 ){
        ptsMaxX.append(pts[j]);
      }
      else if( (dDist - dMinX)<-0.05 ){
        dMinX = dDist;
        ptsMinX.setLength(0);
        ptsMinX.append(pts[j]);
      }
      else if( (dDist - dMaxX)>0.05 ){
        dMaxX = dDist;
        ptsMaxX.setLength(0);
        ptsMaxX.append(pts[j]);
      }
      else{
      }
    }
  
    dDist = vy.dotProduct(pts[j]-el.ptOrg());
    if(!boundYSet){
      boundYSet = TRUE;
      dMinY = dDist;
      dMaxY = dDist;
      ptsMinY.append(pts[j]);
      ptsMaxY.append(pts[j]);
    }
    else{
      if( (dDist - dMinY)<=0.05 && (dDist - dMinY)>=-0.05 ){
        ptsMinY.append(pts[j]);
      }
      else if( (dDist - dMaxY)<=0.05 && (dDist - dMaxY)>=-0.05 ){
        ptsMaxY.append(pts[j]);
      }
      else if( (dDist - dMinY)<-0.05 ){
        dMinY = dDist;
        ptsMinY.setLength(0);
        ptsMinY.append(pts[j]);
      }
      else if( (dDist - dMaxY)>0.05 ){
        dMaxY = dDist;
        ptsMaxY.setLength(0);
        ptsMaxY.append(pts[j]);
      }
      else{
      }
    }
  }
}
Point3d ptMinXMinY;
Point3d ptMinXMaxY;

double dMin;
double dMax;
 
int boundSet = FALSE;
for(int i=0;i<ptsMinX.length();i++){
  double dDist = ptsMinX[i].dotProduct(vy);
  if(!boundSet){
    boundSet = TRUE;
    dMin = dDist;
    dMax = dDist;
    ptMinXMinY = ptsMinX[i];
    ptMinXMaxY = ptsMinX[i];
  }
  else{
    if(dDist<dMin){
      dMin = dDist;
      ptMinXMinY = ptsMinX[i];
    }
    else if(dDist>dMax){
      dMax = dDist;
      ptMinXMaxY = ptsMinX[i];
    }
    else{
    }
  }
}

Point3d ptMaxXMinY;
Point3d ptMaxXMaxY; 
boundSet = FALSE;
for(int i=0;i<ptsMaxX.length();i++){
  double dDist = ptsMaxX[i].dotProduct(vy);
  if(!boundSet){
    boundSet = TRUE;
    dMin = dDist;
    dMax = dDist;
    ptMaxXMinY = ptsMaxX[i];
    ptMaxXMaxY = ptsMaxX[i];
  }
  else{
    if(dDist<dMin){
      dMin = dDist;
      ptMaxXMinY = ptsMaxX[i];
    }
    else if(dDist>dMax){
      dMax = dDist;
      ptMaxXMaxY = ptsMaxX[i];
    }
    else{
    }
  }
}

Point3d ptMinYMinX;
Point3d ptMinYMaxX;
boundSet = FALSE;
for(int i=0;i<ptsMinY.length();i++){
  double dDist = ptsMinY[i].dotProduct(vx);
  if(!boundSet){
    boundSet = TRUE;
    dMin = dDist;
    dMax = dDist;
    ptMinYMinX = ptsMinY[i];
    ptMinYMaxX = ptsMinY[i];
  }
  else{
    if(dDist<dMin){
      dMin = dDist;
      ptMinYMinX = ptsMinY[i];
    }
    else if(dDist>dMax){
      dMax = dDist;
      ptMinYMaxX = ptsMinY[i];
    }
    else{
    }
  }
}

Point3d ptMaxYMinX;
Point3d ptMaxYMaxX;
boundSet = FALSE;
for(int i=0;i<ptsMaxY.length();i++){
  double dDist = ptsMaxY[i].dotProduct(vx);
  if(!boundSet){
    boundSet = TRUE;
    dMin = dDist;
    dMax = dDist;
    ptMaxYMinX = ptsMaxY[i];
    ptMaxYMaxX = ptsMaxY[i];
  }
  else{
    if(dDist<dMin){
      dMin = dDist;
      ptMaxYMinX = ptsMaxY[i];
    }
    else if(dDist>dMax){
      dMax = dDist;
      ptMaxYMaxX = ptsMaxY[i];
    }
    else{
    }
  }
}
// ***
// End of finding points for diagonal dimensioning.
// ***


// direction of dim 
Vector3d  vDimX, vDimY;
if (nAlignment == 0) { vDimX = _YW; vDimY = -_XW;}
else if (nAlignment == 1) { vDimX = _YW; vDimY = -_XW;}
else if (nAlignment == 2) { vDimX = _XW; vDimY = _YW;}
else if (nAlignment == 3) { vDimX = _XW; vDimY = _YW;}
else  { vDimX = _XW; vDimY = _YW;}
//draw description

Point3d ptTemp1 = ptMaxXMinY - vy*vy.dotProduct(ptMaxXMinY-ptMinYMaxX);
Point3d ptTemp2 = ptMinXMinY - vy*vy.dotProduct(ptMinXMinY-ptMinYMinX);
double dElemLength = (ptTemp1-ptTemp2).length();
Point3d ptTemp3 = ptMaxYMinX - vx*vx.dotProduct(ptMaxYMinX - ptMinXMaxY);
Point3d ptTemp4 = ptMinYMinX - vx*vx.dotProduct(ptMinYMinX - ptMinXMinY);
double dElemHeight = (ptTemp3-ptTemp4).length();

double dxOff[] = {  -dDimOff,(dDimOff + dElemLength),0,0};
double dyOff[] = { 0, 0, -dDimOff,dElemHeight+dDimOff};
double dxTextOff[0];
double dyTextOff[0];
if(nTextSide == 1){
  dxTextOff.append(0);
  dxTextOff.append(0);
  dxTextOff.append( -(dElemLength + dTextOff) );
  dxTextOff.append( -(dElemLength + dTextOff) );

  dyTextOff.append( -(dElemHeight + dTextOff) );
  dyTextOff.append( -(dElemHeight + dTextOff) );
  dyTextOff.append(0);
  dyTextOff.append(0);
}
else if(nTextSide == -1){
  dxTextOff.append(0);
  dxTextOff.append(0);
  dxTextOff.append( dTextOff );
  dxTextOff.append( dTextOff );

  dyTextOff.append( dTextOff );
  dyTextOff.append( dTextOff );
  dyTextOff.append(0);
  dyTextOff.append(0);
}
Point3d ptStrt = ptMinXMinY - vy*vy.dotProduct(ptMinXMinY-ptMinYMinX);
Point3d pElZero =	ptStrt + vx *( dxOff[nAlignment] + dxTextOff[nAlignment] )+ vy *( dyOff[nAlignment] + dyTextOff[nAlignment] );

Point3d pel0 = pElZero;
pel0.transformBy(ms2ps);


DimLine lnPs; // dimline in PS (Paper Space)
lnPs = DimLine(pel0, vDimX, vDimY );
DimLine lnMs = lnPs; lnMs.transformBy(ps2ms); // dimline in MS (Model Space)

// End description dimline
Point3d pntsMs[0]; // define array of points in MS

//set reference to origin of element
if (nReference == 0){
	pntsMs.append(ptMinXMinY - vy*vy.dotProduct(ptMinXMinY-ptMinYMinX)); // append origin of element as reference point
}
//set reference to origin of zone
if (nReference == 1) {
  GenBeam gh[0];
  for (int i = 0; i < arGBeams.length(); i++) {	
    if(arGBeams[i].bIsDummy()) continue;
    if (arGBeams[i].myZoneIndex() == nZoneRef) gh.append(arGBeams[i]);
  }
  Point3d pBodies[0];
  for (int i = 0; i < gh.length(); i++) {
    Body bd0 = gh[i].realBody();
    Point3d pBd0[] = bd0.allVertices();
    pBodies.append(pBd0);
  }
  Line lnBodies (pel0, vDimX);
  lnBodies.transformBy(ps2ms);
  pBodies = lnBodies.orderPoints(pBodies);
  if (pBodies.length() == 0) pBodies.append(el.ptOrg());
  pntsMs.append(pBodies[0]);	
  pntsMs.append(pBodies[pBodies.length() - 1]);
}
//set reference to origin of rafters
if (nReference == 3) {
	Line lnDimX (pel0, vDimX);
	lnDimX.transformBy(ps2ms);

	Point3d arPtRafterX[] = lnDimX.orderPoints(arPtRafter);
	if(arPtRafterX .length() == 0) arPtRafterX.append(el.ptOrg());
	pntsMs.append(arPtRafterX[0]);	
	pntsMs.append(arPtRafterX[arPtRafterX.length() - 1]);
}

if (sObject==sArObject[0]) {//Element
  if(nAlignment < 2){//Vertical left or right
    pntsMs.append(ptMinYMinX);
    pntsMs.append(ptMaxYMinX);		
  }
  else if(nAlignment < 4){//Horizontal bottom or top
    pntsMs.append(ptMinXMinY);
    pntsMs.append(ptMaxXMinY);
  }
  else{
  }
}
else if (sObject==sArObject[1]) { //zoneindex 
  if (nZone==0) { // we only take the beams
    for(int i=0;i<arBms.length();i++){
      Beam bm = arBms[i];
      if( (nAlignment == 0 || nAlignment ==1) && (bm.vecX().isParallelTo(vy)) ){
        Body bd(bm.realBody());

        Point3d ptPlane = bm.ptCen() -0.5 * vx * bm.dW();
        PlaneProfile pProf = bd.extractContactFaceInPlane(Plane(ptPlane,vx),U(10));
        PLine pLine[] = pProf.allRings();
        Point3d pntsPLine[0];
        
        //get the angle of the beam on the positive side of the beam Add a ">" sign to it (this is the token).
        String sCutPAngle = bm.strCutPC() + ">";
        //filter the angle out of sCutPAngle (0.00>30.00>). Get index 1 of the string use ">" as seperation sign.
        String sPAngle = sCutPAngle.token(0,">");
        //Convert angle to double
        double dPAngle = sPAngle.atof();

        //get the angle of the beam on the negative side of the beam Add a ">" sign to it (this is the token).
        String sCutNAngle = bm.strCutNC() + ">";
        //filter the angle out of sCutNAngle (0.00>30.00>). Get index 1 of the string use ">" as seperation sign.
        String sNAngle = sCutNAngle.token(0,">");
        //Convert angle to double
        double dNAngle = sNAngle.atof();

        for(int j=0;j<pntsPLine.length();j++){
          double dDist = abs(vz.dotProduct(pntsPLine[j] - ptStrt));
          if(dDist < U(0.1)){
            if( vy.dotProduct(pntsPLine[j] - bm.ptCen()) > 0 ){
              pntsMs.append(pntsPLine[j] +bm.vecX() * dSideParBms * bm.dW()* tan(dPAngle));
            }
            else{
              pntsMs.append(pntsPLine[j] +bm.vecX() * dSideParBms * bm.dW() * tan(dNAngle));
            }
          }
        }



      }
      else if( (nAlignment ==2 || nAlignment ==3) && (bm.vecX().isParallelTo(vx)) ){
        Body bd(bm.realBody());

        Point3d ptPlane = bm.ptCen() -0.5 * vy * bm.dW();
        PlaneProfile pProf = bd.extractContactFaceInPlane(Plane(ptPlane,vy),U(10));
        PLine pLine[] = pProf.allRings();
        Point3d pntsPLine[0];
        for(int j=0;j<pLine.length();j++){
//          pntsPLine.append(pLine[j].vertexPoints(TRUE));
        }
        
        //get the angle of the beam on the positive side of the beam Add a ">" sign to it (this is the token).
        String sCutPAngle = bm.strCutPC() + ">";
        //filter the angle out of sCutPAngle (0.00>30.00>). Get index 1 of the string use ">" as seperation sign.
        String sPAngle = sCutPAngle.token(0,">");
        //Convert angle to double
        double dPAngle = sPAngle.atof();

        //get the angle of the beam on the negative side of the beam Add a ">" sign to it (this is the token).
        String sCutNAngle = bm.strCutNC() + ">";
        //filter the angle out of sCutNAngle (0.00>30.00>). Get index 1 of the string use ">" as seperation sign.
        String sNAngle = sCutNAngle.token(0,">");
        //Convert angle to double
        double dNAngle = sNAngle.atof();

        for(int j=0;j<pntsPLine.length();j++){
          double dDist = abs(vz.dotProduct(pntsPLine[j] - ptStrt));
          if(dDist < U(0.1)){
            if( vy.dotProduct(pntsPLine[j] - bm.ptCen()) > 0 ){
              pntsMs.append(pntsPLine[j] +bm.vecX() * dSideParBms * bm.dW()* tan(dPAngle));
            }
            else{
              pntsMs.append(pntsPLine[j] +bm.vecX() * dSideParBms * bm.dW() * tan(dNAngle));
            }
          }
        }
      }
      else{
        //Diagonal beam
      }
    }
    pntsMs.append(lnMs.collectDimPoints(arBms,nSide));
  }
  else { // take the sheeting from a zone
    GenBeam arGBmZn[0];
    for( int i=0;i<arGBeams.length();i++ ){
      GenBeam gBm = arGBeams[i];
      if( gBm.myZoneIndex() == nZone ){
          arGBmZn.append(gBm);
      }
    }
    pntsMs.append(lnMs.collectDimPoints(arGBmZn,nSide));
  }
}
else if (sObject==sArObject[2]) {//TSL
  Point3d pt(0,0,0);
  int nNrOfPoints = pntsMs.length();
  for(int i = 0; i < arTsl.length(); i++){
    if(sTsl == "All"){
      pntsMs.append(arTsl[i].ptOrg());
      int p = 0;
      while( Vector3d(arTsl[i].gripPoint(p) - pt).length() > 0 ){
        pntsMs.append(arTsl[i].gripPoint(p));
        p++;
      }
    }
    else if(arTsl[i].scriptName() == sTsl){
      pntsMs.append(arTsl[i].ptOrg());
      int p = 0;
      while( Vector3d(arTsl[i].gripPoint(p) - pt).length() > 0 ){
        pntsMs.append(arTsl[i].gripPoint(p));
        p++;
      }
    }
  }
  if( pntsMs.length() == nNrOfPoints )return;
}
else if (sObject==sArObject[3]) {//Perimeter
	PlaneProfile ppEl = el.profBrutto(nZone);
	if( nZone == 0 ){
		PlaneProfile ppBm(csEl);
		for( int i=0;i<arBms.length();i++ ){
			Beam bm = arBms[i];
			ppBm.unionWith(bm.envelopeBody(false, true).shadowProfile(Plane(csEl.ptOrg(), csEl.vecZ())));
		}
		ppBm.shrink(-U(5));
		ppBm.shrink(U(5));
		ppEl = ppBm;
	}
	
	
	PLine arPlEl[] = ppEl.allRings();
	int arNRingIsOpening[] = ppEl.ringIsOpening();

	for(int i=0;i<arPlEl.length();i++){
		if( !arNRingIsOpening[i] ){
			pntsMs.append(arPlEl[i].vertexPoints(TRUE));
		}
	}
}
else if (sObject==sArObject[4]) {//Beam with beamcode
  GenBeam arGBmZn[0];	
  //Take all beams not only filtered
  GenBeam arGBmAll[] = el.genBeam();
  Point3d arPtBmCode[0];
  for(int i=0;i<arGBmAll.length();i++){
    GenBeam gBm = arGBmAll[i];
    if( arSDimBC.find(gBm.name("beamcode").token(0).makeUpper()) != -1 ){
      arGBmZn.append(gBm);
    }
    arPtBmCode.append( lnMs.collectDimPoints(arGBmZn,nSide) );
  }
  if( arPtBmCode.length() == 0 )
	return;
  pntsMs.append(arPtBmCode);
}
//else if (sObject==sArObject[4]) {//Beam with beamcode
//  //Take all beams not only filtered
//  GenBeam arGBmAll[] = el.genBeam();
//  for(int i=0;i<arGBmAll.length();i++){
//   GenBeam gBm = arGBmAll[i];
//    if( arSDimBC.find(gBm.name("beamcode").token(0)) != -1 ){
//      pntsMs.append( gBm.envelopeBody().allVertices() );
//    }
//  }
//}
else if (sObject==sArObject[5]) {//Beam with label/name
	GenBeam arGBmZn[0];
	//Take all beams not only filtered
	GenBeam arGBmAll[] = el.genBeam();
	for(int i=0;i<arGBmAll.length();i++){
		GenBeam gBm = arGBmAll[i];
		String sLabel = gBm.label();
		sLabel.makeUpper();
		String sName = gBm.name();
		sName.makeUpper();
		sName.trimLeft();
		sName.trimRight();
		if( arSDimLbl.find(sLabel) != -1 || arSDimLbl.find(sName) != -1 ){
			arGBmZn.append(gBm);
		}
	}
	pntsMs.append( lnMs.collectDimPoints(arGBmZn,nSide) );
}

// add special dim points to the dimline
if( sSpecial == "L1" ){ // linex add points at the top of roof elements
	Point3d arPtRafter[0];
	for( int i=0;i<arBmRafter.length();i++ ){
		Beam bmRafter = arBmRafter[i];
		Body bdRafter = bmRafter.envelopeBody(FALSE, TRUE);
		PlaneProfile ppRafter = bdRafter.extractContactFaceInPlane(pnBack, U(100));
		arPtRafter.append(ppRafter.getGripVertexPoints());	
	}
	
	Point3d arPtRafterY[] = lnY.projectPoints(arPtRafter);
	arPtRafterY = lnY.projectPoints(arPtRafterY);
	if( arPtRafterY.length() > 0 )
		pntsMs.append(arPtRafterY[arPtRafterY.length() - 1]);

	for( int i=0;i<arBms.length();i++ ){
		Beam bm = arBms[i];
		
		if( bm.beamCode().token(0) == "N" ){
			Point3d arPtBm[] = bm.envelopeBody().allVertices();
			Point3d arPtBmY[] = lnY.projectPoints(arPtBm);
			arPtBmY = lnY.orderPoints(arPtBm);
			if( arPtBmY.length() > 0 )
				pntsMs.append(arPtBmY[arPtBmY.length() - 1]);
		}
	}
}

for(int i=0;i<pntsMs.length();i++){
	Point3d pt = pntsMs[i];
	pt.transformBy(ms2ps);
	pt.vis(i);
}

//Offset to element. Different for each alignment 
double dxProj[] = {  -dDimOff,dDimOff,0,0};
double dyProj[] = { 0, 0, -dDimOff,dDimOff};
//Define line for projection of points.
Point3d ptProjectMs = pElZero - vx * dxProj[nAlignment] - vy * dyProj[nAlignment];
Point3d ptProjectPs = ptProjectMs;
ptProjectPs.transformBy(ms2ps);
Line lnPSProject (ptProjectPs,vDimX*nStartDim);
Line lnMSProject = lnPSProject;
lnMSProject.transformBy(ps2ms);

//Define line for sorting
Line lnPSSort (pel0,vDimX*nStartDim);
Line lnMSSort = lnPSSort;
lnMSSort.transformBy(ps2ms);

//Project points on one line.
//Order points. First point in array is start of cummulative dimensioning.
if(!nExtLines){
  pntsMs = lnMSProject.projectPoints(pntsMs);
}
pntsMs = lnMSSort.orderPoints(pntsMs);

Point3d arPtDimLine[0];
for(int i=0; i<(pntsMs.length() - 1);i++){
	Point3d ptThis = pntsMs[i];
	Point3d ptNext = pntsMs[i+1];
	if(i==0){
		arPtDimLine.append(ptThis);
	}
	double dBetweenPoints = (ptNext - ptThis).length();
	if( dBetweenPoints > dEps ){
		arPtDimLine.append(ptNext);
	}
}
pntsMs = arPtDimLine;


if( pntsMs.length() < 2 ){
	return;
}

//Start description of dimline
String sDescText = sObject;
if (sObject == sArObject[0]) sDescText = T("Element");
if (sObject == sArObject[1]) sDescText = el.zone(nZone).material();
if (sObject == sArObject[2]) sDescText = T("Tsl") + " - " + sTsl;
if (sObject == sArObject[4]) sDescText = sDimBeamCode;
if (nZone == 0 && sObject == sArObject[1]) sDescText = T("Beams");

if(sDescription != "") sDescText = sDescription;

if (vxps.isCodirectionalTo(vx)) {
  if (nAlignment < 2){
    dp.draw(sDescText,pel0 + dElemHeight * vyps,_YW,-_XW,-1*nTextSide,0);//vertical
  }
  else if (nAlignment < 4){
    dp.draw(sDescText,pel0 + dElemLength * vxps,_XW,_YW,-1*nTextSide,0);//horizontal
  }
}
else{
  if (nAlignment < 2){
    dp.draw(sDescText,pel0 + dElemHeight * vyps,_YW,-_XW,-1*nTextSide,0);//vertical
  }
  else if (nAlignment < 4){
    dp.draw(sDescText,pel0 + dElemLength * vxps,_XW,_YW,-1*nTextSide,0);//horizontal
  }
  else{
    dp.draw(sDescText,pel0 - U(200) * vxps,_XW,_YW,-1*nTextSide,0);
  }
}


Dim dim(lnMs,pntsMs,"<>","{<>}",nDimStyleDelta,nDimStyleCum); // def in MS
dim.transformBy(ms2ps); // transfrom the dim from MS to PS

Vector3d vReadDirection = -_XW + _YW;
if( nReadDirection == 1 )
	vReadDirection = -_YW + _XW;
dim.setReadDirection(vReadDirection);
dim.setDeltaOnTop(nDeltaOnTop);
dp.draw(dim); 


































#End
#BeginThumbnail
M_]C_X``02D9)1@`!`0```0`!``#__@`N26YT96PH4BD@2E!%1R!,:6)R87)Y
M+"!V97)S:6]N(%LQ+C4Q+C$R+C0T70#_VP!#`%`W/$8\,E!&049:55!?>,B"
M>&YN>/6ON9'(________________________________________________
M____VP!#`55:6GAI>.N"@NO_____________________________________
M____________________________________Q`&B```!!0$!`0$!`0``````
M`````0(#!`4&!P@)"@L0``(!`P,"!`,%!00$```!?0$"`P`$$042(3%!!A-1
M80<B<10R@9&A""-"L<$54M'P)#-B<H()"A87&!D:)28G*"DJ-#4V-S@Y.D-$
M149'2$E*4U155E=865IC9&5F9VAI:G-T=79W>'EZ@X2%AH>(B8J2DY25EI>8
MF9JBHZ2EIJ>HJ:JRL[2UMK>XN;K"P\3%QL?(R<K2T]35UM?8V=KAXN/DY>;G
MZ.GJ\?+S]/7V]_CY^@$``P$!`0$!`0$!`0````````$"`P0%!@<("0H+$0`"
M`0($!`,$!P4$!``!`G<``0(#$00%(3$&$D%1!V%Q$R(R@0@40I&AL<$)(S-2
M\!5B<M$*%B0TX27Q%Q@9&B8G*"DJ-38W.#DZ0T1%1D=(24I35%565UA96F-D
M969G:&EJ<W1U=G=X>7J"@X2%AH>(B8J2DY25EI>8F9JBHZ2EIJ>HJ:JRL[2U
MMK>XN;K"P\3%QL?(R<K2T]35UM?8V=KBX^3EYN?HZ>KR\_3U]O?X^?K_P``1
M"`&3`6@#`1$``A$!`Q$!_]H`#`,!``(1`Q$`/P!U;""@!4ZFDS2.P@Z"F1+=
MA0(*`"@`H`*`"@`H`*``]#0..Z%?J*2+EL)3,PH`*`"@`H`*`"@`H`*``?Q_
M2I6_S_1&T=D(.@HCLC)[BU0@H`*`"@`H`*`"@`H`1ONTG^J_,J'Q(DC_`./C
M_@!_F*3^'YE2Z?/]"Q69`4`%`!0`R3[H^H_F*3*CO]_Y#Z9(4`%`!0`4`5*V
M$%`"IU-)FD=A!T%,B6["@04`%`!0`4`%`!0`4`!Z&@<=T*_44D7+82F9A0`4
M`%`!0`4`%`!0`4``_C^E2M_G^B-H[(0=!1'9&3W%JA!0`4`%`!0`4`%`!0`C
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
0`!0`4`%`!0`4`%`!0`#_V04`
`



































#End
