#Version 8
#BeginDescription
Last modified by: Anno Sportel (as@hsb-cad.com)
18.03.2009  -  version 1.5























#End
#Type O
#NumBeamsReq 0
#NumPointsGrip 0
#DxaOut 0
#ImplInsert 1
#FileState 1
#MajorVersion 1
#MinorVersion 5
#KeyWords BOM, labels in paperspace
#BeginContents
/*
*  COPYRIGHT
*  ---------------
*  Copyright (C) 2009 by
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
* date: 03.02.2009
* version 1.0: 	Pilot version
* date: 17.03.2009
* version 1.1: 	Performance update (analyze each element seperately)
* version 1.2: 	Will not be numbered and exported
* version 1.3: 	Align beam text with beam-axis
* date: 18.03.2009
* version 1.4: 	Only show numbers of some tsls (see list at top of this tsl)
*				Location of steel beam is invalid area
*				Do not show duplicate numbers/labels if sheets are within 50 mm of each other.
* version 1.5: 	Only add floor beams to first element
*
*/

Unit (1,"mm");//script uses mm

//Only show numbers of tsls if their name is in this list
String arSShowNumberOfTheseTsls[] = {
	"Byggma-Nibbo",
	"Byggma-Hanger"
};

//Invalid position fro numbering
String arSBmCodeSteelBm[] = {
	"SD1"
};

//Properties
//Select dimstyle
PropString sDimStyle(0, _DimStyles, T("|Dimension style|"));

//PropDouble dTextHeightNumbers(0, U(50), T("|Textheight numbering|"));
//PropDouble dTextHeightLabels(1, U(75), T("|Textheight labels|"));

PropInt nColorNumbers(0, -1, T("|Color numbers|"));
PropInt nColorLabels(1, 1, T("|Color numbers|"));

String arSYesNo[] = {T("|Yes|"), T("|No|")};
int arNYesNo[] = {_kYes, _kNo};
//Number
PropString sNumberBeams(1, arSYesNo, T("|Number beams|"));
int bNumberBeams = arNYesNo[arSYesNo.find(sNumberBeams, 0)];
PropString sNumberSheets(2, arSYesNo, T("|Number sheets|"));
int bNumberSheets = arNYesNo[arSYesNo.find(sNumberSheets, 0)];
PropString sNumberTsls(3, arSYesNo, T("|Number tsls|"));
int bNumberTsls = arNYesNo[arSYesNo.find(sNumberTsls, 0)];
//Label
PropString sLabelBeams(4, arSYesNo, T("|Label beams|"));
int bLabelBeams = arNYesNo[arSYesNo.find(sLabelBeams, 0)];
PropString sLabelSheets(5, arSYesNo, T("|Label sheets|"));
int bLabelSheets = arNYesNo[arSYesNo.find(sLabelSheets, 0)];

// filter beams with beamcode
PropString sFilterBC(6,"",T("Filter beams with beamcode"));
String sFBC = sFilterBC + ";";
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

	arSFBC.append(sTokenBC);
}

// filter GenBeams with label
PropString sFilterLabel(7,"",T("Filter beams/sheets with (sub)label/material"));
String sFLabel = sFilterLabel + ";";
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

String arSRange[] = {T("|Selected element|"), T("|Floorgroup|")};
PropString sRange(8, arSRange, T("|Range|"));
int nRange = arSRange.find(sRange,0);

if( _bOnInsert ){
	_Viewport.append(getViewport(T("Select the viewport that holds the element.")));

	showDialog("_Default");
	return;
}

if(_Viewport.length()==0){eraseInstance();return;}

Viewport vp = _Viewport[0];
// check if the viewport has hsb data
if (!vp.element().bIsValid()) return;

CoordSys ms2ps = vp.coordSys();
CoordSys ps2ms = ms2ps; ps2ms.invert();
double dVpScale = ms2ps.scale();

Display dpNumbers(nColorNumbers);
dpNumbers.dimStyle(sDimStyle);
//dpNumbers.textHeight(dTextHeightNumbers * dVpScale);
Display dpLabels(nColorLabels);
dpLabels.dimStyle(sDimStyle);
//dpLabels.textHeight(dTextHeightLabels * dVpScale);
Display dp(3);

Element arEl[0];
//Group info
Group grpElem = vp.element().elementGroup();
Group grpFloor(grpElem.namePart(0), grpElem.namePart(1),"");
if( nRange == 0 ){
	arEl.append(vp.element());
}
else if( nRange == 1 ){
	Group grpElem = vp.element().elementGroup();
	Group grpFloor(grpElem.namePart(0), grpElem.namePart(1),"");
	Entity arEntFloor[] = grpFloor.collectEntities(TRUE, Element(), _kModelSpace);
	for( int i=0;i<arEntFloor.length();i++ ){
		Element el = (Element)arEntFloor[i];
		if( el.bIsValid() ){
			arEl.append(el);
		}
	}
}

