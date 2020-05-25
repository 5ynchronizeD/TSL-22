#Version 8
#BeginDescription
Last modified by: OBOS (Oscar.ragnerby@obos.se)
OR - 1.13 - 31.10.2019 - Removed bärlina from the vertical beams to check for interference









#End
#Type O
#NumBeamsReq 0
#NumPointsGrip 0
#DxaOut 1
#ImplInsert 1
#FileState 1
#MajorVersion 1
#MinorVersion 13
#KeyWords 
#BeginContents
/// <summary Lang=en>
/// Draw the single insulation between two studs. Aslo adds CDT information to the wall
/// </summary>

/// <insert>
/// Inserted by the MYR-Insulation tsl. Its also possible to insert it manually
/// </insert>

/// <remark Lang=en>
/// .
/// </remark>

/// <version  value="1.13" date="31.10.2019"></version>

/// <history>
/// AS - 1.00 - 22.08.2006 -	Pilot version
/// AS - 1.01 - 23.08.2006 -	Assign to zone 10 of the element
/// AS - 1.02 - 23.08.2006 -	Implement insert in this tsl
/// AS - 1.03 - 09.10.2008 -	Insulation erased if its not the full height
/// AS - 1.04 - 23.10.2008 -	Bug-fix on previous change; Align insulation to centre of element
/// AS - 1.05 - 24.10.2008 -	Both beams must touch bottom- and top plate
/// AS - 1.06 - 24.02.2009 -	Add PLines used for hatching in layout
/// AS - 1.07 - 20.05.2009 -	Store state in dwg, no recalc at dwg-in
/// AS - 1.08 - 28.09.2009 -	Add a material to the elemItem -> exported to database
/// AS - 1.09 - 30.09.2009 -	Change insulation name
/// AS - 1.10 - 02.10.2009 -	Draw hatch in display representation, with option to show the hatch or not
/// AS - 1.11 - 31.01.2011 -	Only use non-vertical beams while finding the top- and bottomplate
/// AS - 1.12 - 12.06.2018 -	Add BOM Link data.
/// OR - 1.13 - 31.10.2019 -	Removed bärlina from the vertical beams to check for interference
/// </history>

double dEps = Unit(.01, "mm");

String sVersion = _ThisInst.version();

PropInt nColor(0,3,T("Color"));
PropInt nColorHatch(1, 3, T("|Color hatch|"));

String arSMaterial[] = {
	"Isolering240"
};
PropString sMaterial(0, arSMaterial, T("|Material|"));

PropString sDispRepHatch(1, _ThisInst.dispRepNames() , T("Show hatch in display representation"));
String arSYesNo[] = {T("|Yes|"), T("|No|")};
int arNYesNo[] = {_kYes, _kNo};
PropString sShowHatch(2, arSYesNo, T("|Show hatch|"));


if( _bOnInsert ){
	_Element.append(getElement(T("Select an element")));
	
	_Beam.append(getBeam(T("Select beam on the left")));
	_Beam.append(getBeam(T("Select beam on the right")));
	
	showDialog();
	return;
}

int nShowHatch = arNYesNo[arSYesNo.find(sShowHatch,0)];

if( _Element.length() == 0 )return;
Element el = _Element[0];
CoordSys csEl = el.coordSys();
Point3d ptEl = csEl.ptOrg();
Vector3d vxEl=el.vecX();
Vector3d vyEl=el.vecY();
Vector3d vzEl=el.vecZ();

// displays
Display dp(nColor);
Display dpHatch(nColorHatch);
dpHatch.showInDispRep(sDispRepHatch);


if( _Beam.length() != 2 ) return;
Beam bmPrev = _Beam[0];
Beam bmThis = _Beam[1];

Body  bdBmPrev = bmPrev.envelopeBody(false, true);
Body  bdBmThis = bmThis.envelopeBody(false, true);
	
Point3d ptLeft = bmPrev.ptCen() + vxEl * .5 * bmPrev.dD(vxEl);
Point3d ptRight = bmThis.ptCen() - vxEl * .5 * bmThis.dD(vxEl);

