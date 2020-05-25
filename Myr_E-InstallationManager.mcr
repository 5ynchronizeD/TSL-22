#Version 8
#BeginDescription
Last modified by: Anno Sportel (anno.sportel@hsbcad.com)
05.07.2017  -  version 1.03

 - Block definition -
This tsl reads a block and creates installation objects (Myresjo_E-InstallationPoint and Myresjo_E-InstallationTube) for every polyline in the block. The settings for the tubes are based on the colour of the polyline and are read from a loaded configuration file.

 - Installation Configuration -
The settings for this tube and the point are taken from an installation configuration. This configuration is stored in an xml file in the 'hsbCompany/TSL/Configurations' folder. The configuration is loaded in the drawing and the settings will be taken from this loaded configuration.
It is possible to reload the configuration settings through a custom action on the tsl (right click - Custom - Reload installation configurations).
#End
#Type O
#NumBeamsReq 0
#NumPointsGrip 0
#DxaOut 1
#ImplInsert 1
#FileState 1
#MajorVersion 1
#MinorVersion 3
#KeyWords 
#BeginContents
/// <summary Lang=en>
/// Block definition
/// This tsl reads a block and creates installation objects (Myr_E-InstallationPoint and Myr_E-InstallationTube) for every polyline in the block. The settings for the tubes are based on the colour of the polyline and are read from a loaded configuration file.
/// 
/// Installation Configuration
/// The settings for this tube and the point are taken from an installation configuration. This configuration is stored in an xml file in the 'hsbCompany/Abbund' folder. The configuration is loaded in the drawing and the settings will be taken from this loaded configuration.
/// It is possible to reload the configuration settings through a custom action on the tsl (right click - Custom - Reload installation configurations). 
/// </summary>

/// <insert>
/// Select an element and a block with the definition of the installations.
/// </insert>

/// <remark Lang=en>
/// The configurations are stored in _kPathHsbCompany + "\\TSL\\Configurations\\InstallationConfigurations.xml".
/// Multiple 'Installation Managers' can be added to the element, if the identifiers are unique.
/// </remark>

/// <version  value="1.03" date="05.07.2017"></version>

/// <history>
/// AS - 1.00 - 04.05.2017 -	Pilot version
/// AS - 1.01 - 28.06.2017 -	Disable drill in sheeting. This is now done by the installation point tsl.
/// AS - 1.02 - 29.06.2017 -	Add support for installation side.
/// AS - 1.03 - 05.07.2017 -	Reduce log level
/// </history>

double tolerance = Unit(0.01, "mm");

String installationTubeScriptName = "Myr_E-InstallationTube";
String installationPointScriptName = "Myr_E-InstallationPoint";

String installationTubePropSetName = "hsbInstallationTube";
String installationPointPropSetName = "hsbInstallationPoint";

String sides[] = {"Front", "Back", "Center"};
int sideIndexes[] = {1, -1, 0};

int log = 0;
if (log == 1) reportNotice(TN("|Parent triggered|"));

String recalcTriggers[] = 
{
	T("|Reload installation configurations|")
};
for (int r=0;r<recalcTriggers.length();r++)
	addRecalcTrigger(_kContext, recalcTriggers[r]);

// Load configurations
String fileName = _kPathHsbCompany + "\\Tsl\\Configurations\\InstallationConfigurations.xml";

String dictionary = "tslDict";
String entry = "InstallationConfigurations";
MapObject configDictionary(dictionary, entry);

if (!configDictionary.bIsValid())
{
	if (findFile(fileName).length()<4)
	{
		reportMessage("\n**********" + scriptName() + "**********\n" + 
			T("|The configuration file|") +"\n" + fileName + "\n" + T("|could not be found.|") + "\n" + T("|The tsl will be deleted.|"));
			reportMessage("\n*************************************");
		eraseInstance();
		return;
	}
	
	Map map;
	map.readFromXmlFile(fileName);
	configDictionary.dbCreate(map);
	
	reportMessage("\n**********" + scriptName() + "**********\n" + 
		T("|The configuration file|") +"\n" + fileName + "\n" + T("|is loaded in the drawing.|"));
}
if (_kExecuteKey == recalcTriggers[0])
{
	if (findFile(fileName).length()<4)
	{
		reportMessage("\n**********" + scriptName() + "**********\n" + 
			T("|The configuration file|") +"\n" + fileName + "\n" + T("|could not be found and is NOT reloaded.|"));
			reportMessage("\n*************************************");
	}
	else
	{
		Map map;
		map.readFromXmlFile(fileName);
		configDictionary.setMap(map);
		
		reportMessage("\n**********" + scriptName() + "**********\n" + 
			T("|The configuration file|") +"\n" + fileName + "\n" + T("|is reloaded in the drawing.|"));
	}
}