//Coordsys of wordl
CoordSys csWorld(_Pt0, _XW, _YW, _ZW);
Plane pnWorld(_Pt0, _ZW);
//Planeprofile withinvalid locations of floorgroup
PlaneProfile ppFloorGroup(csWorld);
//Beams of floorgroup
Entity arEntBmFloor[] = grpFloor.collectEntities(FALSE, Beam(), _kModelSpace);
Beam arBmFloor[0];
for( int i=0;i<arEntBmFloor.length();i++ ){
	Beam bm = (Beam)arEntBmFloor[i];
	
	if( nRange == 1 ){
		if( 	(arSFBC.find(bm.name("beamcode").token(0)) == -1) && 
			(arSFLabel.find(bm.label()) == -1) && 
			(arSFLabel.find(bm.subLabel()) == -1) &&
			(arSFLabel.find(bm.hsbId()) == -1) && 
			(arSFLabel.find(bm.material()) == -1))
		{
			arBmFloor.append(bm);
		}
	}

	
	if( arSBmCodeSteelBm.find(bm.beamCode().token(0)) != -1 ){
		ppFloorGroup.unionWith(bm.realBody().shadowProfile(pnWorld));
	}
}

//Go over elements
for( int e=0;e<arEl.length();e++ ){
	Element el = arEl[e];
	
	CoordSys csEl = el.coordSys();
	Vector3d vxEl = csEl.vecX();
	Vector3d vyEl = csEl.vecY();
	Vector3d vzEl = csEl.vecZ();
	
	GenBeam arGenBm[0];
	Beam arBm[0];
	if( e==0 )
		arBm.append(arBmFloor);
	Sheet arSh[0];
	TslInst arTslInst[0];
		
	//Filters
	GenBeam arGBeamsTmp[] = el.genBeam(); // collect all 
	for(int i=0;i<arGBeamsTmp.length();i++){
		if( arGBeamsTmp[i].bIsDummy() )continue;
		if( 	(arSFBC.find(arGBeamsTmp[i].name("beamcode").token(0)) == -1) && 
				(arSFLabel.find(arGBeamsTmp[i].label()) == -1) && 
				(arSFLabel.find(arGBeamsTmp[i].subLabel()) == -1) && 
				(arSFLabel.find(arGBeamsTmp[i].hsbId()) == -1) && 
				(arSFLabel.find(arGBeamsTmp[i].material()) == -1))
		{
			arGenBm.append(arGBeamsTmp[i]);
		}
	}
	
	Beam arBmsTmp[] = el.beam();
	for(int i=0;i<arBmsTmp.length();i++){
		if( arBmsTmp[i].bIsDummy() )continue;
		if( 	(arSFBC.find(arBmsTmp[i].name("beamcode").token(0)) == -1) && 
				(arSFLabel.find(arBmsTmp[i].label()) == -1) && 
				(arSFLabel.find(arBmsTmp[i].subLabel()) == -1) &&
				(arSFLabel.find(arBmsTmp[i].hsbId()) == -1) && 
				(arSFLabel.find(arBmsTmp[i].material()) == -1))
		{
			arBm.append(arBmsTmp[i]);
		}
	}
	
	Sheet arShTmp[] = el.sheet(); // collect all
	Point3d arPtSh[0];
	String arSLabelSh[0];
	for(int i=0;i<arShTmp.length();i++){
		Sheet sh = arShTmp[i];
		if( 		(arSFLabel.find(sh.label()) == -1) && 
				(arSFLabel.find(sh.subLabel()) == -1) && 
				(arSFLabel.find(sh.material()) == -1))
		{
			int bDisplayInformation = TRUE;
			for( int j=0;j<arPtSh.length();j++ ){
				Point3d pt = arPtSh[j];
				String sLabel = arSLabelSh[j];
				if( (pt-sh.ptCen()).length() < U(50) && sLabel == sh.label() ){
					bDisplayInformation = FALSE;
					break;
				}
			}			
			
			if( bDisplayInformation ){
				arPtSh.append(sh.ptCen());
				arSLabelSh.append(sh.label());
				arSh.append(sh);
			}
		}
	}
	
	arTslInst.append(el.tslInst());
	
	//Planeprofile with all text locations
	PlaneProfile ppAllTxt(csWorld);
	ppAllTxt.unionWith(ppFloorGroup);
	String arSTxt[0];
	Point3d arPtTxt[0];
	Display arDisplay[0];
	Vector3d arVTransformation[0];
	Vector3d arVxTxt[0];
	Vector3d arVyTxt[0];
	if( bNumberBeams || bLabelBeams ){
		for( int i=0;i<arBm.length();i++ ){
			Beam bm = arBm[i];
			Vector3d vxBm = bm.vecX();
			if( vxBm.dotProduct(_XW+_YW) < 0 )
				vxBm=  -vxBm;
			Vector3d vyBm = vzEl.crossProduct(vxBm);
			
			if( bNumberBeams ){
				String sTxt = bm.posnum();
				arSTxt.append(sTxt);
				Point3d ptTxt = bm.ptCen() + 2 * bm.dD(vyBm) * vyBm; ptTxt.transformBy(ms2ps);
				arPtTxt.append(ptTxt);
				arDisplay.append(dpNumbers);
				arVTransformation.append(vxBm);
				arVxTxt.append(vxBm);
				arVyTxt.append(vyBm);
			}
	
			if( bLabelBeams ){
				String sTxt = bm.label();
				arSTxt.append(sTxt);
				Point3d ptTxt = bm.ptCen() - 2 * bm.dD(vyBm) * vyBm; ptTxt.transformBy(ms2ps);
				arPtTxt.append(ptTxt);
				arDisplay.append(dpLabels);
				arVTransformation.append(vyBm);
				arVxTxt.append(vxBm);
				arVyTxt.append(vyBm);
			}
		}
	}
	if( bNumberSheets || bLabelSheets ){
		for( int i=0;i<arSh.length();i++ ){
			Sheet sh = arSh[i];
			Vector3d vxSh = sh.vecX();
			Vector3d vySh = vzEl.crossProduct(vxSh);
			
			if( bNumberSheets ){
				String sTxt = sh.posnum();
				arSTxt.append(sTxt);
				Point3d ptTxt = sh.ptCen() + vySh * U(100); ptTxt.transformBy(ms2ps);
				arPtTxt.append(ptTxt);
				arDisplay.append(dpNumbers);
				arVTransformation.append(vxSh);
				arVxTxt.append(_XW);
				arVyTxt.append(_YW);
			}
	
			if( bLabelSheets ){
				String sTxt = sh.label();
				arSTxt.append(sTxt);
				Point3d ptTxt = sh.ptCen() - vySh * U(100); ptTxt.transformBy(ms2ps);
				arPtTxt.append(ptTxt);
				arDisplay.append(dpLabels);
				arVTransformation.append(vySh);
				arVxTxt.append(_XW);
				arVyTxt.append(_YW);
			}
		}
	}
	
	if( bNumberTsls ){
		for( int i=0;i<arTslInst.length();i++ ){
			TslInst tsl = arTslInst[i];
			
			//Is it a tsl to show?
			if( arSShowNumberOfTheseTsls.find(tsl.scriptName()) == -1 )continue;			
			
			String sTxt = tsl.posnum();
			arSTxt.append(sTxt);
			Point3d ptTxt = tsl.ptOrg() + (tsl.coordSys().vecX() + tsl.coordSys().vecY()) * U(100); ptTxt.transformBy(ms2ps);
			arPtTxt.append(ptTxt);
			arDisplay.append(dpNumbers);
			arVTransformation.append(_YW);
			arVxTxt.append(_XW);
			arVyTxt.append(_YW);
		}
	}
	
	for( int i=0;i<arPtTxt.length();i++ ){
		Point3d ptTxt = arPtTxt[i];
		String sTxt = arSTxt[i];
		Display dp = arDisplay[i];
		Vector3d vTransformation = arVTransformation[i];
					
		double dLTxt = dp.textLengthForStyle(sTxt, sDimStyle);
		double dHTxt = dp.textHeightForStyle(sTxt, sDimStyle);
			
		Vector3d vxTxt = arVxTxt[i];//_XW;
		Vector3d vyTxt = arVyTxt[i];//_YW;
		
		PLine plTxt(_ZW);
		LineSeg lnSegTxt(ptTxt - vxTxt * .5 * dLTxt - vyTxt * .5 * dHTxt, ptTxt + vxTxt * .5 * dLTxt + vyTxt * .5 * dHTxt);
		plTxt.createRectangle(lnSegTxt, vxTxt, vyTxt);
		PlaneProfile ppThisTxt(plTxt);
		ppThisTxt.shrink(-.25 * dHTxt);
	//	dpNumbers.draw(ppThisTxt);
		
		PlaneProfile ppTmp = ppThisTxt;
		ppTmp.intersectWith(ppAllTxt);
		int nNrOfExecutionLoops =0;
		while( ppTmp.area() > 0 && nNrOfExecutionLoops < 15){
			LineSeg lnSeg = ppTmp.extentInDir(vTransformation);
			double dTransformation = abs(vTransformation.dotProduct(lnSeg.ptEnd() - lnSeg.ptStart()));
			ptTxt.transformBy(vTransformation * dTransformation);
			ppThisTxt.transformBy(vTransformation * dTransformation);
			
			ppTmp = ppThisTxt;
			ppTmp.intersectWith(ppAllTxt);
			
			nNrOfExecutionLoops++;
		}
		
		ppAllTxt.unionWith(ppThisTxt);
		dp.draw(sTxt, ptTxt, vxTxt, vyTxt, 0, 0);
	}
}
//dp.draw(ppAllTxt);


#End
#BeginThumbnail


#End
