#Version 8
#BeginDescription
Last modified by: Anno Sportel (as@hsb-cad.com)
31.08.2010  -  version 1.3




#End
#Type O
#NumBeamsReq 0
#NumPointsGrip 0
#DxaOut 0
#ImplInsert 1
#FileState 1
#MajorVersion 1
#MinorVersion 3
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

/// <version  value="1.03" date="31.08.2010"></version>

/// <history>
/// AJ 	- 1.00 - 21.02.2007 	- Pilot version
/// AS	- 1.01 - 18.11.2008 	- Solve bug on removal of modulenames at Wall Junctions
/// AS	- 1.02 - 06.02.2009 	- Extra check added for removal of modules
/// AS 	- 1.03 - 31.08.2010 	- Ignore the -1 or -2 at the end of module names. These modules are seen as the same modules.
/// </history>

Unit (1,"mm");
double dEps = U(0.1);


//---------------------------------------------------------------------------------------------------------------------
//                                                                     Properties

//String arSModuleName[] = {T("Window"), T("Door"), T("Junction"), T("All")};
//PropString sModuleToErase(0,arSModuleName,T("Select the Modules to Erase"),1);
//int bModuleToErase = arSModuleName.find(sModuleToErase,1);

String arSYesNo[] = {T("No"), T("Yes")};

PropString sEraseWindows(0,arSYesNo,T("Remove from Windows"),0);
int bEraseWindows = arSYesNo.find(sEraseWindows,0);

PropString sEraseDoors(1,arSYesNo,T("Remove from Doors"),0);
int bEraseDoors = arSYesNo.find(sEraseDoors,0);

PropString sEraseOpening(2,arSYesNo,T("Remove from Openings"),0);
int bEraseOpening = arSYesNo.find(sEraseOpening,0);


PropString sEraseWallJunctions(3,arSYesNo,T("Remove from Wall Junctions"),0);
int bEraseWallJunctions = arSYesNo.find(sEraseWallJunctions,0);

PropString sErasePointLoads(4,arSYesNo,T("Remove from Point Loads"),0);
int bErasePointLoads = arSYesNo.find(sErasePointLoads,0);

PropString sEraseVents(5,arSYesNo,T("Remove from Vents"),0);
int bEraseVents = arSYesNo.find(sEraseVents,0);

PropString sEraseGrade(6,arSYesNo,T("Remove from Grade"),0);
int bEraseGrade = arSYesNo.find(sEraseGrade,0);

PropString sGradeToErase(7, "<name>", T("Grade to Erase"));

// filter beams with grade
String sFBC = sGradeToErase + ";";
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
	sTokenBC.makeUpper();
  arSFBC.append(sTokenBC);
}

PropString sEraseAll(8,arSYesNo,T("Remove All Module"),0);
int bEraseAll = arSYesNo.find(sEraseAll,0);




if( _bOnInsert ){
	if (insertCycleCount()>1) { eraseInstance(); return; }
	PrEntity ssE(T("Select a set of elements"), Element());
	
	if( ssE.go() ){
		_Element.append(ssE.elementSet());
	}
	
	showDialog();
	return;
}

if( _Element.length() == 0 ){
	eraseInstance();
	return;
}


//---------------------------------------------------------------------------------------------------------------------
//                                              Define usefull set of vectors and array's, ...