Map installationConfigurations = configDictionary.map();

int installationColors[0];
String installationTypes[0];
// Load the data from the configuration file.
for (int c=0;c<installationConfigurations.length();c++)
{
	if (!installationConfigurations.hasMap(c) || installationConfigurations.keyAt(c) != "InstallationConfiguration")
		continue;
	
	Map installationConfiguration = installationConfigurations.getMap(c);
	installationColors.append(installationConfiguration.getInt("ColorIndex"));
	installationTypes.append(installationConfiguration.getString("Type"));
}

String categories[] = 
{
	T("|Visualisation|")
};

PropString tslIdentifier(0, "", T("|Indentifier|"));
tslIdentifier.setDescription(T("|Only one tsl instance, per identifier, can be attached to an element.|")); 



PropInt symbolColor(0, 4, T("|Color|"));
symbolColor.setCategory(categories[0]);
symbolColor.setDescription(T("|Specifies the color of the visualisation symbol.|"));

PropDouble symbolSize(0, U(40), T("|Symbol size|"));
symbolSize.setCategory(categories[0]);
symbolSize.setDescription(T("|Specifies the size of the visualisation symbol.|"));


// Set properties if inserted with an execute key
String catalogNames[] = TslInst().getListOfCatalogNames(scriptName());
if( catalogNames.find(_kExecuteKey) != -1 ) 
	setPropValuesFromCatalog(_kExecuteKey);

if (_bOnInsert) {
	if (insertCycleCount() > 1) 
	{
		eraseInstance();
		return;
	}
	
	if( _kExecuteKey == "" || catalogNames.find(_kExecuteKey) == -1 )
		showDialog();
	
	_Element.append(getElement(T("|Select an element|")));
	_Entity.append(getBlockRef(T("|Select the installation block|")));
	
	return;
}

if (_Element.length() == 0)
{
	reportWarning(T("|Invalid or no element selected.|"));
	eraseInstance();
	return;
}

Element el = _Element[0];
if (!el.bIsValid())
{
	reportNotice(TN("|The selected element is invalid|!"));
	eraseInstance();
	return;
}
_Pt0 = el.ptOrg();
CoordSys csEl = el.coordSys();
Vector3d elX = csEl.vecX();
Vector3d elY = csEl.vecY();
Vector3d elZ = csEl.vecZ();

int isAFloorElement = false;
int isARoofElement = false;
int isAWallElement = false;

if (el.bIsA(ElementWallSF()))
{
	isAWallElement = true;
}
else if(el.bIsA(ElementRoof()))
{
	ElementRoof elRf = (ElementRoof)el;
	if (elRf.bIsAFloor())
	{
		if (_ZW.dotProduct(el.ptOrg() - _PtW) > U(1000))
			isARoofElement = true;
		else	
			isAFloorElement = true;
	}
	else
	{
		isARoofElement = true;
	}
}

BlockRef installationBlockReference;
for (int e=0;e<_Entity.length();e++)
{
	BlockRef blockReference = (BlockRef)_Entity[e];
	if (blockReference.bIsValid())
	{
		installationBlockReference = blockReference;
		break;
	}
}

if (!installationBlockReference.bIsValid())
{
	reportNotice(TN("|The installation block reference could not be found for element| ") + el.number() + "!" + TN("|The installation manager will be removed.|"));
	eraseInstance();
	return;
}

//setDependencyOnEntity(installationBlockReference);
Block installationBlockDefinition = Block(installationBlockReference.definition());

CoordSys installationCoordSys = installationBlockReference.coordSys();
CoordSys definitionToReference(
	installationCoordSys.ptOrg(),
	installationCoordSys.vecX() * installationBlockReference.dScaleX(),
	installationCoordSys.vecY() * installationBlockReference.dScaleY(),
	installationCoordSys.vecZ() * installationBlockReference.dScaleZ()
);

String installationScriptNames[] = 
{
	"Myr_E-InstallationTube",
	"Myr_E-InstallationPoint"
};

