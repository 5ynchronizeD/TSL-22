#Version 8
#BeginDescription
Last modified by: Anno Sportel (anno.sportel@hsbcad.com)
19.10.2015  -  version 1.16












#End
#Type O
#NumBeamsReq 0
#NumPointsGrip 0
#DxaOut 1
#ImplInsert 1
#FileState 1
#MajorVersion 1
#MinorVersion 16
#KeyWords 
#BeginContents
/// <summary Lang=en>
/// Redistributes the internal sheeting. Use the center of the openings of the 
/// </summary>

/// <insert>
/// Select a set of elements
/// </insert>

/// <remark Lang=en>
/// .
/// </remark>

/// <version  value="1.16" date="19.10.2015"></version>

/// <history>
/// AS - 1.00 - 20.11.2008 -	Pilot version
/// AS - 1.01 - 24.11.2008 -	Implement inersection with connected walls
/// AS - 1.02 - 25.11.2008 -	Create beam
/// AS - 1.03 - 25.11.2008 -	Implement rule for no -, single - and double stud
/// AS - 1.04 - 25.11.2008 -	Add module information of selected wall to the tsl
/// AS - 1.05 - 26.11.2008 -	Implement rule for no -, single - and double stud
/// AS - 1.06 - 26.11.2008 -	Implement rule for no -, single - and double stud
/// AS - 1.07 - 26.11.2008 -	Validate that the Conected Points are inside of the Selected Element
/// AS - 1.08 - 24.02.2009 -	Add a minimum distance between the studs
/// AS - 1.09 - 29.05.2009 -	Updated with wall-codes for Myr and SmV
/// AS - 1.10 - 01.07.2009 -	Set grade of new studs to "Regel"
/// AS - 1.11 - 02.07.2009 -	Only place stud when the available space is more than the minimum distance specified in the tsl
/// AS - 1.12 - 24.08.2009 -	Also set the beamcode
/// AS - 1.13 - 01.10.2009 -	Check size of beam, must be full width of wall
/// AS - 1.14 - 14.12.2010 -	Updated with wall-codes CY, DI, DJ
/// Myresjohus - 1.15 - 13.01.2011 - Updated for Vägg 2010
/// AS - 1.16 - 19.10.2015 -	Make grade and beamcode uppercase.
/// </history>

//Logging
// 0 = error messages only
// 1 = debug
int nLog = 0;

//Script uses mm
Unit(1,"mm");
double dEps = U(0.1);

String arSCodeOuterWalls[]={
	"CA",
	"CB",
	"CC",
	"CF",
	"CL",
	"CP",
	"CT",
	"CV",
	"CX",
	"CY",
	"FA",
	"FB",
	"FC",
	"FF",
	"FL",
	"FP",
	"FT",
	"MA",
	"MC",
	"MF",
	"ML",
	"MP",
	"MT",
	"Add codes for outer walls here"
};

String arSCodeInnerWalls[] = {
	"DA",
	"DB",
	"DC",
	"DD",
	"DE",
	"DF",
	"DG",
	"DH",
	"DI",
	"DJ",
	"DK",
	"DL",
	"DM",
	"DN",
	"DO",
	"DP",
	"DQ",
	"DR",
	"DT",
	"DU",
	"DV",
	"DZ",
	"SA",
	"SB",
	"SC",
	"SI",
	"SJ",
	"SK",
	"SL",
	"Add codes for inner walls here"
};

int arNBmTypeTop[] = {
	_kSFTopPlate
};
int arNBmTypeBottom[] = {
	_kSFBottomPlate
};

double dToleranceStudPosition = U(0.1);

double dMinimumAllowedDistanceStudToTConnection  = U(15);
double dMinimumAllowedDistanceDoubleStudAtTConnection = U(60);
double dMaximumAllowedDistanceDoubleStudAtTConnection = U(90);

double dMinimumAllowedSpacingBetweenStuds = U(45);

String sStudId = "30";
int nStudColor = 32;

