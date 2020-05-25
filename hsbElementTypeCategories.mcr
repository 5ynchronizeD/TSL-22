#Version 8
#BeginDescription
Last modified by: Anno Sportel (anno.sportel@hsbcad.com)
10.06.2015  -  version 1.00

This tsl maintains a dictionary of element type categories. The dictionary is also written to the company folder.
If the tsl is excuted with the executekey set to "ReadFromFile" it will reload the dictionary in the drawing.
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
/// This tsl maintains a dictionary of element type categories. The dictionary is also written to the company folder.
/// If the tsl is excuted with the executekey set to "ReadFromFile" it will reload the dictionary in the drawing.
/// </summary>

/// <insert>
/// -
/// </insert>

/// <remark Lang=en>
/// 
/// </remark>

/// <version  value="1.00" date="10.06.2015"></version>

/// <history>
/// 1.00 - 10.06.2015 - 	Pilot version
/// </hsitory>

Unit(1,"mm");

String sPath = _kPathHsbCompany+"\\Element\\ElementTypes.xml";
String sFileName = findFile(sPath);
String strDictionary = "ElementTypes";
int bDataBaseChanged = FALSE;

if (_bOnInsert) {
	// === phase 1 ===
	String arAction[]={T("|New|"), T("|Edit|"), T("|Copy|"), T("|Rename|"), T("|Delete|")};
	PropString pAction(0,arAction,T("|Action|"));
	// make a property with the list of available styles
	String arEntries[] = MapObject().getAllEntryNames(strDictionary);
	if (arEntries.length() == 0 || _kExecuteKey == "ReadFromFile") {
		arEntries.setLength(0);
		// read entries from xml file stored in the company folder.
		if (sFileName.length() > 0) {
			Map mapElementTypes;
			mapElementTypes.readFromXmlFile(sPath);
			
			for (int i=0;i<mapElementTypes.length();i++) {
				if (!mapElementTypes.hasMap(i))
					continue;
				
				Map mapElementType = mapElementTypes.getMap(i);
				MapObject mo(strDictionary, mapElementTypes.keyAt(i));
				mo.setMap(mapElementType);
			}
			
			if (_kExecuteKey == "ReadFromFile") {
				reportNotice(TN("|Dictionary| ") + strDictionary + T(" |successfully  updated from| ") + sPath);
				eraseInstance();
				return;
			}
			
			arEntries.append(MapObject().getAllEntryNames(strDictionary));
		}
		else {
			if (_kExecuteKey == "ReadFromFile") {
				reportWarning(TN("|Dictionary| ") + strDictionary + T(" |could not be updated from| ") + sPath);
				eraseInstance();
				return;
			}
		}
	}
			
	if (arEntries.length()==0) 
		arEntries.append(T("-- |No entries available| --"));
	PropString pStyle(2,arEntries,T("|Style to modify|"));
	setCatalogFromPropValues("Step1"); // will save the default values
	showDialog("Step1"); // use the default values, not the previous entered values.
	// if the showDialog appears a second time later on, these properties are not suppose to be changed.
	pAction.setReadOnly(TRUE);
	pStyle.setReadOnly(TRUE);
	
	// === phase 2 ===
	// Action New
	if (pAction==T("|New|")) {
		// read the map from the selected style, to use as default for the new style
		String strTypes = "a list of element types";
		MapObject mo1(strDictionary ,pStyle); // will lookup automatically 
		if (mo1.bIsValid()) {
			Map mp1 = mo1.map();
			strTypes = mp1.getString("types");
		} 
		PropString pNewStyle(1,"",T("|New style name|"));
		pNewStyle.setDescription(T("|If new style name is given, a new style will be created.|"));
		PropString pTypes(3, strTypes,T("|Element types|"));
		
		setCatalogFromPropValues("Step2"); // will save the default values
		showDialog("Step2"); // use the default values, not the previous entered values.
		// create a new object
		String strEntry = pNewStyle;
		MapObject mo(strDictionary ,strEntry); // will lookup automatically 
		if (!mo.bIsValid()) { // if object is found, bIsValid is TRUE
			// add the properties to a map, and the map to the MapObject
			Map map;
			
			map.setString("types",pTypes);
			mo.dbCreate(map); // make sure the dictionary and entry name are set in the constructor before calling dbCreate
			bDataBaseChanged = TRUE;
		}
		else {
			// The style already exists.
			reportNotice(TN("|Unable to create new MapObject.| ")+mo.entryName()+T(" |in dictionary| ") +mo.dictionaryName() + T(" |already exists|."));
		}
		if (!mo.bIsValid()) { // should not happen.
			reportNotice(TN("|Something is wrong with MapObject name| ")+mo.entryName()+T(" |for dictionary| ") +mo.dictionaryName());
		}
	}
	// Action Edit
	if (pAction==T("|Edit|")) {
		// read the map from the selected style
		String strTypes = "a new set of element types";
		MapObject mo(strDictionary ,pStyle); // will lookup automatically 
		if (mo.bIsValid()) {
			Map map= mo.map();
			strTypes = map.getString("types");
			PropString pTypes(3, strTypes,"Element types");
			
			setCatalogFromPropValues("Step2"); // will save the default values
			showDialog("Step2"); // use the default values, not the previous entered values.
			map.setString("types",pTypes);
			mo.setMap(map);
			bDataBaseChanged = TRUE;
		} 
		else {
			reportNotice(TN("|Unable to edit MapObject|. ")+mo.entryName()+T(" |in dictionary| ") +mo.dictionaryName() + ".");
		}
	}
	// Action Copy
	if (pAction==T("|Copy|")) {
		// read the map from the selected style, to use for the new style
		Map mapOld;
		MapObject mo1(strDictionary ,pStyle); // will lookup automatically 
		if (mo1.bIsValid()) {
			mapOld = mo1.map(); // copy map
		} 
		PropString pNewStyle(1,"",T("|New style name|"));
		pNewStyle.setDescription(T("|If new style name is given, a new style will be created.|"));
		setCatalogFromPropValues("Step2"); // will save the default values
		showDialog("Step2"); // use the default values, not the previous entered values.
		// create a new object
		String strEntry = pNewStyle;
		MapObject mo(strDictionary ,strEntry); // will lookup automatically 
		if (!mo.bIsValid()) { // if object is found, bIsValid is TRUE
			// add the properties to a map, and the map to the MapObject
			mo.dbCreate(mapOld); // make sure the dictionary and entry name are set in the constructor before calling dbCreate
			bDataBaseChanged = TRUE;
		}
		else {
			// The style already exists.
			reportNotice(TN("|Unable to create new MapObject.| ")+mo.entryName()+T(" |in dictionary| ") +mo.dictionaryName() + T(" |already exists|."));
		}
		if (!mo.bIsValid()) { // should not happen.
			reportNotice(TN("|Something is wrong with MapObject name| ")+mo.entryName()+T(" |for dictionary| ") +mo.dictionaryName());
		}
	}
	// Action Rename
	if (pAction==T("|Rename|")) {
		PropString pNewStyle(1,"",T("|New style name|"));
		pNewStyle.setDescription(T("|If new style name is given, the style will be renamed.|"));
		setCatalogFromPropValues("Step2"); // will save the default values
		showDialog("Step2"); // use the default values, not the previous entered values.
		// create a new object
		int bOk = FALSE;
		MapObject mo(strDictionary ,pStyle); // will lookup automatically 
		if (mo.bIsValid()) { // if object is found, bIsValid is TRUE
			mo.dbRename(pNewStyle);
			if (mo.entryName()==pNewStyle) bOk = TRUE;
			bDataBaseChanged = TRUE;
		}
		if (!bOk) {
			reportNotice(TN("|Unable to rename new MapObject.| ")+mo.entryName()+T(" |in dictionary| ") +mo.dictionaryName() + T(" |to| ") + pNewStyle);
		}
	}
	// Action Delete
	if (pAction==T("|Delete|")) {
		MapObject mo(strDictionary ,pStyle); // will lookup automatically 
		if (mo.bIsValid()) { // if object is found, bIsValid is TRUE
			Entity ents[] = mo.getReferencesToMe(); // check if there is anybody refering to this style
			if (ents.length()==0) {
				mo.dbErase(); // erase from the database
				reportNotice(TN("|MapObject| ")+mo.entryName()+T(" |in dictionary| ") +mo.dictionaryName() + T(" |erased|."));
				bDataBaseChanged = TRUE;
			}
			else {
				// when there are still entities refering to the style, it should not be erased.
				reportNotice(TN("|MapObject| ")+mo.entryName()+T(" |in dictionary| ") +mo.dictionaryName() + T(" |could not be erased because it has| ") + 
				ents.length() + T(" |references|."));
			}
		}
	}
	if (bDataBaseChanged) {
		// When a style is erased, added,..., the list of styles is changed, so all Tsl's that do refer to a style, have most likely a combo property with a list of styles.
		// So these need to be triggered for recalculation.
		MapObject().recalcAllReferencesToDictionary(strDictionary); 
		
		Map mapElementTypes;
		MapObject mapEntries[] = MapObject().getAllEntries(strDictionary);
		String entryNames[] = MapObject().getAllEntryNames(strDictionary);
		for (int i=0;i<mapEntries.length();i++) {
			MapObject mo = mapEntries[i];
			String entryName = entryNames[i];
			Map map = mo.map();
			mapElementTypes.setMap(entryName, map);
		}
		mapElementTypes.writeToXmlFile(sPath);
		reportNotice(TN("|Dictionary written to|: ") + sPath);
	}
	eraseInstance();
	return;
}
#End
#BeginThumbnail



#End