/*
TL = Top Left
BL = Bottom left
TR = Top Right
BR = Bottom Right
*/
Point3d ptTL = ptLeft + vyEl * .5 * bdBmPrev.lengthInDirection(vyEl); 
Point3d ptBL = ptLeft - vyEl * .5 * bdBmPrev.lengthInDirection(vyEl); 
Point3d ptBR = ptRight - vyEl * .5 * bdBmThis.lengthInDirection(vyEl);
Point3d ptTR = ptRight + vyEl * .5 * bdBmThis.lengthInDirection(vyEl);

ptTL.vis(1);

Beam arBm[] = el.beam();
Beam arBmNotVertical[0];
for( int i=0;i<arBm.length();i++ ){
	Beam bm = arBm[i];
	if( abs(abs(bm.vecX().dotProduct(vyEl)) - 1 ) < dEps || bm.grade() == "Bärlina")
		continue;
	
	 arBmNotVertical.append(bm);
}
Beam arBmIntersectTL[] = Beam().filterBeamsHalfLineIntersectSort(arBmNotVertical, ptTL, vyEl);
Beam arBmIntersectTR[] = Beam().filterBeamsHalfLineIntersectSort(arBmNotVertical, ptTR, vyEl);
Beam arBmIntersectBL[] = Beam().filterBeamsHalfLineIntersectSort(arBmNotVertical, ptBL, -vyEl);
Beam arBmIntersectBR[] = Beam().filterBeamsHalfLineIntersectSort(arBmNotVertical, ptBR, -vyEl);

if( (arBmIntersectTL.length() * arBmIntersectTL.length() * arBmIntersectTL.length() * arBmIntersectTL.length()) == 0 ){
	reportWarning(TN("|No intersecting beams found on all four corners!|"));
	return;
}

Beam bmTL = arBmIntersectTL[0];
bmTL.envelopeBody(false, true).vis(1);
Beam bmTR = arBmIntersectTR[0];
Beam bmBL = arBmIntersectBL[0];
Beam bmBR = arBmIntersectBR[0];

int arNTopPlate[] = {
	_kSFTopPlate
};
int arNBottomPlate[] = {
	_kSFBottomPlate
};

int bTopPlateFound = FALSE;
if( arNTopPlate.find(bmTL.type()) != -1 && arNTopPlate.find(bmTR.type()) != -1 ){
	bTopPlateFound = TRUE;
}
if( !bTopPlateFound ){
	reportMessage(T("|No top plate found. Insulation is not the full height!|"));
	eraseInstance();
}
int bBottomPlateFound = FALSE;
if( arNBottomPlate.find(bmBL.type()) != -1 && arNBottomPlate.find(bmBR.type()) != -1 ){
	bBottomPlateFound = TRUE;
}
if( !bBottomPlateFound ){
	reportMessage(T("|No bottom plate found. Insulation is not the full height!|"));
	eraseInstance();
}

double dElBmWidth = el.dBeamWidth();
Plane pnEl(el.ptOrg() - vzEl * .5 * dElBmWidth, vzEl);
PLine plFoamBLtoTR(ptBL, ptTR);
plFoamBLtoTR.projectPointsToPlane(pnEl, vzEl);
PLine plFoamBRtoTL(ptBR, ptTL);
plFoamBRtoTL.projectPointsToPlane(pnEl, vzEl);
dp.draw(plFoamBLtoTR);
dp.draw(plFoamBRtoTL);

_Pt0 = ptBL;

double dWFoam = vxEl.dotProduct(ptBR - ptBL);
double dHFoam = vyEl.dotProduct(ptTL - ptBL);

Map mapFoam;
mapFoam.setString("Version", sVersion);
mapFoam.setDouble("DX",dWFoam);
mapFoam.setDouble("DY",dHFoam);
mapFoam.setString("MATERIAL", sMaterial);

Map mapXFoam;
mapXFoam.setString("Material", sMaterial);
mapXFoam.setDouble("Width",dWFoam);
mapXFoam.setDouble("Height",dHFoam);
Map mapBomLink;
mapBomLink.setMap("Insulation", mapXFoam);
_ThisInst.setSubMapX("Hsb_BomLink", mapBomLink);

ElemItem ItemFoam(0,"INSULATION",ptBL,vxEl,mapFoam);
ItemFoam.setShow(_kNo);
el.addTool(ItemFoam);

