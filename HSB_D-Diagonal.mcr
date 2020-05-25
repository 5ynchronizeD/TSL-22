#Version 8
#BeginDescription
Last modified by: Anno Sportel (anno.sportel@itwindustry.nl)
18.02.2013  -  version 1.02
































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
/// 
/// </summary>

/// <insert>
/// 
/// </insert>

/// <remark Lang=en>
/// 
/// </remark>

/// <version  value="1.02" date="18.02.2013"></version>

/// <history>
/// AS - 1.00 - 05.02.2013 -	Pilot version
/// AS - 1.01 - 13.02.2013 -	Increase margin to 5 mm
/// AS - 1.02 - 18.02.2013 -	Make margin available as property.
/// </history>

//Script uses mm
double dEps = U(.001,"mm");

int nLog = 0;

String arSYesNo[] = {T("|Yes|"), T("|No|")};
int arNYesNo[] = {_kYes, _kNo};

// ---------------------------------------------------------------------------------
PropString sSeperator01(0, "", T("|Selection|"));
sSeperator01.setReadOnly(true);

PropString sFilterBC(1,"","     "+T("|Filter beams with beamcode|"));

PropString sFilterLabel(2,"","     "+T("|Filter beams/sheets with label/material|"));

PropString sFilterZone(3, "1;7", "     "+T("|Filter zones|"));

// ---------------------------------------------------------------------------------
PropString sSeperator02(4, "", T("|Diagonal dimension|"));
sSeperator02.setReadOnly(true);

String sArDimensionMethod[]={T("|As arrow|"), T("|As dimensionline|")};
PropString sDimensionMethod(5,sArDimensionMethod,"     "+T("|Show dimension|"));
PropDouble dCornerMargin(3, U(25), "     "+T("|Allowed offset for corners|"));

String arSPosition[] = {
	T("|Automatic|"),
	T("|From bottom|-")+T("|left|"),
	T("|From bottom|-")+T("|right|")
};
PropString sPosition(6,arSPosition,"     "+T("Position dimensionline|"));
sPosition.setDescription(	T("|The position for the diagonal dimension.|")+ 
								TN("|If 'Automatic' is selected, the script will try to place a line from bottom-right to top-left.|")+
								TN("|If the element has an angle at the top-left it will try to place a dimension from bottom-left to top-right.|")+
								TN("|If the top-right is also angled it will place both of the lines.|"));

PropString sDimStyle(7, _DimStyles, "     "+T("|Dimension style|"));

String sArDimLayout[] ={
	T("|Delta perpendicular|"),
	T("|Delta parallel|"),
	T("|Cummulative perpendicular|"),
	T("|Cummulative parallel|"),
	T("|Both perpendicular|"),
	T("|Both parallel|"),
	T("|Delta parallel, cummulative perpendicular|"),
	T("|Delta perpendicular, cummulative parallel|")
};
int nArDimLayoutDelta[] = {_kDimPerp, _kDimPar,_kDimNone,_kDimNone,_kDimPerp,_kDimPar,_kDimPar,_kDimPerp};
int nArDimLayoutCum[] = {_kDimNone,_kDimNone,_kDimPerp, _kDimPar,_kDimPerp,_kDimPar,_kDimPerp,_kDimPar};
//PropString sDimLayout(8,sArDimLayout,"     "+T("|Dimension layout|"));

//Used to set the side of the text.
String arSDeltaOnTop[]={T("|Above|"), T("|Below|")};
int arNDeltaOnTop[]={true, false};
//PropString sDeltaOnTop(9,arSDeltaOnTop,"     "+T("|Position delta dimension|"),0);

PropInt nPrecision(0, 0, "     "+T("|Precision|"));

PropDouble dArrowLength(0, U(300), "     "+T("|Arrow length|"));

PropDouble dxOffsetTxt(1, U(50), "     "+T("|X-Offset dimension|"));
PropDouble dyOffsetTxt(2, U(15), "     "+T("|Y-Offset dimension|"));

