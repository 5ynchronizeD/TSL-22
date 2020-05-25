#Version 8
#BeginDescription
Last modified by: Myresjohus
19.01.2011  -  version 1.1












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
/// This tsl creates blocking pieces in the slab boxes at stud locations of the wall attached
/// </summary>

/// <insert>
/// Select slab box, select wall
/// </insert>

/// <remark Lang=en>
/// 
/// </remark>

/// <version  value="1.00" date="21.10.2009"></version>

/// <history>
/// AS - 1.00 - 21.10.2009 	- Pilot version
/// Myresjohus - 19.01.2011 - Change BKS2 to BKS1
/// </history>

//Script uses mm
double dEps = U(.001,"mm");

String arSBmCodeBlocking[] = {
	"BKS1",
	"BKSL2"
};

int arNInvalidBmType[0];// = {
//	_kSFStudLeft,
//	_kSFStudRight
//};

//Width of blocking
PropDouble dBlockingWidth(0, U(45), T("|Blocking width|"));

//Insert
if( _bOnInsert ){
	if( insertCycleCount() > 1 ){
		eraseInstance();
		return;
	}
	
	_Element.append(getElement(T("|Select a slab box|")));
	_Element.append(getElement(T("|Select a wall|")));
	
	if( _kExecuteKey == "" ){
		showDialog();
	}
	else{
		setPropValuesFromCatalog(_kExecuteKey);
	}
	
	return;
}

if( _Element.length() != 2 ){
	reportMessage(T("|Two elements must be selected|"));
	eraseInstance();
	return;
}
//return;
//Selected element
Element el01 = _Element[0];
ElementRoof elSlab = (ElementRoof)el01;
if( !elSlab.bIsValid() ){
	reportMessage("|First element selected needs to be a slab!|");
	eraseInstance();
	return;
}
Element el02 = _Element[1];
ElementWallSF elWall = (ElementWallSF)el02;
if( !elWall.bIsValid() ){
	reportMessage("|Second element selected needs to be a wall!|");
	eraseInstance();
	return;
}

//Assign this tsl to the element
_ThisInst.assignToElementGroup(elSlab, TRUE, 0, 'T');

// coordSys slab
CoordSys csSlab = elSlab.coordSys();
Point3d ptSlab = csSlab.ptOrg();
Vector3d vxSlab = csSlab .vecX();
Vector3d vySlab = csSlab.vecY();
Vector3d vzSlab = csSlab.vecZ();
_Pt0 = ptSlab;

// plane
Plane pnSlabZ(ptSlab, vzSlab);
pnSlabZ.vis();

// planeprofile
PlaneProfile ppSlab = elSlab.profNetto(0);

// coordSys wall
CoordSys csWall = elWall.coordSys();
Point3d ptWall = csWall.ptOrg();
Vector3d vxWall = csWall.vecX();
Vector3d vyWall = csWall.vecY();
Vector3d vzWall = csWall.vecZ();

// wall side
int nWallSide = 1; // top
if( vzSlab.dotProduct(ptWall - ptSlab) < 0 )
	nWallSide = -1;

// wall height
LineSeg lnSegWall = elWall.segmentMinMax();
double dWallHeight = vyWall.dotProduct(lnSegWall.ptEnd() - lnSegWall.ptStart());

// slab height
double dSlabHeight = elSlab.zone(0).dH();

// beams of slab
Beam arBmSlab[] = elSlab.beam();
String sBlockingCodeFound = "BKS1";
Beam arBmBlock[0];
for( int i=0;i<arBmSlab.length();i++ ){
	Beam bm  = arBmSlab[i];
	if( arSBmCodeBlocking.find(bm.beamCode().token(0)) != -1 ){
		arBmBlock.append(bm);
		sBlockingCodeFound = bm.beamCode();
	}
}

// beams of wall
Beam arBmWall[] = elWall.beam();
// vertical beams of wall
// and find possible locations for blocking in the same go
Beam arBmStud[0];
Point3d arPtBlocking[0];
for( int i=0;i<arBmWall.length();i++ ){
	Beam bm = arBmWall[i];
	// must be vertical
	if( !bm.vecX().isPerpendicularTo(vxWall) )
		continue;
	
	if( arNInvalidBmType.find(bm.type()) != -1 )
		continue;
	
	String sGrade = bm.grade().makeUpper();
	if( sGrade.find("REGEL",0) > -1 ){
		// stud found
		arBmStud.append(bm);
		
		// interscetion, offsetted with .5 slabheight
		Line ln(bm.ptCen(), bm.vecX());
		Point3d ptBlock = ln.intersect(pnSlabZ, -.5 * nWallSide * dSlabHeight);
		
		// must be on slab
		if( ppSlab.pointInProfile(ptBlock) != _kPointInProfile ){
			ptBlock.vis(4);
			continue;
		}
		
		// must be close to one of the extremes of the "regel"
		Point3d ptBmMin = bm.ptRef() + bm.vecX() * bm.dLMin();
		Point3d ptBmMax = bm.ptRef() + bm.vecX() * bm.dLMax();
		if( !(abs(vzSlab.dotProduct(ptBmMin - ptBlock)) < U(300) || abs(vzSlab.dotProduct(ptBmMax - ptBlock)) < U(300)) ){
			ptBlock.vis(5);
			continue;
		}
		
		Body bdPoint(ptBlock, vxWall, vyWall, vzWall, .9 * dBlockingWidth, 1, 1);
		// check if there is already a blocking piece at that location
		int bIntersectionFound = FALSE;
		for( int j=0;j<arBmSlab.length();j++ ){
			Body bdExistingBeam = arBmSlab[j].envelopeBody();
			if( bdPoint.hasIntersection(bdExistingBeam) ){
				ptBlock.vis(1);
				bIntersectionFound = TRUE;
				break;
			}
		}
		
		if( !bIntersectionFound ){
			arPtBlocking.append(ptBlock);
			ptBlock.vis(3);
		}
	}
}

// create new blocking
for( int i=0;i<arPtBlocking.length();i++ ){
	Point3d pt = arPtBlocking[i];
	
	Beam arBmBack[] = Beam().filterBeamsHalfLineIntersectSort(arBmSlab, pt, -vzWall);
	Beam arBmFront[] = Beam().filterBeamsHalfLineIntersectSort(arBmSlab, pt, vzWall);
	// back
	if( arBmBack.length() == 0 ){
		reportWarning(TN("|No beams found at the back!|"));
		continue;
	}
	Beam bmBack = arBmBack[0];
	// front
	if( arBmFront.length() == 0 ){
		reportWarning(TN("|No beams found at the front!|"));
		continue;
	}
	Beam bmFront = arBmFront[0];
	
	Beam bmNew;
	bmNew.dbCreate(pt, vzWall, -vxWall, vyWall, U(1), dBlockingWidth, dSlabHeight, 0, 0, 0);
	bmNew.stretchStaticTo(bmBack, TRUE);
	bmNew.stretchStaticTo(bmFront, TRUE);
	bmNew.assignToElementGroup(elSlab, TRUE, 0, 'Z');
	bmNew.setColor(32);
	bmNew.setBeamCode(sBlockingCodeFound);
}

// job done
eraseInstance();



#End
#BeginThumbnail



#End
