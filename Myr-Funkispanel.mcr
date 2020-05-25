#Version 8
#BeginDescription
Last modified by: Leif Isacsson, Myresjohus
21.12.2009  -  version 1.4


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
/// Create areas to apply sheeting distribution.
/// </summary>

/// <insert>
/// Select a set of elements
/// </insert>

/// <remark Lang=en>
/// .
/// </remark>

/// <version  value="1.06" date="29.09.2009"></version>

/// <history>
/// AS - 1.00 - 15.01.2008 	- Pilot version
/// AS - 1.01 - 12.03.2008 	- Calculate height of sheets in a different way
/// AS - 1.02 - 23.10.2008 	- Erase sheeting with height less than 22 mm
/// AS - 1.03 - 29.09.2009 	- Offset tooling from a reference point, use a standard sheet size to calculate the tool-positions
/// Isac - 1.04 - 21.12.2009  - Default values changed
/// </history>

Unit (1,"mm");
double dEps = U(0.1);

double dMinimumWidth = U(22);

PropDouble dRabbetTopHeight(0, U(28), T("Height top"));
PropDouble dRabbetTopExtraHeight(1, U(5), T("Extra height top"));
PropDouble dRabbetTopDepth(2, U(10.5), T("Depth top"));

PropDouble dRabbetBottomHeight(3, U(14), T("Height bottom"));
PropDouble dRabbetBottomExtraHeight(4, U(0), T("Extra height bottom"));
PropDouble dRabbetBottomDepth(5, U(10.5), T("Depth bottom"));

PropDouble dRabbetWidthBackV(6, U(-39), T("Size vertical back"));
PropDouble dRabbetWidthFrontV(7, U(25), T("Size vertical front"));

String arSLeftRight[] = {"Left", "Right"};
int arNLeftRight[] = {1, -1};
PropString sLeftRight(0,arSLeftRight, "Start verticaal rabat");
int nLeftRight = arNLeftRight[arSLeftRight.find(sLeftRight,0)];

PropDouble dNormalSheetSizeH(8, U(145), T("|Normal size horizontal sheeting|")); 
PropDouble dNormalSheetSizeV(9, U(118), T("|Normal size vertical sheeting|"));

String arSRabatH[] = {
	"PANELBRÄDA P81"
};
String arSRabatV[] = {
	"FUNKISPANEL"
};

if(_bOnInsert){
	_Pt0 = getPoint(T("Select an insertion point"));
	// the constructor of PrEntity requires a type of entity. Here we use Element()
	PrEntity ssE("\nSelect a set of elements",Element());

	if (ssE.go()) { // let the prompt class do its job, only one run
		Entity ents[0]; // the PrEntity will return a list of entities, and not elements
		// copy the list of selected entities to a local array: for performance and readability
		ents = ssE.set(); 

		// turn the selected set into an array of elements
		for (int i=0; i<ents.length(); i++) {
			Element el = (Element)ents[i]; // cast the entity to a element    
			_Element.append(el);
		}
	}

	return;
}

if(_Element.length()==0){eraseInstance();return;}