PropInt nDimColor(1, 1, "     "+T("|Color dimension|"));
PropInt nArrowColor(2, 3, "     "+T("|Color arrow|"));

PropString sSeperator03(8, "", T("|Setup|"));
sSeperator03.setReadOnly(true);
PropString sShowScriptName(9, arSYesNo, "     "+T("|Draw scriptname|"));
PropString sAssignToLayer(10, "", "     "+T("|Draw scriptname on layer|"));
sAssignToLayer.setDescription(T("|The name of the script is drawn on the specified layer. It is ignored if the name is empty.|"));
PropInt nNameColor(3, -1, "     "+T("|Color scriptname|"));

String arSTrigger[] = {
	T("|Filter this element|"),
	"     ----------",
	T("|Remove filter for this element|"),
	T("|Clear filter for all elements|")
};
for( int i=0;i<arSTrigger.length();i++ )
	addRecalcTrigger(_kContext, arSTrigger[i] );

if( _bOnDbCreated && _kExecuteKey != "" )
	setPropValuesFromCatalog(_kExecuteKey);

//Insert
if( _bOnInsert ){
	//Erase after 1 cycle
	if( insertCycleCount() > 1 ){
		eraseInstance();
		return;
	}
	
	_Viewport.append(getViewport(TN("|Select a viewport|")));
	_Pt0 = getPoint(T("|Select a position|"));

	//Showdialog
	if (_kExecuteKey=="")
		showDialog();
	
	return;
}

//Is there a viewport selected
if( _Viewport.length()==0 ){
	eraseInstance();
	return;
}
Viewport vp = _Viewport[0];

int bShowScriptName = arNYesNo[arSYesNo.find(sShowScriptName,0)];
if( bShowScriptName ){
	Display dpName(nNameColor);
	String sLayer = sAssignToLayer;
	sLayer.trimLeft();
	sLayer.trimRight();
	if( sLayer.length() > 0 )
		dpName.layer(sLayer);
	dpName.textHeight(U(5));
	dpName.draw(_ThisInst.scriptName(), _Pt0, _XW, _YW, 1, 1);
}
// check if the viewport has hsb data
Element el = vp.element();
if( !el.bIsValid() )
	return;

// Add filteer
if( _kExecuteKey == arSTrigger[0] ){
	Map mapFilterElements;
	if( _Map.hasMap("FilterElements") )
		mapFilterElements = _Map.getMap("FilterElements");
	
	mapFilterElements.setString(el.handle(), "Element Filter");
	_Map.setMap("FilterElements", mapFilterElements);
}

// Remove single filteer
if( _kExecuteKey == arSTrigger[2] ){
	Map mapFilterElements;
	if( _Map.hasMap("FilterElements") ){
		mapFilterElements = _Map.getMap("FilterElements");
		
		if( mapFilterElements.hasString(el.handle()) )
			mapFilterElements.removeAt(el.handle(), true);
		_Map.setMap("FilterElements", mapFilterElements);
	}
}

// Remove all filteer
if( _kExecuteKey == arSTrigger[3] ){
	if( _Map.hasMap("FilterElements") )
		_Map.removeAt("FilterElements", true);
}

Map mapFilterElements;
if( _Map.hasMap("FilterElements") )
	mapFilterElements = _Map.getMap("FilterElements");
if( mapFilterElements.hasString(el.handle()) )
	return;

//Element coordSys
//CoordSys csEl = el.coordSys();
//Point3d ptEl = csEl.ptOrg();
//Vector3d vxEl = csEl.vecX();
//Vector3d vyEl = csEl.vecY();
//Vector3d vzEl = csEl.vecZ();


//Coordinate system
CoordSys ms2ps = vp.coordSys();
CoordSys ps2ms = ms2ps; ps2ms.invert(); // take the inverse of ms2ps
double dVpScale = ps2ms.scale();

