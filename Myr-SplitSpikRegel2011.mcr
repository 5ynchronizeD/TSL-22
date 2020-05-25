#Version 8
#BeginDescription
Last modified by: Anno Sportel (anno.sportel@itwindustry.nl)
29.04.2011  -  version 1.19.MJ
























#End
#Type O
#NumBeamsReq 0
#NumPointsGrip 0
#DxaOut 1
#ImplInsert 1
#FileState 1
#MajorVersion 1
#MinorVersion 18
#KeyWords 
#BeginContents
/// <summary Lang=en>
/// This tsl re-organizes the spikregel of zone 2
/// </summary>

/// <insert>
/// Select a set of elements
/// </insert>

/// <remark Lang=en>
/// .
/// </remark>

/// <version  value="1.17" date="15.10.2009"></version>

/// <history>
/// AS - 1.01 - 26.10.2006 - Pilot version
/// AS - 1.02 - 11.03.2008 - Adjust it to the Myresjohus needs (was used for Smalland)
/// AS - 1.03 - 23.06.2008 - Solve bug on line 366.. out of range
/// AS - 1.04 - 03.09.2008 - Add the openingshape as beamcuts to sheets of zone 2
/// AS - 1.05 - 22.10.2008 - Auto-select the type (el.code())
///							Change material name of regel above opening
///							Correct beamcuts in opening
///							Add beamcuts at sides of opening
/// AS - 1.06 - 14.01.2009 - Fix CA issues
/// AS - 1.07 - 15.01.2009 - Solve issue with openings next to each other.
///							No sheeting between connection openings
/// AS - 1.08 - 26.02.2009 - Store state in dwg
/// AS - 1.09 - 25.06.2009 - Solve bug on splitregel with adjacent openings
/// AS - 1.10 - 25.06.2009 - Above electrical cabinet on 83 mm instead of 73 mm
/// AS - 1.11 - 25.06.2009 - Update on electrical cabinet
/// AS - 1.12 - 01.07.2009 - Split CA walls at the side of an opening
/// AS - 1.13 - 24.09.2009 - Extra spikregel of CA wall are same width as gypsum
///							Intersection of adjacent openings is now done through a plane profile
/// AS - 1.14 - 27.09.2009 - Bugfix on intersction with planeprofile
/// AS - 1.15 - 28.09.2009 - Split existing sheeting if there is intersection with new ones found
/// AS - 1.16 - 29.09.2009 - Take length from spikregel under opening from solidlength of body
///							Remove duplicates if centerpoints are less the 15 mm from each other
/// AS - 1.17 - 15.10.2009 - Spikregel under and over opening are adjusted from 508 to 554 
/// AS - 1.18 - 15.10.2009 - Move spikregel at height of 2435 mm 150 mm down
/// </history>

double dEps = U(0.01,"mm");
PropDouble dMaxShLength(0,U(4246),T("Maximum split length"));

String arSType[] = {"CA", "CB", "CC", "CF", "CL", "CP", "CT"};
String arSVerticalTypes[] = {"CL", "CP", "CT"};
//PropString sType(0, arSType, T("Type"));

PropDouble dMinimumAllowedLength(1, U(96),T("Minimum allowed length"));

int nSheetColor = 1;

if( _bOnInsert ){
	_Element.append(getElement(T("Select an element")));
	showDialogOnce("|_Default|");
	return;
}

if( _Element.length()==0 ){eraseInstance(); return;}

ElementWallSF el = (ElementWallSF)_Element[0];
if( !el.bIsValid() )return;

CoordSys csEl = el.coordSys();
Point3d ptEl = csEl.ptOrg();
Vector3d vxEl = csEl.vecX();
Vector3d vyEl = csEl.vecY();
Vector3d vzEl = csEl.vecZ();

Line lnX(ptEl, vxEl);

Plane pnElZ(ptEl, vzEl);

String sType = el.code();

// element extremes
LineSeg lnSegEl = el.segmentMinMax();
Point3d ptElStart = lnSegEl.ptStart();
Point3d ptElEnd = lnSegEl.ptEnd();
Point3d ptElMid = lnSegEl.ptMid();

//Debug - Preview zones that are important for this tsl.
if( _bOnDebug ){
	int arNValidZones[] = {2};
	GenBeam arGBm[] = el.genBeam();
	Display dp(-1);
	for( int i=0;i<arGBm.length();i++ ){
		GenBeam gBm = arGBm[i];
		if( arNValidZones.find(gBm.myZoneIndex()) != -1 ){
			dp.color(gBm.color());
			dp.draw(gBm.realBody());
		}
	}
}

