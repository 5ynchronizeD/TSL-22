#Version 8
#BeginDescription
Last modified by: OBOS
14.04.2020  -  version 1.09

OR  - 1.09 - 14.04.2020 - Filters out SF Blockings from collection of valid beams









#End
#Type O
#NumBeamsReq 0
#NumPointsGrip 0
#DxaOut 1
#ImplInsert 1
#FileState 0
#MajorVersion 1
#MinorVersion 9
#KeyWords 
#BeginContents
/// <summary Lang=en>
/// This tsl inserts the single insulation
/// </summary>

/// <insert>
/// Select a set of elements
/// </insert>

/// <remark Lang=en>
/// .
/// </remark>

/// <version  value="1.08" date="04.09.2015"></version>

/// <history>
/// AS - 1.00 - 22.08.2006 -	Pilot version
/// AS - 1.01 - 23.08.2006 -	Make this tsl a master tsl
/// AS - 1.02 - 28.11.2006 -	Only erase tsl if there are single insulation pieces placed.
/// AS - 1.03 - 29.11.2006 -	Add filter options
/// AS - 1.04 - 23.10.2008 -	Remove existing single insulations from the selected elements; Change default of minimum size tdbErase
/// AS - 1.05 - 24.10.2008 -	Bug on existing tsl deletion
/// AS - 1.06 - 24.02.2009 -	Add properties to single insulation
/// Myresjohus - 1.07 - 03.02.2011 - Add insulation 250
/// AS  - 1.08 - 04.09.2015 - Add support for element filters. Tsl can be inserted by master tsl.
/// OR  - 1.09 - 14.04.2020 - Filters out SF Blockings from collection of valid beams
/// </history>

Unit (1,"mm");

String categories[] = {
	T("|Filter|"),
	T("|Generation|"),
	T("|Insulation|"),
	T("|Visualization|")
};


String elementFilterCatalogNames[] = TslInst().getListOfCatalogNames("hsbElementFilter");
elementFilterCatalogNames.insertAt(0, T("|Do not use an element filter|"));
PropString elementFilter(5, elementFilterCatalogNames, T("|Element filter catalog|"));
elementFilter.setDescription(T("|Sets the element filter to use.|"));
elementFilter.setCategory(categories[0]);

PropInt sequenceForGeneration(2, 0, T("|Sequence number|"));
sequenceForGeneration.setDescription(T("|The sequence number is used to sort the list of tsls during the generation of the element.|"));
sequenceForGeneration.setCategory(categories[1]);
// Set the sequence for execution on generate construction.
_ThisInst.setSequenceNumber(sequenceForGeneration);

//filter options
// filter beams with beamcode
PropString sFilterBC(0,"",T("Filter beams with beamcode"));
sFilterBC.setDescription(T("|List of beam codes to exclude.|"));
sFilterBC.setCategory(categories[0]);

// filter GenBeams with label
PropString sFilterLabel(1,"",T("Filter beams/sheets with label"));
sFilterLabel.setDescription(T("|List of labels to exclude.|"));
sFilterLabel.setCategory(categories[0]);

PropDouble dMinimumInsulationSize(0, U(45), T("Minimale insulation size"));
dMinimumInsulationSize.setDescription(T("|Sets the minimum required size for the insulation.|"));
dMinimumInsulationSize.setCategory(categories[2]);
String arSMaterial[] = {
	"Isolering250",
	"Isolering240"
};
PropString sMaterial(2, arSMaterial, T("|Material|"));
sMaterial.setDescription(T("|Sets the material.|"));
sMaterial.setCategory(categories[2]);

PropString sDispRepHatch(3, _ThisInst.dispRepNames() , T("Show hatch in display representation"));
sDispRepHatch.setDescription(T("|Specifies the display representation to show the insulation in.|"));
sDispRepHatch.setCategory(categories[3]);
PropInt nColor(0,3,T("Color"));
nColor.setDescription(T("|Sets the color of the insulation.|"));
nColor.setCategory(categories[3]);
PropInt nColorHatch(1, 3, T("|Color hatch|"));
nColorHatch.setDescription(T("|Sets the color of the hatch.|"));
nColorHatch.setCategory(categories[3]);
String arSYesNo[] = {T("|Yes|"), T("|No|")};
int arNYesNo[] = {_kYes, _kNo};
PropString sShowHatch(4, arSYesNo, T("|Show hatch|"));
sShowHatch.setDescription(T("|Specifies whether the hatch is visible or not.|"));
sShowHatch.setCategory(categories[3]);

// Is it an initial insert by the tool inserter? Return and wait for recalc after the props are set correctly.
int executeMode = -1;
if (_Map.hasInt("ExecuteMode")) 
	executeMode = _Map.getInt("ExecuteMode");
if (executeMode == 69)
	return;

// Set properties if inserted with an execute key
String arSCatalogNames[] = TslInst().getListOfCatalogNames("Myr-Nailing");
if( arSCatalogNames.find(_kExecuteKey) != -1 ) 
	setPropValuesFromCatalog(_kExecuteKey);

if( _bOnInsert ){
	if( insertCycleCount() > 1 ){
		eraseInstance();
		return;
	}
	
	if( _kExecuteKey == "" || arSCatalogNames.find(_kExecuteKey) == -1 )
		showDialog();

	PrEntity ssE(T("|Select a set of elements|"),ElementWallSF());
	if(ssE.go()){
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
		_Element.append(arSelectedElement);
	}
	showDialogOnce("_Default");
	return;
}

