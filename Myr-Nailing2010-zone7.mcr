#Version 8
#BeginDescription
Last modified by: Myresjohus
13.01.2011  -  version 1.7










#End
#Type O
#NumBeamsReq 0
#NumPointsGrip 0
#DxaOut 1
#ImplInsert 1
#FileState 1
#MajorVersion 1
#MinorVersion 7
#KeyWords 
#BeginContents
// Automatically saved contents for tsl
// Date & time: dinsdag 31 augustus 2010 14:29:53

/// <summary Lang=en>
/// Create nailing lines
/// </summary>

/// <insert>
/// Select a set of elements
/// </insert>

/// <remark Lang=en>
/// .
/// </remark>

/// <version  value="1.05" date="31.08.2010"></version>

/// <history>
/// AS - 1.00 - 05.05.2008 	- Pilot version
/// AS - 1.01 - 18.11.2008 	- Nailines always from bottom to top
///										  Distance to top-, bottomplate and t-connections is adjusted
///										  Remove some redundant code
///										  Split naillines on top plate
///										  Solve bug on header. Reposition nailLines after they've been calculated by automated nailline routine
/// AS - 1.02 - 16.03.2009 	- Issues with t-connections solved. Offset to edge of sub-element solved. Remove naillines < 5mm
/// AS - 1.03 - 18.03.2009 	- T-Connections with headers (bmCode == HB) are no longer possible. Minimum length of nailline removed again
/// AS - 1.04 - 31.08.2010 	- Use beam vecX instead of element vecX for splitting beam
/// AS - 1.05 - 31.08.2010 	- Split linesegs on top and bottom plate. No longer use dummy beams for that.
/// Isac - 1.06 - 27.09.2010 - Updated to Eurosystem 2010. Nailing only in zone 6.
/// Myresjohus - 13.01.2011 - Updated for Vägg 2010
/// MJ - 03.03.2014 - Nailing Zone 7
/// </history>

double dEps(Unit(1,"mm"));

int arNZone[] = {-2};

double dSizeTP = U(54);
double dDistanceToTopPlateZn01 = U(135);
//dDistanceToTopPlateZn01 -= dSizeTP;
double dDistanceToTopPlateZn07 = U(225);
//dDistanceToTopPlateZn07 -= dSizeTP;
double arDDistanceToTopPlate[] = {dDistanceToTopPlateZn01, dDistanceToTopPlateZn07};

double dSizeBP = U(54);
double dDistanceToBottomPlateZn01 = U(225);
//dDistanceToBottomPlateZn01 -= dSizeBP;
double dDistanceToBottomPlateZn07 = U(210);
//dDistanceToBottomPlateZn07 -= dSizeBP;
double arDDistanceToBottomPlate[] = {dDistanceToBottomPlateZn01, dDistanceToBottomPlateZn07};

double dDistanceToTConnection = U(25.1);

double dDistanceToSheetEdge = U(22);

double dOffsetFromSheetJoint = U(12);

double dOffsetFromSheetEdge = U(10);

int nColorIndex = 4;

PropDouble dDistBetweenNailsZn01(0,U(200),T("Distance between nails zone 1"));
PropDouble dDistBetweenNailsZn07(1,U(200),T("Distance between nails zone 7"));
double arDDistBetweenNails[] = {dDistBetweenNailsZn01, dDistBetweenNailsZn07};

//Insert
if( _bOnInsert ){
	//Only execute insert once
	if( insertCycleCount() > 1 ){
		eraseInstance();
		return;
	}
	
	//Select multiple elements
	PrEntity ssE(T("Select element(s) to nail"), ElementWallSF());
	Element arEl[0];
	if( ssE.go() ){
		arEl.append(ssE.elementSet());
	}
	
	//Tsl attributes
	String sScriptName = scriptName();
	Vector3d vUcsX = _XU;
	Vector3d vUcsY = _YU;

	int nArPropInt[0];
	double dArPropDouble[0];
	dArPropDouble.append(dDistBetweenNailsZn01);
	dArPropDouble.append(dDistBetweenNailsZn07);
	String sArPropString[0];
	
	Point3d arPt[0];
	Element arElem[0];
	GenBeam arGBm[0];
	
	//Insert tsl per element
	for( int i=0;i<arEl.length();i++ ){
		Element el = arEl[i];
		
		arElem.setLength(0);
		arElem.append(el);
		
		//insert this tsl
		TslInst thisTsl;
		thisTsl.dbCreate(sScriptName, vUcsX, vUcsY, arGBm, arElem, arPt, nArPropInt, dArPropDouble, sArPropString);
	}
	
	//Delete this instance
	eraseInstance();
	return;
}

