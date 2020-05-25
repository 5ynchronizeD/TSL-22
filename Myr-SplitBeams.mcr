#Version 8
#BeginDescription
Last modified by: Alberto Jena (aj@hsb-cad.com)
01.02.2018  -  version 1.01



#End
#Type O
#NumBeamsReq 0
#NumPointsGrip 0
#DxaOut 1
#ImplInsert 1
#FileState 1
#MajorVersion 1
#MinorVersion 1
#KeyWords 
#BeginContents
/// <summary Lang=en>
/// Create areas to apply sheeting distribution.
/// </summary>

/// <insert>
/// Select a set of elements
/// </insert>

/// <remark Lang=en>
/// .
/// </remark>

/// <version  value="1.05" date="17 February 2009"></version>

/// <history>
/// AJ - 1.00 - 19.01.2009 - Pilot version
/// RP - 1.01 - 01.02.2018 - Change tsl so it can be used on element generation
/// </history>

//Script uses mm
Unit (1,"mm");
double dEps = U(.001,"mm");

String sArBmCode[]={"BKK1","BK1"};

// bOnInsert
	if(_bOnInsert)
	{
		if (insertCycleCount()>1) { eraseInstance(); return; }
					
	// silent/dialog
		String sKey = _kExecuteKey;
		sKey.makeUpper();

		if (sKey.length()>0)
		{
			String sEntries[] = TslInst().getListOfCatalogNames(scriptName());
			for(int i=0;i<sEntries.length();i++)
				sEntries[i] = sEntries[i].makeUpper();	
			if (sEntries.find(sKey)>-1)
				setPropValuesFromCatalog(sKey);
			else
				setPropValuesFromCatalog(T("|_LastInserted|"));					
		}	
		else	
			showDialog();
		
	// prompt for elements
		PrEntity ssE(T("|Select element(s)"), Element());
	  	if (ssE.go())
			_Element.append(ssE.elementSet());

	// prepare tsl cloning
		TslInst tslNew;
		Vector3d vecXTsl= _XE;
		Vector3d vecYTsl= _YE;
		GenBeam gbsTsl[] = {};
		Entity entsTsl[1] ;
		Point3d ptsTsl[1];
		int nProps[]={};
		double dProps[]={};
		String sProps[]={};
		Map mapTsl;	
		mapTsl.setInt("ManualInserted", true);
		String sScriptname = scriptName();
		
	// insert per element
		for(int i=0;i<_Element.length();i++)
		{
			entsTsl[0]= _Element[i];	
			ptsTsl[0]=_Element[i].ptOrg();
			
			tslNew.dbCreate(scriptName(), vecXTsl ,vecYTsl,gbsTsl, entsTsl, ptsTsl, 
					nProps, dProps, sProps,_kModelSpace, mapTsl);	
			
		}

		eraseInstance();
		return;
	}	
// end on insert	__________________

if (_bOnElementConstructed || _Map.getInt("ManualInserted"))
{ 
	ElementRoof el = (ElementRoof)_Element[0];
	if( !el.bIsValid() )
	{
		eraseInstance();
		return;
	}

	//CoordSys
	CoordSys csEl = el.coordSys();
	Vector3d vxEl = csEl.vecX();
	Vector3d vyEl = csEl.vecY();
	Vector3d vzEl = csEl.vecZ();
	_Pt0=csEl.ptOrg();
	
	Plane plnZ (csEl.ptOrg(), vzEl);
	
	Beam bmAll[]=el.beam();
	
	if (bmAll.length()<1)
	{
		eraseInstance();
		return;
	}
	
	Beam bmAllJoist[0];
	Beam bmToSplit[0];
	for (int i=0; i<bmAll.length(); i++)
	{
		if (sArBmCode.find(bmAll[i].beamCode().token(0), -1)!=-1)
			bmToSplit.append(bmAll[i]);
		if (bmAll[i].type()==_kDakCenterJoist)
			bmAllJoist.append(bmAll[i]);
	}
	
	for (int i=0; i<bmToSplit.length(); i++)
	{
		Beam bm=bmToSplit[i];
		PlaneProfile ppBm (csEl);
		ppBm=bm.realBody().shadowProfile(plnZ);
		ppBm.shrink(U(2));
		Beam bmArValidJoist[0];
		for (int j=0; j<bmAllJoist.length(); j++)
		{
			Beam bmJoist=bmAllJoist[j];
			PlaneProfile ppBmJoist (csEl);
			ppBmJoist=bmJoist.realBody().shadowProfile(plnZ);
			ppBmJoist.shrink(U(2));
			ppBmJoist.intersectWith(ppBm);
			if (ppBmJoist.area()>U(1)*U(1))
				bmArValidJoist.append(bmJoist);
			bmJoist.vecX().vis(bmJoist.ptCen(), 1);
		}
		
		bmArValidJoist=(-bm.vecX()).filterBeamsPerpendicularSort(bmArValidJoist);
		for (int j=0; j<bmArValidJoist.length(); j++)
		{
			Beam bmJoist=bmArValidJoist[j];
			Point3d ptTo=bmJoist.ptCen()+bmJoist.vecD(bm.vecX())*bmJoist.dD(bm.vecX())*0.5; ptTo.vis(1);
			Point3d ptFrom=bmJoist.ptCen()-bmJoist.vecD(bm.vecX())*bmJoist.dD(bm.vecX())*0.5; ptFrom.vis(2);
			bm.dbSplit(ptTo, ptFrom);
		}
		
	}
	//Erase this tsl.
	eraseInstance();
	return;
}



#End
#BeginThumbnail


#End