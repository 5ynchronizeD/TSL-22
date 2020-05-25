#Version 8
#BeginDescription
Last modified by: Anno Sportel (anno.sportel@itwindustry.nl)
13.05.2011  -  version 1.01





























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
/// Draw outline of a specific zone in paperspace
/// </summary>

/// <insert>
/// Select a set of elements
/// </insert>

/// <remark Lang=en>
/// .
/// </remark>

/// <version  value="1.00" date="01.09.2010"></version>

/// <history>
/// AS	- 1.00 - 01.09.2010 	- Pilot version
/// AS	- 1.01 - 13.05.2011 	- Remove adding of beam profiles; add option to draw it with openings
/// </history>


Unit (1,"mm");//script uses mm

String arSYesNo[] = {T("|Yes|"), T("|No|")};
int arNYesNo[] = {_kYes, _kNo};
PropString sWithOpening(0, arSYesNo, T("|With openings|"));

int arZone[]={0,1,2,3,4,5,6,7,8,9,10};
PropInt nPropZone(1,arZone,T("Zone"));

PropInt nColor(0, -1, T("|Color|"));

if (_bOnInsert) {
	Viewport vp = getViewport(T("Select a viewport.")); // select viewport
	_Viewport.append(vp);
	showDialog();
	return;
}

if (_Viewport.length() == 0){
	eraseInstance();
	return;
}
Viewport vp = _Viewport[0];

Element el = vp.element();
if (!el.bIsValid()) return;

Display dp(nColor);

int nZone = nPropZone;
if( nZone > 5 )
	nZone = 5 - nZone;

int bWithOpening = arNYesNo[arSYesNo.find(sWithOpening,0)];

CoordSys ms2ps = vp.coordSys();
CoordSys ps2ms = ms2ps; ps2ms.invert(); // take the inverse of ms2ps

CoordSys csEl = el.coordSys();
Point3d ptEl = csEl.ptOrg();
Vector3d vxEl = csEl.vecX();
Vector3d vyEl = csEl.vecY();
Vector3d vzEl = csEl.vecZ();

Beam arBm[] = el.beam();

Plane pnZ(ptEl, vzEl);

PlaneProfile ppEl(csEl);
ppEl = el.profBrutto(nZone);
if( bWithOpening )
	ppEl = el.profNetto(nZone);

//if( nZone == 0 ){
//	PlaneProfile ppBm(csEl);
//	for( int i=0;i<arBm.length();i++ ){
//		Beam bm = arBm[i];
//		ppBm.unionWith(bm.envelopeBody(false, true).shadowProfile(pnZ));
//	}
//	ppBm.shrink(-U(5));
//	ppBm.shrink(U(5));
//	PLine arPlBm[] = ppBm.allRings();
//	int arNRing[] = ppBm.ringIsOpening();
//	
//	ppEl = PlaneProfile(csEl);
//	for( int j=0;j<arPlBm.length();j++ ){
//		int isRing = arNRing[j];
//		if( isRing )
///		continue;
//		
//		PLine ring = arPlBm[j];
//		ppEl.joinRing(ring, _kAdd);
//	}
//}

ppEl.transformBy(ms2ps);
dp.draw(ppEl);






#End
#BeginThumbnail


#End
