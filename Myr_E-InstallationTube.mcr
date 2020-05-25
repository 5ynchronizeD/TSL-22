#Version 8
#BeginDescription
Last modified by: Anno Sportel (anno.sportel@hsbcad.com)
29.06.2017  -  version 1.03
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
/// This tsl adds a tube. The settings for the tube are taken from the configuration file.
/// </summary>

/// <insert>
/// Select an element and a polyline.
/// </insert>

/// <remark Lang=en>
/// Configurations are stored in _kPathHsbCompany + "\\Abbund\\InstallationConfigurations.xml".
/// </remark>

/// <version  value="1.03" date="29.06.2017"></version>

/// <history>
/// AS - 1.00 - 04.05.2017 -	Pilot version
/// AS - 1.01 - 29.06.2017 -	Disable drill in sheeting. This is now done by the installation point tsl.
/// AS - 1.02 - 29.06.2017 -	Add support for the installation side.
/// AS - 1.03 - 29.06.2017 -	Set linetype based on position in the wall. Change tool (BeamCut io Drill) for placement at the front and back of the wall.
/// </history>

double tolerance = Unit(0.001, "mm");


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
double tubeDiameters[0];
double beamDrillDiameters[0];
double plateDrillDiameters[0];
double beamCutWidths[0];
double beamCutDepths[0];
// Load the data from the configuration file.
for (int c=0;c<installationConfigurations.length();c++)
{
	if (!installationConfigurations.hasMap(c) || installationConfigurations.keyAt(c) != "InstallationConfiguration")
		continue;
	
	Map installationTubeConfiguration = installationConfigurations.getMap(c);
	if (installationTubeConfiguration.getString("Type") != "Tube")
		continue;
	
	installationColors.append(installationTubeConfiguration.getInt("ColorIndex"));
	installationDescriptions.append(installationTubeConfiguration.getString("Description"));
	tubeDiameters.append(installationTubeConfiguration.getDouble("TubeDiameter"));
	beamDrillDiameters.append(installationTubeConfiguration.getDouble("BeamDrillDiameter"));
	plateDrillDiameters.append(installationTubeConfiguration.getDouble("PlateDrillDiameter"));
	beamCutWidths.append(installationTubeConfiguration.getDouble("BeamCutWidth"));
	beamCutDepths.append(installationTubeConfiguration.getDouble("BeamCutDepth"));
}

double extraToolLength = U(2);

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
	
	Entity  selectedInstallationTubes[0];
	PrEntity ssE(T("|Select installation tubes|"), EntPLine());
	if (ssE.go())
		selectedInstallationTubes.append(ssE.set());
	
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
	for (int e=0;e<selectedInstallationTubes.length();e++) 
	{
		EntPLine selectedInstallationTube = (EntPLine)selectedInstallationTubes[e];
		if (!selectedInstallationTube.bIsValid())
			continue;
		
		lstEntities[1] = selectedInstallationTube;
		
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
	Map installationTubesMap = parentMap.getMap("InstallationTube[]");
	installationTubesMap.appendEntity("InstallationTube", _ThisInst);
	parentMap.setMap("InstallationTube[]", installationTubesMap);
	parent.setMap(parentMap);
}

assignToElementGroup(el, true, 0, 'E');

CoordSys csEl = el.coordSys();
Point3d elOrg = csEl.ptOrg();
Vector3d elX = csEl.vecX();
Vector3d elY = csEl.vecY();
Vector3d elZ = csEl.vecZ();

_Pt0 = installationPath.ptStart();

int configIndex = installationColors.find(installationColor,0);

String installationDescription = installationDescriptions[configIndex];
double beamDrillDiameter = beamDrillDiameters[configIndex];
double tubeDiameter = tubeDiameters[configIndex];
double plateDrillDiameter = plateDrillDiameters[configIndex];
double beamCutWidth = beamCutWidths[configIndex];
double beamCutDepth = beamCutDepths[configIndex];

Display installationDisplay(installationColor);
installationDisplay.elemZone(el, 0, 'I');
PLine toolPath = installationPath;
if (installationSide == 0)
{
	toolPath.projectPointsToPlane(Plane(elOrg - elZ * 0.5 * el.zone(0).dH(), elZ), elZ);
	installationDisplay.lineType("DASHDOT");
}
else
{
	Point3d planeNormal = el.zone(installationSide).coordSys().vecZ();
	Point3d planeOrigin = el.zone(installationSide).coordSys().ptOrg()  - planeNormal * 0.5 * tubeDiameter;
	toolPath.projectPointsToPlane(Plane(planeOrigin, planeNormal), planeNormal);
	installationDisplay.lineType(installationSide == 1 ? "DASHED" : "Continuous");
}
installationDisplay.draw(toolPath);