//Check if there is a valid element selected.
if( _Element.length()==0 ){
	eraseInstance();
	return;
}

//Get element
Element el = _Element[0];
ElementWallSF elSF = (ElementWallSF)el;

//Create coordsys
CoordSys csEl = elSF.coordSys();
Vector3d vxEl = csEl.vecX();
Vector3d vyEl = csEl.vecY();
Vector3d vzEl = csEl.vecZ();
//Set origin point
_Pt0 = csEl.ptOrg();

//Display
Display dp(-1);

//Collect beams used for nailing
Beam arAllBeams[] = el.beam();
Beam arBm[] = NailLine().removeGenBeamsWithNoNailingBeamCode(arAllBeams);
Beam arBmVert[] = vxEl.filterBeamsPerpendicularSort(arBm);

//Find top and bottom plates
int arNTypeTopPlate[] = {
	_kTopPlate,
	_kSFTopPlate,
	_kSFAngledTPLeft,
	_kSFAngledTPRight
};
int arNTypeBottomPlate[] = {
	_kSFBottomPlate
};
String arSBmCodeToExcludeForTConnection[] = {
	"HB"
};
Beam arBmTopPlate[0];
Beam arBmBottomPlate[0];
Beam arBmAllowedForTConnection[0];
for( int i=0;i<arAllBeams.length();i++ ){
	Beam bm = arAllBeams[i];
	int nType = bm.type();
	String sBmCode = bm.beamCode().token(0);
	
	if( arSBmCodeToExcludeForTConnection.find(sBmCode) == -1 )
		arBmAllowedForTConnection.append(bm);
	
	if( arNTypeTopPlate.find(nType) != -1 ){//Top plates
		arBmTopPlate.append(bm);
	}
	else if( arNTypeBottomPlate.find(nType) != -1 ){//Bottom plates
		arBmBottomPlate.append(bm);
	}
}

//LineSeg used during development
LineSeg lnSegMinMax = elSF.segmentMinMax();
dp.draw(lnSegMinMax);

// remove all nailing lines of nZone with color nColorIndex
for( int i=0;i<arNZone.length();i++ ){
	int nZone = arNZone[i];
	NailLine nlOld[] = el.nailLine(nZone);
	for( int n=0; n<nlOld.length(); n++ ){
		NailLine nl = nlOld[n];
		if( nl.color() == nColorIndex ){
			nl.dbErase();
		}
	}
}


//Find the split locations
Point3d arPtSplitLocation[0];
String sPreviousModuleName;
Beam bmPreviousVert;
int bFirstModuleFound = FALSE;
for( int i=0;i<arBmVert.length();i++ ){
	Beam bmVert = arBmVert[i];
//	bmVert.realBody().vis(bmVert.color());
	String sModuleName = bmVert.module();
	if( bmVert.module() != sPreviousModuleName ){
		if( !bFirstModuleFound ){
			bFirstModuleFound = TRUE;
		}
		else if( sPreviousModuleName != "" ){
			arPtSplitLocation.append(bmPreviousVert.ptCen() - vxEl * (.5 * bmPreviousVert.dD(vxEl) - U(10)));
			sPreviousModuleName = sModuleName;
		}
		if( sModuleName != "" ){
			arPtSplitLocation.append(bmVert.ptCen() + vxEl * (.5 * bmVert.dD(vxEl) - U(10)));
			sPreviousModuleName = sModuleName;
		}
	}
	bmPreviousVert = bmVert;
}

for( int i=0;i<arPtSplitLocation.length();i++ ){
	Point3d pt = arPtSplitLocation[i];
	pt.vis(i);
}