Display dpDim(nDimColor);
dpDim.dimStyle(sDimStyle, dVpScale); // dimstyle was adjusted for display in paper space, sets textHeight

Display dpArrow(nArrowColor);

// resolve props
// selection
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
int arNFilterZone[0];
int nIndex = 0;
String sZones = sFilterZone + ";";
int nToken = 0;
String sToken = sZones.token(nToken);
while( sToken != "" ){
	int nZn = sToken.atoi();
	if( nZn == 0 && sToken != "0" ){
		nToken++;
		sToken = sZones.token(nToken);
		continue;
	}
	if( nZn > 5 )
		nZn = 5 - nZn;	
	arNFilterZone.append(nZn);
	
	nToken++;
	sToken = sZones.token(nToken);
}
// dimension
int nDimensionMethod = sArDimensionMethod.find(sDimensionMethod,0);
int nPosition = arSPosition.find(sPosition,0);
//int nDimLayoutDelta = nArDimLayoutDelta[sArDimLayout.find(sDimLayout,0)];
//int nDimLayoutCum = nArDimLayoutCum[sArDimLayout.find(sDimLayout,0)];
//int nDeltaOnTop = arNDeltaOnTop[arSDeltaOnTop.find(sDeltaOnTop,0)];

Point3d ptMs = _Pt0;
ptMs.transformBy(ps2ms);
Vector3d vxMs = _XW;
vxMs.transformBy(ps2ms);
vxMs.normalize();
Vector3d vyMs = _YW;
vyMs.transformBy(ps2ms);
vyMs.normalize();
Vector3d vzMs = _ZW;
vzMs.transformBy(ps2ms);
vzMs.normalize();

CoordSys csMs(ptMs, vxMs, vyMs, vzMs);

Plane pnZMs(ptMs, vzMs);

//Vector3d vxDim = _XW;
//vxDim.transformBy(ps2ms);
//vxDim.normalize();
//Vector3d vyDim = _YW;
//vyDim.transformBy(ps2ms);
//vyDim.normalize();
//Vector3d vzDim = _ZW;
//vzDim.transformBy(ps2ms);
//vzDim.normalize();

TslInst tslSection;
GenBeam arGBmAll[0];
if( !tslSection.bIsValid() )
	arGBmAll = el.genBeam(); // collect all
else{
	Map mapTsl = tslSection.map();
	for( int i=0;i<mapTsl.length();i++ ){
		if( mapTsl.keyAt(i) == "GENBEAM" ){
			Entity entGBm = mapTsl.getEntity(i);
			GenBeam gBm = (GenBeam)entGBm;
			arGBmAll.append(gBm);
		}
	}
}

if( arGBmAll.length() == 0 )
	return;

Beam arBm[0];
Sheet arSh[0];
for( int i=0;i<arGBmAll.length();i++ ){
	GenBeam gBm = arGBmAll[i];
	Beam bm = (Beam)gBm;
	Sheet sh = (Sheet)gBm;
	
	Body bdGBm = gBm.realBody();//gBm.envelopeBody(false, true);//
	if( bdGBm.volume() < U(1) )
		continue;
	
	// apply filters
	String sBmCode = gBm.beamCode().token(0);
	String sMaterial = gBm.material();
	String sLabel = gBm.label();
	int nZnIndex = gBm.myZoneIndex();
	if( arSFBC.find(sBmCode) != -1 )
		continue;
	if( arSFLabel.find(sMaterial) != -1 )
		continue;
	if( arSFLabel.find(sLabel) != -1 )
		continue;
	if( arNFilterZone.find(nZnIndex) != -1 )
		continue;
	
	if( sh.bIsValid() ){
		arSh.append(sh);
	}
	else if( bm.bIsValid() ){	
		arBm.append(bm);
	}
}


