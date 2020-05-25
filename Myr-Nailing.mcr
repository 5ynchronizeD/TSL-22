#Version 8
#BeginDescription
Last modified by: OBOS (Oscar.ragnerby@obos.se)
05.12.2019  -  version 1.09








#End
#Type O
#NumBeamsReq 0
#NumPointsGrip 0
#DxaOut 1
#ImplInsert 1
#FileState 1
#MajorVersion 1

#MinorVersion 9

#KeyWords 
#BeginContents
/// <summary Lang=en>
/// Create nailing lines
/// </summary>

/// <insert>
/// Select a set of elements
/// </insert>

/// <remark Lang=en>
/// .
/// </remark>


/// <version  value="1.09" date="05.12.2019"></version>


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
/// AS - 1.06 - 12.06.2015 	- Nail zone 7 and not 6 if it is available. Add support for execution on generate construction and from master tsl.
/// AS - 1.07 - 03.09.2015 	- Dummy beams removed outside the loop for creating nail lines.

/// OR - 1.08 - 05.06.2019	- Offset from T connected beams changed 
/// OR - 1.09 - 05.12.2019	- Offset from T connected beams changed 

/// </history>

double dEps(Unit(1,"mm"));

double dSizeTP = U(54);
double dDistanceToTopPlate = U(225);

double dSizeBP = U(54);
double dDistanceToBottomPlate = U(210);

double dDistanceToTConnection = U(55.6);
double dDistanceToSheetEdge = U(22);
double dOffsetFromSheetJoint = U(100);
double dOffsetFromSheetEdge = U(10);
double dNoNailZoneSize = U(45);

int nColorIndex = 4;

String categories[] = {
	T("|Element filter|"),
	T("|Generation|"),
	T("|Nailing|")
};

String SubElementToSkipNoNailZone[] = 
{
	"MH_EL"
};

String elementFilterCatalogNames[] = TslInst().getListOfCatalogNames("hsbElementFilter");
elementFilterCatalogNames.insertAt(0, T("|Do not use an element filter|"));
PropString elementFilter(0, elementFilterCatalogNames, T("|Element filter catalog|"));
elementFilter.setDescription(T("|Sets the element filter to use.|"));
elementFilter.setCategory(categories[0]);

PropInt sequenceForGeneration(0, 0, T("|Sequence number|"));
sequenceForGeneration.setDescription(T("|The sequence number is used to sort the list of tsls during the generation of the element.|"));
sequenceForGeneration.setCategory(categories[1]);
// Set the sequence for execution on generate construction.
_ThisInst.setSequenceNumber(sequenceForGeneration);


PropDouble dDistBetweenNails(1,U(200),T("Distance between nails"));
dDistBetweenNails.setDescription(T("|Sets the distance between the nails.|"));
dDistBetweenNails.setCategory(categories[2]);

// Is it an initial insert by the tool inserter? Return and wait for recalc after the props are set correctly.
int executeMode = -1;
if (_Map.hasInt("ExecuteMode")) 
	executeMode = _Map.getInt("ExecuteMode");
if (executeMode == 69)
	return;

// Set properties if inserted with an execute key
String arSCatalogNames[] = TslInst().getListOfCatalogNames("Myr-Nailing");
if( arSCatalogNames.find(_kExecuteKey) != -1 ) 
	setPropValuesFromCatalog(_kExecuteKey);
	
if(_bOnElementConstructed)
{ 
	eraseInstance();
}


if( _bOnInsert ){
	if( insertCycleCount() > 1 ){
		eraseInstance();
		return;
	}
	
	if( _kExecuteKey == "" || arSCatalogNames.find(_kExecuteKey) == -1 )
		showDialog();
	
	int nNrOfTslsInserted = 0;
	PrEntity ssE(T("Select a set of elements"), ElementWallSF());

	if( ssE.go() ){
		Element arSelectedElement[0];
		if (elementFilter !=  elementFilterCatalogNames[0]) {
			Entity selectedEntities[] = ssE.set();
			Map elementFilterMap;
			elementFilterMap.setEntityArray(selectedEntities, false, "Elements", "Elements", "Element");
			TslInst().callMapIO("hsbElementFilter", elementFilter, elementFilterMap);
			
			Entity filteredEntities[] = elementFilterMap.getEntityArray("Elements", "Elements", "Element");
			for (int i=0;i<filteredEntities.length();i++) {
				Element el = (Element)filteredEntities[i];
				if (!el.bIsValid())
					continue;
				arSelectedElement.append(el);
			}
		}
		else {
			arSelectedElement = ssE.elementSet();
		}
		
		String strScriptName = "Myr-Nailing"; // name of the script
		Vector3d vecUcsX(1,0,0);
		Vector3d vecUcsY(0,1,0);
		Beam lstBeams[0];
		Element lstElements[1];
		
		Point3d lstPoints[0];
		int lstPropInt[0];
		double lstPropDouble[0];
		String lstPropString[0];
		Map mapTsl;
		mapTsl.setInt("MasterToSatellite", true);
		mapTsl.setInt("ManualInsert", true);
		setCatalogFromPropValues("MasterToSatellite");
				
		for( int e=0;e<arSelectedElement.length();e++ ){
			Element el = arSelectedElement[e];
			
			lstElements[0] = el;

			TslInst tsl;
			tsl.dbCreate(strScriptName, vecUcsX,vecUcsY,lstBeams, lstElements, lstPoints, lstPropInt, lstPropDouble, lstPropString, _kModelSpace, mapTsl);
			nNrOfTslsInserted++;
		}
	}
	
	reportMessage(nNrOfTslsInserted + T(" |tsl(s) inserted|"));
	
	eraseInstance();
	return;
}

