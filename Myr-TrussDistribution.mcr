#Version 8
#BeginDescription
Last modified by: Anno Sportel (anno.sportel@itwindustry.nl)
02.10.2009  -  version 1.5



#End
#Type O
#NumBeamsReq 0
#NumPointsGrip 0
#DxaOut 1
#ImplInsert 1
#FileState 1
#MajorVersion 1
#MinorVersion 5
#KeyWords 
#BeginContents
/// <summary Lang=en>
/// Add a truss-distribution. Tsl remains active in the drawing and allows redistribution of the trusses
/// </summary>

/// <insert>
/// Select roofplanes, select start- and endpoint and select point for direction
/// </insert>

/// <remark Lang=en>
/// Custom property added to redistribute the trusses
/// </remark>

/// <version  value="1.05" date="02.10.2009"></version>

/// <history>
/// AS - 0.01 - 11.03.2008 - Pilot version
/// AS - 0.02 - 12.03.2008 - Add distribution types
/// AS - 0.03 - 12.03.2008 - Correct last truss on distribution from both sides
/// AJ - 1.00 - 11.02.2009 - Add Properties to display information on the trusses
/// AS - 1.01 - 17.07.2009 - Add recalc trigger to redistribute the trusses
/// AS - 1.02 - 03.09.2009 - Add properties to set the distance to the first and last truss
/// AS - 1.03 - 30.09.2009 - Add properties to assign trusses to a selected floorgroup and a display representation
/// AS - 1.04 - 01.10.2009 - Remove reportnotice.
/// AS - 1.05 - 02.10.2009 - There was 1 truss too much when the option start-to-end was choosen with a small distance at the end.
/// </history>


int nExecuteKey = 0; 
// 0 = insert
// 1 = redistribute
// 2 = reset labels
// 3 = static

if( _Map.hasInt("ExecuteKey") ){
	nExecuteKey = _Map.getInt("ExecuteKey");
//	reportNotice(TN("Executekey: ")+nExecuteKey);
}



//Script uses mm
double dEps = Unit(.01,"mm");

//Properties
PropDouble dWTruss(0, U(45), T("Width of truss"));
//Spacing
PropDouble dSpacing(1, U(1200), T("Spacing"));

//Distance to center first & last truss
PropDouble dFirstTruss(2, U(22.5), T("|Distance to first truss|"));
PropDouble dLastTruss(3, U(22.5), T("|Distance to last truss|"));

//Non-Default Spacing
PropString sNonDefaultFieldIndexes(0, "2;", T("Non-default field indexes"));
PropString sNonDefaultFieldSpacings(1, "600;", T("Non-default field spacings"));
//Distribution type
String arSDistributionType[] = {
	T("From start to end"),
	T("From end to start"),
	T("From centre"),
	T("From both sides")
};
PropString sDistributionType(2, arSDistributionType, T("Distribution type"));

PropString sDimStyle(3, _DimStyles, T("Dimension style truss description"));

PropString sLabelMiddle (4, "", T("Label Middle"));
PropDouble dXOffsetMiddle (4, 0, T("X Offset Middle Text"));
PropString sLabelLeft(5, "", T("Label Left"));
PropDouble dXOffsetLeft (5, 0, T("X Offset Left Text"));
PropString sLabelRight(6, "", T("Label Right"));
PropDouble dXOffsetRight (6, 0, T("X Offset Right Text"));
PropDouble dYOffset (7, 0, T("Y Offset Text"));

String arSNameFloorGroup[0];
Group arFloorGroup[0];
Group arAllGroups[] = Group().allExistingGroups();
for( int i=0;i<arAllGroups.length();i++ ){
	Group grp = arAllGroups[i];
	if( grp.namePart(2) == "" && grp.namePart(1) != ""){
		arSNameFloorGroup.append(grp.name());
		arFloorGroup.append(grp);
	}
}

PropString sShowTrussInDispRep(7, _ThisInst.dispRepNames(), T("|Show truss in display representation|"));
PropString sNameFloorGroup(8, arSNameFloorGroup, T("|Floorgroup|"));