// Remove existing tsl's placed by this instance.
TslInst elementTsls[] = el.tslInst();
for (int t=0;t<elementTsls.length();t++)
{
	TslInst installationTsl = elementTsls[t];
	if (!installationTsl.bIsValid() || installationScriptNames.find(installationTsl.scriptName()) == -1) 
		continue;
	
	Map installationTslMap = installationTsl.map().getMap("InstallationProperties");
	if (!installationTslMap.hasEntity("Parent")) 
		continue;
	
	Entity parent = installationTslMap.getEntity("Parent");
	if (parent == _ThisInst) 
		installationTsl.dbErase();
}
_Map.removeAt("InstallationTube[]", true);
_Map.removeAt("InstallationPoint[]", true);

Sheet sheets[] = el.sheet();

Vector3d vecUcsX(1,0,0);
Vector3d vecUcsY(0,1,0);
Beam lstBeams[0];
Entity lstEntities[] = { el };

Point3d lstPoints[0];
int lstPropInt[0];
double lstPropDouble[0];
String lstPropString[0];
Map mapTsl;


// TODO: Sort them by type. First apply the milling, after that the tubes.
Entity installationEntities[] = installationBlockDefinition.entity();
for (int e=0;e<installationEntities.length();e++)
{
	Entity installationEntity = installationEntities[e];
	
	int installationPathIsACircle = false;
	double installationDiameter;
	if (installationEntity.bIsA(EntPLine()))
	{
		EntPLine installation = (EntPLine)installationEntity;
		PLine installationPath = installation.getPLine();
		
		if (installationPath.vertexPoints(true).length() == 2)
		{
			LineSeg extents = PlaneProfile(installationPath).extentInDir(installationCoordSys.vecX());
			installationDiameter = abs(installationCoordSys.vecX().dotProduct(extents.ptEnd() - extents.ptStart()));
			if (abs(installationDiameter - abs(installationCoordSys.vecY().dotProduct(extents.ptEnd() - extents.ptStart()))) < tolerance)
			{
				installationPathIsACircle = true;
			}
		}
	}
	else if (installationEntity.typeName() == "AcDbCircle")
	{
		LineSeg extents = PlaneProfile(installationEntity.getPLine()).extentInDir(installationCoordSys.vecX());
		installationDiameter = abs(installationCoordSys.vecX().dotProduct(extents.ptEnd() - extents.ptStart()));
		
		installationPathIsACircle = true;
	}
	else
	{
		continue;
	}
	installationDiameter *= installationBlockReference.dScaleX();
	

	int installationColor = installationEntity.color();
	int installationIndex = installationColors.find(installationColor);
	if (installationIndex == -1)
	{
		reportNotice(TN("|Installation index could not be found for color|: ") + installationColor);
		continue;
	}
	
	PLine installationPath = installationEntity.getPLine();
	installationPath.transformBy(definitionToReference);
	
	String installationType = installationTypes[installationIndex];
	if (installationType == "Tube" || installationType == "Point")
	{	
		String attachedPropSetNames[] = installationEntity.attachedPropSetNames();
		
		String installationScriptName;
		int installationSide = -1;
		if (installationType == "Tube") 
		{
			installationScriptName = installationTubeScriptName;
			
			if (attachedPropSetNames.find(installationTubePropSetName) != -1)
			{
				Map propSetMap = installationEntity.getAttachedPropSetMap(installationTubePropSetName);
				installationSide = sideIndexes[sides.find(propSetMap.getString("Side"), 0)];
			}
		}
		else
		{
			installationScriptName = installationPointScriptName;
			
			if (attachedPropSetNames.find(installationPointPropSetName) != -1)
			{
				Map propSetMap = installationEntity.getAttachedPropSetMap(installationPointPropSetName);
				installationSide = sideIndexes[sides.find(propSetMap.getString("Side"), 0)];
				

			}
		}
		
		Map installationPropertiesMap;
		installationPropertiesMap.setEntity("Parent", _ThisInst);
		installationPropertiesMap.setPLine("Path", installationPath);
		installationPropertiesMap.setInt("Color", installationColor);
		installationPropertiesMap.setInt("Side", installationSide);
		mapTsl.setMap("InstallationProperties", installationPropertiesMap);
		
		TslInst tslNew;
		tslNew.dbCreate(installationScriptName, vecUcsX,vecUcsY,lstBeams, lstEntities, lstPoints, lstPropInt, lstPropDouble, lstPropString, _kModelSpace, mapTsl);
	}
	else if (installationType == "Milling")
	{
		int zonesToProcess[0];
		if (isAFloorElement)
		{
			zonesToProcess.append(1);
			zonesToProcess.append(2);
			zonesToProcess.append(3);
			zonesToProcess.append(4);
			zonesToProcess.append(5);
		}
		else if (isARoofElement)
		{
			zonesToProcess.append(-1);
			zonesToProcess.append(-2);
			zonesToProcess.append(-3);
			zonesToProcess.append(-4);
		}
	
		// Visualize the tool.
		if (installationPathIsACircle)
		{
			Point3d drillPosition = (installationPath.ptStart() + installationPath.ptMid())/2;
			Drill sheetDrill(drillPosition + elZ * U(500), drillPosition - elZ * U(500), 0.5 * installationDiameter);
			int nrOfSheetsAffected = sheetDrill.addMeToGenBeamsIntersect(el.sheet());
		}
		else
		{
//			installationPath.convertToLineApprox(U(0.1));
//			installationPath.close();
			Point3d pointInProfile;
			pointInProfile.setToAverage(installationPath.vertexPoints(true));
			
			PlaneProfile profile(csEl);
			profile.joinRing(installationPath, _kAdd);
			
			CoordSys cs = installationPath.coordSys();
			Plane plane(cs.ptOrg(), cs.vecZ());
			double maxDeviation = U(1); // 1 mm
			PLine freeProfilePath;
			freeProfilePath.createSmoothArcsApproximation(plane, installationPath.vertexPoints(false), maxDeviation);
			
			FreeProfile milling(freeProfilePath, pointInProfile);
			
//			FreeProfile milling(installationPath, pointInProfile);
			for (int s=0;s<sheets.length();s++)
			{
				Sheet sh = sheets[s];
				if (zonesToProcess.find(sh.myZoneIndex()) == -1)
					continue;
				
				PlaneProfile sheetProfile = sh.profShape();
				if (sheetProfile.intersectWith(profile))
					sh.addTool(milling);
			}
		}
	}
}

