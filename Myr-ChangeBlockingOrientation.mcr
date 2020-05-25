#Version 8
#BeginDescription
Last modified by: Anno Sportel (anno.sportel@itwindustry.nl)
01.09.2010  -  version 1.0

#End
#Type O
#NumBeamsReq 0
#NumPointsGrip 0
#DxaOut 1
#ImplInsert 1
#FileState 0
#MajorVersion 1
#MinorVersion 0
#KeyWords 
#BeginContents
/// <summary Lang=en>
/// This tsl switches the orientation of blocking pieces which are generated wrong
/// </summary>

/// <insert>
/// Select a viewport
/// </insert>

/// <remark Lang=en>
/// .
/// </remark>

/// <version  value="1.00" date="01.09.2010"></version>

/// <history>
/// AS - 1.00 - 01.09.2010 	- Pilot version
/// </history>


//Script uses mm.
double dEps = U(0.01,"mm");


//Beams to replace have beamcode: OK.
PropString sBmCode(0, "BOK2", T("|BeamCode|"));


//Insert
if( _bOnInsert ){
	if( insertCycleCount()>1 ){eraseInstance(); return;}
	
	PrEntity ssE(T("|Select a set of elements|"),Element());
	
	if( ssE.go() ){
		_Element.append(ssE.elementSet());
	}
	
	showDialog();
	return;
}

//Check if there is an element selected.
if( _Element.length() == 0 ){eraseInstance(); return; }

for( int e=0;e<_Element.length();e++ ){
	if( _Element[e].bIsKindOf(ERoofPlane()) )continue;
	//Assign selected element to el
	Element el = _Element[e];

	//Vectors
	Vector3d vx = el.vecX();
	Vector3d vy = el.vecY();
	Vector3d vz = el.vecZ();

	//Beams
	Beam arBm[] = el.beam();

	for( int i=0;i<arBm.length();i++ ){
		Beam bm2Replace = arBm[i];
		if( bm2Replace.name("beamCode").token(0) == sBmCode ){
			Point3d ptInsert = bm2Replace.ptCen();
			Beam bmNew;
			bmNew.dbCreate(ptInsert, vx, vy, vz, bm2Replace.dH(), bm2Replace.dL(), bm2Replace.dW());
			bmNew.setType(bm2Replace.type());
			bmNew.setLabel(bm2Replace.label());
			bmNew.setSubLabel(bm2Replace.subLabel());
			bmNew.setSubLabel2(bm2Replace.subLabel2());
			bmNew.setGrade(bm2Replace.grade());
			bmNew.setInformation(bm2Replace.information());
			bmNew.setMaterial(bm2Replace.material());
			bmNew.setBeamCode(bm2Replace.beamCode());
			bmNew.setName(bm2Replace.name());
			bmNew.setModule(bm2Replace.module());
			bmNew.setHsbId(bm2Replace.hsbId());
			bmNew.setColor(bm2Replace.color());
			
			bmNew.assignToElementGroup(el,TRUE,0,'Z');
		
			bm2Replace.dbErase();		
		}
	}
}	

eraseInstance();

#End
#BeginThumbnail


#End
