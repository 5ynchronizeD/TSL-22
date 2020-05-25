#Version 8
#BeginDescription
Last modified by: OBOS (Oscar.Ragnerby@obos.se)
08.11.2019  -  version 1.16






#End
#Type O
#NumBeamsReq 0
#NumPointsGrip 0
#DxaOut 1
#ImplInsert 1
#FileState 1
#MajorVersion 1
#MinorVersion 16
#KeyWords 
#BeginContents
/// <summary Lang=en>
/// Tsl that sets the grade field of beams around an opening.
/// </summary>

/// <insert>
/// -
/// </insert>

/// <remark Lang=en>
/// 
/// </remark>

/// <version  value="1.16" date="12.11.2019"></version>

/// <history>
/// AS	- 1.00 - 23.04.2008 - 	Pilot version
/// LI	- 1.01 - 23.04.2008 - 	Remove duplicates; add symbol for windows
/// AS	- 1.02 - 23.04.2008 - 	Assign to element layer 'Info 5'
/// AS	- 1.03 - 03.09.2008 - 	Add Swing-angle.
/// AS	- 1.04 - 23.10.2008 - 	Add symbol for double door
/// AS	- 1.05 - 24.10.2008 - 	Add opening handle as a readonly prop for sub element list
/// AS	- 1.06 - 19.11.2008 - 	Fix double door solution. Implement turning direction and hangside comming from the revit link.
/// AS	- 1.07 - 04.12.2008 - 	Add to layer T0 io I5, Store state in dwg
/// AS	- 1.08 - 02.07.2009 - 	Draw in display representation
/// AS	- 1.09 - 10.06.2015 - 	Change to information layer. Add element filters. (FogBugzId 1388)
/// AS	- 1.10 - 11.06.2015 - 	Add support for execution on element constructed.
/// AS	- 1.11 - 11.06.2015 - 	Bugfix execution from generate construction
/// AS	- 1.12 - 22.05.2019 - 	Read turning direction and hinge side from mapX
/// AS	- 1.13 - 24.05.2019 - 	Respect coordinate system of opening for face and hand side.
/// OR   - 1.14 - 05.08.2019 - Added override function for windows with hinges on the sides (Door symbol is added)
/// OR   - 1.15 - 06.08.2019 - Added double door and single door as choosable option
/// OR   - 1.16 - 12.11.2019 - Added double door and single door as choosable option
/// </hsitory>

String categories[] = {
	T("|Element filter|"),
	T("|Generation|"),
	T("|Visualization|")
};

String elementFilterCatalogNames[] = TslInst().getListOfCatalogNames("hsbElementFilter");
elementFilterCatalogNames.insertAt(0, T("|Do not use an element filter|"));
PropString elementFilter(5, elementFilterCatalogNames, T("|Element filter catalog|"));
elementFilter.setDescription(T("|Sets the element filter to use.|"));
elementFilter.setCategory(categories[0]);

PropInt sequenceForGeneration(0, 0, T("|Sequence number|"));
sequenceForGeneration.setDescription(T("|The sequence number is used to sort the list of tsls during the generation of the element.|"));
sequenceForGeneration.setCategory(categories[1]);
// Set the sequence for execution on generate construction.
_ThisInst.setSequenceNumber(sequenceForGeneration);

PropDouble dSwingAngle(0, 15, T("Swing angle"));
dSwingAngle.setFormat(_kAngle);
dSwingAngle.setDescription(T("|Sets the swing angle of the opening.|"));
dSwingAngle.setCategory(categories[2]);

PropString sDimStyle(0, _DimStyles, T("Dimension style"));
sDimStyle.setDescription(T("|Sets the dimension style to use.|"));
sDimStyle.setCategory(categories[2]);

//Display representation to draw the obejct in
PropString sDispRep(1, _ThisInst.dispRepNames(), T("|Draw in display representation|"));
sDispRep.setDescription(T("|Sets the display representation to draw the symbol in.|"));
sDispRep.setCategory(categories[2]);

//String arShowState[] = {"False", "True"};
String arShowState[] = {"False", "Single Door", "Double Door"};
PropString sShowSwing(5, arShowState, T("|Override defaultl"));
sShowSwing.setDescription(T("|Override option|"));
sShowSwing.setCategory(categories[2]);

double dMaximumSizeSingleDoor = U(1200);

// Set properties if inserted with an execute key
String arSCatalogNames[] = TslInst().getListOfCatalogNames("Myr-TurningDirection");


