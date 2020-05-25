#Version 8
#BeginDescription
Last modified by: Anno Sportel (anno.sportel@hsbcad.com)
29.06.2017  -  version 1.02
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
/// This tsl adds an installation point to an element. The settings for the tube are taken from the configuration file.
/// </summary>

/// <insert>
/// Select an element and a polyline.
/// </insert>

/// <remark Lang=en>
/// Configurations are stored in _kPathHsbCompany + "\\Abbund\\InstallationConfigurations.xml".
/// </remark>

/// <version  value="1.01" date="28.06.2017"></version>

/// <history>
/// AS - 1.00 - 04.05.2017 -	Pilot version
/// AS - 1.01 - 28.06.2017 -	Disable drill in sheeting. This is now done by the installation point tsl.
/// AS - 1.02 - 29.06.2017 -	Add support for installation side. Take the diameter from the polyline.
/// </history>

double tolerance = Unit(0.001, "mm");

String installationType = "Point";

String fileName = _kPathHsbCompany + "\\TSL\\Configurations\\InstallationConfigurations.xml";


String recalcTriggers[] = 
{
	T("|Reload installation configurations|")
};
for (int r=0;r<recalcTriggers.length();r++)
	addRecalcTrigger(_kContext, recalcTriggers[r]);

// Load configurations
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
String installationDescriptions[0];
double extraDrillDiameters[0];
// Load the data from the configuration file.
for (int c=0;c<installationConfigurations.length();c++)
{
	if (!installationConfigurations.hasMap(c) || installationConfigurations.keyAt(c) != "InstallationConfiguration")
		continue;
	
	Map installationConfiguration = installationConfigurations.getMap(c);
	if (installationConfiguration.getString("Type") != installationType)
		continue;
	
	installationColors.append(installationConfiguration.getInt("ColorIndex"));
	installationDescriptions.append(installationConfiguration.getString("Description"));
	extraDrillDiameters.append(installationConfiguration.getDouble("ExtraDrillDiameter"));
}

double extraDrillLength = U(2);

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
	
	if( (_kExecuteKey == "" || catalogNames.find(_kExecuteKey) == -1) && _ThisInst.getListOfPropNames().length() > 0 )
		showDialog();
	setCatalogFromPropValues(T("_LastInserted"));
	
	Element el = getElement(T("|Select an element|"));
	
	Entity  selectedInstallationPoints[0];
	PrEntity ssE(T("|Select installation points|"), EntPLine());
	if (ssE.go())
		selectedInstallationPoints.append(ssE.set());
	
	String strScriptName = scriptName();
	Vector3d vecUcsX(1,0,0);
	Vector3d vecUcsY(0,1,0);
	Beam lstBeams[0];
	Entity lstEntities[2];
	
	Point3d lstPoints[0];
	int lstPropInt[0];
	double lstPropDouble[0];
	String lstPropString[0];
	Map mapTsl;
	mapTsl.setInt("ManualInserted", true);

	lstEntities[0] = el;
	for (int e=0;e<selectedInstallationPoints.length();e++) 
	{
		EntPLine selectedInstallationPoint = (EntPLine)selectedInstallationPoints[e];
		if (!selectedInstallationPoint.bIsValid())
			continue;
		
		lstEntities[1] = selectedInstallationPoint;
		
		TslInst tslNew;
		tslNew.dbCreate(strScriptName, vecUcsX,vecUcsY,lstBeams, lstEntities, lstPoints, lstPropInt, lstPropDouble, lstPropString, _kModelSpace, mapTsl);
	}
	
	eraseInstance();
	return;
}

if( _Element.length() != 1 )
{
	reportWarning(TN("|No element selected!|"));
	eraseInstance();
	return;
}

int manualInserted = false;
if (_Map.hasInt("ManualInserted")) 
{
	manualInserted = _Map.getInt("ManualInserted");
	_Map.removeAt("ManualInserted", true);
}

// set properties from catalog
if (_bOnDbCreated && manualInserted)
	setPropValuesFromCatalog(T("|_LastInserted|"));

Element el = _Element[0];
if (!el.bIsValid())
{
	reportNotice(TN("|The selected element is invalid|!"));
	eraseInstance();
	return;
}

