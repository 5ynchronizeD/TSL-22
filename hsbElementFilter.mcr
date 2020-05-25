#Version 8
#BeginDescription
Last modified by: Anno Sportel (anno.sportel@hsbcad.com)
21.10.2015  -  version 1.01

This tsl can be used to set up element filters. The element filters can be used by tsls which rely on elements.
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
/// This tsl can be used to set up element filters. The element filters can be used by tsls which rely on elements.
/// </summary>

/// <insert>
/// -
/// </insert>

/// <remark Lang=en>
/// 
/// </remark>

/// <version  value="1.01" date="21.10.2015"></version>

/// <history>
/// 1.00 - 10.06.2015 - 	Pilot version
/// 1.01 - 21.10.2015 - 	Remove debugging information
/// </hsitory>

int bOnDebug = _bOnDebug;

// Filter options
String categories[] = {
	T("|Element filter|")
};

String operations[] = {
	T("|Exclude|"),
	T("|Include|")
};

String trueFalse[] = {
	T("|True|"),
	T("|False|")
};

PropString enabled(0, trueFalse, T("|Enabled|"));
enabled.setDescription(T("|Specifies whether the filter is enabled|"));
enabled.setCategory(categories[0]);

PropString operationElementFilter(1, operations, T("|Operation element filter|"));
operationElementFilter.setDescription(T("|Include or exclude elements meeting the filter criteria. This operation results in a set of elements.|"));
operationElementFilter.setCategory(categories[0]);

// Create a filter based on element types. The element types are stored in a dictionary.
String elementTypeDictionary = "ElementTypes";
String elementTypeDictionaryEntryNames[] = MapObject().getAllEntryNames(elementTypeDictionary);
if (elementTypeDictionaryEntryNames.length() == 0) 
	reportMessage(TN("|Element type dictionary is not found or empty.|"));

// Create a set of possible combinations.
String elementTypeCombinations[0];
int jStart = 1;
for( int i=0;i<elementTypeDictionaryEntryNames.length();i++ ){
	String typeA = elementTypeDictionaryEntryNames[i];
	if( elementTypeCombinations.find(typeA) == -1 )
		elementTypeCombinations.append(typeA);
	
	int j = jStart;

	while( j<elementTypeDictionaryEntryNames.length() ){
		String typeB = elementTypeDictionaryEntryNames[j];
		
		typeA += ";"+typeB;
		elementTypeCombinations.append(typeA);

		j++;
	}
	
	jStart++;
	if( jStart < elementTypeDictionaryEntryNames.length() )
		i--;
	else
		jStart = i+2;
}
elementTypeCombinations.insertAt(0, T("|None|"));

PropString filterElementTypes(2, elementTypeCombinations, T("|Filter element types|"));
filterElementTypes.setDescription(T("|The criteria used to filter the elements|"));
filterElementTypes.setCategory(categories[0]);


String catalogNames[] = TslInst().getListOfCatalogNames("hsbElementFilter");
if( catalogNames.find(_kExecuteKey) != -1 ) 
	setPropValuesFromCatalog(_kExecuteKey);

// Insert
if (_bOnInsert) {
	if (insertCycleCount() > 1) {
		eraseInstance();
		return;
	}
	
	if( _kExecuteKey == "" || catalogNames.find(_kExecuteKey) == -1 )
		showDialog();
}
// Map IO
if (_bOnMapIO) {
	if (_kExecuteKey != "" && catalogNames.find(_kExecuteKey) != -1)
		setPropValuesFromCatalog(_kExecuteKey);
}

// Resolve properties
int filterEnabled = (trueFalse.find(enabled,0) == 0);
int exclude = (operations.find(operationElementFilter) == 0);