if( arSCatalogNames.find(_kExecuteKey) != -1 ) 
	setPropValuesFromCatalog(_kExecuteKey);

if( _bOnInsert ){
	if( insertCycleCount() > 1 ){
		eraseInstance();
		return;
	}
	
	if( _kExecuteKey == "" || arSCatalogNames.find(_kExecuteKey) == -1 )
		showDialog();
	
	int nNrOfTslsInserted = 0;
	PrEntity ssE(T("Select a set of elements"), ElementWallSF());

	if( ssE.go() ){
		Element arSelectedElement[0];
		if (elementFilter !=  elementFilterCatalogNames[0]) {
			Entity selectedEntities[] = ssE.set();
			Map elementFilterMap;
			elementFilterMap.setEntityArray(selectedEntities, false, "Elements", "Elements", "Element");
			TslInst().callMapIO("hsbElementFilter", elementFilter, elementFilterMap);
			
			Entity filteredEntities[] = elementFilterMap.getEntityArray("Elements", "Elements", "Element");
			for (int i=0;i<filteredEntities.length();i++) {
				Element el = (Element)filteredEntities[i];
				if (!el.bIsValid())
					continue;
				arSelectedElement.append(el);
			}
		}
		else {
			arSelectedElement = ssE.elementSet();
		}
						
		for( int e=0;e<arSelectedElement.length();e++ ){
			Element el = arSelectedElement[e];
			Opening openings[] = el.opening();
			for (int i=0;i<openings.length();i++) {
				OpeningSF opening = (OpeningSF)openings[i];
				if (!opening.bIsValid())
					continue;
//				String sType = opening.type().token(0).makeUpper();
//				if( sType == "DOOR" || sType == "WINDOW")
//					_Entity.append(opening);
					
				Map revitIDMap = opening.subMapX("REVITID");
				String openingType = revitIDMap.getString("Category");
				
				if (openingType == "Doors" || openingType == "Windows")
				{
					_Entity.append(opening);
				}
				
						
			}
		}
		
		reportMessage("\n"+_Entity.length()+" doors & windows selected.");
	}
}

String arSTurningDirection[] = {T("Outside"),T("Inside")};
String arSTurningDirectionFromLink[] = {"1", "-1"};
int arNTurningDirection[] = {1, -1};
PropString sTurningDirection(2, arSTurningDirection, T("Turning direction"));

String arSHangside[] = {T("Left"),T("Right")};
String arSHangsideFromLink[] = {"V", "H"};
PropString sHangside(3, arSHangside, T("Hangside"));

PropString sHandle(4, "", T("|Handle|"));
sHandle.setReadOnly(TRUE);




if( _bOnInsert ){
	String sScriptName = scriptName();
	Vector3d vUcsX = _XU;
	Vector3d vUcsY = _YU;
	
	int nArPropInt[1];
	double dArPropDouble[0];
	String sArPropString[6];
	
	nArPropInt[0] = sequenceForGeneration;
	
	sArPropString[0] = sDimStyle; //00
	sArPropString[1] = sDispRep; //00
	sArPropString[5] = elementFilter;
	
	Point3d arPt[0];
	GenBeam arGBm[0];
	Entity arEnt[0];

	for( int e=0;e<_Entity.length();e++ ){
		Entity ent  = _Entity[e];
		OpeningSF opSF = (OpeningSF)ent;
		
		Element el = opSF.element();
		CoordSys elementCoordSys = el.coordSys();
		Vector3d elX = elementCoordSys.vecX();
		Vector3d elZ = elementCoordSys.vecZ();
		
		CoordSys openingCoordSys = opSF.coordSys();
		Vector3d openingX = openingCoordSys.vecX();
		Vector3d openingZ = openingCoordSys.vecZ();
		int facingFlipped = (elZ.dotProduct(openingZ) < 0);
		int handFlipped = (elX.dotProduct(openingX) < 0);
		if (facingFlipped)
		{
			handFlipped = ! handFlipped;
		}

		sArPropString[2] = arSTurningDirection[facingFlipped ? 1 : 0];
		sArPropString[3] = arSHangside[handFlipped ? 1 : 0];
		
		String sOpeningHandle = opSF.handle();
		sArPropString[4] = sOpeningHandle; //03
	
		arEnt.setLength(0);
		arEnt.append(ent);
		
		
	
		TslInst thisTsl;
		thisTsl.dbCreate(sScriptName, vUcsX, vUcsY, arGBm, arEnt, arPt, nArPropInt, dArPropDouble, sArPropString);
	}
	
	eraseInstance();
	return;
}

