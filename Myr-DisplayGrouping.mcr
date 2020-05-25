#Version 8
#BeginDescription
Last modified by: OBOS (Oscar.Ragnerby@obos.se)

Shows the Grouping tag at the element 

OR - 1.01 - 13.09.2019 - Displays all children mapx
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
/// This tsl displays the salesorder child tags
/// </summary>

/// <insert>
/// 
/// </insert>

/// <remark Lang=en>
/// .
/// </remark>

/// <version  value="1.01" date="13.09.2019"></version>

/// <history>
/// OR - 1.00 - 02.09.2019 - Pilot version
/// OR - 1.01 - 13.09.2019 - Displays all children mapx

/// </history>

double vectorTolerance = Unit(0.01,"mm");
double pointTolerance = U(0.1);
double dTextOffset = 200;
String categories[] = 
{
T("|Element filter|")
};

String elementFilterCatalogNames[] = TslInst().getListOfCatalogNames("hsbElementFilter");
elementFilterCatalogNames.insertAt(0, T("|Do not use an element filter|"));
PropString elementFilter(0, elementFilterCatalogNames, T("|Element filter catalog|"));
elementFilter.setDescription(T("|Sets the element filter to use.|"));
elementFilter.setCategory(categories[0]);

//String catalogNames[] = TslInst().getListOfCatalogNames(scriptName());
//if (_kExecuteKey != "" && catalogNames.find(_kExecuteKey) != -1)
//	setPropValuesFromCatalog(_kExecuteKey);
	
if( _bOnInsert ){

	if( insertCycleCount()>1)
	{
		eraseInstance(); 
		return;
	}
	
//	if( _kExecuteKey == "" || catalogNames.find(_kExecuteKey) == -1 )
//		showDialog();
//	setCatalogFromPropValues(T("_LastInserted"));
//	
	Element selectedElements[0];
//	Entity entities[]=Group().collectEntities(true, Element(), _kModel);
	
//	if (elementFilter !=  elementFilterCatalogNames[0]) 
//	{
//			Entity selectedEntities[]=Group().collectEntities(true, Element(), _kModel);
//			Map elementFilterMap;
//			elementFilterMap.setEntityArray(selectedEntities, false, "Elements", "Elements", "Element");
//			TslInst().callMapIO("hsbElementFilter", elementFilter, elementFilterMap);
//			
//			Entity filteredEntities[] = elementFilterMap.getEntityArray("Elements", "Elements", "Element");
//			for (int i=0;i<filteredEntities.length();i++) {
//				Element el = (Element)filteredEntities[i];
//				if (!el.bIsValid())
//					continue;
//				selectedElements.append(el);
//			}
//	}
//	else 
//	{
		Entity selectedEntities[]=Group().collectEntities(true, Element(), _kModel);
		
		for (int i=0;i<selectedEntities.length();i++) {
			Element el = (Element)selectedEntities[i];
			if (!el.bIsValid())
				continue;
			selectedElements.append(el);
		}
//	}
	
	int nNrOfTslsInserted = 0;
	
	String strScriptName = scriptName();
	Vector3d vecUcsX(1,0,0);
	Vector3d vecUcsY(0,1,0);
	Beam lstBeams[0];
	Element lstElements[1];
	
	Point3d lstPoints[0];
	int lstPropInt[0];
	double lstPropDouble[0];
	String lstPropString[0];
	Map mapTsl;
	
	for (int e=0;e<selectedElements.length();e++) {
		Element selectedElement = selectedElements[e];
		lstElements[0] = selectedElement;
		
		// Remove existing tsl connected to the element
		TslInst arTsl[] = selectedElement.tslInst();
		for( int i=0;i<arTsl.length();i++ ){
			TslInst tsl = arTsl[i];
			if( tsl.scriptName() == scriptName() && tsl.handle() != _ThisInst.handle() ){
				_Pt0 = tsl.ptOrg();
				tsl.dbErase();
				break;
			}
		}
		
		
		TslInst tslNew;
		tslNew.dbCreate(strScriptName, vecUcsX,vecUcsY,lstBeams, lstElements, lstPoints, lstPropInt, lstPropDouble, lstPropString, _kModelSpace, mapTsl);
		if (tslNew.bIsValid())
			tslNew.setPropValuesFromCatalog(T("|_LastInserted|"));
	}
	
	
//	for( int e=0;e<selectedElements.length();e++ ){
//			Element el = (Element) selectedElements[e];
//			
//			lstElements[0] = el;
//
//			TslInst tsl;
//			tsl.dbCreate(strScriptName, vecUcsX,vecUcsY,lstBeams, lstElements, lstPoints, lstPropInt, lstPropDouble, lstPropString, _kModelSpace, mapTsl);
//			nNrOfTslsInserted++;
//	}
//	
//	reportMessage(nNrOfTslsInserted + T(" |tsl(s) inserted|"));
	eraseInstance();
    	return;
   
}

