#Version 8
#BeginDescription
Last modified by: Anno Sportel (as@hsb-cad.com)
01.02.2018 - version 1.08









#End
#Type O
#NumBeamsReq 0
#NumPointsGrip 0
#DxaOut 1
#ImplInsert 1
#FileState 1
#MajorVersion 1
#MinorVersion 8
#KeyWords 
#BeginContents
/// <summary Lang=en>
/// This tsl closes openings in existing sheets
/// </summary>

/// <insert>
/// Select a set of elements
/// </insert>

/// <remark Lang=en>
/// .
/// </remark>

/// <version  value="1.07" date="01.02.2018"></version>

/// <history>
/// AS - 1.00 - 22.01.2009 	- Pilot version
/// AS - 1.01 - 22.01.2009 	- Rename from Myr-CloseOpenings to Myr-CloseOpenings & RemoveBeamsInside
///								- And implement removal
/// AS - 1.02 - 09.02.2009 	- Make the beams to remove a property
/// AS - 1.03 - 09.02.2009 	- Als use DakLeft/RightEdge als as beamtypes
/// AS - 1.04 - 10.02.2009 	- Remove beams with center point in opening
/// AS - 1.05 - 11.02.2009 	- Use openingProfile of zone 0 instead of zone 1
/// AS - 1.06 - 06.03.2009 	- Ignore sheeting with material BOARD
/// RP - 1.07 - 01.02.2018 	- New oninsert and check for opening to be able to add to elementconstructed
/// RP - 1.08 - 01.02.2018 	- Use openingRoof instead of opening
/// </history>
double areaTolerance = U(1, "mm");

PropString sListOfBmCodesToRemove(0, "BK1; BKK1", T("|Beamcodes to remove|"));

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

//Number of elements
if( _Element.length() == 0 ){
	reportMessage(TN("|No element selected|"));
	eraseInstance();
	return;
}

if (_bOnElementConstructed || _Map.getInt("ManualInserted") || _bOnDebug)
{
	//Subtract beamCodes from ; separated string
	String sBmCode = sListOfBmCodesToRemove + ";";
	sBmCode.makeUpper();
	String arSBmCodeToRemove[0];
	int nIndexBmCode = 0;
	int sIndexBmCode = 0;
	while (sIndexBmCode < sBmCode.length() - 1) {
		String sTokenBC = sBmCode.token(nIndexBmCode);
		nIndexBmCode++;
		if (sTokenBC.length() == 0) {
			sIndexBmCode++;
			continue;
		}
		sIndexBmCode = sBmCode.find(sTokenBC, 0);
		arSBmCodeToRemove.append(sTokenBC);
	}
	
	//Selected element
	Element el = _Element[0];
	
	//Coordinate system
	CoordSys csEl = el.coordSys();
	Vector3d vxEl = csEl.vecX();
	Vector3d vyEl = csEl.vecY();
	Vector3d vzEl = csEl.vecZ();
	
	//Origin point
	_Pt0 = el.ptOrg();
	PlaneProfile profBruto = el.profBrutto(0);
	profBruto.vis(2);
	Group grpEl = el.elementGroup();
	Group grpFloor(grpEl.namePart(0), grpEl.namePart(1), "" );
	Entity arEntOpRf[] = grpFloor.collectEntities(true, OpeningRoof(), _kModelSpace);
	int hasOpening = false;
	for (int index = 0; index < arEntOpRf.length(); index++)
	{
		OpeningRoof opening = (OpeningRoof)arEntOpRf[index];
		PLine openingPline = opening.plShape();
		Point3d pLinePoints[] = openingPline.vertexPoints(true);
		for (int p=0;p<pLinePoints.length();p++)
		{
			Point3d pLinePoint = pLinePoints[p];
			if (profBruto.pointInProfile(pLinePoint) == _kPointInProfile)
				{
					hasOpening = true;
					break;
				}
		}

	}
	if ( ! hasOpening)
	{
		reportMessage(TN("|No opening found for element: |") + el.number());
		eraseInstance();
		return;
	}
	
	
	//Sheets
	Sheet arShZn01[] = el.sheet(1);
	
	PlaneProfile ppOp(csEl);
	
	for ( int i = 0; i < arShZn01.length(); i++) {
		Sheet sh = arShZn01[i];
		if ( sh.material() == "BOARD" )continue;
		
		PLine plSh = sh.plEnvelope();
		//		plSh.vis();
		
		PlaneProfile ppZn01 = el.profBrutto(1);
		ppOp = el.profBrutto(0);
		ppOp.vis(3);
		int bSubtracted = ppOp.subtractProfile(el.profNetto(0));
		ppOp.vis(1);
		
		Sheet shNew;
		shNew.dbCreate(ppZn01, sh.dH(), 1);
		shNew.assignToElementGroup(el, TRUE, 1, 'Z');
		shNew.setColor(sh.color());
		shNew.setType(sh.type());
		shNew.setLabel(sh.label());
		shNew.setSubLabel(sh.subLabel());
		shNew.setSubLabel2(sh.subLabel2());
		shNew.setGrade(sh.grade());
		shNew.setInformation(sh.information());
		shNew.setMaterial(sh.material());
		shNew.setBeamCode(sh.beamCode());
		shNew.setName(sh.name());
		shNew.setModule(sh.module());
		shNew.setHsbId(sh.hsbId());
		
		ppZn01.vis();
		
		sh.dbErase();
	}
	
	
	//Remove beams (BK1 & BKK1) inside the opening 
	Beam arBm[] = el.beam();
	Beam arBmToRemove[0];
	for ( int i = 0; i < arBm.length(); i++) {
		Beam bm = arBm[i];
		
		//Check beamcodes
		String sBmCode = bm.name("beamCode").token(0);
		if ( arSBmCodeToRemove.find(sBmCode) == -1 ) continue;
		
		if ( ppOp.pointInProfile(bm.ptCen()) == _kPointInProfile ) {
			bm.dbErase();//setColor(5);
		}
	}
	
	eraseInstance();
	return;
}



















#End
#BeginThumbnail








#End