for(int e=0;e<_Element.length();e++){
	Element el = _Element[e];

	Vector3d vx = el.vecX();
	Vector3d vy = el.vecY();
	Vector3d vz = el.vecZ();

	Sheet arSh[] = el.sheet();
	Sheet arShH[0];
	Sheet arShV[0];
	for(int i=0;i<arSh.length();i++){
		Sheet sh = arSh[i];
		String sMaterial = sh.material();
		sMaterial.makeUpper();
		if( arSRabatH.find(sMaterial) != -1 ){
			arShH.append(sh);
		}
		if( arSRabatV.find(sMaterial) != -1 ){
			arShV.append(sh);
		}
	}

	for(int i=0;i<arShH.length();i++){
		Sheet sh = arShH[i];
		int nSide = 1;
		if( sh.myZoneIndex() < 0 ) nSide = -1;	

		double dShY;// = sh.dL();
		double dMin;
		double dMax;
		int bMinMaxSet = FALSE;
		Body bdSh = sh.envelopeBody();
		Point3d arPtBdSh[] = bdSh.allVertices();
		for(int j=0;j<arPtBdSh.length();j++){
			Point3d pt = arPtBdSh[j];
			double dDist=el.vecY().dotProduct(pt - bdSh.ptCen());
			if( !bMinMaxSet ){
				bMinMaxSet = TRUE;
				dMin = dDist;
				dMax = dDist;
			}
			else{
				if( (dMin - dDist) > dEps ){
					dMin = dDist;
				}
				if( (dDist - dMax) > dEps ){
					dMax = dDist;
				}
			}
		}
		dShY = dMax - dMin;
		
		if( dShY < dMinimumWidth )sh.dbErase();
		
		// find reference point for sheet
		Point3d ptSheet = sh.ptCen() - vy * .5 * dShY;

		//Cut top
		Point3d ptBmCutTop = ptSheet + vy * (dNormalSheetSizeH - dRabbetTopHeight) - vz * nSide * (.5 * sh.dH() - dRabbetTopDepth);
		//ptBmCutTop.vis();
		BeamCut bmCutTop(ptBmCutTop, vx, vy, vz, U(10000), 5 * dRabbetTopHeight, 5 * dRabbetTopDepth, 0, 1, nSide);
		//sh.realBody().vis(3);
		sh.addTool(bmCutTop);
		
		//Extra cut top
		if( dRabbetTopExtraHeight > 0 ){
			Vector3d vyCut = vy.rotateBy(atan(dRabbetTopExtraHeight/dRabbetTopDepth), vx * nSide);
			Vector3d vzCut = vx.crossProduct(vyCut);
			BeamCut bmCutTopExtra(ptBmCutTop, vx, vyCut, vzCut, U(10000), 5 * dRabbetTopHeight, 5 * dRabbetTopDepth, 0, 1, nSide);
			//sh.realBody().vis(3);
			sh.addTool(bmCutTopExtra);
		}
		
		//Cut Bottom
		Point3d ptBmCutBottom = ptSheet + vy * dRabbetBottomHeight + vz * nSide * (.5 * sh.dH() - dRabbetBottomDepth);
		//ptBmCutBottom.vis();
		BeamCut bmCutBottom(ptBmCutBottom, vx, vy, vz, U(10000), 5 * dRabbetBottomHeight, 5 * dRabbetBottomDepth, 0, -1, -nSide);
		//sh.realBody().vis(3);
		sh.addTool(bmCutBottom);
		
		//Extra cut bottom
		if( dRabbetBottomExtraHeight > 0 ){
			Vector3d vyCut = vy.rotateBy(atan(dRabbetBottomExtraHeight/dRabbetBottomDepth), vx * nSide);
			Vector3d vzCut = vx.crossProduct(vyCut);
			BeamCut bmCutBottomExtra(ptBmCutBottom, vx, vyCut, vzCut, U(10000), 5 * dRabbetBottomHeight, 5 * dRabbetBottomDepth, 0, -1, -nSide);
			//sh.realBody().vis(3);
			sh.addTool(bmCutBottomExtra);
		}
	}

	for(int i=0;i<arShV.length();i++){
		Sheet sh = arShV[i];
		int nSide = 1;
		if( sh.myZoneIndex() < 0 ) nSide = -1;	
		
		if( sh.solidWidth() < dMinimumWidth )sh.dbErase();
		
		// find reference point for sheeting
		Point3d ptSheet = sh.ptCen() - vx * nLeftRight * .5 * sh.solidWidth();

		Point3d ptBack = sh.ptCen() + vx * nLeftRight * dRabbetWidthBackV;
		BeamCut bCutBack(ptBack, vx, vy, vz, sh.solidWidth(), 1.1 * sh.solidLength(), sh.dH(), -nLeftRight, 0, -nSide); 
		sh.addTool(bCutBack);
		Point3d ptFront = ptSheet + vx * nLeftRight * (dNormalSheetSizeV - dRabbetWidthFrontV);
		BeamCut bCutFront(ptFront, vx, vy, vz, sh.solidWidth(), 1.1 * sh.solidLength(), sh.dH(), nLeftRight, 0, nSide); 
		sh.addTool(bCutFront);
	}
	
	if(_bOnDebug){
		GenBeam arGBm[] = el.genBeam();
		Display dp(-1);
		for(int i=0;i<arGBm.length();i++){
			GenBeam gBm = arGBm[i];
//			if( arNZoneH.find(gBm.myZoneIndex()) == -1 && arNZoneV.find(gBm.myZoneIndex()) == -1 )continue;
			dp.color(gBm.color());
			dp.draw(gBm.realBody());
		}
	}
}











#End
#BeginThumbnail












#End
