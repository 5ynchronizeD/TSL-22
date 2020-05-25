#Version 8
#BeginDescription
Last modified by: Alberto Jena (aj@hsb-cad.com)
23.02.2009  -  version 1.00




#End
#Type O
#NumBeamsReq 0
#NumPointsGrip 0
#DxaOut 1
#ImplInsert 1
#FileState 1
#MajorVersion 1
#MinorVersion 0
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

/// <version  value="1.00" date="23 February 2009"></version>

/// <history>
/// AJ - 1.00 - 23.02.2009 - Pilot version
/// </history>

//Script uses mm
Unit (1,"mm");
double dEps = U(.001,"mm");

PropDouble dMaxBmLengthFront (0, U(1102.5), T("Max Length Front Panel"));
PropDouble dMaxBmLengthBack (1, U(277.5), T("Max Length Back Panel"));



String sArBmCode[]={"BRS1","None"};
String sArBmCodeBlocking[]={"BK1","None"};

double dBmMinGap=500;

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

	PrEntity ssE(T("|Select one or more elements|"), ElementRoof());
	if (ssE.go())
	{
		_Element = ssE.elementSet();
	}
	return;
}//End bOnInsert

Element arAllElements[0];
arAllElements =_Element;

for( int e=0;e<arAllElements.length();e++ )
{
	ElementRoof el = (ElementRoof)arAllElements[e];
	if( !el.bIsValid() ){
		continue;
	}
	
	//CoordSys
	CoordSys csEl = el.coordSys();csEl.vis();
	Vector3d vxEl = csEl.vecX();
	Vector3d vyEl = csEl.vecY();
	Vector3d vzEl = csEl.vecZ();
	_Pt0=csEl.ptOrg();
	
	Plane plnZ (csEl.ptOrg(), vzEl);
	
	Beam bmAll[]=el.beam();
	LineSeg ls=el.segmentMinMax();
	double dElLength=abs(vyEl.dotProduct(ls.ptStart()-ls.ptEnd()));
	
	if (bmAll.length()<1)
	{
		eraseInstance();
		return;
	}
	
	Beam bmAllBlocking[0];
	Beam bmToSplit[0];
	for (int i=0; i<bmAll.length(); i++)
	{
		if (sArBmCode.find(bmAll[i].beamCode().token(0), -1)!=-1)
			bmToSplit.append(bmAll[i]);
			
		if (sArBmCodeBlocking.find(bmAll[i].beamCode().token(0), -1)!=-1)
			bmAllBlocking.append(bmAll[i]);
	}
	
	for (int i=0; i<bmToSplit.length(); i++)
	{
		Beam bm=bmToSplit[i];
		
		double dLen=bm.solidLength();
		
		if (dElLength-dLen<dBmMinGap)
		{
			continue;
		}
		
		PlaneProfile ppBm (csEl);
		ppBm=bm.realBody().shadowProfile(plnZ);
		
		ppBm.shrink(U(2));
		
		LineSeg ls=ppBm.extentInDir(vyEl);
		
		Point3d ptB=ls.ptStart();
		Point3d ptT=ls.ptEnd();
		
		if (abs(vyEl.dotProduct(csEl.ptOrg()-ptT))<abs(vyEl.dotProduct(csEl.ptOrg()-ptB)))
		{
			Point3d ptAux=ptT;
			ptT=ptB;
			ptB=ptAux;
			
		}
		ptT.vis(1);
		ptB.vis(2);
		
		//PlaneProfile ppTandB (csEl);
		
		LineSeg lsTop(ptT-vyEl*U(dMaxBmLengthBack)-vxEl*U(10), ptT+vxEl*U(10));
		PLine plTop(vzEl);
		plTop.createRectangle(lsTop, vxEl, vyEl);
		plTop.vis(1);
		PlaneProfile ppTop(csEl);
		ppTop.joinRing(plTop, FALSE);
		//ppTandB.joinRing(plTop, FALSE);
		
		LineSeg lsBottom(ptB+vyEl*U(dMaxBmLengthFront)-vxEl*U(10), ptB+vxEl*U(10));
		PLine plBottom(vzEl);
		plBottom.createRectangle(lsBottom, vxEl, vyEl);
		plBottom.vis(2);
		PlaneProfile ppBottom(csEl);
		ppBottom.joinRing(plBottom, FALSE);
		//ppTandB.joinRing(plBottom, FALSE);
		
		//
		Beam bmArValidBlockingTop[0];
		Beam bmArValidBlockingBottom[0];
		for (int j=0; j<bmAllBlocking.length(); j++)
		{
			Beam bmBlock=bmAllBlocking[j];
			PlaneProfile ppBmBlock (csEl);
			PlaneProfile ppAux (csEl);
			ppBmBlock=bmBlock.realBody().shadowProfile(plnZ);
			ppBmBlock.shrink(U(2));
			ppAux=ppBmBlock;
			ppBmBlock.intersectWith(ppTop);
			ppAux.intersectWith(ppBottom);
			if (ppBmBlock.area()>U(1)*U(1))
			{
				bmArValidBlockingTop.append(bmBlock);
				bmBlock.vecX().vis(bmBlock.ptCen(), 1);
			}
			if (ppAux.area()>U(1)*U(1))
			{
				bmArValidBlockingBottom.append(bmBlock);
				bmBlock.vecX().vis(bmBlock.ptCen(), 1);
			}

		}

		bmArValidBlockingTop=bm.vecX().filterBeamsPerpendicularSort(bmArValidBlockingTop);
		bmArValidBlockingBottom=bm.vecX().filterBeamsPerpendicularSort(bmArValidBlockingBottom);
		
		if (bmArValidBlockingTop.length()<1 || bmArValidBlockingBottom.length()<1)
		{
			continue;
		}
		
		Beam bmTop=bmArValidBlockingTop[bmArValidBlockingTop.length()-1];
		Beam bmBot=bmArValidBlockingBottom[0];
		
		Point3d ptSplitTop=bmTop.ptCen()-bmTop.vecD(vyEl) * bmTop.dD(vyEl) * 0.5; ptSplitTop.vis(2);
		Point3d ptSplitBottom=bmBot.ptCen()+bmBot.vecD(vyEl) * bmBot.dD(vyEl) * 0.5; ptSplitBottom.vis(1);
		
		if (bm.vecX().dotProduct(ptSplitTop-ptSplitBottom)>0)
		{
			bm.dbSplit(ptSplitTop, ptSplitBottom);
		}
		else
		{
			bm.dbSplit(ptSplitBottom, ptSplitTop);
		}
	}
}

//Erase this tsl.
eraseInstance();
return;

#End
#BeginThumbnail


#End