Map mapBOM;
mapBOM.setString("Name", installationDescription);
mapBOM.setDouble("Width", tubeDiameter);
double tubeLength = installationPath.length()/1000;
mapBOM.setDouble("Quantity", (int)tubeLength);
_Map.setMap("BOM", mapBOM);

setCompareKey(tubeDiameter + "_" + installationDescription);

// Expose dim info
PLine elementOutline = el.plEnvelope();
elementOutline.projectPointsToPlane(Plane(installationPath.ptStart(), installationPath.coordSys().vecZ()), installationPath.coordSys().vecZ());
Point3d elementOutlineIntersections[] = elementOutline.intersectPLine(installationPath);

for (int p=0;p<elementOutlineIntersections.length();p++)
{
	Point3d dimPoint = elementOutlineIntersections[p];
	dimPoint.vis(1);
}

// Store the element outline intersections as dimpoints
Map mapDimInfo;
mapDimInfo.setPoint3dArray("Points", elementOutlineIntersections);
_Map.setMap("DimInfo", mapDimInfo);


Beam beams[] = el.beam();

for (int b=0;b<beams.length();b++)
{
	Beam bm = beams[b];
	Vector3d bmX = bm.vecX();
	Vector3d bmZ = bm.vecD(elZ);
	Vector3d bmY = bmZ.crossProduct(bmX);
		
	Point3d tubeIntersectionsLeft[] = toolPath.intersectPoints(
									Plane(bm.ptCenSolid() - bmY * 0.5 * bm.dD(bmY), bmY));
	if (tubeIntersectionsLeft.length() == 0)
		continue;
	
	// Find possible start positions.
	// Use beam extremes to validate the intersctions. Intersecting point must be located between the beam extremes.
	Point3d beamStart = bm.ptCenSolid() - bmX * 0.5 * bm.solidLength() - bmZ * 0.5 * bm.dD(bmZ);
	Point3d beamEnd = bm.ptCenSolid() + bmX * 0.5 * bm.solidLength() + bmZ * 0.5 * bm.dD(bmZ);
	
	
	Point3d tubeStartPositions[0];
	for (int i=0;i<tubeIntersectionsLeft.length();i++)
	{
		Point3d pt = tubeIntersectionsLeft[i];
		if ((bmX.dotProduct(pt - beamStart) * bmX.dotProduct(pt - beamEnd)) < 0 && (bmZ.dotProduct(pt - beamStart) * bmZ.dotProduct(pt - beamEnd)) < 0)
			tubeStartPositions.append(pt);
	}
	
	if (tubeStartPositions.length() == 0)
		continue;
	
	
	Point3d tubeIntersectionsRight[] = toolPath.intersectPoints(
									Plane(bm.ptCenSolid() + bmY * 0.5 * bm.dD(bmY), bmY));
	if (tubeIntersectionsRight.length() == 0)
		continue;
	
	// Find possible end positions.
	Point3d tubeEndPositions[0];
	for (int i=0;i<tubeIntersectionsRight.length();i++)
	{
		Point3d pt = tubeIntersectionsRight[i];
		if ((bmX.dotProduct(pt - beamStart) * bmX.dotProduct(pt - beamEnd)) < 0)
			tubeEndPositions.append(pt);
	}
	
	// The number of start and end positions must be the same
	if (tubeStartPositions.length() != tubeEndPositions.length())
		continue;
	
	for (int i=0;i<tubeStartPositions.length();i++)
	{
		Point3d startPosition = tubeStartPositions[i];
		startPosition.vis(i);
		Point3d endPosition = tubeEndPositions[i];
		endPosition.vis(i);
		
		Point3d toolPosition = (startPosition + endPosition)/2;
		Vector3d toolDirection = bm.vecD(endPosition - startPosition);
		double toolLength = bm.dD(toolDirection);
		
		if (installationSide == 0){ 
			Drill drill(
			toolPosition - toolDirection * 0.5 * (toolLength + extraToolLength), 
			toolPosition + toolDirection * 0.5 * (toolLength + extraToolLength), 
			0.5 * beamDrillDiameter
			);
			bm.addTool(drill);
		}
		else
		{
			Vector3d toolY = bm.vecX();
			Vector3d toolZ = elZ * installationSide;
			Vector3d toolX = toolY.crossProduct(toolZ);
			BeamCut beamCut(toolPosition, toolX, toolY, toolZ, toolLength + extraToolLength, beamCutWidth, beamCutDepth + U(0.001));
			bm.addTool(beamCut);
		}
	}
}
#End
#BeginThumbnail


#End