String filterElementTypeEntries[0];
String list = filterElementTypes + ";";
int tokenIndex = 0;
int characterIndex = 0;
while (characterIndex < list.length() - 1) {
	String token = list.token(tokenIndex);
	tokenIndex++;
	if (token == T("|None|") || token.length() == 0) {
		characterIndex++;
		continue;
	}
	characterIndex = list.find(token,0);
	
	filterElementTypeEntries.append(token);
}

// Get the list of element types to filter.
String elementTypesToFilter[0];
for (int i=0;i<filterElementTypeEntries.length();i++) {
	MapObject filterElementTypeEntry(elementTypeDictionary, filterElementTypeEntries[i]);
	if (!filterElementTypeEntry.bIsValid()) {
		reportNotice(	TN("|Selected element type filter could not be found in the dictionary.|") + 
						TN("|Dictionary|: ") + elementTypeDictionary + "\t" + T("|Element type filter|: ") + filterElementTypeEntries[i]);
		continue;
	}
	setDependencyOnDictObject(filterElementTypeEntry);
	
	Map elementTypeFilter = filterElementTypeEntry.map();
	String typesToFilter = elementTypeFilter.getString("Types");
	String list = typesToFilter + ";";
	int tokenIndex = 0;
	int characterIndex = 0;
	while (characterIndex < list.length() - 1) {
		String token = list.token(tokenIndex);
		tokenIndex++;
		if (token.length() == 0) {
			characterIndex++;
			continue;
		}
		characterIndex = list.find(token,0);
		
		elementTypesToFilter.append(token);
	}
}
if (bOnDebug) {
	reportNotice(TN("|Element filter|") + TN("|Enabled|: ") + enabled + TN("|Operation|: ") + operationElementFilter);
	reportNotice(TN("|Filtered element types|: ") + elementTypesToFilter);
}

if (!filterEnabled) {
	eraseInstance();
	return;
}

//Insert
if (_bOnInsert) {	
	PrEntity selectionSet(T("|Select elements|"), Element());
	if (selectionSet.go()) {
		Element selectedElements[] = selectionSet.elementSet();
		for (int i=0;i<selectedElements.length();i++) {
			Element selectedElement = selectedElements[i];
			
			if (bOnDebug)
				reportNotice(TN("|Element|: ") + selectedElement.number());
			
			// Apply the filtering
			String elementType = selectedElement.code();
			// Exlude this element?
			if (exclude && elementTypesToFilter.find(elementType) != -1) {
				if (bOnDebug)
					reportNotice(T(" |is NOT a valid element.|"));
				continue;
			}
			// Include this element?
			if (!exclude && elementTypesToFilter.find(elementType) == -1) {
				if (bOnDebug)
					reportNotice(T(" |is NOT a valid element.|"));
				continue;
			}
			
			if (bOnDebug)
				reportNotice(T(" |is a valid element.|"));
			_Element.append(selectedElement);
		}
	}
	
	eraseInstance();
	return;
}
//Map IO
if (_bOnMapIO) {	
	Entity entities[] = _Map.getEntityArray("Elements", "Elements", "Element");
	Entity validEntities[0];
	for (int i=0;i<entities.length();i++) {
		Element selectedElement = (Element)entities[i];
		
		if (bOnDebug)
			reportNotice(TN("|Element|: ") + selectedElement.number());

		// Apply the filtering
		String elementType = selectedElement.code();
	
		// Exlude this element?
		if (exclude && elementTypesToFilter.find(elementType) != -1) {
			if (bOnDebug)
				reportNotice(T(" |is NOT a valid element.|"));
			continue;
		}
		// Include this element?
		if (!exclude && elementTypesToFilter.find(elementType) == -1) {
			if (bOnDebug)
				reportNotice(T(" |is NOT a valid element.|"));
			continue;
		}
		
		if (bOnDebug)
			reportNotice(T(" |is a valid element.|"));
		validEntities.append(selectedElement);
	}
	_Map.setEntityArray(validEntities, true, "Elements", "Elements", "Element");
	
	return;
}

eraseInstance();
return;
#End
#BeginThumbnail


#End