PlaneProfile ppBeams(csMs);
for( int i=0;i<arBm.length();i++ ){
	Beam bm = arBm[i];
	
	ppBeams.unionWith(bm.envelopeBody(false, true).shadowProfile(pnZMs));
}
ppBeams.shrink(-U(10));
ppBeams.shrink(U(10));

PlaneProfile ppBrutto(csMs);
PLine arPlBeams[] = ppBeams.allRings();
double dMaxArea = 0;
PLine plBeam(vzMs);
for( int i=0;i<arPlBeams.length();i++ ){
	PLine pl = arPlBeams[i];
	if( pl.area() > dMaxArea ){
		dMaxArea = pl.area();
		plBeam = pl;
	}
}

if( dMaxArea > 0 )
	ppBrutto.joinRing(plBeam, _kAdd);
ppBrutto.vis(5);

// = el.profBrutto(0);
Point3d arPtProfBrutto[] = ppBrutto.getGripVertexPoints();
int nArSquaredCorner[0];
// 10 = Bottom left
// 20 = Bottom right
// 30 = Top right
// 40 = Top left
if( arPtProfBrutto.length() > 2 ){
	arPtProfBrutto.append(arPtProfBrutto[0]);
	arPtProfBrutto.append(arPtProfBrutto[1]);
	
	for( int i=1;i<(arPtProfBrutto.length() - 1);i++ ){
		Point3d ptPrev = arPtProfBrutto[i-1];
		Point3d ptThis = arPtProfBrutto[i];
		Point3d ptNext = arPtProfBrutto[i+1];
		
		Vector3d vToPrev(ptPrev - ptThis);
		double dxToPrev = vToPrev.dotProduct(vxMs);
		double dyToPrev = vToPrev.dotProduct(vyMs);
		vToPrev.normalize();

		Vector3d vToNext(ptNext - ptThis);
		double dxToNext = vToNext.dotProduct(vxMs);
		double dyToNext = vToNext.dotProduct(vyMs);
		vToNext.normalize();
		
		Vector3d vOut = -(vToPrev + vToNext);
		vOut.normalize();
		
		double dxOut = vxMs.dotProduct(vOut);
		double dyOut = vyMs.dotProduct(vOut);
		
		double dAngleOut = atan(dyOut/dxOut);
		if( abs(abs(dAngleOut) - 45) > dEps )
			continue;
		
		if( dxOut > 0 ){ // Right
			if( dyOut < 0 ){ // Bottom
				nArSquaredCorner.append(20);
				if( nLog == 1 )
					reportNotice("\nBR");
			}
			else{ // Top
				nArSquaredCorner.append(30);
				if( nLog == 1 )
					reportNotice("\nTR");
			}
		}
		else{
			if( dyOut < 0 ){ // Bottom
				nArSquaredCorner.append(10);
				if( nLog == 1 )
					reportNotice("\nBL");
			}
			else{ // Top
				nArSquaredCorner.append(40);
				if( nLog == 1 )
					reportNotice("\nTL");
			}
		}
	}	
}

for(int s1=1;s1<nArSquaredCorner.length();s1++){
	int s11 = s1;
	for(int s2=s1-1;s2>=0;s2--){
		if( nArSquaredCorner[s11] < nArSquaredCorner[s2] ){
			nArSquaredCorner.swap(s2, s11);
			s11=s2;
		}
	}
}

Line lnXMs(ptMs, vxMs);
Line lnYMs(ptMs, vyMs);

Point3d arPtProfBruttoX[] = lnXMs.orderPoints(arPtProfBrutto);
Point3d arPtProfBruttoY[] = lnYMs.orderPoints(arPtProfBrutto);
if( arPtProfBruttoX.length() < 2 || arPtProfBruttoY.length() < 2 )
	return;

