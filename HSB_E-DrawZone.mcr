#Version 8
#BeginDescription
Last modified by: Anno Sportel (anno.sportel@hsbcad.com)
03.09.2015  -  version 1.06




































#End
#Type O
#NumBeamsReq 0
#NumPointsGrip 0
#DxaOut 1
#ImplInsert 1
#FileState 1
#MajorVersion 1
#MinorVersion 6
#KeyWords 
#BeginContents
/// <summary Lang=en>
/// Draw outline of a specific zone in paperspace
/// </summary>

/// <insert>
/// Select a set of elements
/// </insert>

/// <remark Lang=en>
/// .
/// </remark>

/// <version  value="1.06" date="03.09.2015"></version>

/// <history>
/// AS	- 1.00 - 19.06.2012 	- Pilot version
/// AS	- 1.01 - 17.09.2012 	- Don't break when a point is found. Keep looping for a better result.
/// AS	- 1.02 - 17.09.2012 	- Make a difference in the analyzis if zone A contains more vertex points than zone B
/// AS	- 1.03 - 27.11.2012 	- Also support hsbId 4101 as rafter.
/// AS	- 1.04 - 05.12.2012 	- Remove debug data which was still in from last update.
/// AS	- 1.05 - 03.05.2013 	- Update for DSP changes. Outline positions are now used for outside outline. Zone 6 is used as inside outline.
/// AS	- 1.06 - 03.09.2015 	- Draw opening rings of zoneprofile of zone 0 if the openings couldn't be found.
/// </history>


Unit (1,"mm");//script uses mm

String arSYesNo[] = {T("|Yes|"), T("|No|")};
int arNYesNo[] = {_kYes, _kNo};

String arSInExclude[] = {T("|Include|"), T("|Exclude|")};