// visualisation
Display visualisationDisplay(symbolColor);
visualisationDisplay.textHeight(U(4));
visualisationDisplay.addHideDirection(elY);
visualisationDisplay.addHideDirection(-elY);
visualisationDisplay.elemZone(el, 0, 'I');

Point3d ptSymbol01 = _Pt0 - elY * 2 * symbolSize;
Point3d ptSymbol02 = ptSymbol01 - (elX + elY) * symbolSize;
Point3d ptSymbol03 = ptSymbol01 + (elX - elY) * symbolSize;

PLine plSymbol01(elZ);
plSymbol01.addVertex(_Pt0);
plSymbol01.addVertex(ptSymbol01);
PLine plSymbol02(elZ);
plSymbol02.addVertex(ptSymbol02);
plSymbol02.addVertex(ptSymbol01);
plSymbol02.addVertex(ptSymbol03);

visualisationDisplay.draw(plSymbol01);
visualisationDisplay.draw(plSymbol02);

Vector3d vxTxt = elX + elY;
vxTxt.normalize();
Vector3d vyTxt = elZ.crossProduct(vxTxt);
visualisationDisplay.draw(scriptName(), ptSymbol01, vxTxt, vyTxt, -1.1, 1.75);
visualisationDisplay.draw(tslIdentifier, ptSymbol01, vxTxt, vyTxt, -2.1, -1.75);

{
	Display visualisationDisplayPlan(symbolColor);
	visualisationDisplayPlan.textHeight(U(4));
	visualisationDisplayPlan.addViewDirection(elY);
	visualisationDisplayPlan.addViewDirection(-elY);
	visualisationDisplayPlan.elemZone(el, 0, 'I');
	
	Point3d ptSymbol01 = _Pt0 + elZ * 2 * symbolSize;
	Point3d ptSymbol02 = ptSymbol01 - (elX - elZ) * symbolSize;
	Point3d ptSymbol03 = ptSymbol01 + (elX + elZ) * symbolSize;
	
	PLine plSymbol01(elY);
	plSymbol01.addVertex(_Pt0);
	plSymbol01.addVertex(ptSymbol01);
	PLine plSymbol02(elY);
	plSymbol02.addVertex(ptSymbol02);
	plSymbol02.addVertex(ptSymbol01);
	plSymbol02.addVertex(ptSymbol03);
	
	visualisationDisplayPlan.draw(plSymbol01);
	visualisationDisplayPlan.draw(plSymbol02);
	
	Vector3d vxTxt = elX - elZ;
	vxTxt.normalize();
	Vector3d vyTxt = elY.crossProduct(vxTxt);
	visualisationDisplayPlan.draw(scriptName(), ptSymbol01, vxTxt, vyTxt, -1.1, 1.75);
	visualisationDisplayPlan.draw(tslIdentifier, ptSymbol01, vxTxt, vyTxt, -2.1, -1.75);
}

#End
#BeginThumbnail

#End