int nTurningDirection = arNTurningDirection[arSTurningDirection.find(sTurningDirection,0)];
int nHangside = arSHangside.find(sHangside,0);

if( _Entity.length() == 0 ){
	reportMessage(T("|No entity found|"));
	eraseInstance();
	return;
}

Display dp(-1);
dp.dimStyle(sDimStyle);

Display dpDispRep(-1);
dpDispRep.dimStyle(sDimStyle);
dpDispRep.showInDispRep(sDispRep);

ElementWallSF elSf;
if (_Element.length() > 0) 
	elSf = (ElementWallSF)_Entity[0];

CoordSys elementCoordSys = elSf.coordSys();
Vector3d elX = elementCoordSys.vecX();
Vector3d elZ = elementCoordSys.vecZ();

if (elSf.bIsValid()) {
	String sScriptName = scriptName();
	Vector3d vUcsX = _XU;
	Vector3d vUcsY = _YU;
	
	int nArPropInt[1];
	double dArPropDouble[0];
	String sArPropString[6];
	
	nArPropInt[0] = sequenceForGeneration;
	
	sArPropString[0] = sDimStyle; //00
	sArPropString[1] = sDispRep; //00
	sArPropString[5] = elementFilter;
	
	Point3d arPt[0];
	GenBeam arGBm[0];
	Entity arEnt[0];
	
	Opening arOp[] = elSf.opening();
	
	for( int e=0;e<arOp .length();e++ ){
		OpeningSF opSf = (OpeningSF)arOp[e];
		if (!opSf.bIsValid())
			continue;
		
		Map revitIDMap = opSf.subMapX("REVITID");
		String openingType = revitIDMap.getString("Category");
		
		if (!(openingType == "Doors" || openingType == "Windows"))
		{
			continue;
		}
		
		CoordSys openingCoordSys = opSf.coordSys();
		
		Vector3d openingX = openingCoordSys.vecX();
		Vector3d openingZ = openingCoordSys.vecZ();
		int facingFlipped = (elZ.dotProduct(openingZ) < 0);
		int handFlipped = (elX.dotProduct(openingX) < 0);
		if (facingFlipped)
		{
			handFlipped = ! handFlipped;
		}
		
		sArPropString[2] = arSTurningDirection[facingFlipped ? 1 : 0];
		sArPropString[3] = arSHangside[handFlipped ? 1 : 0];
		
		String sOpeningHandle = opSf.handle();
		sArPropString[4] = sOpeningHandle; //03
	
		arEnt.setLength(0);
		arEnt.append(opSf);
		
		
		
		TslInst thisTsl;
		thisTsl.dbCreate(sScriptName, vUcsX, vUcsY, arGBm, arEnt, arPt, nArPropInt, dArPropDouble, sArPropString);
	}
	
	eraseInstance();
	return;
}


OpeningSF op = (OpeningSF)_Entity[0];

if (!op.bIsValid()) {
	reportNotice(T("|Selected entity is not an opening|"));
	eraseInstance();
	return;
}

//Get element of opening
Element el = op.element();
	
//CoordSys
CoordSys csEl = el.coordSys();
Vector3d vx = csEl.vecX();
Vector3d vy = csEl.vecY();
Vector3d vz = csEl.vecZ();
csEl.vis();
CoordSys csOp = op.coordSys();
csOp.vis();
//Opening start and end
Line lnX(el.ptOrg(), vx);
Point3d arPtOp[] = op.plShape().vertexPoints(TRUE);
Point3d arPtOpX[] = lnX.orderPoints(arPtOp);
if( arPtOpX.length() < 2){
	reportNotice("\nNot enough points found for opening: "+op.descrSF());
	eraseInstance();
	return;
}
Point3d arPtOpExtremes[] = {arPtOpX[0], arPtOpX[arPtOpX.length() - 1]};
double dOpWidth = abs(vx.dotProduct(arPtOpX[0] - arPtOpX[arPtOpX.length() - 1]));

//Origin point	
_Pt0 = el.ptOrg() + vx * vx.dotProduct(arPtOpExtremes[0] - el.ptOrg());