Beam arBm[] = el.beam();
Sheet arSh[] = el.sheet();
Sheet arShZn02[0];
Sheet arShZn02HorizontalNotNew[0];
for( int i=0;i<arSh.length();i++ ){
	Sheet sh = arSh[i];
	
	int bValidSh = TRUE;
	if( sh.myZoneIndex() == 2 ){
		Point3d ptSh = sh.ptCen();
		double d = vyEl.dotProduct(ptSh - ptEl);
//		reportNotice("\n"+d);
		if( abs(vyEl.dotProduct(ptSh - ptEl) - U(2435)) < U(2) )
			sh.transformBy(-vyEl * U(150));
		
		ptSh = sh.ptCen(); 
		
		if( vyEl.dotProduct(ptSh - ptElMid) > 0 ){
			if( abs(vxEl.dotProduct(ptSh - ptElEnd)) < U(100) || abs(vxEl.dotProduct(ptSh - ptElStart)) < U(100) ){
				sh.dbErase();
				continue;
			}
		}
			
		for( int j=0;j<arShZn02.length();j++ ){
			Point3d pt = arShZn02[j].ptCen();
			if( Vector3d(pt-ptSh).length() < U(15) ){
				// is already there
				sh.dbErase();
				bValidSh = FALSE;
				break;
			}
		}
		if( bValidSh ){
			arShZn02.append(sh);
			
			Body bdSh = sh.envelopeBody();
			double dShX = bdSh.lengthInDirection(vxEl);
			double dShY = bdSh.lengthInDirection(vyEl);
			if( dShX > dShY )
				arShZn02HorizontalNotNew.append(arShZn02);
		}
	}
}


double arDDistanceExtraSpikRegelOverOpening[0];
double arDOffsetWidthExtraSpikRegelOverOpening[0];
String arSCdtLabelOverOpening[0];
String arSMaterialOverOpening[0];

double arDDistanceExtraSpikRegelUnderOpening[0];
double arDOffsetWidthExtraSpikRegelUnderOpening[0];
String arSCdtLabelUnderOpening[0];
String arSMaterialUnderOpening[0];

if( sType == "CA" ){
	arDDistanceExtraSpikRegelOverOpening.append(U(131));
	arDOffsetWidthExtraSpikRegelOverOpening.append(U(-23));
	arSCdtLabelOverOpening.append("");
	arSMaterialOverOpening.append("Spikregel");

	arDDistanceExtraSpikRegelUnderOpening.append(U(72));
	arDOffsetWidthExtraSpikRegelUnderOpening.append(U(-23));
	arSCdtLabelUnderOpening.append("");
	arSMaterialUnderOpening.append("Spikregel");

}
else if( sType == "CB" || sType == "CC"){
	arDDistanceExtraSpikRegelOverOpening.append(U(165));
	arDOffsetWidthExtraSpikRegelOverOpening.append(U(100));
	arSCdtLabelOverOpening.append("");
	arSMaterialOverOpening.append("Spikregel");

	arDDistanceExtraSpikRegelUnderOpening.append(U(46));
	arDOffsetWidthExtraSpikRegelUnderOpening.append(U(100));
	arSCdtLabelUnderOpening.append("");
	arSMaterialUnderOpening.append("Spikregel");

	arDDistanceExtraSpikRegelUnderOpening.append(U(121));
	arDOffsetWidthExtraSpikRegelUnderOpening.append(U(0));
	arSCdtLabelUnderOpening.append("NON");
	arSMaterialUnderOpening.append("Spikregel");
	
	arDDistanceExtraSpikRegelUnderOpening.append(U(221));
	arDOffsetWidthExtraSpikRegelUnderOpening.append(U(0));
	arSCdtLabelUnderOpening.append("");
	arSMaterialUnderOpening.append("Spikregel");
}
else if( sType == "CF" ){
	arDDistanceExtraSpikRegelOverOpening.append(U(95));
	arDOffsetWidthExtraSpikRegelOverOpening.append(U(100));
	arSCdtLabelOverOpening.append("");
	arSMaterialOverOpening.append("Spikregel");

	arDDistanceExtraSpikRegelUnderOpening.append(U(46));
	arDOffsetWidthExtraSpikRegelUnderOpening.append(U(100));
	arSCdtLabelUnderOpening.append("");
	arSMaterialUnderOpening.append("Spikregel");
}
else if( sType == "CL" ){
	arDDistanceExtraSpikRegelOverOpening.append(U(95));
	arDOffsetWidthExtraSpikRegelOverOpening.append(U(100));
	arSCdtLabelOverOpening.append("");
	arSMaterialOverOpening.append("Spikregel");

}
else if( sType == "CP" ){
}
else if( sType == "CT" ){
}
else{
}

BeamCut arBmCut[0];

Sheet arShNew[0];

Opening arOp[] = el.opening();
int nNrOfOpenings = arOp.length();

Body arBdOp[nNrOfOpenings];
Point3d arPtOpCen[nNrOfOpenings];
Point3d arPtOpLeft[nNrOfOpenings];
Point3d arPtOpRight[nNrOfOpenings];
PlaneProfile arPpModule[nNrOfOpenings];