//Create PLines for hatching in layout
PLine plFoamSide(vxEl);
plFoamSide.addVertex(_Pt0 + vzEl * .5 * dElBmWidth);
plFoamSide.addVertex(_Pt0 - vzEl * .5 * dElBmWidth);
plFoamSide.addVertex(_Pt0 - vzEl * .5 * dElBmWidth + vyEl * dHFoam);
plFoamSide.addVertex(_Pt0 + vzEl * .5 * dElBmWidth +vyEl * dHFoam);
plFoamSide.close();
//dp.draw(plFoamSide);
_Map.setPLine("SIDE", plFoamSide);

PLine plFoamTop(vyEl);
plFoamTop.addVertex(_Pt0 + vzEl * .5 * dElBmWidth);
plFoamTop.addVertex(_Pt0 - vzEl * .5 * dElBmWidth);
plFoamTop.addVertex(_Pt0 - vzEl * .5 * dElBmWidth + vxEl * dWFoam);
plFoamTop.addVertex(_Pt0 + vzEl * .5 * dElBmWidth +vxEl * dWFoam);
plFoamTop.close();
//dp.draw(plFoamTop);
_Map.setPLine("TOP", plFoamTop);

if( nShowHatch ){
	// draw hatch
	PLine plHatch = plFoamTop;
	
	Vector3d vxHatch = vxEl;
	Vector3d vyHatch = -vzEl;
	Line lnXHatch(ptEl, vxHatch);
	Line lnYHatch(ptEl, vyHatch);
	 
	Point3d arPtHatch[] = plHatch.vertexPoints(TRUE);
	Point3d arPtHatchX[] = lnXHatch.orderPoints(arPtHatch);
	Point3d arPtHatchY[] = lnYHatch.orderPoints(arPtHatch);
	Point3d ptBLHatch = arPtHatchX[0] + vyHatch * vyHatch.dotProduct(arPtHatchY[0] - arPtHatchX[0]);
	Point3d ptTRHatch = arPtHatchX[arPtHatchX.length() -1] + vyHatch * vyHatch.dotProduct(arPtHatchY[arPtHatchY.length() -1] - arPtHatchX[arPtHatchX.length() -1]);
	double dHInsulation = vyHatch.dotProduct(ptTRHatch - ptBLHatch);
	double dLInsulation = vxHatch.dotProduct(ptTRHatch - ptBLHatch);
	double dRadiusHatch = .125 * dHInsulation;
	PLine plSingleInsulation(_ZW);
	plSingleInsulation.addVertex(ptBLHatch);
	plSingleInsulation.addVertex(ptBLHatch + vxHatch * .125 * dHInsulation + vyHatch * .125 * dHInsulation, dRadiusHatch, _kCCWise);
	plSingleInsulation.addVertex(ptBLHatch + vxHatch * .125 * dHInsulation + vyHatch * .875 * dHInsulation);
	plSingleInsulation.addVertex(ptBLHatch + vxHatch * .250 * dHInsulation + vyHatch * dHInsulation, dRadiusHatch, _kCWise);
	//		plSingleInsulation.addVertex(ptBLHatch + vxHatch * .375 * dHInsulation + vyHatch * .125 * dHInsulation);
	//		plSingleInsulation.addVertex(ptBLHatch + vxHatch * .500 * dHInsulation, dRadiusHatch, _kCCWise);
	
	double dNrOfLoops = dLInsulation/(.25*dHInsulation);
	int nNrOfLoops = dNrOfLoops;
	
	double dFirstTransformation = (dLInsulation - (nNrOfLoops * .25 * dHInsulation))/2;
	plSingleInsulation.transformBy(vxHatch * dFirstTransformation);
	
	for( int j=0;j<nNrOfLoops;j++ ){
		dpHatch.draw(plSingleInsulation);
		
		// coordinate system to swap
		CoordSys csSwap;
		csSwap.setToRotation(180, vxHatch, ptBLHatch + vyHatch * .5 * dHInsulation);		
		// move to next location
		plSingleInsulation.transformBy(vxHatch * .25 * dHInsulation);
		// swap the pline
		plSingleInsulation.transformBy(csSwap);
	}	
}	

assignToElementGroup(el, TRUE, -5, 'Z');

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
  <lst nm="TslInfo" />
  <unit ut="L" uv="millimeter" />
  <unit ut="A" uv="radian" />
</Hsb_Map>
#End