String arSZone[] = {T("|Do not connect|"), "0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "Outline.Inside", "Outline.Outside"};
int arNZone[]={-99,0,1,2,3,4,5,6,7,8,9,10,99,100};

PropString sSeperator03(7, "", T("|Space|"));
sSeperator03.setReadOnly(true);
String sPaperSpace = T("|Paper space|");
String sShopdrawSpace = T("|Shopdraw multipage|");
String sArSpace[] = {sPaperSpace , sShopdrawSpace };
PropString sSpace(8,sArSpace,"     "+T("|Drawing space|"));

PropString sSeperator01(0, "", T("|Draw zone|"));
sSeperator01.setReadOnly(true);
PropString sWithOpening(1, arSYesNo, "     "+T("|With openings|"));
PropString sWithOpeningGaps(2, arSYesNo, "     "+T("|With openinggaps|"));
PropString sWithExtendedRafters(10, arSYesNo, "     "+T("|With extended rafters|"));

sWithOpeningGaps.setDescription(T("|Only applicable for log-walls.|"));
PropString sZone(11,arSZone,"     "+T("Zone"),1);
PropInt nColorOutline(1, -1, "     "+T("|Color outline|"));
PropInt nColorRafter(3, 7, "     "+T("|Color extended rafters|"));

PropString sConnectToZone(9, arSZone,"     "+T("|Connect to other zone|"));
String arSHatchPattern[] = {T("|No Hatch|")};
arSHatchPattern.append(_HatchPatterns);
PropString sHatchPattern(6, arSHatchPattern, "     "+T("|Hatch pattern|"));
PropDouble dHatchScale(0, 10, "     "+T("|Hatch scale|"));
PropInt nHatchColor(2, 8, "     "+T("|Hatch color|"));

PropString sSeperator02(3, "", T("|Filter|"));
sSeperator02.setReadOnly(true);
PropString sInExcludeFilters(4, arSInExclude, "     "+T("|Include|")+T("/|Exclude|"),1);
PropString sFilterName(5,"","     "+T("|Filter beams with name|"));

if (_bOnInsert) {
	showDialog();
	
	if (sSpace==sPaperSpace){
		Viewport vp = getViewport(T("|Select the viewport|")); // select viewport
		_Viewport.append(vp);
	}
	else if (sSpace==sShopdrawSpace){
		Entity ent = getShopDrawView(T("|Select the view entity|")); // select ShopDrawView
		_Entity.append(ent);
	}
	
	_Pt0 = getPoint(T("|Select a location|"));
	
	return;
}

// determine the space type depending on the contents of _Entity[0] and _Viewport[0]
if (_Viewport.length()>0)
	sSpace.set(sPaperSpace);
else if (_Entity.length()>0 && _Entity[0].bIsKindOf(ShopDrawView()))
		sSpace.set(sShopdrawSpace);
else {
	eraseInstance(); // this Tsl not allowed to be appended to model space
	return;
}
sSpace.setReadOnly(true);

int bError = 0; // 0 means FALSE = no error
// set of variables that change depending on the type of space
CoordSys ms2ps; // default to identity transformation
Element el;
if( sSpace==sShopdrawSpace ){
	ShopDrawView sv;
	if (_Entity.length()>0)
		sv = (ShopDrawView)_Entity[0];
	if (!bError && !sv.bIsValid())
		bError = 1;
	// interprete the list of ViewData in my _Map
	ViewData arViewData[] = ViewData().convertFromSubMap( _Map, _kOnGenerateShopDrawing + "\\" + _kViewDataSets,0); // 2 means verbose
	int nIndFound = ViewData().findDataForViewport(arViewData, sv);// find the viewData for my view
	if (!bError && nIndFound<0)
		bError = 2; // no viewData found
	if (!bError) {
		ViewData vwData = arViewData[nIndFound];
		ms2ps = vwData.coordSys(); // transformation to view
		Entity arEnt[] = vwData.showSetDefineEntities();
		
		for( int i=0;i<arEnt.length();i++ ){
			Entity ent = arEnt[i];
			Element elInView = (Element)ent;
			if( elInView.bIsValid() ){
				el = elInView;
				break;
			}
		}
	}
}
else if( sSpace==sPaperSpace ){// If it is a viewport
	//Is there a viewport selected?
	if( !bError && _Viewport.length()==0 )
		bError = 3;
	
	//get the selected viewport
	if( !bError ){
		Viewport vp = _Viewport[0];
		el = vp.element();
		if( !el.bIsValid() )
			bError = 4;// no hsbData attached to viewport.
		ms2ps = vp.coordSys();
	}
}

Display dpName(-1);
dpName.textHeight(U(5));
dpName.draw(_ThisInst.scriptName(), _Pt0, _XW, _YW, 1, 2);

if( !el.bIsValid() )
	return;

Display dpOutline(nColorOutline);
Display dpHatch(nHatchColor);

Display dpRafter(nColorRafter);


int nZone = arNZone[arSZone.find(sZone,1)];
if( nZone == -99 ){
	reportMessage(T("|Zone reset to 0.|"));
	sZone.set(arSZone[1]);
	nZone = 0;
}

if( nZone > 5 && nZone < 50 )
	nZone = 5 - nZone;

int bWithOpening = arNYesNo[arSYesNo.find(sWithOpening,0)];
int bWithOpeningGaps = arNYesNo[arSYesNo.find(sWithOpeningGaps,0)];
int bWithExtendedRafters= arNYesNo[arSYesNo.find(sWithExtendedRafters,0)];

//int nConnectionIndex = arSZone.find(sConnectToZone,0);
int nConnectToZone = arNZone[arSZone.find(sConnectToZone,1)];
if( nConnectToZone > 5 && nConnectToZone < 50 )
	nConnectToZone = 5 - nConnectToZone;

int bExclude = arSInExclude.find(sInExcludeFilters,1);

String sFName = sFilterName + ";";
String arSFName[0];
int nIndexName = 0; 
int sIndexName = 0;
while(sIndexName < sFName.length()-1){
	String sTokenName = sFName.token(nIndexName);
	nIndexName++;
	if(sTokenName.length()==0){
		sIndexName++;
		continue;
	}
	sIndexName = sFName.find(sTokenName,0);

	arSFName.append(sTokenName);
}

CoordSys ps2ms = ms2ps; ps2ms.invert(); // take the inverse of ms2ps

CoordSys csEl = el.coordSys();
Point3d ptEl = csEl.ptOrg();
Vector3d vxEl = csEl.vecX();
Vector3d vyEl = csEl.vecY();
Vector3d vzEl = csEl.vecZ();

Plane pnZ(ptEl, vzEl);

PlaneProfile ppEl(csEl);
PlaneProfile ppRafter(csEl);

int arNRafterType[] = {
	_kRafter,
	_kDakCenterJoist,
	_kDakLeftEdge,
	_kDakRightEdge
};
String arSRafterID[] = {
	"4101"
};
	
Beam arBmAll[] = el.beam();
Beam arBm[0];
for( int i=0;i<arBmAll.length();i++ ){
	Beam bm = arBmAll[i];
	String sName = bm.name();
	sName.trimLeft();
	sName.trimRight();
	
	if( bExclude ){
		if( arSFName.find(sName) != -1 )
			continue;
	}
	else{
		if( arSFName.find(sName) == -1 && arSFName.length() != 0 )
			continue;
	}
	arBm.append(bm);
	
	if( bWithExtendedRafters && (arNRafterType.find(bm.type()) != -1 || arSRafterID.find(bm.hsbId()) != -1) )
		ppRafter.unionWith(bm.envelopeBody(true, true).shadowProfile(pnZ));
}
ppRafter.vis();

if( nZone == 0 ){
	PlaneProfile ppBm(csEl);
	
	for( int i=0;i<arBm.length();i++ ){
		Beam bm = arBm[i];
		PlaneProfile ppThisBm(csEl);
		ppThisBm.unionWith(bm.envelopeBody(false, true).shadowProfile(Plane(bm.ptCen(), bm.vecD(vzEl))));
		ppThisBm.shrink(-U(5));
		ppBm.unionWith(ppThisBm);
	}
	ppBm.shrink(U(5));

	PLine arPlBm[] = ppBm.allRings();
	int arNRing[] = ppBm.ringIsOpening();
	
	ppEl = PlaneProfile(csEl);
	for( int i=0;i<arPlBm.length();i++ ){
		int isRing = arNRing[i];
		PLine ring = arPlBm[i];
		if( isRing )
			continue;
			
		ppEl.joinRing(ring, _kAdd);
	}
	
	if( bWithOpening ){
		Opening arOp[] = el.opening();
		for( int j=0;j<arOp.length();j++ ){
			Opening op = arOp[j];
			PLine plOp = op.plShape();
			if( bWithOpeningGaps ){
				OpeningLog opLog = (OpeningLog)op;
				if( opLog.bIsValid() ){
					double dGapL = opLog.dGapLeft();
					double dGapR = opLog.dGapRight();
					double dGapT = opLog.dGapTop();
					double dGapB = opLog.dGapBottom();
					
					PLine p = plOp;
					p.transformBy(ms2ps);
					p.vis(1);
					
					PlaneProfile ppOpLog(plOp);
					Point3d arPtGripMidEdge[] = ppOpLog.getGripEdgeMidPoints();
					for( int k=0;k<arPtGripMidEdge.length();k++ ){
						Point3d pt = arPtGripMidEdge[k];
						pt += vxEl;
						if( ppOpLog.pointInProfile(pt) == _kPointInProfile ){//Left
							ppOpLog.moveGripEdgeMidPointAt(k, -vxEl * dGapL);
						}
						else if( ppOpLog.pointInProfile(pt) == _kPointOutsideProfile ){//Right
							ppOpLog.moveGripEdgeMidPointAt(k, vxEl * dGapR);
						}
						else if( ppOpLog.pointInProfile(pt) == _kPointOnRing ){
							pt += vyEl;
							if( ppOpLog.pointInProfile(pt) == _kPointInProfile ){//Bottom
								ppOpLog.moveGripEdgeMidPointAt(k, -vyEl * dGapB);
							}
							else if( ppOpLog.pointInProfile(pt) == _kPointOutsideProfile ){//Top
								ppOpLog.moveGripEdgeMidPointAt(k, vyEl * dGapT);
							}
						}
					}
					
					PLine arPlOpLog[] = ppOpLog.allRings();
					for( int k=0;k<arPlOpLog.length();k++ ){
						plOp = arPlOpLog[k];
						
						PLine p = plOp;
						p.transformBy(ms2ps);
						p.vis(k);
						
						break;
					}
				}
			}
			
			ppEl.joinRing(plOp, _kSubtract);
		}
		
		if (arOp.length() == 0) {
			PlaneProfile ppNetto = el.profNetto(0);
			PLine arPlNetto[] = ppNetto.allRings();
			int arBPLineIsRing[] = ppNetto.ringIsOpening();
			for (int r=0;r<arPlNetto.length();r++) {
				int ringIsOpening = arBPLineIsRing[r];
				if (!ringIsOpening)
					continue;
				PLine ring = arPlNetto[r];
				ppEl.joinRing(ring , _kSubtract);
			}
		}
	}
}
else{
	if( nZone > 5 ){
		ppEl = el.profBrutto(0);
		if( bWithOpening )
			ppEl = el.profNetto(0);
	}
	else{	
		ppEl = el.profBrutto(nZone);
		if( bWithOpening )
			ppEl = el.profNetto(nZone);
	}
}

ppEl.transformBy(ms2ps);
int nHatchIndex = arSHatchPattern.find(sHatchPattern,0);
if( nHatchIndex > 0 ){
	ppEl.shrink(U(0.25));
	Hatch hatch(sHatchPattern, dHatchScale);
	dpHatch.draw(ppEl, hatch);
	ppEl.shrink(-U(0.25));
}
dpOutline.draw(ppEl);

if( nConnectToZone != -99 ){
	Point3d ptZoneRef;
	if( nZone < 6 ){
		int nZn = nZone;
		if( nZone < 0 )
			nZn -= 1;
		else if( nZone > 0 )
			nZn += 1;
		ptZoneRef = el.zone(nZn).coordSys().ptOrg();
	}
	else if(nZone > 5 ){
		if( nZone == 99 )
			ptZoneRef = el.zone(-5).coordSys().ptOrg();
		else if( nZone == 100 )
			ptZoneRef = el.zone(4).coordSys().ptOrg();
	}
	else{
		reportWarning(T("|Invalid zone index selected|!"));
	}
Point3d p1 = ptZoneRef;
p1.transformBy(ms2ps);
p1.vis(1);	
	PlaneProfile ppZone(CoordSys(ptZoneRef, vxEl, vyEl, vzEl));
	if( nZone > 5 )
		ppZone.unionWith(el.profBrutto(0));
	else{
		ppZone.unionWith(el.profBrutto(nZone));
	}
	PlaneProfile pp1 = ppZone;
	pp1.transformBy(ms2ps);
	pp1.vis(3);
	
	
	Point3d ptConnectRef;
	if( nConnectToZone < 6 ){
		int nZn = nConnectToZone;
		if( nConnectToZone < 0 )
			nZn -= 1;
		else if( nConnectToZone > 0 )
			nZn += 1;
		ptConnectRef = el.zone(nZn).coordSys().ptOrg();
	}
	else if(nConnectToZone > 5 ){
		if( nConnectToZone == 99 )
			ptConnectRef = el.zone(-5).coordSys().ptOrg();
		else if( nConnectToZone == 100 )
			ptConnectRef = el.zone(4).coordSys().ptOrg();
	}
	else{
		reportWarning(T("|Invalid zone index selected|!"));
	}
Point3d p2 = ptConnectRef;
p2.transformBy(ms2ps);
p2.vis(1);
	PlaneProfile ppConnect(CoordSys(ptConnectRef, vxEl, vyEl, vzEl));
	if( nConnectToZone > 5 ){	
		ppConnect.unionWith(el.profBrutto(0));
	}
	else{
		ppConnect.unionWith(el.profBrutto(nConnectToZone));
	}
	PlaneProfile pp2 = ppConnect;
	pp2.transformBy(ms2ps);
	pp2.vis(3);
	
	if( bWithExtendedRafters ){
		ppRafter.subtractProfile(ppZone);
		ppRafter.subtractProfile(ppConnect);
	}
	
	Point3d arPtZone[] = ppZone.getGripVertexPoints();
	Point3d arPtConnect[] = ppConnect.getGripVertexPoints();
	
	if( arPtZone.length() != arPtConnect.length() ){
		int bSwapped = false;
		if( arPtZone.length() < arPtConnect.length() ){
			Point3d arPtTmp[0];
			arPtTmp.append(arPtZone);
			arPtZone = arPtConnect;
			arPtConnect = arPtTmp;
			
			bSwapped = true;
		}
		
		Point3d arPtConnectTo[arPtZone.length()];
		for( int i=0;i<arPtZone.length();i++ ){
			Point3d ptZone = arPtZone[i];
			
			double dMin = U(999999);
			Point3d ptConnect;
			int bPointFound = false;
			for( int j=0;j<arPtConnect.length();j++ ){
				Point3d ptCnnct = arPtConnect[j];
				double dConnect = (ptZone - ptCnnct).length();
				if( dConnect < dMin ){
					bPointFound = true;
					dMin = dConnect;
					ptConnect = ptCnnct;
				}
			}
			if( bPointFound )
				arPtConnectTo[i] = ptConnect;
		}
		arPtConnect = arPtConnectTo;
	}
	else{
		int nIndexDifference = 0;
		double dMin = U(999999);
		
		for( int i=0;i<(arPtZone.length()-1);i++ ){
			double dConnect = 0;
			for( int j=0;j<arPtZone.length();j++ ){
				Point3d ptZone = arPtZone[j];
				Point3d ptCnnct;
				if( arPtConnect.length() > (j+i) )
					ptCnnct = arPtConnect[j+i];
				else
					ptCnnct = arPtConnect[j+i-arPtConnect.length()];
//				double d = (ptZone - ptCnnct).length();
				dConnect += (ptZone - ptCnnct).length();
			}
			
			if( dConnect < dMin ){
				dMin = dConnect;
				nIndexDifference = i;
			}
		}
			
//		for( int i=0;i<arPtZone.length();i++ ){
//			Point3d ptZone = arPtZone[i];
//			
//			Point3d ptConnect;
//			for( int j=0;j<arPtConnect.length();j++ ){
//				Point3d ptCnnct = arPtConnect[j];
//				double dConnect = (ptZone - ptCnnct).length();
//				if( dConnect < dMin ){
//					dMin = dConnect;
//					ptConnect = ptCnnct;
//					
//					nIndexDifference = j - i;
//				}
//			}
//		}
		
		if( nIndexDifference != 0 ){
			Point3d arPtTmp[arPtConnect.length()];
			for( int i=0;i<arPtConnect.length();i++ ){
				int nIndex = i + nIndexDifference;
				if( nIndex > (arPtConnect.length() - 1) )
					nIndex -= (arPtConnect.length() - 1) ;
				if( nIndex < 0 )
					nIndex = arPtConnect.length() - abs(nIndex);
				
				arPtTmp[i] = arPtConnect[nIndex];
			}
			arPtConnect = arPtTmp;
		}
	}

	for( int i=0;i<arPtZone.length();i++ ){
		Point3d ptZone = arPtZone[i];
		Point3d ptConnect = arPtConnect[i];
		LineSeg lnSeg(ptZone, ptConnect);
		lnSeg.transformBy(ms2ps);
		dpOutline.draw(lnSeg);
	}
}

if( bWithExtendedRafters ){
	ppRafter.transformBy(ms2ps);
	dpRafter.draw(ppRafter);
}









#End
#BeginThumbnail










#End