for( int i=0;i<nNrOfOpenings;i++ ){
	Opening op = arOp[i];
	PLine plOp = op.plShape();

	Body bdOp(plOp, vzEl);
	arBdOp[i] = bdOp;
	
	Point3d ptOp = bdOp.ptCen();
	arPtOpCen[i] = ptOp;
	arPtOpLeft[i] = ptOp - vxEl * (.5 * op.width() + U(22));
	arPtOpRight[i] = ptOp + vxEl * (.5 * op.width() + U(22));
	
	// find extremes of module
	// left
	Beam arBmLeft[] = Beam().filterBeamsHalfLineIntersectSort(arBm, ptOp, -vxEl);
	Point3d ptLeft;
	String sThisModule;
	for( int j=0;j<arBmLeft.length();j++ ){
		Beam bm = arBmLeft[j];
		String sModule = bm.module();
		if( j==0 )
			sThisModule = sModule;
		else if( sThisModule != sModule )
			break;
		
		ptLeft = bm.ptCen() - vxEl * .5 * bm.dD(vxEl);
	}
	// right
	Beam arBmRight[] = Beam().filterBeamsHalfLineIntersectSort(arBm, ptOp, vxEl);
	Point3d ptRight;
	for( int j=0;j<arBmRight.length();j++ ){
		Beam bm = arBmRight[j];
		String sModule = bm.module();
		if( j==0 )
			sThisModule = sModule;
		else if( sThisModule != sModule )
			break;
		
		ptRight = bm.ptCen() + vxEl * .5 * bm.dD(vxEl);
	}

	PLine plModule(vzEl);
	Point3d ptBL = ptOp - vyEl * .5 * op.height() + vxEl * vxEl.dotProduct(ptLeft - ptOp);
	Point3d ptBR = ptOp - vyEl * .5 * op.height() + vxEl * vxEl.dotProduct(ptRight - ptOp);
	Point3d ptTR = ptOp + vyEl * .5 * op.height() + vxEl * vxEl.dotProduct(ptRight - ptOp);
	Point3d ptTL = ptOp + vyEl * .5 * op.height() + vxEl * vxEl.dotProduct(ptLeft - ptOp);
	plModule.addVertex(ptBL);
	plModule.addVertex(ptBR);
	plModule.addVertex(ptTR);
	plModule.addVertex(ptTL);
	plModule.close();
	
	PlaneProfile ppModule(csEl);
	ppModule.joinRing(plModule, _kAdd);
	arPpModule[i] = ppModule;
}

//Order openings left to right
for(int s1=1;s1<arOp.length();s1++){
	int s11 = s1;
	for(int s2=s1-1;s2>=0;s2--){
		if( vxEl.dotProduct(arPtOpCen[s11] - arPtOpCen[s2]) < 0 ){
			arOp.swap(s2, s11);
			arBdOp.swap(s2, s11);
			arPtOpCen.swap(s2, s11);
			arPtOpLeft.swap(s2, s11);
			arPtOpRight.swap(s2, s11);
			arPpModule.swap(s2,s11);
						
			s11=s2;
		}
	}
}

//remove sheeting between openings if distance is less then 140 mm
for( int i=0;i<(arBdOp.length() - 1);i++ ){
	Body bdThisOp = arBdOp[i];
	Body bdNextOp = arBdOp[i+1];
	
	Point3d ptLeftNextOp = bdNextOp.ptCen() - vxEl * .5 * bdNextOp.lengthInDirection(vxEl);
	Point3d ptRightThisOp = bdThisOp.ptCen() + vxEl * .5 * bdThisOp.lengthInDirection(vxEl);

	double dDistBetweenOp = vxEl.dotProduct(ptLeftNextOp - ptRightThisOp);
	
	if( dDistBetweenOp < U(140) ){
		//Check if there is sheeting of zone 2 between openings... if so: delete it!
		Body bdBetweenOp(ptRightThisOp, vxEl, vyEl, vzEl, dDistBetweenOp, U(1), U(500), 1, 0, 0);
		for( int j=0;j<arShZn02.length();j++ ){
			Sheet shZn02 = arShZn02[j];
			if( shZn02.realBody().hasIntersection(bdBetweenOp) ){
				shZn02.dbErase();
			}
		}
	}
}

//Profile of zone 2, with opening
PlaneProfile ppZn02 = el.profNetto(2);
Point3d arPtZn02[] = ppZn02.getGripVertexPoints();
Point3d arPtZn02X[] = lnX.orderPoints(arPtZn02);
//Extreme points of zone 2 in vecX direction
if( arPtZn02X.length() < 2 )
	reportWarning(T("|Something wrong with outline of zone 2.|"));
Point3d ptLeftZn02 = arPtZn02X[0];
Point3d ptRightZn02 = arPtZn02X[arPtZn02X.length() - 1];

//Cuts at the start and end of the element
BeamCut bmCutLeft(ptLeftZn02, vxEl, vyEl, vzEl, U(500), U(10000), U(500), -1, 0, 0);
arBmCut.append(bmCutLeft);
BeamCut bmCutRight(ptRightZn02, vxEl, vyEl, vzEl, U(500), U(10000), U(500), 1, 0, 0);
arBmCut.append(bmCutRight);