if( _Element.length()==0 ){
	eraseInstance();
	return;
}

String sFBC = sFilterBC + ";";
String arSFBC[0];
int nIndexBC = 0; 
int sIndexBC = 0;
while(sIndexBC < sFBC.length()-1){
	String sTokenBC = sFBC.token(nIndexBC);
	nIndexBC++;
	if(sTokenBC.length()==0){
		sIndexBC++;
		continue;
	}
	sIndexBC = sFBC.find(sTokenBC,0);

	arSFBC.append(sTokenBC);
}

String sFLabel = sFilterLabel + ";";
String arSFLabel[0];
int nIndexLabel = 0; 
int sIndexLabel = 0;
while(sIndexLabel < sFLabel.length()-1){
	String sTokenLabel = sFLabel.token(nIndexLabel);
	nIndexLabel++;
	if(sTokenLabel.length()==0){
		sIndexLabel++;
		continue;
	}
	sIndexLabel = sFilterLabel.find(sTokenLabel,0);

	arSFLabel.append(sTokenLabel);
}




//Properties for tsl to insert
String sScriptName = "Myr-SingleInsulation";
Vector3d vecUcsX;
Vector3d vecUcsY;

Beam lstBeams[0];
Element lstElements[0];
Point3d lstPoints[0];

int lstPropInt[0];
lstPropInt.append(nColor);
lstPropInt.append(nColorHatch);
double lstPropDouble[0];
String lstPropString[0];
lstPropString.append(sMaterial);
lstPropString.append(sDispRepHatch);
lstPropString.append(sShowHatch);

int bSingleInsulationPlaced = FALSE;

for( int e=0;e<_Element.length();e++ ){
	ElementWallSF el = (ElementWallSF)_Element[e];
	if( !el.bIsValid() )continue;
	
	//Erase previously placed tsls
	TslInst arTsl[] = el.tslInst();
	for( int i=0;i<arTsl.length();i++ ){
		TslInst tsl = arTsl[i];
		if( tsl.scriptName() == sScriptName ){
			tsl.dbErase();
		}
	}
	
	Vector3d vx = el.vecX();
	Vector3d vy = el.vecY();
	Vector3d vz = el.vecZ();
	
	vecUcsX = vx;
	vecUcsY = vy;
	
	Beam arBmTmp[] = el.beam();
	Beam arBm[0];
	for(int i=0;i<arBmTmp.length();i++){
		if( arBmTmp[i].bIsDummy() )continue;
		
		if(  (arSFBC.find(arBmTmp[i].name("beamcode").token(0)) == -1) && (arSFLabel.find(arBmTmp[i].label()) == -1) && (arSFLabel.find(arBmTmp[i].hsbId()) == -1)){
			if (arBmTmp[i].name("type") == "SF Blocking") 
			{
				
				continue;
			}

			arBm.append(arBmTmp[i]);
		}
	}	
	
	Beam arBmVert[] = vx.filterBeamsPerpendicularSort(arBm);
	Opening arOp[] = el.opening();
	
	for (int b=0;b<arBmVert.length();b++){ 
		Beam bm = arBmVert[b];
		
	}
	
	if( arBmVert.length() == 0 ){
		continue;
	}
	
	Beam bmPrev = arBmVert[0];
	for( int i=1;i<arBmVert.length();i++ )
	{
		
		Beam bmThis = arBmVert[i];
		
		Body  bdBmPrev = bmPrev.realBody();
		Body  bdBmThis = bmThis.realBody();
		
		Point3d ptLeft = bmPrev.ptCen() + vx * .5 * bmPrev.dD(vx);
		Point3d ptRight = bmThis.ptCen() - vx * .5 * bmThis.dD(vx);
		Point3d ptCenter = (ptLeft + ptRight)/2;
		
		if( vx.dotProduct(ptRight - ptLeft) < dMinimumInsulationSize ){
			bmPrev = bmThis;
			continue;
		}
		
		int bBmAtOpening = FALSE;
		for( int j=0;j<arOp.length();j++ ){
			Opening op = arOp[j];
			Body opBd(op.plShape(),vz);
			Point3d ptOpLeft = opBd.ptCen() - vx * .5 * op.width();
			Point3d ptOpRight = opBd.ptCen() + vx * .5 * op.width();
			
			if( (vx.dotProduct(ptOpLeft - ptCenter) * vx.dotProduct(ptOpRight - ptCenter)) < 0 ){
				bBmAtOpening = TRUE;
				break;
			}
		}
		
		if( bBmAtOpening ){
			bmPrev = bmThis;
			continue;
		}
		
			
		lstElements.setLength(0);
		lstElements.append(el);
		lstBeams.setLength(0);
		lstBeams.append(bmPrev);
		lstBeams.append(bmThis);
		
		//Call tsl to place a single insulation
		TslInst tsl;
		tsl.dbCreate(sScriptName, vecUcsX,vecUcsY,lstBeams, lstElements, lstPoints, lstPropInt, lstPropDouble, lstPropString );
		
		bSingleInsulationPlaced =TRUE;
							
		bmPrev = bmThis;
	}
}

if( bSingleInsulationPlaced ){
	eraseInstance();
}








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
  <lst nm="TslInfo" />
  <unit ut="L" uv="millimeter" />
  <unit ut="A" uv="radian" />
</Hsb_Map>
#End