//Insert
if( _bOnInsert ){
	//Erase after 1 cycle
	if( insertCycleCount() > 1 ){
		eraseInstance();
		return;
	}
	
	//Select beam(s) and insertion point
	PrEntity ssE(T("|Select one or more elements|"), ElementWallSF());
	if (ssE.go()) {
		Element arSelectedElements[] = ssE.elementSet();

		String strScriptName = "Myr-T-Connections"; // name of the script
		Vector3d vecUcsX(1,0,0);
		Vector3d vecUcsY(0,1,0);
		Beam lstBeams[0];
		Element lstElements[1];
		
		Point3d lstPoints[0];
		int lstPropInt[0];
		double lstPropDouble[0];
		String lstPropString[0];
		Map mapTsl;
		mapTsl.setInt("MasterToSatellite", TRUE);
		setCatalogFromPropValues("MasterToSatellite");
		
		for( int i=0;i<arSelectedElements.length();i++ ){
			Element selectedEl = arSelectedElements[i];
			if( arSCodeOuterWalls.find(selectedEl.code()) == -1 )continue;
			
			lstElements[0] = selectedEl;
			
			TslInst tsl;
			tsl.dbCreate(strScriptName, vecUcsX,vecUcsY,lstBeams, lstElements, lstPoints, lstPropInt, lstPropDouble, lstPropString, _kModelSpace, mapTsl);
		}
	}
	
	return;
}

if( _Map.hasInt("MasterToSatellite") ){
	int bMasterToSatellite = _Map.getInt("MasterToSatellite");
	if( bMasterToSatellite ){
		int bPropertiesSet = _ThisInst.setPropValuesFromCatalog("MasterToSatellite");
		_Map.removeAt("MasterToSatellite", TRUE);
	}
}

//Number of elements
if( _Element.length() == 0 ){
	eraseInstance();
	return;
}

//ElementWallSF
ElementWallSF elSelected = (ElementWallSF)_Element[0];
Beam arBmElSelected[] = elSelected.beam();

//Check if selected element is an elementWallSF
if( !elSelected.bIsValid() ){
	eraseInstance();
	return;
}

//Insertion point
_Pt0 = elSelected.ptOrg();

//Coordinate system
CoordSys csElSelected = elSelected.coordSys();
Vector3d vxElSelected = csElSelected.vecX();
Vector3d vyElSelected = csElSelected.vecY();
Vector3d vzElSelected = csElSelected.vecZ();

//Lines
Line lnElSelectedX(_Pt0, vxElSelected);
Line lnElSelectedY(_Pt0, vyElSelected);
Line lnElSelectedZ(_Pt0, vzElSelected);

//Outline of the selected element (outside element)
PLine plOutlineSelectedWall = elSelected.plOutlineWall();
Point3d arPtPlOutlineSelectedWall[] = plOutlineSelectedWall.vertexPoints(TRUE);
Point3d arPtPlOutlineSelectedWallZ[] = lnElSelectedZ.orderPoints(arPtPlOutlineSelectedWall);
if( arPtPlOutlineSelectedWallZ.length() < 2 ){
	reportWarning(TN("|Not enough points found on wall outline!|"));
	eraseInstance();
	return;
}
Plane pnElSelected(arPtPlOutlineSelectedWallZ[0], -vzElSelected);