//Remove duplicates
TslInst arTsl[] = el.tslInst();
for( int i=0;i<arTsl.length();i++ ){
	TslInst tsl = arTsl[i];
	if( tsl.handle() != _ThisInst.handle() &&  tsl.scriptName() == _ThisInst.scriptName() ){
		Point3d ptTslOrg = tsl.ptOrg();
		if( (ptTslOrg - _Pt0).length() < U(5) ){
			tsl.dbErase();
		}
	}
}

//Assign to element
assignToElementGroup(el, TRUE, 0, 'I');

PLine plSymbol(vy);
//Must be a door or a window
String sType = op.type().token(0).makeUpper();

Map revitIDMap = op.subMapX("REVITID");
String openingType = revitIDMap.getString("Category");

CoordSys openingCoordSys = op.coordSys();
Vector3d openingX = openingCoordSys.vecX();
Vector3d openingZ = openingCoordSys.vecZ();
int facingFlipped = (elZ.dotProduct(openingZ) < 0);
int handFlipped = (elX.dotProduct(openingX) < 0);


if (openingType == "Doors" || sShowSwing != "False"){ 
//if( sType == "DOOR" ){	
	Point3d ptSymbol = _Pt0;
	
	if( (dOpWidth > dMaximumSizeSingleDoor && sShowSwing == "False")  || sShowSwing == "Double Door"){ //Double door
		if( nTurningDirection == -1 ){//inside
			ptSymbol -= vz * el.zone(0).dH();
			ptSymbol += vx * dOpWidth;
		}
		plSymbol.addVertex(ptSymbol);
		plSymbol.addVertex(ptSymbol + vz.rotateBy(90 - dSwingAngle, vy) * nTurningDirection * .5 * dOpWidth);
		plSymbol.addVertex(ptSymbol + vx * nTurningDirection * .5 * dOpWidth, .5 * dOpWidth, _kCCWise);
		plSymbol.addVertex(ptSymbol + vx * nTurningDirection * dOpWidth + vz.rotateBy(90 - dSwingAngle, -vy) * nTurningDirection * .5 * dOpWidth, .5 * dOpWidth, _kCCWise);
		plSymbol.addVertex(ptSymbol + vx * nTurningDirection * dOpWidth);
		
		plSymbol.close();
	}
	else{ // Single door
		if( nTurningDirection == 1 ){//outside
			ptSymbol += vx * vx.dotProduct(arPtOpExtremes[nHangside] - ptSymbol);
		}
		else{//inside
			ptSymbol += vx * vx.dotProduct(arPtOpExtremes[arPtOpExtremes.length() - (1 + nHangside)] - _Pt0);
			ptSymbol -= vz * el.zone(0).dH();
		}
		plSymbol.addVertex(ptSymbol);
		
		if( nHangside == 1 ){//Right
			plSymbol.addVertex(ptSymbol + vz.rotateBy(90 - dSwingAngle, -vy) * nTurningDirection * dOpWidth);
			plSymbol.addVertex(ptSymbol - vx * nTurningDirection * dOpWidth, dOpWidth, _kCWise);
		}
		else{//Left
			plSymbol.addVertex(ptSymbol + vz.rotateBy(90 - dSwingAngle, vy) * nTurningDirection * dOpWidth);
			plSymbol.addVertex(ptSymbol + vx * nTurningDirection * dOpWidth, dOpWidth, _kCCWise);
		}
		plSymbol.close();
		
	}
}

if( openingType == "Windows" && sShowSwing == "False"  ){
	Point3d ptSymbol = _Pt0 - vz * .5 * el.zone(0).dH();

	plSymbol.addVertex(ptSymbol);
	plSymbol.addVertex(ptSymbol + vx * dOpWidth);
	
}
dp.draw(plSymbol);
dpDispRep.draw(plSymbol);



#End
#BeginThumbnail













#End
#BeginMapX
<?xml version="1.0" encoding="utf-16"?>
<Hsb_Map>
  <lst nm="TslIDESettings">
    <lst nm="HostSettings">
      <dbl nm="PreviewTextHeight" ut="L" vl="1" />
    </lst>
    <lst nm="{E1BE2767-6E4B-4299-BBF2-FB3E14445A54}">
      <lst nm="BreakPoints" />
    </lst>
  </lst>
  <lst nm="TslInfo">
    <lst nm="TSLINFO">
      <lst nm="TSLINFO">
        <lst nm="TSLINFO" />
      </lst>
    </lst>
  </lst>
  <unit ut="L" uv="millimeter" />
  <unit ut="A" uv="radian" />
</Hsb_Map>
#End