//Insert
if( _bOnInsert || nExecuteKey == 1 ){
	if( insertCycleCount() > 1 ){
		eraseInstance();
		return;
	}
	
	Entity arSelectedRfPlaneAsEntity[0];
	Point3d ptStartTrusses;
	Point3d ptEndTrusses;
	Vector3d vecDirection;
	if( nExecuteKey == 1 ){//Redistribute
		arSelectedRfPlaneAsEntity.append(_Entity);
		vecDirection = _Map.getVector3d("Direction");
		ptStartTrusses = _Map.getPoint3d("StartTrusses");
		ptEndTrusses = _Map.getPoint3d("EndTrusses");
	}
	else{//Insert
		//Select the roofplane
		PrEntity ssE(T("Select the roofplanes"), ERoofPlane());
		
		if( ssE.go() ){
			Entity arEnt[] = ssE.set();
			for( int i=0;i<arEnt.length();i++ ){
				Entity ent = arEnt[i];
				ERoofPlane eRoofPlane = (ERoofPlane)ent;
				if( eRoofPlane.bIsValid() ){
					arSelectedRfPlaneAsEntity.append(eRoofPlane);
				}
			}
		}
		_Entity.append(arSelectedRfPlaneAsEntity);
		
		//Select startpoint for distribution
		ptStartTrusses = getPoint(T("Select insert point of truss"));
		_Map.setPoint3d("StartTrusses", ptStartTrusses);
		PrPoint ssPtDirection(T("Select point for direction of truss"), ptStartTrusses);
		Point3d ptDirection;
		if( ssPtDirection.go() == _kOk ){
			ptDirection = ssPtDirection.value();
		}
		ptDirection += _ZW * _ZW.dotProduct(ptStartTrusses - ptDirection);
		vecDirection = Vector3d(ptDirection - ptStartTrusses);
		vecDirection.normalize();
		_Map.setVector3d("Direction", vecDirection);
		
		//End of distribution
		ptEndTrusses = getPoint(T("Select end point of distribution"));
		_Map.setPoint3d("EndTrusses", ptEndTrusses);
		
		//Show dialog
		showDialog();
	}
	
	// get the floorgroup for the main information
	Group grpFloor = arFloorGroup[arSNameFloorGroup.find(sNameFloorGroup)];
	//Coordsys of distribution
	Vector3d vx = vecDirection;
	Vector3d vy = _ZW.crossProduct(vecDirection);
	if( vy.dotProduct(-_XW + _YW) < 0 )
		vy = -vy;
	Vector3d vz = _ZW;
	vx = vy.crossProduct(vz);
	
	//Swap points if other ditribution type is used
	int nDistributionType = arSDistributionType.find(sDistributionType,0);

	if( nDistributionType == 1 ){
		Point3d ptTmp = ptStartTrusses;
		ptStartTrusses = ptEndTrusses;
		ptEndTrusses = ptTmp;
	}
	//Align coordsys properly
	if( vy.dotProduct(ptEndTrusses - ptStartTrusses) < 0 ){
		vx = -vx;
		vy = -vy;
	}
	
	//Reposition start- & endpoint. Truss needs to be on startpoint with the edge
	ptStartTrusses += vy * dFirstTruss;
	ptEndTrusses -= vy * dLastTruss;
	Point3d ptCentre = ptStartTrusses + vy * .5 * vy.dotProduct(ptEndTrusses - ptStartTrusses);
	
	_Pt0 = ptCentre;
	
	//Create a list of non-default field indexes, with the corresponding spacings
	String sNDFI = sNonDefaultFieldIndexes + ";";
	int arNNonDefaultFieldIndexes[0];
	int nIndexNDFI = 0; 
	int sIndexNDFI = 0;
	while(sIndexNDFI < sNDFI.length()-1){
		String sTokenNDFI = sNDFI.token(nIndexNDFI);
		nIndexNDFI++;
		if(sTokenNDFI.length()==0){
			sIndexNDFI++;
			continue;
		}
		sIndexNDFI = sNDFI.find(sTokenNDFI,0);
	
		int nTokenNDFI = sTokenNDFI.atoi();
		if( nTokenNDFI == 0 )continue;
		arNNonDefaultFieldIndexes.append(nTokenNDFI);
	}
	
	String sNDFS = sNonDefaultFieldSpacings + ";";
	double arDNonDefaultFieldSpacings[0];
	int nIndexNDFS = 0; 
	int sIndexNDFS = 0;
	while(sIndexNDFS < sNDFS.length()-1){
		String sTokenNDFS = sNDFS.token(nIndexNDFS);
		nIndexNDFS++;
		if(sTokenNDFS.length()==0){
			sIndexNDFS++;
			continue;
		}
		sIndexNDFS = sNDFS.find(sTokenNDFS,0);
	
		double dTokenNDFS = sTokenNDFS.atof();
		if( dTokenNDFS == 0 )continue;
		arDNonDefaultFieldSpacings.append(dTokenNDFS);
	}
	
	//Distribute trusses by inserting tsl's
	//Default tsl properties
	String strScriptName = "Myr-Truss"; // name of the script
	Vector3d vecUcsX(vx);
	Vector3d vecUcsY(vy);
	Beam lstBeams[0];
	Point3d lstPoints[0];
	int lstPropInt[0];
	double lstPropDouble[0];
	lstPropDouble.append(dWTruss);
	lstPropDouble.append(dXOffsetMiddle);
	lstPropDouble.append(dXOffsetLeft);
	lstPropDouble.append(dXOffsetRight);
	lstPropDouble.append(dYOffset);
	
	String lstPropString[0];
	
	lstPropString.append(sDimStyle);
	lstPropString.append(sLabelMiddle);
	lstPropString.append(sLabelLeft);
	lstPropString.append(sLabelRight);
	lstPropString.append(sShowTrussInDispRep);
	lstPropString.append(sNameFloorGroup);

	Map mapTsl;
	mapTsl.setPoint3d("ptOrg", ptStartTrusses);
	mapTsl.setVector3d("vecX", vx);
	mapTsl.setVector3d("vecY", vy);
	mapTsl.setVector3d("vecZ", vz);
	Point3d ptTruss;
	int nIndex = 0;
	double dThisSpacing = 0;
	if( nDistributionType < 2 ){//From left or right
		ptTruss = ptStartTrusses;
		while( TRUE ){
			int nNonDefaultIndex = arNNonDefaultFieldIndexes.find(nIndex);
			if( nNonDefaultIndex != -1 ){
				if( nNonDefaultIndex < arDNonDefaultFieldSpacings.length() ){
					dThisSpacing += arDNonDefaultFieldSpacings[nNonDefaultIndex];
				}
				else{
					dThisSpacing += dSpacing;
				}
			}
			else if( nIndex > 0 ){
				dThisSpacing += dSpacing;
			}
			
			ptTruss = ptStartTrusses + vy * dThisSpacing;
			
			// check if this still a valid position...if not: break out of the loop
			if( vy.dotProduct(ptTruss - ptEndTrusses) > 0 )
				break;
			
			mapTsl.setPoint3d("ptOrg", ptTruss);
			TslInst tslTruss;
			tslTruss.dbCreate( strScriptName, vecUcsX, vecUcsY, lstBeams, arSelectedRfPlaneAsEntity, lstPoints, lstPropInt, lstPropDouble, lstPropString, _kModelSpace, mapTsl);
			_Entity.append(tslTruss);
			grpFloor.addEntity(tslTruss, TRUE, 0, 'Z');

			//Increase index
			nIndex++;
		}
		ptTruss = ptEndTrusses;
		mapTsl.setPoint3d("ptOrg", ptTruss);
		TslInst tslTruss;
		tslTruss.dbCreate( strScriptName, vecUcsX, vecUcsY, lstBeams, arSelectedRfPlaneAsEntity, lstPoints, lstPropInt, lstPropDouble, lstPropString, _kModelSpace, mapTsl);
		_Entity.append(tslTruss);
	}
	else if( nDistributionType == 2 ){//From centre
		ptTruss = ptCentre;
		while( vy.dotProduct((ptCentre + vy * dThisSpacing) - ptEndTrusses) < 0 ){
			//Negative side
			int nNonDefaultIndex = arNNonDefaultFieldIndexes.find(nIndex);
			if( nNonDefaultIndex != -1 ){
				if( nNonDefaultIndex < arDNonDefaultFieldSpacings.length() ){
					dThisSpacing += arDNonDefaultFieldSpacings[nNonDefaultIndex];
				}
				else{
					dThisSpacing += dSpacing;
				}
			}
			else if( nIndex > 0 ){
				dThisSpacing += dSpacing;
			}
			ptTruss = ptCentre - vy * dThisSpacing;
			mapTsl.setPoint3d("ptOrg", ptTruss);
			TslInst tslTruss;
			tslTruss.dbCreate( strScriptName, vecUcsX, vecUcsY, lstBeams, arSelectedRfPlaneAsEntity, lstPoints, lstPropInt, lstPropDouble, lstPropString, _kModelSpace, mapTsl);
			_Entity.append(tslTruss);
			grpFloor.addEntity(tslTruss, TRUE, 0, 'Z');
			if( nIndex > 0 ){
				//Positive side
				ptTruss = ptCentre + vy * dThisSpacing;
				mapTsl.setPoint3d("ptOrg", ptTruss);
				TslInst tslTruss;
				tslTruss.dbCreate( strScriptName, vecUcsX, vecUcsY, lstBeams, arSelectedRfPlaneAsEntity, lstPoints, lstPropInt, lstPropDouble, lstPropString, _kModelSpace, mapTsl);
				_Entity.append(tslTruss);
				grpFloor.addEntity(tslTruss, TRUE, 0, 'Z');
			}
			
			//Increase index
			nIndex++;
		}
		//Start of distribution
		ptTruss = ptStartTrusses;
		mapTsl.setPoint3d("ptOrg", ptTruss);
		TslInst tslTrussStart;
		tslTrussStart.dbCreate( strScriptName, vecUcsX, vecUcsY, lstBeams, arSelectedRfPlaneAsEntity, lstPoints, lstPropInt, lstPropDouble, lstPropString, _kModelSpace, mapTsl);
		_Entity.append(tslTrussStart);
		grpFloor.addEntity(tslTrussStart, TRUE, 0, 'Z');
		//End of distribution
		ptTruss = ptEndTrusses;
		mapTsl.setPoint3d("ptOrg", ptTruss);
		TslInst tslTrussEnd;
		tslTrussEnd.dbCreate( strScriptName, vecUcsX, vecUcsY, lstBeams, arSelectedRfPlaneAsEntity, lstPoints, lstPropInt, lstPropDouble, lstPropString, _kModelSpace, mapTsl);
		_Entity.append(tslTrussEnd);
		grpFloor.addEntity(tslTrussEnd, TRUE, 0, 'Z');
	}
	else if( nDistributionType == 3 ){//From left and right
		ptTruss = ptStartTrusses;
		while( vy.dotProduct((ptStartTrusses + vy * dThisSpacing) - ptCentre) < 0 ){
			double dLocalSpacing = dSpacing;
			int nNonDefaultIndex = arNNonDefaultFieldIndexes.find(nIndex);
			if( nNonDefaultIndex != -1 ){
				if( nNonDefaultIndex < arDNonDefaultFieldSpacings.length() ){
					dLocalSpacing = arDNonDefaultFieldSpacings[nNonDefaultIndex];
					dThisSpacing += dLocalSpacing;
				}
				else{
					dThisSpacing += dSpacing;
				}
			}
			else if( nIndex > 0 ){
				dThisSpacing += dSpacing;
			}
			if( vy.dotProduct((ptStartTrusses + vy * dThisSpacing) - ptCentre) > 0 ){
				if( vy.dotProduct((ptStartTrusses + vy * dThisSpacing) - ptCentre) < (.5 * dLocalSpacing) ){
					//Centre of distribution
					ptTruss = ptCentre;
					mapTsl.setPoint3d("ptOrg", ptTruss);
					TslInst tslTruss;
					tslTruss.dbCreate( strScriptName, vecUcsX, vecUcsY, lstBeams, arSelectedRfPlaneAsEntity, lstPoints, lstPropInt, lstPropDouble, lstPropString, _kModelSpace, mapTsl);
					_Entity.append(tslTruss);
					grpFloor.addEntity(tslTruss, TRUE, 0, 'Z');
				}
				break;
			}
			
			//Negative side
			ptTruss = ptEndTrusses - vy * dThisSpacing;
			mapTsl.setPoint3d("ptOrg", ptTruss);
			TslInst tslTrussEnd;
			tslTrussEnd.dbCreate( strScriptName, vecUcsX, vecUcsY, lstBeams, arSelectedRfPlaneAsEntity, lstPoints, lstPropInt, lstPropDouble, lstPropString, _kModelSpace, mapTsl);
			_Entity.append(tslTrussEnd);
			grpFloor.addEntity(tslTrussEnd, TRUE, 0, 'Z');
			
			//Positive side
			ptTruss = ptStartTrusses + vy * dThisSpacing;
			mapTsl.setPoint3d("ptOrg", ptTruss);
			TslInst tslTrussStart;
			tslTrussStart.dbCreate( strScriptName, vecUcsX, vecUcsY, lstBeams, arSelectedRfPlaneAsEntity, lstPoints, lstPropInt, lstPropDouble, lstPropString, _kModelSpace, mapTsl);
			_Entity.append(tslTrussStart);
			grpFloor.addEntity(tslTrussStart, TRUE, 0, 'Z');
			
			//Increase index
			nIndex++;
		}
	}
	else{
	}
	
	_Map.setInt("ExecuteKey", 3);//static
	
	if( _bOnInsert )
		return;
}