if( _Map.hasInt("MasterToSatellite") ){
	int bMasterToSatellite = _Map.getInt("MasterToSatellite");
	if( bMasterToSatellite ){
		int bPropertiesSet = _ThisInst.setPropValuesFromCatalog("MasterToSatellite");
		_Map.removeAt("MasterToSatellite", TRUE);
	}
}

int bManualInsert = false;
if( _Map.hasInt("ManualInsert") ){
	bManualInsert = _Map.getInt("ManualInsert");
	_Map.removeAt("ManualInsert", true);
}

if (_Element.length() == 0) {
	reportError(T("|No element selected|"));
	eraseInstance();
	return;
}

ElementWallSF el= (ElementWallSF) _Element[0];
if (!el.bIsValid()) { 
	eraseInstance();
	return;
}

//Create coordsys
CoordSys csEl = el.coordSys();
Vector3d vxEl = csEl.vecX();
Vector3d vyEl = csEl.vecY();
Vector3d vzEl = csEl.vecZ();
//Set origin point
_Pt0 = csEl.ptOrg();
_Pt0.vis(5);

Display NoNailZones(5);

//Collect all openings

//Entity arEntOp[] = el.collectEntities(TRUE, Opening(), _kModelSpace);


//Add no nail zones
Opening arOpenings[] = el.opening();

for (int i = 0; i < arOpenings.length(); i++)
{
	OpeningSF op = (OpeningSF)arOpenings[i];
	
	Element el = op.element();
	CoordSys elementCoordSys = el.coordSys();
	Vector3d elX = elementCoordSys.vecX();
	Vector3d elZ = elementCoordSys.vecZ();
	Vector3d elY = elementCoordSys.vecY();
	
	//reportMessage(op.constrDetail());
	//reportMessage(SubElementToSkipNoNailZone.find(op.constrDetail()));
	
	if (SubElementToSkipNoNailZone.find(op.constrDetail()) != -1) continue;
	
	CoordSys csOp = op.coordSys();
	Vector3d openingZ = csOp.vecZ();
	Vector3d openingX = csOp.vecX();
	Vector3d openingY = csOp.vecY();
	openingX.rotateBy(180, elZ);
	
	csOp.vis(2);
	
	openingX.normalize();
	openingZ.normalize();
	openingY.normalize();
	
	
	PLine plOp = op.plShape();
	
	Point3d arPtOp[] = plOp.vertexPoints(TRUE);
	
	Line lnX(csEl.ptOrg(), vxEl);
	Line lnY(csEl.ptOrg(), vyEl);
	lnX.vis();
	lnY.vis();
	Point3d arPtOpX[] = lnX.orderPoints(arPtOp);
	Point3d arPtOpY[] = lnY.orderPoints(arPtOp);
	
	if ( arPtOpX.length() < 2 || arPtOpY.length() < 2 )
	{
		reportMessage(T("|The selected opening has an invalid outline|!"));
		eraseInstance();
		return;
	}
	
	Point3d ptOpCenter = .5 * (arPtOpX[0] + arPtOpX[arPtOpX.length() - 1]);
	
	if (_bOnDebug) ptOpCenter.vis();
	
	for (int pt = 0; pt < arPtOpX.length(); pt++) {
		
		Point3d ptCorner = arPtOpX[pt];
		PLine plNoNailArea;
		Point3d arNoNailArea[0];
		Vector3d vVerticalDirection;
		Vector3d vHorizontalDirection;
		
		
		if (openingY.dotProduct(ptOpCenter - ptCorner) < 0)
		{
			vVerticalDirection = openingY;
		}
		else
		{
			vVerticalDirection = openingY.rotateBy(180, elZ);
		}
		
		if (csOp.vecX().dotProduct(ptOpCenter - ptCorner) < 0)
		{
			vHorizontalDirection = csOp.vecX();
		}
		else
		{
			vHorizontalDirection = csOp.vecX().rotateBy(180, elY);
		}
		
		vHorizontalDirection.vis(ptCorner, 20);
		vVerticalDirection.vis(ptCorner, 20);
		
		
		
		PlaneProfile ppEl = el.plEnvelope();
		ppEl.vis(50);
		
		//Check if point is valid
		Point3d NewPoint = ptCorner + vVerticalDirection * dNoNailZoneSize;
		NewPoint.vis();
		
		int bInElement = ppEl.pointInProfile(NewPoint);
		
		if(elY.dotProduct(_Pt0 - NewPoint) < 0)
		//if (bInElement)
		{
			
			//if (op.sillHeight() > 45 && ptCorner + vVerticalDirection * dNoNailZoneSize) {
			plNoNailArea.addVertex(ptCorner);
			plNoNailArea.addVertex(ptCorner + vVerticalDirection * dNoNailZoneSize);
			plNoNailArea.addVertex((ptCorner + vVerticalDirection * dNoNailZoneSize) + vHorizontalDirection * dNoNailZoneSize);
			plNoNailArea.addVertex(ptCorner + vHorizontalDirection * dNoNailZoneSize);
			plNoNailArea.addVertex(ptCorner);
			
			ElemNoNail NoNailArea(-1,plNoNailArea);
			el.addTool(NoNailArea);
		}
		
		
	}
}

