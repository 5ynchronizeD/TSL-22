#Version 8
#BeginDescription
Last modified by: Anno Sportel (as@hsb-cad.com)
04.09.2009  -  version 1.2




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
/// Redistributes the internal sheeting. Use the center of the openings of the 
/// </summary>

/// <insert>
/// Select a set of elements
/// </insert>

/// <remark Lang=en>
/// .
/// </remark>

/// <version  value="1.02" date="04.09.2009"></version>

/// <history>
/// AS - 1.00 - 16.07.2009 - Pilot version
/// AS - 1.01 - 04.09.2009 - Solve issue with detailoverride left AND right
/// AS - 1.02 - 04.09.2009 - Tsl now ignores internal walls..and doesnt erase this tsl when it finds an internal wall
/// </history>

double dEps = U(0.001);

PropString sDetailOverrideSplit(0, "SPLIT", T("|Detailoverride wall-split|"));
PropString sDetailOverrideCorner(1, "CORNER", T("|Detailoverride corner|"));

String arSYesNo[] = {T("|Yes|"), T("|No|")};
int arNYesNo[] = {_kYes, _kNo};
PropString sPrefixWithWallType(2, arSYesNo, T("|Prefix with wall type|"));

double dOpeningFromSideMin = U(644);
double dOpeningFromSideMax = U(796);

if (_bOnDbCreated) setPropValuesFromCatalog(_kExecuteKey);

int bPrefixWithWallCode = arNYesNo[arSYesNo.find(sPrefixWithWallType,0)];

if( _bOnInsert ){
	//Erase after 1 cycle
	if( insertCycleCount() > 1 ){
		eraseInstance();
		return;
	}
	
	//Showdialog
	if (_kExecuteKey=="")
		showDialog();	
	
	//Select beam(s) and insertion point
	PrEntity ssE(T("|Select one or more elements|"), ElementWallSF());
	if (ssE.go()) {
		Element arSelectedElements[] = ssE.elementSet();

		//insertion point
		String strScriptName = "Myr-DetailOverrides"; // name of the script
		Vector3d vecUcsX(1,0,0);
		Vector3d vecUcsY(0,1,0);
		Beam lstBeams[0];
		Entity lstEntities[1];
		
		Point3d lstPoints[0];
		int lstPropInt[0];
		double lstPropDouble[0];
		String lstPropString[0];
		Map mapTsl;
		mapTsl.setInt("MasterToSatellite", TRUE);
		setCatalogFromPropValues("MasterToSatellite");
		
		for( int i=0;i<arSelectedElements.length();i++ ){
			ElementWallSF elSF = (ElementWallSF)arSelectedElements[i];
			if( !elSF.bIsValid() ){
				continue;
			}
			lstEntities[0] = elSF;
			
			TslInst tsl;
			tsl.dbCreate(strScriptName, vecUcsX,vecUcsY,lstBeams, lstEntities, lstPoints, lstPropInt, lstPropDouble, lstPropString, _kModelSpace, mapTsl);
		}
	}
	
	eraseInstance();
	return;
}
//Done after the first execution, set the properties which were set in the master
if( _Map.hasInt("MasterToSatellite") ){
	int bMasterToSatellite = _Map.getInt("MasterToSatellite");
	if( bMasterToSatellite ){
		int bPropertiesSet = _ThisInst.setPropValuesFromCatalog("MasterToSatellite");
		_Map.removeAt("MasterToSatellite", TRUE);
	}
}

if( _Element.length()==0 ){
	reportMessage(TN("|No element selected|"));
	eraseInstance();
	return;
}

ElementWallSF el = (ElementWallSF)_Element[0];
if( !el.bIsValid() ){
	reportMessage(TN("|Selected element is not a valid stickframe wall|"));
	eraseInstance();
	return;
}

//Only external walls
String sElCode = el.code();
if( sElCode.left(1) != "C" ){
	reportMessage(TN("|Selected element is not an external wall|"));
	eraseInstance();
	return;
}

//CoordSys
CoordSys csEl = el.coordSys();
Point3d ptEl = csEl.ptOrg();
Vector3d vxEl = csEl.vecX();
Vector3d vyEl = csEl.vecY();
Vector3d vzEl = csEl.vecZ();

//Line to order points
Line lnX(ptEl,vxEl);

//Get the extremes of the wall
PLine plElement = el.plOutlineWall();
Point3d arPtEl[] = plElement.vertexPoints(TRUE);
Point3d arPtElX[] = lnX.orderPoints(arPtEl);
Point3d ptElLeft = arPtElX[0];
Point3d ptElRight = arPtElX[arPtElX.length() - 1];

//get the openings. Only apply this tsl when one of the openings is closer than the specified distance from the edge of the element
Opening arOp[] = el.opening();

//Check if one of the openings is close to the edge of the element
int bOverrideLeft = FALSE;
int bOverrideRight = FALSE;
for( int i=0;i<arOp.length();i++ ){
	Opening op = arOp[i];
	Point3d arPtOp[] = op.plShape().vertexPoints(TRUE);
	
	arPtOp = lnX.orderPoints(arPtOp);
	if( arPtOp.length() < 2 )
		continue;
	
	double dLeft = abs(vxEl.dotProduct(ptElLeft - arPtOp[0]));
	if( (dLeft <=  dOpeningFromSideMax) && (dLeft >= dOpeningFromSideMin) )
		bOverrideLeft = TRUE;
		
	double dRight = abs(vxEl.dotProduct(ptElRight - arPtOp[arPtOp.length() - 1]));
	if( dRight <=  dOpeningFromSideMax && dRight >=  dOpeningFromSideMin )
		bOverrideRight = TRUE;
}

//Remove tsl if a detail override is not needed
if( !(bOverrideLeft || bOverrideRight) ){
	reportMessage(TN("|No overrides needed|"));
	eraseInstance();
	return;
}

Display dp(-1);
dp.draw(scriptName(), ptEl, vxEl, vyEl, 0, 0, _kDevice);

//Find the connected elements connection determines the type of override
Element arElConnected[] = el.getConnectedElements();

int bIsWallSplitLeft = FALSE;
int bIsWallSplitRight = FALSE;
for( int i=0;i<arElConnected.length();i++ ){
	Element elConnected = arElConnected[i];
	
	//Only external walls
	String sElCode = elConnected.code();
	if( sElCode.left(1) != "C" ){
		reportMessage(TN("|Invalid wall found|"));
		continue;
	}
	
	int bLeft = FALSE;
	if( vxEl.dotProduct(ptEl - elConnected.ptOrg()) > 0 )
		bLeft = TRUE;
	
	//Figure out what kind of connection it is; only check if it is a split, otherwise use default override (Corner)
	if( elConnected.vecZ().isParallelTo(vzEl) ){
		if( bLeft ){
			bIsWallSplitLeft = TRUE;
		}
		else{
			bIsWallSplitRight = TRUE;
		}
		break;
	}	
}

String sPrefix = "";
if( bPrefixWithWallCode )
	sPrefix = el.code();


if( bOverrideLeft ){
	if( bIsWallSplitLeft ){
		el.setConstrDetailLeft(sPrefix + sDetailOverrideSplit);
	}
	else{
		el.setConstrDetailLeft(sPrefix + sDetailOverrideCorner);
	}
}
else if( bOverrideRight ){
	if( bIsWallSplitRight ){
		el.setConstrDetailRight(sPrefix + sDetailOverrideSplit);
	}
	else{
		el.setConstrDetailRight(sPrefix + sDetailOverrideCorner);
	}
}

//Erase tsl
eraseInstance();




#End
#BeginThumbnail



#End
