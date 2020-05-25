#Version 8
#BeginDescription










#End
#Type O
#NumBeamsReq 0
#NumPointsGrip 0
#DxaOut 1
#ImplInsert 1
#FileState 0
#MajorVersion 0
#MinorVersion 0
#KeyWords 
#BeginContents
String arSBmCodeZn8[0];
arSBmCodeZn8.append("IH");

//Insert
if( _bOnInsert ){
	if( insertCycleCount()>1 ){eraseInstance(); return;}
	
	PrEntity ssE("\nVälj Hörn till Zon 8",Element());
	
	if( ssE.go() ){
		_Element.append(ssE.elementSet());
	}
	
	//showDialog("_Default");
	return;
}

//Check if there is an element selected.
if( _Element.length() == 0 ){eraseInstance(); return; }

for( int e=0;e<_Element.length();e++ ){
	if( _Element[e].bIsKindOf(ERoofPlane()) )continue;
	//Assign selected element to el
	Element el = _Element[e];

	Beam arBm[] = el.beam();
	for( int i=0;i<arBm.length();i++ ){
		Beam bm = arBm[i];
		String sBmCode = bm.name("beamCode").token(0);
		int nZoneIndex = 0;
		int nColor = -1;

		if( arSBmCodeZn8.find(sBmCode) != -1 ){
			nColor = 7;
			nZoneIndex = -3;
		}
		else{
			continue;
		}
		
		Body bd = bm.realBody();
		Sheet sh;
		
		PlaneProfile ppBm = bd.getSlice( Plane(bm.ptCen(), bm.vecD(el.vecZ())) );
		double dThickness = bm.dD(bm.vecD(el.vecZ()));
		
		sh.dbCreate( ppBm, dThickness, 0 );
		sh.assignToElementGroup(el,TRUE, nZoneIndex, 'Z');
		sh.setColor(nColor);
		sh.setLabel(bm.label());
		sh.setSubLabel(bm.subLabel());
		sh.setSubLabel2(bm.subLabel2());
		sh.setGrade(bm.grade());
		sh.setInformation(bm.information());
		sh.setModule(bm.module());
		sh.setName(bm.name());
		sh.setMaterial(bm.material());

		bm.dbErase();
	}
	
}	

if (_bOnElementConstructed)
	eraseInstance();









#End
#BeginThumbnail




#End