//Center of zone 2
Point3d ptCenterZone02 = el.ptOrg() + vzEl * (el.zone(1).dH() + .5 * el.zone(2).dH());
for( int i=0;i<arOp.length();i++ ){
	Opening op = arOp[i];
	
	//Detail
	OpeningSF opSF = (OpeningSF)op;
	String sDetail = opSF.constrDetail();
	
	double arDDistanceExtraSpikRegelOverThisOpening[0];
	double arDOffsetWidthExtraSpikRegelOverThisOpening[0];
	String arSCdtLabelOverThisOpening[0];
	String arSMaterialOverThisOpening[0];
	
	double arDDistanceExtraSpikRegelUnderThisOpening[0];
	double arDOffsetWidthExtraSpikRegelUnderThisOpening[0];
	String arSCdtLabelUnderThisOpening[0];
	String arSMaterialUnderThisOpening[0];
	if( sDetail == "MH_EL" && (sType == "CA" || sType == "CC" || sType == "CF") ){
		arDDistanceExtraSpikRegelOverThisOpening.append(U(101));
		arDOffsetWidthExtraSpikRegelOverThisOpening.append(U(-23));
		arSCdtLabelOverThisOpening.append("");
		arSMaterialOverThisOpening.append("Spikregel P616");
	
		arDDistanceExtraSpikRegelUnderThisOpening.append(U(0));
		arDOffsetWidthExtraSpikRegelUnderThisOpening.append(U(-23));
		arSCdtLabelUnderThisOpening.append("");
		arSMaterialUnderThisOpening.append("Spikregel");
	}
	else{
		arDDistanceExtraSpikRegelOverThisOpening.append(arDDistanceExtraSpikRegelOverOpening);
		arDOffsetWidthExtraSpikRegelOverThisOpening.append(arDOffsetWidthExtraSpikRegelOverOpening);
		arSCdtLabelOverThisOpening.append(arSCdtLabelOverOpening);
		arSMaterialOverThisOpening.append(arSMaterialOverOpening);
		
		arDDistanceExtraSpikRegelUnderThisOpening.append(arDDistanceExtraSpikRegelUnderOpening);
		arDOffsetWidthExtraSpikRegelUnderThisOpening.append(arDOffsetWidthExtraSpikRegelUnderOpening);
		arSCdtLabelUnderThisOpening.append(arSCdtLabelUnderOpening);
		arSMaterialUnderThisOpening.append(arSMaterialUnderOpening);
	}
	
	//Shape	
	PLine plOp = op.plShape();
	Body bdOp(plOp,vzEl);
	
	//Centre point of opening
	Point3d ptOpening = bdOp.ptCen();
	
	//Width and height of opening
	double dWidth = bdOp.lengthInDirection(vxEl);
	double dOpY = bdOp.lengthInDirection(vyEl);
	
	//Create a list of beamcuts
	BeamCut bmCut(ptOpening, vxEl, vyEl, vzEl, dWidth, dOpY, U(1000), 0, 0 ,0);
	arBmCut.append(bmCut);
	
	//Add beams from this opening to the body
	String sModule;
	for( int j=0;j<arBm.length();j++ ){
		Beam bm = arBm[j];
		
		if( bm.module() != "" ){
			if( abs(vxEl.dotProduct(bm.ptCen() - ptOpening)) < (.5 * dWidth + el.dBeamHeight()) ){
				sModule = bm.module();
				break;
			}
		}	
	}

	if( sModule != "" ){
		for( int j=0;j<arBm.length();j++ ){
			Beam bm = arBm[j];
			if( bm.module() == sModule ){
				bdOp.addPart(arBm[j].envelopeBody());
			}
		}
	}
	bdOp.vis(i);
	
	Point3d ptOpLeft = arPtOpLeft[i];
	Point3d ptOpRight = arPtOpRight[i];
	
	//get the extreme vertices of this extended body
	Point3d arPtOp[] = bdOp.allVertices();
	Line lnX(el.ptOrg(), el.vecX());		
	arPtOp = lnX.orderPoints(arPtOp);
	//Length cannot be 0
	if( arPtOp.length() == 0 )return;
	
	//Width updated to width of extended body
	dWidth = el.vecX().dotProduct(arPtOp[arPtOp.length() - 1] - arPtOp[0]);

	Point3d arPtSh[0];
	double arDShX[0];
	double arDShY[0];
	double arDShZ[0];
	String arSLabel[0];
	String arSMaterial[0];
	
	if( sType == "CA" ){
		for( int j=0;j<arShZn02.length();j++ ){
			Sheet sh = arShZn02[j];
		
			Body bdSh = sh.realBody();
			ptCenterZone02 = bdSh.ptCen();
			Point3d ptShMin = bdSh.ptCen() - vxEl * .5 * bdSh.lengthInDirection(vxEl);
			Point3d ptShMax = bdSh.ptCen() + vxEl * .5 * bdSh.lengthInDirection(vxEl);
			Point3d ptOpLeft = ptOpening - vxEl * .5 * (dWidth + 2 * U(-23));
			if( (vxEl.dotProduct(ptOpLeft - ptShMin) * vxEl.dotProduct(ptOpLeft - ptShMax)) < 0 ){
				Point3d ptSplit = ptOpLeft;
				arShZn02.append(sh.dbSplit(Plane(ptSplit,vxEl), 0));
			}
			Point3d ptOpRight = ptOpening + vxEl * .5 * (dWidth + 2 * U(-23));
			if( (vxEl.dotProduct(ptOpRight - ptShMin) * vxEl.dotProduct(ptOpRight - ptShMax)) < 0 ){
				Point3d ptSplit = ptOpRight;
				arShZn02.append(sh.dbSplit(Plane(ptSplit,vxEl), 0));
			}
//			if( (vxEl.dotProduct(ptOpening - ptShMin) * vxEl.dotProduct(ptOpening - ptShMax)) < 0 ){
//				Point3d ptSplit = sh.ptCen() + vxEl * vxEl.dotProduct(ptOpening - bdSh.ptCen());
//				arShZn02.append(sh.dbSplit(Plane(ptSplit,vxEl), dWidth + 2 * U(-23)));
//				arPtSh.append(ptSplit);
//				arDShX.append(dWidth + 2 * U(-23));
//				arDShY.append(bdSh.lengthInDirection(vyEl));
//				arDShZ.append(bdSh.lengthInDirection(vzEl));
//				arSLabel.append("");
//				arSMaterial.append("Spikregel");
//			}
		}
	}
	
	for( int j=0;j<arDDistanceExtraSpikRegelOverThisOpening.length();j++ ){
		double dDistanceExtraSpikRegelOverOpening = arDDistanceExtraSpikRegelOverThisOpening[j];
		double dOffsetWidthExtraSpikRegelOverOpening = arDOffsetWidthExtraSpikRegelOverThisOpening[j];
		String sCdtLabelOverOpening = arSCdtLabelOverThisOpening[j];
		String sMaterialOverOpening = arSMaterialOverThisOpening[j];
		Point3d ptShCen = ptOpening + vyEl * (.5 * dOpY + dDistanceExtraSpikRegelOverOpening + .5 * U(70)) + vzEl * vzEl.dotProduct(ptCenterZone02 - ptOpening);
		double dShLength = dWidth + 2 * dOffsetWidthExtraSpikRegelOverOpening;
		arPtSh.append(ptShCen);
		arDShX.append(dShLength);
		
		if( sDetail == "MH_EL" && (sType == "CA" || sType == "CC" || sType == "CF") ){
//			arDShX[arDShX.length() - 1] += 2 * dOffsetWidthExtraSpikRegelOverOpening;
		}
		else{
			//Check if there is intersection with an adjacent opening
			Point3d ptShLeft = ptShCen - vxEl * .5 * dShLength;
			Point3d ptShRight = ptShCen + vxEl * .5 * dShLength;
			
			for( int k=0;k<arPpModule.length();k++ ){
				PlaneProfile ppModule = arPpModule[k];
				if( ppModule.pointInProfile(ptShLeft) == _kPointInProfile ){
					Point3d ptLeft = ptShCen - vxEl * .5 * dShLength;
					double dCorrection = abs(vxEl.dotProduct(ptOpLeft - ptLeft));
					ptShCen += vxEl * .5 * dCorrection;
					arPtSh[arPtSh.length() - 1] = ptShCen;
					arDShX[arDShX.length() - 1] = dShLength - dCorrection;
				}
				if( ppModule.pointInProfile(ptShRight) == _kPointInProfile ){
					Point3d ptRight = ptShCen + vxEl * .5 * dShLength;
					double dCorrection = abs(vxEl.dotProduct(ptOpRight - ptRight));
					ptShCen -= vxEl * .5 * dCorrection;
					arPtSh[arPtSh.length() - 1] = ptShCen;
					arDShX[arDShX.length() - 1] = dShLength - dCorrection;
				}
			}

//			//Check if there is intersection with an adjacent opening
//			Body bdTmp(ptOpening + vyEl * .5 * dOpY, vxEl, vyEl, vzEl, dWidth + 4 * U(70), U(70), U(500));
//			for( int k=0;k<arBdOp.length();k++ ){
//				if( k==i ) continue;
//				Body bdOp = arBdOp[k];
//				bdOp.vis();
//				if( bdTmp.hasIntersection(bdOp) ){
//					int nSide = -1;//Left
//					if( vxEl.dotProduct(bdOp.ptCen() - bdTmp.ptCen()) > 0 ){
//						nSide = 1;//Right
//					}
//					arPtSh[arPtSh.length() - 1] += vxEl * nSide * .5 * dOffsetWidthExtraSpikRegelOverOpening;
//					arDShX[arDShX.length() - 1] += dOffsetWidthExtraSpikRegelOverOpening;
//					//break;
//				}
//			}
		}

		arDShY.append(U(70));
		arDShZ.append(U(24));
		arSLabel.append(sCdtLabelOverOpening);
		arSMaterial.append(sMaterialOverOpening);
	}
	
	if( sType == "CL" ){
		//Copy vertical sheets from jacks to side of element.
		//Cut sheets on kingstuds
		Point3d ptJackOverOpening = ptOpening + vyEl * .5 * dOpY;
		Point3d ptLeftKingStud = ptOpening - vxEl * .5 * dWidth;
		Point3d ptRightKingStud = ptOpening + vxEl * .5 * dWidth;

		Sheet shJackOverOpening;
		double dDistClosestJackOverOpening;
		int bClosestDistJackSet = FALSE;
		//KingStud on the left
		Sheet shLeftKingStud;
		double dDistClosestLeftKingStud;
		int bClosestDistLeftKingStudSet = FALSE;
		//KingStud on the right
		Sheet shRightKingStud;
		double dDistClosestRightKingStud;
		int bClosestDistRightKingStudSet = FALSE;
		//All sheets of zone2
		for( int j=0;j<arShZn02.length();j++ ){
			Sheet sh = arShZn02[j];
			Point3d ptSh = sh.ptCen();
			if( vyEl.dotProduct(ptSh - ptJackOverOpening) > 0 ){
				double dDistJack = abs(vxEl.dotProduct(ptSh - ptJackOverOpening));
				if( !bClosestDistJackSet ){
					bClosestDistJackSet = TRUE;
					dDistClosestJackOverOpening = dDistJack;
					shJackOverOpening = sh;
				}
				else{
					if( dDistJack < dDistClosestJackOverOpening ){
						dDistClosestJackOverOpening = dDistJack;
						shJackOverOpening = sh;
					}
				}
			}
			double dDistLeftKingStud = abs(vxEl.dotProduct(ptSh - ptLeftKingStud));
			if( !bClosestDistLeftKingStudSet ){
				bClosestDistLeftKingStudSet = TRUE;
				dDistClosestLeftKingStud = dDistLeftKingStud;
				shLeftKingStud = sh;
			}
			else{
				if( dDistLeftKingStud < dDistClosestLeftKingStud ){
					dDistClosestLeftKingStud = dDistLeftKingStud;
					shLeftKingStud = sh;
				}
			}
			double dDistRightKingStud = abs(vxEl.dotProduct(ptSh - ptRightKingStud));
			if( !bClosestDistRightKingStudSet ){
				bClosestDistRightKingStudSet = TRUE;
				dDistClosestRightKingStud = dDistRightKingStud;
				shRightKingStud = sh;
			}
			else{
				if( dDistRightKingStud < dDistClosestRightKingStud ){
					dDistClosestRightKingStud = dDistRightKingStud;
					shRightKingStud = sh;
				}
			}
		}
		if( bClosestDistJackSet ){
			BeamCut bmCutOp(ptOpening, vxEl, vyEl, vzEl, dWidth, dOpY + 2 * (arDDistanceExtraSpikRegelOverThisOpening[0] + U(70)), U(500));
			shJackOverOpening.addToolStatic(bmCutOp);
						
			Body bdSh = shJackOverOpening.realBody();
			
			Point3d ptShLeft = bdSh.ptCen() - vxEl * (.5 * dWidth - U(22.5));
			if( abs(vxEl.dotProduct(ptShLeft - ptElEnd)) < U(100) || abs(vxEl.dotProduct(ptShLeft - ptElStart)) < U(100) ){
				// close to the edge of the element
			}
			else{
				arPtSh.append(ptShLeft);
				arDShX.append(U(70));
				arDShY.append(bdSh.lengthInDirection(vyEl));//.solidLength());
				arDShZ.append(U(24));
				arSLabel.append("");
				arSMaterial.append("Spikregel");
			}
			
			Point3d ptShRight = bdSh.ptCen() + vxEl * (.5 * dWidth - U(22.5));
			if( abs(vxEl.dotProduct(ptShRight - ptElEnd)) < U(100) || abs(vxEl.dotProduct(ptShRight - ptElStart)) < U(100) ){
				// close to the edge of the element
			}
			else{
				arPtSh.append(ptShRight);
				arDShX.append(U(70));
				arDShY.append(bdSh.lengthInDirection(vyEl));//.solidLength());
				arDShZ.append(U(24));
				arSLabel.append("");
				arSMaterial.append("Spikregel");
			}
		}
		Cut ct(ptOpening + vyEl * (.5 * dOpY + U(45)), vyEl);
		if( bClosestDistLeftKingStudSet ){
			shLeftKingStud.addToolStatic(ct);
		}
		if( bClosestDistRightKingStudSet ){
			shRightKingStud.addToolStatic(ct);
		}
	}
	
	/// create a plane profile for each module; extreme points in x adn y direction, create rectangle, create planeprofile
	/// check if point is in profile.. adjust spikregel
	
	
	
	
	if( op.openingType() != _kDoor && dOpY <  U(2000)){
		for( int j=0;j<arDDistanceExtraSpikRegelUnderThisOpening.length();j++ ){
			double dDistanceExtraSpikRegelUnderOpening = arDDistanceExtraSpikRegelUnderThisOpening[j];
			double dOffsetWidthExtraSpikRegelUnderOpening = arDOffsetWidthExtraSpikRegelUnderThisOpening[j];
			String sCdtLabelUnderOpening = arSCdtLabelUnderThisOpening[j];
			String sMaterialUnderOpening = arSMaterialUnderThisOpening[j];
			
			Point3d ptShCen = ptOpening - vyEl * (.5 * dOpY + dDistanceExtraSpikRegelUnderOpening + .5 * U(70)) + vzEl * vzEl.dotProduct(ptCenterZone02 - ptOpening);
			double dShLength = dWidth + 2 * dOffsetWidthExtraSpikRegelUnderOpening;
			arPtSh.append(ptShCen);
			arDShX.append(dShLength);
			
			if( sDetail == "MH_EL" && (sType == "CA" || sType == "CC" || sType == "CF") ){
//				arDShX[arDShX.length() - 1] += 2 * dOffsetWidthExtraSpikRegelUnderOpening;
			}
			else{
				//Check if there is intersection with an adjacent opening
				Point3d ptShLeft = ptShCen - vxEl * .5 * dShLength;
				Point3d ptShRight = ptShCen + vxEl * .5 * dShLength;
				
				for( int k=0;k<arPpModule.length();k++ ){
					PlaneProfile ppModule = arPpModule[k];

					if( ppModule.pointInProfile(ptShLeft) == _kPointInProfile ){
						Point3d ptLeft = ptShCen - vxEl * .5 * dShLength;
						double dCorrection = abs(vxEl.dotProduct(ptOpLeft - ptLeft));
						ptShCen += vxEl * .5 * dCorrection;
						arPtSh[arPtSh.length() - 1] = ptShCen;
						arDShX[arDShX.length() - 1] = dShLength - dCorrection;
					}
					if( ppModule.pointInProfile(ptShRight) == _kPointInProfile ){
						Point3d ptRight = ptShCen + vxEl * .5 * dShLength;
						double dCorrection = abs(vxEl.dotProduct(ptOpRight - ptRight));
						ptShCen -= vxEl * .5 * dCorrection;
						arPtSh[arPtSh.length() - 1] = ptShCen;
						arDShX[arDShX.length() - 1] = dShLength - dCorrection;
					}
				}
				
//				Body bdTmp(ptOpening - vyEl * .5 * dOpY, vxEl, vyEl, vzEl, dWidth + 4 * U(70), U(70), U(500));
//				for( int k=0;k<arBdOp.length();k++ ){
//					if( k==i ) continue;
//					Body bdOp = arBdOp[k];
//					bdOp.vis();
//					if( bdTmp.hasIntersection(bdOp) ){
//						int nSide = -1;//Left
//						if( vxEl.dotProduct(bdOp.ptCen() - bdTmp.ptCen()) > 0 ){
//							nSide = 1;//Right
//						}
//						arPtSh[arPtSh.length() - 1] += vxEl * nSide * .5 * dOffsetWidthExtraSpikRegelUnderOpening;
//						arDShX[arDShX.length() - 1] += dOffsetWidthExtraSpikRegelUnderOpening;
//						//break;
//					}
//				}
			}
			arDShY.append(U(70));
			arDShZ.append(U(24));
			arSLabel.append(sCdtLabelUnderOpening);
			arSMaterial.append(sMaterialUnderOpening);
		}
		if( sType == "CP" ){
			arPtSh.append( ptOpening - vxEl * .25 * dWidth - vyEl * (.5 * dOpY + U(8) + .5 * U(70)) + vzEl * vzEl.dotProduct(ptCenterZone02 - ptOpening) );
			arDShX.append(U(250));
			arDShY.append(U(70));
			arDShZ.append(U(24));
			arSLabel.append("");
			arSMaterial.append("Spikregel");
			
			arPtSh.append( ptOpening + vxEl * .25 * dWidth - vyEl * (.5 * dOpY + U(8) + .5 * U(70)) + vzEl * vzEl.dotProduct(ptCenterZone02 - ptOpening) );
			arDShX.append(U(250));
			arDShY.append(U(70));
			arDShZ.append(U(24));
			arSLabel.append("");
			arSMaterial.append("Spikregel");
		}
		if( sType == "CL" ){
			//Copy vertical sheets from jacks to side of element.
			Point3d ptJackUnderOpening = ptOpening - vyEl * .5 * dOpY;
			Sheet shJackUnderOpening;
			double dDistClosestJackUnderOpening;
			int bClosestDistSet = FALSE;
			for( int j=0;j<arShZn02.length();j++ ){
				Sheet sh = arShZn02[j];
				Point3d ptSh = sh.ptCen();
				if( vyEl.dotProduct(ptSh - ptJackUnderOpening) > 0 )
					continue;
				double dDist = abs(vxEl.dotProduct(sh.ptCen() - ptJackUnderOpening));
				if( !bClosestDistSet ){
					bClosestDistSet = TRUE;
					dDistClosestJackUnderOpening = dDist;
					shJackUnderOpening = sh;
				}
				else{
					if( dDist < dDistClosestJackUnderOpening ){
						dDistClosestJackUnderOpening = dDist;
						shJackUnderOpening = sh;
					}
				}
			}
						
			if( bClosestDistSet ){
				
				Body bdSh = shJackUnderOpening.realBody();
				
				arPtSh.append(shJackUnderOpening.ptCen() - vxEl * (.5 * dWidth - U(70)));
				arDShX.append(U(70));
				arDShY.append(bdSh.lengthInDirection(vyEl));//shJackUnderOpening.dL());
				arDShZ.append(U(24));
				arSLabel.append("");
				arSMaterial.append("Spikregel");
				
				arPtSh.append(shJackUnderOpening.ptCen() + vxEl * (.5 * dWidth - U(70)));
				arDShX.append(U(70));
				arDShY.append(bdSh.lengthInDirection(vyEl));//shJackUnderOpening.dL());
				arDShZ.append(U(24));
				arSLabel.append("");
				arSMaterial.append("Spikregel");
			}
		}

	}
	
	for( int j=0;j<arPtSh.length();j++ ){
		Point3d pt = arPtSh[j];
		Sheet sh;
		double dShX = arDShX[j];
		double dShY = arDShY[j];
		double dShZ = arDShZ[j];
		String sLabel = arSLabel[j];
		String sMaterial = arSMaterial[j];
		
		// create a body and check with intersection with existing sheets
		Body bdSh(pt, vyEl, vxEl, vzEl, dShY, dShX - U(2), dShZ, 0, 0, 0);
		for( int k=0;k<arShZn02HorizontalNotNew.length();k++ ){
			Sheet shZn02 = arShZn02HorizontalNotNew[k];
			Body bdShZn02 = shZn02.envelopeBody();
			if( bdSh.hasIntersection(bdShZn02) ){
				// split the existing one
				shZn02.dbSplit(Plane(pt, shZn02.vecY()), dShX);
			}
		}
		
		sh.dbCreate(pt, vyEl, vxEl, vzEl, dShY, dShX, dShZ, 0, 0, 0);
		sh.setColor(nSheetColor);
		sh.setMaterial(sMaterial);
		sh.setLabel(sLabel);
		sh.assignToElementGroup(el,TRUE,2,'Z');
		arShZn02.append(sh);
		arShNew.append(sh);
		pt.vis(j);
	}
}