//Find module information in the selected wall
String arSModuleName[0];
Point3d arPtModuleStart[0];
Point3d arPtModuleEnd[0];
for( int i=0;i<arBmElSelected.length();i++ ){
	Beam bmElSelected = arBmElSelected[i];
	String sModuleName = bmElSelected.module();
	//Check if modulename is empty
	if( sModuleName == "" )continue;
	
	Point3d arPtBm[] = bmElSelected.realBody().allVertices();
	arPtBm = lnElSelectedX.projectPoints(arPtBm);
	arPtBm = lnElSelectedX.orderPoints(arPtBm);
	if( arPtBm.length() < 2 )continue;
	Point3d ptBmStart = arPtBm[0];
	Point3d ptBmEnd = arPtBm[arPtBm.length() - 1];
	
	//Module index
	int nModuleIndex = arSModuleName.find(sModuleName);
	if( nModuleIndex == -1 ){
		arSModuleName.append(sModuleName);
		arPtModuleStart.append(ptBmStart);
		arPtModuleEnd.append(ptBmEnd);
		
		continue;
	}
	
	Point3d ptModuleStart = arPtModuleStart[nModuleIndex];
	if( vxElSelected.dotProduct(ptBmStart - ptModuleStart) < 0 ){
		arPtModuleStart[nModuleIndex] = ptBmStart;
	}
	Point3d ptModuleEnd = arPtModuleEnd[nModuleIndex];
	if( vxElSelected.dotProduct(ptModuleEnd - ptBmEnd) < 0 ){
		arPtModuleEnd[nModuleIndex] = ptBmEnd;
	}
}

//Find connected walls
Element arElConnected[] = elSelected.getConnectedElements();