//NoNailZones.vis();
//return;
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
	
	if( arSBmCodeToExcludeForTConnection.find(sBmCode) == -1)
		arBmAllowedForTConnection.append(bm);
	
	if( arNTypeTopPlate.find(nType) != -1 ){//Top plates
		arBmTopPlate.append(bm);
	}
	else if( arNTypeBottomPlate.find(nType) != -1 ){//Bottom plates
		arBmBottomPlate.append(bm);
	}
}

//LineSeg used during development
LineSeg lnSegMinMax = el.segmentMinMax();
//dp.draw(lnSegMinMax);

// remove all nailing lines of nZone with color nColorIndex
int nZnToNail = -1; // Change this to zone -2 if that zone has sheets.
int arNZone[] = {-1};
if (el.sheet(-2).length() > 0) {
	nZnToNail = -2;
	arNZone.append(-2);
}
// Remove the nails from these zones.
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
	
	//Zone to nail
	if( nZnToNail == 0 )continue;
	
	//Side
	int nSide = nZnToNail/abs(nZnToNail);
	
	// get coordSys of the back of zone 1 or -1, the surface of the beams
	CoordSys csBeam = el.zone(nSide).coordSys();csBeam.vis();
	// get the coordSys of the back of the zone to nail
	CoordSys csSheet = el.zone(nZnToNail).coordSys();
	
	//Beams to nail
	Beam arBmToNail[0];
	//Dummy beams used for alternative nailing positions; will be erased automatically
	Beam arBmDummy[0];

//	//Nailines at the back of the element, on the top- & bottomplate are split at modules
	if( nSide < 0 && (arBmTopPlate.find(bm) != -1 || arBmBottomPlate.find(bm) != -1) ){
		arBmToNail.append(bm);
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
		
	////Distance between nails
	//double dDistBetweenNails = arDDistBetweenNails[j];
	
	////Distance to top/bottom plate
	//double dDistanceToTopPlate = arDDistanceToTopPlate[j];
	//double dDistanceToBottomPlate = arDDistanceToBottomPlate[j];
	
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
	Sheet arSh[] = el.sheet(nZnToNail);
	
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
					lnSeg = LineSeg(ptStart + vLineSeg * dDistanceToTConnection, ptEnd);
					ptStart = lnSeg.ptStart();
					ptEnd = lnSeg.ptEnd();
					bIsTConnection = TRUE;
				}	
				else if( abs(vxBm.dotProduct(ptEnd - ptIntersect)) < U(75) ){
					lnSeg = LineSeg(ptStart, ptEnd - vLineSeg * dDistanceToTConnection);
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
		ElemNail enl(nZnToNail, ptStart, ptEnd, dDistBetweenNails, nToolIndex);
		
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


//eraseInstance();








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
    <lst nm="TSLINFO" />

  </lst>
  <unit ut="L" uv="millimeter" />
  <unit ut="A" uv="radian" />
</Hsb_Map>
#End