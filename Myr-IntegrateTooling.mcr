#Version 8
#BeginDescription
Last modified by: Anno Sportel (anno.sportel@itwindustry.nl)
29.09.2009  -  version 1.4



#End
#Type O
#NumBeamsReq 0
#NumPointsGrip 0
#DxaOut 1
#ImplInsert 1
#FileState 1
#MajorVersion 1
#MinorVersion 4
#KeyWords 
#BeginContents
/// <summary Lang=en>
/// Create a TSL to do the Same that Integrate Tooling but allow you to specify an Offset.
/// </summary>

/// <insert>
/// Select a set of elements
/// </insert>

/// <remark Lang=en>
/// .
/// </remark>

/// <version  value="1.03" date="29.092009"></version>

/// <history>
/// AJ - 1.00 - 22.01.2009 - Pilot version
/// AJ - 1.02 - 17.02.2009 - Set the orientatin of vx to the X vector of the tool beam
/// AS - 1.03 - 29.09.2009 - Size of beamcut was wrong, it took 2 times offset bottom instead of 1 times offset top and bottom
/// AS - 1.04 - 29.09.2009 - Specify during insert which side is the left side
/// </history>

//Script uses mm
double dEps = U(.001,"mm");

PropDouble dOffsetT (0, 0, "Offset Top");
PropDouble dOffsetB (1, 0, "Offset Bottom");
PropDouble dOffsetL (2, 0, "Offset Left");
PropDouble dOffsetR (3, 0, "Offset Right");
int nType=0;

if (_bOnDbCreated) setPropValuesFromCatalog(_kExecuteKey);

//Insert

if( _bOnInsert )
{
	//Erase after 1 cycle
	if( insertCycleCount() > 1 ){
		eraseInstance();
		return;
	}
	
	//Showdialog
	if (_kExecuteKey=="")
		showDialog();
	
	Beam bmFemale[0];
	PrEntity ssE(T("Select Main Beams"),Beam());
	if( ssE.go() ) {
		bmFemale = ssE.beamSet();
	}
	
	Beam bmMale[0];
	PrEntity ssE2(T("Select Beams that define the Tools"),Beam());
	if( ssE2.go() ) {
		bmMale = ssE2.beamSet();
	}
	
	Point3d ptLeft = getPoint(T("|Select a point at the left side|"));

	String strScriptName = "Myr-IntegrateTooling"; // name of the script
	Vector3d vecUcsX(1,0,0);
	Vector3d vecUcsY(0,1,0);
	Beam lstBeams[0];
	Element lstElements[0];
	  
	Point3d lstPoints[0];
	int lstPropInt[0];
	double lstPropDouble[0];
	String lstPropString[0];
	Map mapTsl;
	mapTsl.setInt("MasterToSatellite", TRUE);
	setCatalogFromPropValues("MasterToSatellite");
	mapTsl.setPoint3d("PtLeft", ptLeft, _kAbsolute);

	for (int i=0; i<bmFemale.length(); i++)
	{
		Beam bmF=bmFemale[i];
		Beam bmMaleValid[0];
		bmMaleValid=bmF.filterGenBeamsNotThis(bmMale);
		bmMaleValid=bmF.realBody().filterGenBeamsIntersect(bmMaleValid);
		for (int j=0; j<bmMaleValid.length(); j++)
		{
			lstBeams.setLength(0);
			Beam bmM=bmMaleValid[j];
			lstBeams.append(bmM);
			lstBeams.append(bmF);
			TslInst tsl;
			tsl.dbCreate(strScriptName, vecUcsX,vecUcsY,lstBeams, lstElements, lstPoints, lstPropInt, lstPropDouble, lstPropString, _kModelSpace, mapTsl);
		}
	}
	
	//Beam bm=getBeam(T("Select Main Beam"));
	//_Beam.append(getBeam(T("Select Beam that define the Tool")));
	//_Beam.append(bm);
	eraseInstance();
	return;
}//End bOnInsert

if( _Map.hasInt("MasterToSatellite") ){
	int bMasterToSatellite = _Map.getInt("MasterToSatellite");
	if( bMasterToSatellite ){
		int bPropertiesSet = _ThisInst.setPropValuesFromCatalog("MasterToSatellite");
		_Map.removeAt("MasterToSatellite", TRUE);
	}
}

if (_Beam.length()<2)
{
	eraseInstance();
	return;
}

Vector3d vLeftToRight = _Beam[0].vecY();
if( _Map.hasPoint3d("PtLeft") ){
	Point3d ptLeft = _Map.getPoint3d("PtLeft");
	ptLeft.vis(1);
	ptLeft += _Beam[0].vecX() * _Beam[0].vecX().dotProduct(_Beam[0].ptCen() - ptLeft);
	ptLeft.vis(3);
	ptLeft += _ZW * _ZW.dotProduct(_Beam[0].ptCen() - ptLeft);
	ptLeft.vis(5);
	
	Vector3d vL2R(_Beam[0].ptCen() - ptLeft);
	vL2R.vis(ptLeft, 4);
	if( vL2R.length() > 0 )
		vLeftToRight = _Beam[0].vecD(vL2R);
}
vLeftToRight.normalize();

Body bdTool=_Beam[0].envelopeBody(false, true);

Line lnXBm0 (_Beam[0].ptCen(), _Beam[0].vecX());
Line lnXBm1 (_Beam[1].ptCen(), _Beam[1].vecX());

Point3d ptIntersection=lnXBm0.closestPointTo(lnXBm1);
//Vector3d vxBm0=ptIntersection-_Beam[0].ptCen();
//vxBm0.normalize();
Vector3d vyBm0 = _Beam[0].vecD(vLeftToRight);
Vector3d vzBm0 = _Beam[0].vecD(_ZW);
Vector3d vxBm0 = vyBm0.crossProduct(vzBm0);//_Beam[0].vecX();

Point3d ptCenter=_Beam[0].ptCen()+vyBm0*(dOffsetR-dOffsetL)*.5+vzBm0*(dOffsetT-dOffsetB)*.5;
BeamCut bc(ptCenter, vxBm0, vyBm0, vzBm0, _Beam[0].solidLength(), _Beam[0].dD(vyBm0)+dOffsetL+dOffsetR, _Beam[0].dD(vzBm0)+dOffsetT+dOffsetB);
bc.cuttingBody().vis(1);
_Beam[1].addTool(bc);

_Pt0=ptIntersection;

LineSeg ls1(_Pt0-vxBm0*U(10), _Pt0+vxBm0*U(10));
LineSeg ls2(_Pt0-vyBm0*U(10), _Pt0+vyBm0*U(10));
LineSeg ls3(_Pt0-vzBm0*U(10), _Pt0+vzBm0*U(10));

Display dp(-1);
dp.draw(ls1);
dp.draw(ls2);
dp.draw(ls3);




#End
#BeginThumbnail



#End