if( _Entity.length() ==0 ){
	eraseInstance();
	return;
}

// get the floorgroup for the main information
Group grpFloor = arFloorGroup[arSNameFloorGroup.find(sNameFloorGroup)];

// add special context menu action to trigger the regeneration of the constuction and to reste the labels
//Redistribute
String sTriggerRedistribute = T("Redistribute");
addRecalcTrigger(_kContext, sTriggerRedistribute );

if( _kExecuteKey==sTriggerRedistribute ){
	Entity arRfPlaneAsEntity[0];
	for( int i=0;i<_Entity.length();i++ ){
		//Store roofplanes
		ERoofPlane rfPlane = (ERoofPlane)_Entity[i];
		if( rfPlane.bIsValid() )
			arRfPlaneAsEntity.append(rfPlane);
		
		//Remove trusses
		TslInst tslTruss = (TslInst)_Entity[i];
		if( tslTruss.bIsValid() )
			tslTruss.dbErase();
	}
	
	_Map.setInt("ExecuteKey", 1);//redistribute
	
	String strScriptName = "Myr-TrussDistribution"; // name of the script
	Vector3d vecUcsX(_XW);
	Vector3d vecUcsY(_YW);
	Beam lstBeams[0];
	Point3d lstPoints[0];
	int lstPropInt[0];

	double lstPropDouble[0];
	lstPropDouble.append(dWTruss);
	lstPropDouble.append(dSpacing);
	lstPropDouble.append(dFirstTruss);
	lstPropDouble.append(dLastTruss);
	lstPropDouble.append(dXOffsetMiddle);
	lstPropDouble.append(dXOffsetLeft);
	lstPropDouble.append(dXOffsetRight);
	lstPropDouble.append(dYOffset);
	
	String lstPropString[0];
	lstPropString.append(sNonDefaultFieldIndexes);
	lstPropString.append(sNonDefaultFieldSpacings);
	lstPropString.append(sDistributionType);
	lstPropString.append(sDimStyle);
	lstPropString.append(sLabelMiddle);
	lstPropString.append(sLabelLeft);
	lstPropString.append(sLabelRight);
	lstPropString.append(sShowTrussInDispRep);
	lstPropString.append(sNameFloorGroup);
	
	TslInst tsl;
	tsl.dbCreate(strScriptName, vecUcsX, vecUcsY, lstBeams, arRfPlaneAsEntity, lstPoints, lstPropInt, lstPropDouble, lstPropString, _kModelSpace, _Map);
	grpFloor.addEntity(tsl, TRUE, 0, 'Z');

	eraseInstance();
	return;
}


//Create a visual representation of this tsl
Display dp(-1);
dp.textHeight(U(100));
dp.draw(scriptName(), _Pt0, _XW, _YW,0 , 0);





#End
#BeginThumbnail






#End