Entity installationEntity;
for (int e=0;e<_Entity.length();e++)
{
	Entity ent = _Entity[e];
	if (ent.bIsA(EntPLine()))
	{
		installationEntity = ent;
		break;
	}
}
Map installationPropertiesMap = _Map.getMap("InstallationProperties");
Entity parentEntity = installationPropertiesMap.getEntity("Parent");
TslInst parent = (TslInst)parentEntity;
PLine installationPath = installationPropertiesMap.getPLine("Path");
int installationColor = installationPropertiesMap.getInt("Color");
int installationSide = installationPropertiesMap.getInt("Side");
if (installationEntity.bIsValid())
{
	installationPath = installationEntity.getPLine();
	installationColor = installationEntity.color();
	
	setDependencyOnEntity(installationEntity);
}
// Register this instance to the parent
if  (parent.bIsValid())
{
	Map parentMap = parent.map();
	Map installationPointsMap = parentMap.getMap("InstallationPoint[]");
	installationPointsMap.appendEntity("InstallationPoint", _ThisInst);
	parentMap.setMap("InstallationPoint[]", installationPointsMap);
	parent.setMap(parentMap);
}

assignToElementGroup(el, true, 0, 'E');

CoordSys csEl = el.coordSys();
Vector3d elX = csEl.vecX();
Vector3d elY = csEl.vecY();
Vector3d elZ = csEl.vecZ();

// Verify that the specified path is (still) a circle.
int installationPathIsACircle = false;
double pointDiameter;
if (installationPath.vertexPoints(true).length() == 2)
{
	LineSeg extents = PlaneProfile(installationPath).extentInDir(elX);
	pointDiameter = abs(elX.dotProduct(extents.ptEnd() - extents.ptStart()));
	if (pointDiameter > tolerance && abs(pointDiameter - abs(elY.dotProduct(extents.ptEnd() - extents.ptStart()))) < tolerance)
	{
		installationPathIsACircle = true;
	}
}
if (!installationPathIsACircle)
{
	reportNotice("\n" + scriptName() + " - " + el.number() + TN("|The installation point requires a circular toolpath.|"));
	eraseInstance();
	return;
}

_Pt0 = (installationPath.ptStart() + installationPath.ptMid())/2;

int configIndex = installationColors.find(installationColor,0);

String installationDescription = installationDescriptions[configIndex];
double sheetDrillDiameter = pointDiameter + extraDrillDiameters[configIndex];
PLine installationVisualizedPath = installationPath;
installationVisualizedPath.projectPointsToPlane(Plane(el.zone(installationSide).coordSys().ptOrg(), el.zone(installationSide).coordSys().vecZ()), el.zone(installationSide).coordSys().vecZ());


Display installationDisplay(installationColor);
installationDisplay.elemZone(el, 0, 'I');
installationDisplay.draw(installationVisualizedPath);
if (installationSide > 0)
{
	PlaneProfile installationProfile(installationVisualizedPath);
	installationDisplay.draw(installationProfile, _kDrawFilled);
}

Map mapBOM;
mapBOM.setString("Name", installationDescription);
mapBOM.setDouble("Width", pointDiameter);
mapBOM.setDouble("Quantity", 1);
_Map.setMap("BOM", mapBOM);

setCompareKey(pointDiameter + "_" + installationDescription);

// Drill the sheets.
Sheet sheets[] = el.sheet();
Sheet sheetsOnSpecifiedSide[0];
for (int s=0;s<sheets.length();s++)
	if ((installationSide > 0 && sheets[s].myZoneIndex() > 0) || (installationSide < 0 && sheets[s].myZoneIndex() < 0))
		sheetsOnSpecifiedSide.append(sheets[s]);

Point3d drillPosition = _Pt0;
Drill sheetDrill(drillPosition + elZ * U(500), drillPosition - elZ * U(500), 0.5 * sheetDrillDiameter);
int nrOfSheetsAffected = sheetDrill.addMeToGenBeamsIntersect(sheetsOnSpecifiedSide);

#End
#BeginThumbnail

#End