if (_Element.length() == 0) {
	reportError(T("|No element selected|"));
	eraseInstance();
	return;
}

Element el= (Element) _Element[0];
if (!el.bIsValid()) { 
	eraseInstance();
	return;
}

String parentUIDKey = "ParentUID";

String groupingTypes[0];
Entity groupedEntities[0];
int groupingTypeIndexes[0];
String parentUIDs[0];
Display dChild(-1);




//for (int e = 0; e < entities.length(); e++)
//{
//	Entity el = entities[e];
	String mapChildren[0];
	String childString = "";

	
	String mapXKeys[] = el.subMapXKeys();
	
	for (int m = 0; m < mapXKeys.length(); m++)
	{
		String mapXKey = mapXKeys[m];
		
		if (mapXKey.left(4).makeUpper() == "HSB_" && mapXKey.right(5).makeUpper() == "CHILD")
		{ 
			
				Map groupingChildMap = el.subMapX(mapXKey);
				String sGroupingChild = groupingChildMap.getString(parentUIDKey);
			if(sGroupingChild != ""){ 
				mapChildren.append(mapXKey.mid(4, mapXKey.length() - 9)+":"+sGroupingChild);
			}
		}
	}
	
	if(mapChildren.length() > 0)
	{

		for (int m = 0; m < mapChildren.length(); m++) {
			childString += mapChildren[m] + "|";
		}
	
		childString = childString.left(childString.length() - 1);
		el.setNotes(childString);
	}
	
	

	if(el.bIsKindOf(ElementWallSF()))
	{
		ElementWallSF elSF = (ElementWallSF)el;
		CoordSys csEl = elSF.coordSys();
		csEl.vis();
		Point3d elOrg = csEl.ptOrg();
		Vector3d elX = csEl.vecX();
		Vector3d elY = csEl.vecY();
		Vector3d elZ = csEl.vecZ();
		
		Point3d textPosition = elSF.ptArrow(); 
		textPosition=  textPosition + elZ * U(10);
		if(childString.length()>0){ 
			dChild.textHeight(10);
			dChild.draw(childString, textPosition, elX,elZ,0,0,1);
		}
	}
	
	if(el.bIsKindOf(ElementRoof()))
	{
		ElementRoof elFloor = (ElementRoof)el;
		if(elFloor.bIsAFloor()){
			CoordSys csEl = elFloor.coordSys();
			csEl.vis();
			Point3d elOrg = csEl.ptOrg();
			Vector3d elX = csEl.vecX();
			Vector3d elY = csEl.vecY();
			Vector3d elZ = csEl.vecZ();
			
			if (childString.length() > 0) {
				dChild.textHeight(10);
				dChild.draw(childString, elOrg, elX, elZ, 0, 0, 1);
				_Pt0 = elOrg;
				
			}

		}
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
  <lst nm="TslInfo">
    <lst nm="TSLINFO">
      <lst nm="TSLINFO">
        <lst nm="TSLINFO">
          <lst nm="TSLINFO">
            <lst nm="TSLINFO">
              <lst nm="TSLINFO">
                <lst nm="TSLINFO" />
              </lst>
            </lst>
          </lst>
        </lst>
      </lst>
    </lst>
  </lst>
  <unit ut="L" uv="millimeter" />
  <unit ut="A" uv="radian" />
</Hsb_Map>
#End