Point3d arPtTop[] = {arPtProfBruttoY[arPtProfBruttoY.length() - 1]};
for( int i=(arPtProfBruttoY.length() - 2);i>=0;i-- ){
	Point3d pt = arPtProfBruttoY[i];
	double d = abs(vyMs.dotProduct(pt - arPtTop[0]));
	if( abs(vyMs.dotProduct(pt - arPtTop[0])) < dCornerMargin )
		arPtTop.append(pt);
	else
		break;
}
arPtTop = lnXMs.orderPoints(arPtTop);
if( arPtTop.length() < 2 )
	return;

Point3d ptTL = arPtTop[0];
Point3d ptTR = arPtTop[arPtTop.length() - 1];

Point3d arPtBottom[] = {arPtProfBruttoY[0]};
for( int i=1;i<arPtProfBruttoY.length();i++ ){
	Point3d pt = arPtProfBruttoY[i];
	if( abs(vyMs.dotProduct(pt - arPtBottom[0])) < dCornerMargin )
		arPtBottom.append(pt);
	else
		break;
}
arPtBottom = lnXMs.orderPoints(arPtBottom);
if( arPtBottom.length() < 2 )
	return;

Point3d ptBL = arPtBottom[0];
Point3d ptBR = arPtBottom[arPtBottom.length() - 1];

int bDimBR2TL = false;
int bDimBL2TR = false;
if( nPosition == 0 ){ // Automatic, first try BR - to TL, then BL to TR
	if( nArSquaredCorner.find(20) != -1 && nArSquaredCorner.find(40) != -1 ){
		bDimBR2TL = true;
	}
	else if( nArSquaredCorner.find(10) != -1 && nArSquaredCorner.find(30) != -1 ){
		bDimBL2TR = true;
	}
	else{
		bDimBR2TL = true;
		bDimBL2TR = true;
	}		
}
else if( nPosition == 1 ){ // Bottom-left to top-right
	bDimBL2TR = true;
}
else if( nPosition == 2 ){ // Bottom-right to top-left
	bDimBR2TL = true;
}

Point3d arPtDim[0];
if( bDimBR2TL ){
	arPtDim.append(ptBR);
	arPtDim.append(ptTL);
	Vector3d vxDim(ptBR - ptTL);
	vxDim.normalize();
	Vector3d vyDim = vzMs.crossProduct(vxDim);
	
	if( nDimensionMethod == 0 ){
		PLine plArrowHead(vzMs);
		plArrowHead.addVertex(ptBR);
		plArrowHead.addVertex(ptBR + vxDim * 0.125 * dArrowLength + vyDim * 0.03125 * dArrowLength);
		plArrowHead.addVertex(ptBR + vxDim * 0.125 * dArrowLength - vyDim * 0.03125 * dArrowLength);
		plArrowHead.close();
		PlaneProfile ppArrowHead(csMs);
		ppArrowHead.joinRing(plArrowHead, _kAdd);
		
		ppArrowHead.transformBy(ms2ps);
		dpArrow.draw(ppArrowHead, _kDrawFilled);
		
	}
	else{
		DimLine dimLine(ptTL, vxDim, vyDim);
		Dim dim(dimLine, arPtDim, "", "", _kDimNone, _kDimNone);
		dim.transformBy(ms2ps);
		
		dpDim.draw(dim);
	}
	
	PLine plArrow(ptBR, ptBR + vxDim * dArrowLength);
	plArrow.transformBy(ms2ps);
	dpArrow.draw(plArrow);
	
	double dDim = abs(vxDim.dotProduct(ptBR - ptTL));
	String sDim;
	sDim.formatUnit(dDim, 2, nPrecision);
	
	Point3d ptDimTxt = ptBR + vxDim * dxOffsetTxt + vyDim * dyOffsetTxt;
	ptDimTxt.transformBy(ms2ps);
	Vector3d vxDimTxt = vxDim;
	vxDimTxt.transformBy(ms2ps);
	Vector3d vyDimTxt = vyDim;
	vyDimTxt.transformBy(ms2ps);
	dpDim.draw(sDim, ptDimTxt, vxDimTxt, vyDimTxt, 1, 1);
}

