#Version 8
#BeginDescription
Last modified by: Anno Sportel (anno.sportel@itwindustry.nl)
01.09.2010  -  version 1.02










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
/// This tsl creates blocking pieces in the slab boxes on top of studs in the wall below
/// </summary>

/// <insert>
/// Select slab box, select wall underneath
/// </insert>

/// <remark Lang=en>
/// 
/// </remark>

/// <version  value="1.02" date="01.09.2010"></version>

/// <history>
/// AS - 1.00 - 22.01.2009 	- Pilot version
/// AJ - 1.01 - 12.02.2009 	- Add option when there is no beams on top and bottom of the slab
/// AS - 1.02 - 01.09.2010 	- Use vzWall instead of vxSlab for position of blocking.
/// </history>

//Script uses mm
double dEps = U(.001,"mm");

//Width of blocking
PropDouble dBlockingWidth(0, U(45), T("|Blocking width|"));

PropString sBmCode(0, "Klos", T("|BeamCode|"));

//Insert
if( _bOnInsert ){
	if( insertCycleCount() > 1 ){
		eraseInstance();
		return;
	}
	
	_Element.append(getElement(T("|Select a slab box|")));
	_Element.append(getElement(T("|Select a wall underneath|")));
	
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

//CoordSys slab
CoordSys csSlab = elSlab.coordSys();
Vector3d vxSlab = csSlab .vecX();
Vector3d vySlab = csSlab.vecY();
Vector3d vzSlab = csSlab.vecZ();
_Pt0=csSlab.ptOrg();
//CoordSys wall
CoordSys csWall = elWall.coordSys();
Vector3d vxWall = csWall.vecX();
Vector3d vyWall = csWall.vecY();
Vector3d vzWall = csWall.vecZ();

//Wallheight
LineSeg lnSegWall = elWall.segmentMinMax();
double dWallHeight = vyWall.dotProduct(lnSegWall.ptEnd() - lnSegWall.ptStart());

//Beams of wall
Beam arBmWall[] = elWall.beam();
//Vertical beams of wall
Beam arBmVert[] = vxWall.filterBeamsPerpendicularSort(arBmWall);

//Assign this tsl to the element
_ThisInst.assignToElementGroup(elSlab, TRUE, 0, 'T');

//Create a PlaneProfile with the shape of teh TopPlates
PlaneProfile ppTopPlate (csWall);
Plane plnZ (csWall.ptOrg(), vzWall);
for( int i=0; i<arBmWall.length(); i++ ){
	Beam bm = arBmWall[i];
	
	if (bm.type()==_kSFTopPlate)
	{
		PlaneProfile ppBm=bm.envelopeBody(FALSE, TRUE).shadowProfile(plnZ);
		ppBm.shrink(-U(10));
		ppTopPlate.unionWith(ppBm);
	}
}


//Points to create blocking
Point3d arPtBlock[0];
for( int i=0;i<arBmVert.length();i++ ){
	Beam bm = arBmVert[i];
	PlaneProfile ppBm=bm.envelopeBody(FALSE, TRUE).shadowProfile(plnZ);
	//if( bm.solidLength() > (dWallHeight - U(150)) ){
	ppBm.intersectWith(ppTopPlate);
	if( ppBm.area() > U(1)*U(1) ){
		bm.ptCen().vis(i);
		arPtBlock.append(bm.ptCen());
	}
}

//Line to project points
Line lnSlabY(csSlab.ptOrg(), vySlab);
Line lnSlabX(csSlab.ptOrg(), vxSlab);
Line lnSlabZ(csSlab.ptOrg(), vzSlab);

//Beams
Beam arBmSlab[] = elSlab.beam();

//BBS1
Beam bmBBS1;
//BBS2
Beam bmBBS2;
//BBS3
Beam bmBBS3;
//BBS4
Beam bmBBS4;

//Find extreme points of element in XZ plane
Point3d arPtBm[0];
for( int i=0;i<arBmSlab.length();i++ ){
	Beam bm = arBmSlab[i];
	
	//BeamCode
	String sBmCode = bm.name("beamCode").token(0);
	//Check if its a beam to process
	if( sBmCode == "BBS1" ){
		bmBBS1 = bm;
	}
	else if( sBmCode == "BBS2" ){
		bmBBS2 = bm;
	}
	else if( sBmCode == "BBS3" ){
		bmBBS3 = bm;
	}
	else if( sBmCode == "BBS4" ){
		bmBBS4 = bm;
	}
	else{
	}
		
	//Append all points
	arPtBm.append(bm.realBody().allVertices());	
}

double dBlockHeight = abs(vxSlab.dotProduct(bmBBS3.ptCen() - bmBBS4.ptCen())) - .5 * (bmBBS3.dD(vxSlab) + bmBBS4.dD(vxSlab));
double dBlockWidth = dBlockingWidth;
double dBlockLength;

Point3d ptBlock;

if (bmBBS1.bIsValid())
{
	dBlockLength = abs(vzSlab.dotProduct(bmBBS1.ptCen() - bmBBS2.ptCen())) - .5 * (bmBBS1.dD(vzSlab) + bmBBS2.dD(vzSlab));
	ptBlock = bmBBS1.ptCen() + vzSlab * .5 * (bmBBS1.dD(vzSlab) + dBlockLength); ptBlock.vis(1);
	ptBlock += vzWall * vzWall.dotProduct((bmBBS4.ptCen() + vzWall * .5 * (bmBBS4.dD(vzWall) + dBlockHeight)) - ptBlock); ptBlock.vis(2);
}
else
{
	dBlockLength=bmBBS3.dD(vzSlab);
	ptBlock = bmBBS3.ptCen(); ptBlock.vis(1);
	ptBlock += vzWall * vzWall.dotProduct((bmBBS4.ptCen() + vzWall * .5 * (bmBBS4.dD(vzWall) + dBlockHeight)) - ptBlock); ptBlock.vis(2);

}
	


//Point3d ptBlock = bmBBS1.ptCen() + vzSlab * .5 * (bmBBS1.dD(vzSlab) + dBlockLength); ptBlock.vis(1);


Line lnBlock(ptBlock, vySlab);

//PlaneProfile ppSlab(bmBBS1.realBody().shadowProfile(Plane(elSlab.ptOrg(), vzSlab)));
Plane plnZSlab (csSlab.ptOrg(), vzSlab);
PlaneProfile ppSlab (csSlab);
for( int i=0; i<arBmSlab.length(); i++ ){
	Beam bm = arBmSlab[i];
	
	PlaneProfile ppBm=bm.envelopeBody(FALSE, TRUE).shadowProfile(plnZSlab);
	ppBm.shrink(-U(100));
	ppSlab.unionWith(ppBm);
}
ppSlab.shrink(U(100));
ppSlab.vis(1);

for( int i=0;i<arPtBlock.length();i++ ){
	Point3d pt = arPtBlock[i];
	pt = lnBlock.closestPointTo(pt);
	pt.vis();
	
	if( ppSlab.pointInProfile(pt) == _kPointOutsideProfile )continue;
	
	Beam bmNew;
	bmNew.dbCreate(pt, vzSlab, vySlab, -vxSlab, dBlockLength, dBlockWidth, dBlockHeight);
	bmNew.assignToElementGroup(elSlab, TRUE, 0, 'Z');
	bmNew.setBeamCode(sBmCode);
	bmNew.setColor(32);
	bmNew.realBody().vis(32);
	
}

eraseInstance();




#End
#BeginThumbnail




#End