for( int i=0;i<arBm.length();i++ ){
	//Put nailing on this beam
	Beam bm = arBm[i];
	bm.realBody().vis(i);
	CoordSys csBm = bm.coordSys();
	Vector3d vxBm = csBm.vecX();
	Vector3d vyBm = csBm.vecY();
	Vector3d vzBm = csBm.vecZ();
	
	//Line
	Line lnBmX(bm.ptCen(), vxBm);
	
	//beams to check for possible T-Connections
	Beam arBeamsToCheck[] = bm.filterGenBeamsNotThis(arBmAllowedForTConnection);
	
	//Apply nailing per zone
	for( int j=0;j<arNZone.length();j++ ){
		//Zone to nail
		int nZone = arNZone[j];
		if( nZone == 0 )continue;
		
		//Side
		int nSide = nZone/abs(nZone);
		
		// get coordSys of the back of zone 1 or -1, the surface of the beams
		CoordSys csBeam = el.zone(nSide).coordSys();csBeam.vis();
		// get the coordSys of the back of the zone to nail
		CoordSys csSheet = el.zone(nZone).coordSys();
		
		//Beams to nail
		Beam arBmToNail[0];
		//Dummy beams used for alternative nailing positions; will be erased automatically
		Beam arBmDummy[0];

//		//Nailines at the back of the element, on the top- & bottomplate are split at modules
		if( nSide < 0 && (arBmTopPlate.find(bm) != -1 || arBmBottomPlate.find(bm) != -1) ){
			arBmToNail.append(bm);

//			//Beam is a bottom- or topplate.
//			Line lnBmX(bm.ptCen(), vxBm);
//			Point3d arPtSplitLocationBmX[] = lnBmX.orderPoints(arPtSplitLocation,U(1));
//			
//			//Create a dummy beam
//			Beam bmDummy = bm.dbCopy();
//			bmDummy.setBeamCode("DUMMY");
//			bmDummy.setType(_kDummyBeam);
//			bmDummy.setColor(1);
//			for( int k=0;k<arPtSplitLocationBmX.length();k++ ){
//				//Split location
//				Point3d ptSplit = arPtSplitLocationBmX[k];
//				ptSplit.vis(k);
//				//Check if it is a valid split location
//				Point3d ptBmMin = bmDummy.ptRef() + vxBm * bmDummy.dLMin();ptBmMin.vis(j);
//				Point3d ptBmMax = bmDummy.ptRef() + vxBm * bmDummy.dLMax();ptBmMax.vis(j);
//				if( (vxBm.dotProduct(ptBmMin - ptSplit) * vxBm.dotProduct(ptBmMax - ptSplit)) > 0 )continue;
//				
//				//Split beam
////				double dGapTP = U(20);
//			Beam bmSplitted = bmDummy.dbSplit(ptSplit - bmDummy.vecX() * U(13), ptSplit + bmDummy.vecX() * U(13.1));
//				bmDummy.realBody().vis(k);
//				vxBm.vis(bmDummy.ptCen(), 3);
//				
//				//Add splitted part if its long enough
//				if( bmDummy.solidLength() > (2 * el.dBeamHeight()) )
//				arBmToNail.append(bmDummy);
//				arBmDummy.append(bmDummy);
//				
//				//Create a small beam in the gap created
//				Beam bmInGap;
////				bmInGap.dbCreate(ptSplit + vyEl * .5 * el.dBeamHeight(), vyEl, vxEl, vzEl, el.dBeamHeight(), dGapTP, el.dBeamWidth(),-1, 0, 0); 
////				bmInGap.setBeamCode("DUMMY");
////				bmInGap.setType(_kDummyBeam);
////				bmInGap.setColor(1);
////				
////				arBmToNail.append(bmInGap);
////				arBmDummy.append(bmInGap);
//
//				//Assign splitted beam to dummy beam again
//				bmDummy = bmSplitted;
//			}
//			//Add remaining part also
//			arBmToNail.append(bmDummy);
//			arBmDummy.append(bmDummy);
		}
		else if( bm.module() != "" ){
			Beam bmDummy;
			bmDummy.dbCreate(bm.ptCen(), vxBm, vyBm, vzBm, bm.solidLength(), bm.dD(vyBm), bm.dD(vzBm));
			bmDummy.setBeamCode("DUMMY");
			bmDummy.setType(_kDummyBeam);
			bmDummy.setColor(1);

			arBmToNail.append(bmDummy);
			arBmDummy.append(bmDummy);
		}
		else{
			arBmToNail.append(bm);
		}
		
		//Distance between nails
		double dDistBetweenNails = arDDistBetweenNails[j];
		
		//Distance to top/bottom plate
		double dDistanceToTopPlate = arDDistanceToTopPlate[j];
		double dDistanceToBottomPlate = arDDistanceToBottomPlate[j];
		
		//Plane describing the beam
		Plane planeBeam(csBeam.ptOrg(),csBeam.vecZ());
		double dTolDistPlaneBeam = U(3);
		double dShrinkDistBeam = dOffsetFromSheetEdge;
		
		//Plane describing the sheet
		Plane planeSheet(csSheet.ptOrg(),csSheet.vecZ());
		double dTolDistPlaneSheet = U(3);
		double dShrinkDistSheet = U(10);
		
		//Nailine properties
		int bAllowSheetsToMerge = FALSE;
		double dShrinkDistNailLine = -dShrinkDistBeam + dDistanceToSheetEdge;
		
		//Sheets to nail
		Sheet arSh[] = el.sheet(nZone);
		
		// calculate the nailing lines
		LineSeg arSeg[] = NailLine().calculateAllowedNailLineSegments(
			arBmToNail, planeBeam, dTolDistPlaneBeam, dShrinkDistBeam,
			arSh, planeSheet, dTolDistPlaneSheet, dShrinkDistSheet,
			bAllowSheetsToMerge, dShrinkDistNailLine
		);
		
		// now add nailing lines
		for (int n=0; n<arSeg.length(); n++) {
			LineSeg lnSeg = arSeg[n];
			Point3d ptStart = lnSeg.ptStart();
			Point3d ptEnd = lnSeg.ptEnd();
			
			//Swap points if needed nailines always upwards for Randek
			if( vyEl.dotProduct(ptStart - ptEnd) > 0 ){
				Point3d ptTmp = ptStart;
				ptStart = ptEnd;
				ptEnd = ptTmp;
			}
			Vector3d vLineSeg(ptEnd - ptStart);
//			if( vLineSeg.length() < U(5) )continue;
			vLineSeg.normalize();
			
			ptEnd.vis(1);
			ptStart.vis(3);

			// split linesegments if its a top- or bottomplate and if its internal sheeting
			if( nSide < 0 && (arBmTopPlate.find(bm) != -1 || arBmBottomPlate.find(bm) != -1) ){
				Line lnBmX(bm.ptCen(), vxBm);
				Point3d arPtSplitLocationBmX[] = Line(ptStart, vLineSeg).orderPoints(arPtSplitLocation,U(1));
				for( int k=0;k<arPtSplitLocationBmX.length();k++ ){
					Point3d ptSplit = arPtSplitLocationBmX[k];
					if( (vLineSeg.dotProduct(ptSplit - ptStart) * vLineSeg.dotProduct(ptSplit - ptEnd)) < 0 ){
						Point3d ptStartNew = ptStart + vLineSeg * vLineSeg.dotProduct(ptSplit + vLineSeg * U(35) - ptStart);
						if( vLineSeg.dotProduct(ptEnd - ptStartNew) > 0 ){
							LineSeg lnSegNew(ptStartNew, ptEnd);
							lnSegNew.vis(k);
							arSeg.append(lnSegNew);
						}
						ptEnd += vLineSeg * vLineSeg.dotProduct(ptSplit - vLineSeg * U(35) - ptEnd);
						break;
					}
				}
						
			}
			
			if( vLineSeg.dotProduct(ptEnd - ptStart) < 0 )
				continue;
			//Calculate the transformations
			Point3d ptBm = bm.ptCen() + csBeam.vecZ() * csBeam.vecZ().dotProduct((csBeam.ptOrg() - csBeam.vecZ() * U(1)) - bm.ptCen());
			for( int nDirection=-1;nDirection<2;nDirection+=2 ){
				Beam arBmTConnection[] = bm.filterBeamsHalfLineIntersectSort(arBeamsToCheck, ptBm, -nDirection*bm.vecX());
				Body(bm.realBody()).vis(3);
				
				//Is it a T-Connection..?
				int bIsTConnection = FALSE;
				if( arBmTConnection.length() > 0 ){
					Vector3d vyBmT = vzEl.crossProduct(arBmTConnection[0].vecX());
					if( vyBmT.isPerpendicularTo(vxBm) )continue;
					
					Point3d ptIntersect = lnBmX.intersect(Plane(arBmTConnection[0].ptCen(), vyBmT),0);
					
					//reportNotice("\nSTART:\t"+abs(vxBm.dotProduct(ptStart - ptIntersect)));
					//reportNotice("\nEND:\t"+abs(vxBm.dotProduct(ptEnd - ptIntersect)));
					if( abs(vxBm.dotProduct(ptStart - ptIntersect)) < U(75) ){
						lnSeg = LineSeg(ptStart + vLineSeg * U(3), ptEnd);
						ptStart = lnSeg.ptStart();
						ptEnd = lnSeg.ptEnd();
						bIsTConnection = TRUE;
					}	
					else if( abs(vxBm.dotProduct(ptEnd - ptIntersect)) < U(75) ){
						lnSeg = LineSeg(ptStart, ptEnd - vLineSeg * U(3));
						ptStart = lnSeg.ptStart();
						ptEnd = lnSeg.ptEnd();
						bIsTConnection = TRUE;
					}
				}
			}


			if( vLineSeg.dotProduct(vyEl) > .9 ){
				Line lnNailLine(ptStart, vLineSeg);
				for( int k=0;k<arBmTopPlate.length();k++ ){
					Beam bmTopPlate = arBmTopPlate[k];

					//Coordsys of the topPlate
					Vector3d vxBmTP = bmTopPlate.vecX();
					Vector3d vzBmTP = vxBmTP.crossProduct(vzEl);
					if( vzBmTP.dotProduct(vyEl) < 0 ){
						vzBmTP = -vzBmTP;
					}
					
					//Find the intersection point
					Point3d ptBmTop = bmTopPlate.ptCen() + vzBmTP * .5 * bmTopPlate.dD(vzBmTP);
					Point3d ptIntersect = lnNailLine.intersect(Plane(ptBmTop, vzBmTP),0);
					
					//Check if its a valid point
					Point3d ptBmMin = bmTopPlate.ptRef() + vxBmTP * bmTopPlate.dLMin();
					Point3d ptBmMax = bmTopPlate.ptRef() + vxBmTP * bmTopPlate.dLMax();
					if( (vxBmTP.dotProduct(ptBmMin - ptIntersect) * vxBmTP.dotProduct(ptBmMax - ptIntersect)) > 0 )continue;
					
					//Check if the the nailline is close to the topplate
					if( abs(vLineSeg.dotProduct(ptIntersect - ptEnd)) < dDistanceToTopPlate ){
						ptEnd = ptIntersect - vLineSeg * dDistanceToTopPlate;
						break;
					}
				}
				
				for( int k=0;k<arBmBottomPlate.length();k++ ){
					Beam bmBottomPlate = arBmBottomPlate[k];
					
					//Coordsys of the topPlate
					Vector3d vxBmBP = bmBottomPlate.vecX();
					Vector3d vzBmBP = vxBmBP.crossProduct(vzEl);
					if( vzBmBP.dotProduct(vyEl) < 0 ){
						vzBmBP = -vzBmBP;
					}
					
					//Find the intersection point
					Point3d ptBmBottom = bmBottomPlate.ptCen() - vzBmBP * .5 * bmBottomPlate.dD(vzBmBP);
					Point3d ptIntersect = lnNailLine.intersect(Plane(ptBmBottom, vzBmBP),0);
					
					//Check if its a valid point
					Point3d ptBmMin = bmBottomPlate.ptRef() + vxBmBP * bmBottomPlate.dLMin();
					Point3d ptBmMax = bmBottomPlate.ptRef() + vxBmBP * bmBottomPlate.dLMax();
					if( (vxBmBP.dotProduct(ptBmMin - ptIntersect) * vxBmBP.dotProduct(ptBmMax - ptIntersect)) > 0 )continue;
					
					//Check if the the nailline is close to the bottomplate
					if( abs(vLineSeg.dotProduct(ptIntersect - ptStart)) < dDistanceToBottomPlate ){
						ptStart = ptIntersect + vLineSeg * dDistanceToBottomPlate;
						break;
					}
				}
			}
			
			// make ElemNail tool to be used in the construction of a nailing line
			int nToolIndex = 0;
			ElemNail enl(nZone, ptStart, ptEnd, dDistBetweenNails, nToolIndex);
			
			// add the nailing line to the database
			NailLine nl;
			nl.dbCreate(el, enl);
			nl.setColor(nColorIndex); // set color of Nailing line
		}
		
		//Delete the dummy beams
		for( int j=0;j<arBmDummy.length();j++ ){
			Beam bmDummy = arBmDummy[j];
			bmDummy.dbErase();
		}
	}
}

eraseInstance();












#End
#BeginThumbnail



#End