if( bDimBL2TR ){
	arPtDim.append(ptBL);
	arPtDim.append(ptTR);
	Vector3d vxDim(ptTR - ptBL);
	vxDim.normalize();
	Vector3d vyDim = vzMs.crossProduct(vxDim);
	
	if( nDimensionMethod == 0 ){
		PLine plArrowHead(vzMs);
		plArrowHead.addVertex(ptBL);
		plArrowHead.addVertex(ptBL - vxDim * 0.125 * dArrowLength + vyDim * 0.03125 * dArrowLength);
		plArrowHead.addVertex(ptBL - vxDim * 0.125 * dArrowLength - vyDim * 0.03125 * dArrowLength);
		plArrowHead.close();
		PlaneProfile ppArrowHead(csMs);
		ppArrowHead.joinRing(plArrowHead, _kAdd);
		
		ppArrowHead.transformBy(ms2ps);
		dpArrow.draw(ppArrowHead, _kDrawFilled);
		
	}
	else{
		DimLine dimLine(ptBL, vxDim, vyDim);
		Dim dim(dimLine, arPtDim, "", "", _kDimNone, _kDimNone);
		dim.transformBy(ms2ps);
		
		dpDim.draw(dim);
	}
	
	PLine plArrow(ptBL, ptBL - vxDim * dArrowLength);
	plArrow.transformBy(ms2ps);
	dpArrow.draw(plArrow);
	
	double dDim = abs(vxDim.dotProduct(ptBL - ptTR));
	String sDim;
	sDim.formatUnit(dDim, 2, nPrecision);
	
	Point3d ptDimTxt = ptBL - vxDim * dxOffsetTxt + vyDim * dyOffsetTxt;
	ptDimTxt.transformBy(ms2ps);
	Vector3d vxDimTxt = vxDim;
	vxDimTxt.transformBy(ms2ps);
	Vector3d vyDimTxt = vyDim;
	vyDimTxt.transformBy(ms2ps);
	dpDim.draw(sDim, ptDimTxt, vxDimTxt, vyDimTxt, -1, 1);
}






#End
#BeginThumbnail
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
M**`"BBB@`HHHH`****`"BBB@`HHHH`****`"BBB@`HHHH`****`"BBB@`HHH
MH`****`"BBB@`HHHH`****`"BBB@`I"H(P>E+10!6-J$Y@<Q_P"R!E?R_P`,
M4?:)(N)X\#^^G(_Q%6:3`]*FW8GE[#4E210R,&4]P:?5=[5&<NN4<_Q)P?Q]
M?QIN^XB^\OFKZKP?RHOW"[6Y:HJ**=)B=K<CJ#P1]14M5<:=PHHHH&%%%%`!
M1110`4444`%%%%`!1110`4444`%%%%`!1110`4444`%%%%`!1110`4444`%%
M%%`!1110`4444`%%%%`!1110`4444`%%%%`!1110`4444`%%%%`!1110!%+;
MQRG++R.C#@CZ&HMEQ#]UA*OHW#?GW_SS5JBE83BB".YC9MC91_[K#!_#U_"I
MLBFO$DBE74,#V(J#R)8AF&4X_N/R/SZC]:-4+5%JBJPN@G$Z&,^IY4_C_C5@
M$&A.XTTQ:***8PHHHH`****`"BBB@`HHHH`****`"BBB@`HHHH`****`"BBB
M@`HHHH`****`"BBB@`HHHH`****`"BBB@`HHHH`****`"BBB@`HHHH`****`
M"BBB@`HHHH`****`$*@C!JN;78<P,8SZ#E?R_P`*LT4FDQ-)A1113&%%%%`!
M1110`4444`%%%%`!1110`4444`%%%%`!1110`4444`%%%%`!1110`4444`%%
M%%`!1110`4444`%%%%`!1110`4444`%%%%`!1110`4444`%%%%`!1110`444
$4`?_V110
`






#End