for( int i=0;i<arShNew.length();i++ ){
	Sheet sh = arShNew[i];
	if( !sh.bIsValid() )continue;
	
	
	for( int j=0;j<arShNew.length();j++ ){
		if( j==i )continue;
		Sheet shToCheckOn = arShNew[j];
		
		PlaneProfile ppSh = sh.realBody().shadowProfile(pnElZ);
		ppSh.shrink(U(.01));
		PlaneProfile ppShToCheckOn = shToCheckOn.realBody().shadowProfile(pnElZ);
		if( ppSh.intersectWith(ppShToCheckOn) ){
			if( shToCheckOn.dW() == U(70) && sh.dW() == U(70) ){
				Vector3d vTransform((sh.ptCen() + shToCheckOn.ptCen())/2 - sh.ptCen());
				sh.transformBy(vTransform);
				shToCheckOn.dbErase();
			}
			else{
				sh.dbJoin(shToCheckOn);
			}
			arShNew[j] = Sheet();
			i = 0;
		}
	}
}

Beam arBmVert[] = vxEl.filterBeamsPerpendicularSort(arBm);
arSh.setLength(0);
arSh.append(el.sheet());
for( int i=0;i<arShZn02.length();i++ ){
	Sheet sh = arShZn02[i];
	Body bdSh = sh.realBody();
	double dShX = bdSh.lengthInDirection(vxEl);
		
	if( dShX > dMaxShLength ){
		Point3d ptShMin = bdSh.ptCen() - vxEl * .5 * bdSh.lengthInDirection(vxEl);
		Point3d ptSplit = ptShMin + vxEl * dMaxShLength;
		for( int j=(arBmVert.length()-1);j>-1;j-- ){
			Beam bmVert = arBmVert[j];
			Point3d ptBmMin = bmVert.ptRef() + bmVert.vecX() * bmVert.dLMin();
			Point3d ptBmMax = bmVert.ptRef() + bmVert.vecX() * bmVert.dLMax();
			if( (vyEl.dotProduct((ptBmMin - bmVert.vecX() * el.dBeamHeight()) - ptSplit) * vyEl.dotProduct((ptBmMax + bmVert.vecX() * el.dBeamHeight()) - ptSplit)) > 0 ) continue;
				
			double dDist = int(vxEl.dotProduct(bmVert.ptCen() - ptSplit));
			if( dDist < 0 ){
				ptSplit += vxEl * dDist;
				break;
			}
		}
		arShZn02.append(sh.dbSplit(Plane(ptSplit,-vxEl),0));
	}
	else{
	}
}

if( arSVerticalTypes.find(sType) == -1 ){
	for( int j=0;j<arShZn02.length();j++ ){
		Sheet sh = arShZn02[j];
		Body bdSh = sh.realBody();
		if( bdSh.lengthInDirection(vxEl) < dMinimumAllowedLength ){
			sh.dbErase();
		}
	}
}


for( int i=0;i<arBmCut.length();i++ ){
	BeamCut bmCut = arBmCut[i];
	for( int j=0;j<arShZn02.length();j++ ){
		Sheet sh = arShZn02[j];
		sh.addToolStatic(bmCut);
	}
}

eraseInstance();

































#End
#BeginThumbnail


#End