for( int e=0;e<_Element.length();e++ ){
	
	double dTolerance=U(5);
	
	ElementWallSF el = (ElementWallSF) _Element[e];
	if (!el.bIsValid())
		continue;

	Element elCon[0];
	if (bEraseWallJunctions || bEraseAll)
	{
		elCon=el.getConnectedElements();	
		if (elCon.length()==0)
		{
			//eraseInstance();
			//return;
		}
	}


	Opening arOp[0];
	arOp.append(el.opening());
	
	//if (arOp.length()==0)
	{
	//	eraseInstance();
	//	return;
	}
	
	Vector3d vx = el.vecX();
	Vector3d vy = el.vecY();
	Vector3d vz = el.vecZ();

	_Pt0 = el.ptOrg();
	
	Line lnX (_Pt0, vx);
	
	Beam arBm[] = el.beam();
	if( arBm.length() == 0 )return;

	//---------------------------------------------------------------------------------------------------------------------
	//                          Find start and end of modules and fill an array with studs

	Beam arBmModule[0];
	int arNModuleIndex[0];
	String arSModule[0];

	Beam arBmStud[0];
	for( int i=0;i<arBm.length();i++ ){
		Beam bm = arBm[i];
		
		String sModule = bm.name("module");
//		String sSubPart = sModule.right(2);
//		if( sSubPart.left(1) == "-" )
//			sModule = sModule.left(sModule.length() - 2);
		
		if( bm.type() == _kStud ){
			arBmStud.append(bm);
		}
		if( sModule != "" ){
			arBmModule.append(bm);
			
			if( arSModule.find(sModule) == -1 ){
				arSModule.append(sModule);
			}
			arNModuleIndex.append( arSModule.find(sModule) );
		}
	}
	
	double arDMinModule[arSModule.length()];
	double arDMaxModule[arSModule.length()];
	int arBMinMaxSet[arSModule.length()];
	for( int i=0;i<arBMinMaxSet.length();i++ ){
		arBMinMaxSet[i] = FALSE;
	}
	for( int i=0;i<arBmModule.length();i++ ){
		Beam bm = arBmModule[i];
		int nIndex = arNModuleIndex[i];
	
		Point3d arPtBm[] = bm.realBody().allVertices();
		Plane pn(el.ptOrg() , vy);
		arPtBm = pn.projectPoints(arPtBm);
	
		for( int i=0;i<arPtBm.length();i++ ){
			Point3d pt = arPtBm[i];
			double dDist = vx.dotProduct( pt - el.ptOrg() );
			
			if( !arBMinMaxSet[nIndex] ){
				arBMinMaxSet[nIndex] = TRUE;
				arDMinModule[nIndex] = dDist;
				arDMaxModule[nIndex] = dDist;	
			}
			else{
				if( (arDMinModule[nIndex] - dDist) > dEps ){
					arDMinModule[nIndex] = dDist;
				}
				if( (dDist - arDMaxModule[nIndex]) > dEps ){
					arDMaxModule[nIndex] = dDist;
				}
			}
		}
	}

	int arBModuleIsOpening[0];
	Point3d arPtMinModule[0];
	Point3d arPtMaxModule[0];
	for( int i=0;i<arSModule.length();i++ ){
		arPtMinModule.append(el.ptOrg() + vx * (arDMinModule[i]) - vx * dTolerance);
		arPtMaxModule.append(el.ptOrg() + vx * (arDMaxModule[i]) + vx * dTolerance);
		arBModuleIsOpening.append(FALSE);
	}

	for( int i=0;i<arPtMinModule.length(); i++ ){
		arPtMinModule[i].vis(i);
		arPtMaxModule[i].vis(i);
	}
////////////////////////////////////////////////////////////////////////////////
///	Array of Center Points of each module type

	Point3d ptWindow[0];
	Point3d ptDoor[0];
	Point3d ptOpening[0];
	Point3d ptJunction[0];
	//Point3d ptPocket;
	//Point3d ptVent;
	Point3d ptAll[0];

////////////////////////////////////////////////////////////////////////////////
///	Find the Center point of the Windows or Doors

	for (int i=0; i<arOp.length(); i++)
	{
		Opening op=arOp[i];
		PLine pl=op.plShape();
		Point3d	ptCenter;
		ptCenter.setToAverage(pl.vertexPoints(TRUE));
		
		if (op.openingType()==_kWindow)
		{
			ptWindow.append(ptCenter);
			ptAll.append(ptCenter);
		}
		else	if (op.openingType()==_kDoor)
		{
			ptDoor.append(ptCenter);
			ptAll.append(ptCenter);
		}
		else
		{
			ptOpening.append(ptCenter);
			ptAll.append(ptCenter);
		}
		
		for (int j=0; j<arPtMinModule.length(); j++)
		{
			if( (vx.dotProduct(arPtMinModule[j]-ptCenter) * vx.dotProduct(arPtMaxModule[j]-ptCenter)) < 0 )
			{
				arBModuleIsOpening[j] = TRUE;
			}
		}
	}

////////////////////////////////////////////////////////////////////////////////
///	Find the Center point of the Wall Junction

	for (int i=0; i<elCon.length(); i++)
	{
		Element elC=elCon[i];//dPosZOutlineFront
		double dThick=abs(elC.dPosZOutlineBack());
		Point3d ptFront = elC.ptOrg();
		Point3d ptBack = elC.ptOrg()-elC.vecZ()*dThick;
		Line lnFront(ptFront, elC.vecX());
		Line lnBack(ptBack, elC.vecX());
		Point3d ptIntersect[0];
		ptIntersect.append(lnX.closestPointTo(lnFront));
		ptIntersect.append(lnX.closestPointTo(lnBack));
		Point3d ptCenter;
		ptCenter.setToAverage(ptIntersect);
		ptJunction.append(ptBack);
		ptJunction.append(ptFront);
		ptAll.append(ptCenter);
	}

////////////////////////////////////////////////////////////////////////////////
///	Display

	for (int i=0; i<ptAll.length(); i++)
	{
		ptAll[i].vis(150+i);
		
	}
	
////////////////////////////////////////////////////////////////////////////////
///	Find the right module to erase (door, window, etc)

	int nModuleToErase[0];
	
	
	//Door
	if (bEraseDoors || bEraseAll)
	{
		for (int i=0; i<ptDoor.length(); i++)
		{
			for (int j=0; j<arPtMinModule.length(); j++)
			{
				if (abs(vx.dotProduct(ptDoor[i]-_Pt0)) > abs(vx.dotProduct(arPtMinModule[j]-_Pt0)) && abs(vx.dotProduct(ptDoor[i]-_Pt0)) < abs(vx.dotProduct(arPtMaxModule[j]-_Pt0)))
				{
					nModuleToErase.append(j);
				}
			}
		}
	}

	//Window
	if (bEraseWindows || bEraseAll)
	{
		for (int i=0; i<ptWindow.length(); i++)
		{
			for (int j=0; j<arPtMinModule.length(); j++)
			{
				if (abs(vx.dotProduct(ptWindow[i]-_Pt0)) > abs(vx.dotProduct(arPtMinModule[j]-_Pt0)) && abs(vx.dotProduct(ptWindow[i]-_Pt0)) < abs(vx.dotProduct(arPtMaxModule[j]-_Pt0)))
				{
					nModuleToErase.append(j);
				}
			}
		}
	}
	
	//Opening
	if (bEraseOpening || bEraseAll)
	{
		for (int i=0; i<ptOpening.length(); i++)
		{
			for (int j=0; j<arPtMinModule.length(); j++)
			{
				if (abs(vx.dotProduct(ptOpening[i]-_Pt0)) > abs(vx.dotProduct(arPtMinModule[j]-_Pt0)) && abs(vx.dotProduct(ptOpening[i]-_Pt0)) < abs(vx.dotProduct(arPtMaxModule[j]-_Pt0)))
				{
					nModuleToErase.append(j);
				}
			}
		}
	}


	//Junction
	if (bEraseWallJunctions==TRUE || bEraseAll==TRUE)
	{
		int arNJunctionType[] = {
			_kSFStudLeft,
			_kSFStudRight
		};
		for( int i=0;i<arBmModule.length();i++ ){
			if( arNJunctionType.find(arBmModule[i].type()) != -1 ){
				arBmModule[i].setModule("");
				arBmModule[i].setColor(32);
			}
		}
		for (int i=0; i<ptJunction.length(); i++)
		{
			ptJunction[i].vis(5);
			for (int j=0; j<arPtMinModule.length(); j++)
			{
				if( arBModuleIsOpening[j] )continue;
				if( (vx.dotProduct(ptJunction[i] - arPtMinModule[j]) * vx.dotProduct(ptJunction[i] - arPtMaxModule[j])) < 0 )
//				if (abs(vx.dotProduct(ptJunction[i]-_Pt0)) > abs(vx.dotProduct(arPtMinModule[j]-_Pt0)) && abs(vx.dotProduct(ptJunction[i]-_Pt0)) < abs(vx.dotProduct(arPtMaxModule[j]-_Pt0)))
				{
					nModuleToErase.append(j);
				}
			}
		}
	}

	//PointLoad
	if (bErasePointLoads || bEraseAll)
	{
		for (int i=0;i<arBmModule.length(); i++)
		{
			String sModule = arBmModule[i].name("module");
			String sMod = sModule.token(0,",");
			if(sMod=="pl")
			{
				arBmModule[i].setModule("");
				arBmModule[i].setColor(32);
			}

			
		}
	}
	
	//Vent
	if (bEraseVents || bEraseAll)
	{
		for (int i=0;i<arBmModule.length(); i++)
		{
			String sModule = arBmModule[i].name("module");
			String sMod = sModule.token(0,",");
			if(sMod=="vnt")
			{
				arBmModule[i].setModule("");
				arBmModule[i].setColor(32);
			}
		}
	}

	//Grade
	if (bEraseGrade || bEraseAll)
	{
		for (int j=0; j<arSFBC.length(); j++)
		{
			for (int i=0;i<arBmModule.length(); i++)
			{
				String sModule = arBmModule[i].name("grade");
				sModule.makeUpper();
				//String sMod = sModule.token(0,",");
				if(sModule==arSFBC[j])
				{
					arBmModule[i].setModule("");
					arBmModule[i].setColor(32);
				}
			}
		}
	}
	
	//All
	/*if (bEraseAll)
	{
		for (int i=0; i<ptAll.length(); i++)
		{
			for (int j=0; j<arPtMinModule.length(); j++)
			{
				if (abs(vx.dotProduct(ptAll[i]-_Pt0)) > abs(vx.dotProduct(arPtMinModule[j]-_Pt0)) && abs(vx.dotProduct(ptAll[i]-_Pt0)) < abs(vx.dotProduct(arPtMaxModule[j]-_Pt0)))
				{
					nModuleToErase.append(j);
				}
			}
		}
	}*/


////////////////////////////////////////////////////////////////////////////////
///	Erase the Module Information

	for (int j=0; j<arBmModule.length(); j++)
	{
		if(nModuleToErase.find(arNModuleIndex[j])!=-1)
		{
			arBmModule[j].setModule("");
			arBmModule[j].setColor(32);
		}
	}
}

eraseInstance();








#End
#BeginThumbnail









#End