//Create a connecting stud in the selected wall for each valid connected wall
for( int i=0;i<arElConnected.length();i++ ){
	ElementWallSF elConnected = (ElementWallSF)arElConnected[i];
	
	//Log element code
	if( nLog == 1 ) reportNotice(elConnected.code());
	
	//Code should be in list of internal walls
	if( arSCodeInnerWalls.find(elConnected.code()) == -1 )continue;
	
	//Coordinate system
	CoordSys csElConnected = elConnected.coordSys();
	Vector3d vxElConnected = csElConnected.vecX();
	Vector3d vyElConnected = csElConnected.vecY();
	Vector3d vzElConnected = csElConnected.vecZ();
	
	//Linesegment that define the length of the element
	LineSeg lsElSelected=elSelected.segmentMinMax();
	
	//Lines
	Line lnElConnectedX(csElConnected.ptOrg(), vxElConnected);
	Line lnElConnectedY(csElConnected.ptOrg(), vyElConnected);
	Line lnElConnectedZ(csElConnected.ptOrg(), vzElConnected);
	
	//Outline of connected
	PLine plOutlineConnectedWall = elConnected.plOutlineWall();plOutlineConnectedWall.vis(i);
	Point3d arPtPlOutlineConnectedWall[] = plOutlineConnectedWall.vertexPoints(TRUE);
	
	//Points of connected wall on outline of selected wall
	Point3d arPtPointsOfConnectedWallOnSelectedWall[] = plOutlineConnectedWall.intersectPoints(pnElSelected);
	
	//Check if the points are outside of the Selected Element
	for( int j=0;j<arPtPointsOfConnectedWallOnSelectedWall.length();j++ ){
		Point3d ptAux=arPtPointsOfConnectedWallOnSelectedWall[j];
		if (vxElSelected.dotProduct(ptAux-lsElSelected.ptStart())*vxElSelected.dotProduct(ptAux-lsElSelected.ptEnd())>0)
		{
			arPtPointsOfConnectedWallOnSelectedWall.removeAt(j);
			j--;
		}
	}
	
	//Points of selected wall on outline of connected wall
	Point3d arPtPointsOfSelectedWallOnConnectedWall[0];
	for( int j=0;j<arPtPlOutlineSelectedWall.length();j++ ){
		Point3d pt = arPtPlOutlineSelectedWall[j];
		if( plOutlineConnectedWall.isOn(pt) ){
			arPtPointsOfSelectedWallOnConnectedWall.append(pt);
		}
	}
	
	//If there is more than one point of the selected wall on the connected wall its not corner- or a T-Connection, 
	//but a head-to-head connection
	if( arPtPointsOfSelectedWallOnConnectedWall.length() > 1 )continue;
	
	//There should be 2 points of the connected wall on the selected wall
	if( arPtPointsOfConnectedWallOnSelectedWall.length() != 2 )continue;
	
	//Order points from left to right
	Point3d arPtPointsOfConnectedWallOnSelectedWallX[] = lnElSelectedX.orderPoints(arPtPointsOfConnectedWallOnSelectedWall);
	//Points on outline of selected wall
	Point3d ptLeftConnectedWall = arPtPointsOfConnectedWallOnSelectedWallX[0];
	Point3d ptRightConnectedWall = arPtPointsOfConnectedWallOnSelectedWallX[1];
	//This is the position to create a new stud in the selected wall
	Point3d ptMiddleConnectedWall = (ptLeftConnectedWall + ptRightConnectedWall)/2;
	
	//Beams of the selected walls
	Beam arBmSelectedWall[] = elSelected.beam();
	Beam arBmSelectedWallVertical[] = vxElSelected.filterBeamsPerpendicularSort(arBmSelectedWall);
	Beam arBmSelectedWallStud[0];
	Point3d arPtCenSelectedWallStud[0];
	for( int j=0;j<arBmSelectedWallVertical.length();j++ ){
		Beam bmSelectedWall = arBmSelectedWallVertical[j];
		//Visualize the beam in debug mode
		bmSelectedWall.realBody().vis(bmSelectedWall.color());
		
		//Check if its a full stud
		Beam arBmSelectedWallNotThis[] = bmSelectedWall.filterGenBeamsNotThis(arBmSelectedWall);
		//Intersection at top
		Beam arBmTop[] = Beam().filterBeamsHalfLineIntersectSort(arBmSelectedWallNotThis, bmSelectedWall.ptCen(), vyElSelected);
		//Intersection at bottom
		Beam arBmBottom[] = Beam().filterBeamsHalfLineIntersectSort(arBmSelectedWallNotThis, bmSelectedWall.ptCen(), -vyElSelected);
		//check length of arrays
		if( arBmTop.length() == 0 || arBmBottom.length() == 0 )continue;
		
		//Beam at top
		Beam bmTop = arBmTop[0];
		int nBmTypeTop = bmTop.type();
		//Beam at bottom
		Beam bmBottom = arBmBottom[0];
		int nBmTypeBottom = bmBottom.type();
		
		//Add it if its a full stud; intersection with top and bottom plate
		if( (arNBmTypeTop.find(nBmTypeTop) != -1) && (arNBmTypeBottom.find(nBmTypeBottom) != -1) ){
			arBmSelectedWallStud.append(bmSelectedWall);
			arPtCenSelectedWallStud.append(bmSelectedWall.ptCen());
		}		
	}

	//Index of the stud in the selected wall closest to the connected wall
	int nIndexBmSelectedWallClosestToConnectedWall = -1;
	double dMinimumDistanceSelectedWallStudToConnectedWall;
	for( int j=0;j<arPtCenSelectedWallStud.length();j++ ){
		Point3d ptCenSelectedWallStud = arPtCenSelectedWallStud[j];
		
		if( nLog == 1 ){
			//Draw corresponding beam
			Beam bmSelectedWallStud = arBmSelectedWallStud[j];
			bmSelectedWallStud.realBody().vis(bmSelectedWallStud.color());
		}
		
		double dDistanceSelectedWallStudToConnectedWall = vxElSelected.dotProduct(ptMiddleConnectedWall - ptCenSelectedWallStud);
		if( j==0 ){
			dMinimumDistanceSelectedWallStudToConnectedWall = dDistanceSelectedWallStudToConnectedWall;
			nIndexBmSelectedWallClosestToConnectedWall = j;
			continue;
		}
		
		if( abs(dDistanceSelectedWallStudToConnectedWall) < abs(dMinimumDistanceSelectedWallStudToConnectedWall) ){
			dMinimumDistanceSelectedWallStudToConnectedWall = dDistanceSelectedWallStudToConnectedWall;
			nIndexBmSelectedWallClosestToConnectedWall = j;
		}
		if( dDistanceSelectedWallStudToConnectedWall < 0 ){
			break;
		}
	}
	if( nIndexBmSelectedWallClosestToConnectedWall == -1 ){
		reportWarning(
			TN("Could not find a beam to copy!") + 
			TN("Outside wall ")+elSelected.code() + 
			TN("Connected wall ") + elConnected.code()
		);
		continue;
	}
	//Closest beam and point
	Beam bmClosestStud = arBmSelectedWallStud[nIndexBmSelectedWallClosestToConnectedWall];
	Point3d ptCenClosestStud = arPtCenSelectedWallStud[nIndexBmSelectedWallClosestToConnectedWall];
	ptCenClosestStud.vis(5);
	//Visualize point in debug mode
	ptMiddleConnectedWall.vis(1);
	
	//Skip this connection if there is already a stud at that location
	if( abs(dMinimumDistanceSelectedWallStudToConnectedWall) < dMinimumAllowedDistanceStudToTConnection || bmClosestStud.hsbId() == "30" )
		continue;
	
	int bSkipThisConnection = FALSE;
	//Move ptMiddleConnectedWall if needed.
	double dWNewStud = bmClosestStud.dD(vxElSelected);
	if( abs(dMinimumDistanceSelectedWallStudToConnectedWall) < dWNewStud ){
		//Move the new stud a little bit
		int nSide = dMinimumDistanceSelectedWallStudToConnectedWall/abs(dMinimumDistanceSelectedWallStudToConnectedWall);
		ptMiddleConnectedWall += vxElSelected * nSide * (dWNewStud + dMinimumDistanceSelectedWallStudToConnectedWall * -nSide);
		for( int j=0;j<arPtCenSelectedWallStud.length();j++ ){
			if( j== nIndexBmSelectedWallClosestToConnectedWall )
				continue;
			Point3d ptCenSelectedWallStud = arPtCenSelectedWallStud[j];
			if( abs(vxElSelected.dotProduct(ptCenSelectedWallStud- ptMiddleConnectedWall)) < (dWNewStud + dMinimumAllowedSpacingBetweenStuds) ){
				bSkipThisConnection = TRUE;
				break;
			}
		}
	}
	if( bSkipThisConnection ){
		continue;
	}

	//Visualize point in debug mode
	ptMiddleConnectedWall.vis(3);
	
	//Check if the middle of the connected wall is in a module.... if so: do not create T-connection studs
	//Also find the distance to the closest sub element
	double dMinimumDistanceSubElementToConnectedWall;
	for( int j=0;j<arPtModuleStart.length();j++ ){
		Point3d ptModuleStart = arPtModuleStart[j];
		Point3d ptModuleEnd = arPtModuleEnd[j];
		
		if( (vxElSelected.dotProduct(ptModuleStart - ptMiddleConnectedWall) * vxElSelected.dotProduct(ptModuleEnd - ptMiddleConnectedWall)) < 0 ){
			bSkipThisConnection = TRUE;
			break;
		}
		
		double dDistanceSubElementStartToConnectedWall = vxElSelected.dotProduct(ptMiddleConnectedWall - ptModuleStart);
		double dDistanceSubElementEndToConnectedWall = vxElSelected.dotProduct(ptMiddleConnectedWall - ptModuleEnd);

		if( j==0 ){
			dMinimumDistanceSubElementToConnectedWall = dDistanceSubElementStartToConnectedWall;
			if( abs(dDistanceSubElementEndToConnectedWall) < abs(dMinimumDistanceSubElementToConnectedWall) ){
				dMinimumDistanceSubElementToConnectedWall = dDistanceSubElementEndToConnectedWall;
			}
			continue;
		}
		
		if( abs(dDistanceSubElementStartToConnectedWall) < abs(dMinimumDistanceSubElementToConnectedWall) ){
			dMinimumDistanceSubElementToConnectedWall = dDistanceSubElementStartToConnectedWall;
		}
		if( abs(dDistanceSubElementEndToConnectedWall) < abs(dMinimumDistanceSubElementToConnectedWall) ){
			dMinimumDistanceSubElementToConnectedWall = dDistanceSubElementEndToConnectedWall;
		}
	}
	if( bSkipThisConnection ){
		continue;
	}
	
	//if on debug: uncomment next line
	//return;
//reportNotice(TN("dMinimumDistanceSubElementToConnectedWall: ")+dMinimumDistanceSubElementToConnectedWall);
//reportNotice(TN("dMinimumDistanceSelectedWallStudToConnectedWall: ")+dMinimumDistanceSelectedWallStudToConnectedWall);	
	//Transformation needed for the new stud
	double dTransformation = vxElSelected.dotProduct(ptMiddleConnectedWall - ptCenClosestStud);
	int nTransformationDirection = dTransformation/abs(dTransformation);
	if( 	abs(dMinimumDistanceSelectedWallStudToConnectedWall) < dMaximumAllowedDistanceDoubleStudAtTConnection &&
		abs(dMinimumDistanceSelectedWallStudToConnectedWall) >= dMinimumAllowedDistanceDoubleStudAtTConnection
	){
		int nAmount = 2;
		if( (dMinimumDistanceSubElementToConnectedWall * dMinimumDistanceSelectedWallStudToConnectedWall) < 0 ){
			double dAvailableSpace = abs(dMinimumDistanceSubElementToConnectedWall) + abs(dMinimumDistanceSelectedWallStudToConnectedWall);
//reportNotice(TN("Available space: ")+dAvailableSpace);

			
			if( dAvailableSpace - 1.5 * dMinimumAllowedSpacingBetweenStuds < dMinimumAllowedSpacingBetweenStuds ){
				nAmount = 0;
			}
			else if( dAvailableSpace - 2.5 * dMinimumAllowedSpacingBetweenStuds < dMinimumAllowedSpacingBetweenStuds ){
				nAmount = 1;
			}
		}
		
		for( int j=0;j<nAmount;j++ ){
			//Copy and transform closest stud
			Beam bmNewStud = bmClosestStud.dbCopy();
			bmNewStud.transformBy(vxElSelected * (j+1) * dWNewStud * nTransformationDirection);
			bmNewStud.setColor(nStudColor);
			bmNewStud.setGrade("REGEL");
			bmNewStud.setBeamCode(";;;;;;;;;REGEL;;;");
			bmNewStud.setHsbId(sStudId);
			bmNewStud.setType(_kStud);
			bmNewStud.setModule("");
			double dToElCen = vzElSelected.dotProduct( (elSelected.ptOrg() - vzElSelected * .5 * elSelected.zone(0).dH()) - bmNewStud.ptCen());
			if( abs(dToElCen) > dEps ){
				bmNewStud.transformBy(vzElSelected * dToElCen);
				bmNewStud.setD(vzElSelected, bmNewStud.dD(vzElSelected) + 2 * dToElCen);
			}
				
		}
	}
	else{
		if( abs(dMinimumDistanceSelectedWallStudToConnectedWall) < dMinimumAllowedDistanceDoubleStudAtTConnection ){
			dTransformation = dWNewStud * nTransformationDirection;
		}
//		if( dMinimumAllowedSpacingBetweenStuds )
//			continue;
		//Copy and transform closest stud
		Beam bmNewStud = bmClosestStud.dbCopy();
		bmNewStud.transformBy(vxElSelected * dTransformation);
		bmNewStud.setColor(nStudColor);
		bmNewStud.setGrade("REGEL");
		bmNewStud.setBeamCode(";;;;;;;;;REGEL;;;");
		bmNewStud.setHsbId(sStudId);
		bmNewStud.setType(_kStud);
		bmNewStud.setModule("");
		double dToElCen = vzElSelected.dotProduct( (elSelected.ptOrg() - vzElSelected * .5 * elSelected.zone(0).dH()) - bmNewStud.ptCen());
		if( abs(dToElCen) > dEps ){
			bmNewStud.transformBy(vzElSelected * dToElCen);
			bmNewStud.setD(vzElSelected, bmNewStud.dD(vzElSelected) + 2 * dToElCen);
		}
	}
}

//EraseInstance
eraseInstance();









#End
#BeginThumbnail













#End