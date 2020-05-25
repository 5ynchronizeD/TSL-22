#Version 8
#BeginDescription
Modified by: Anno Sportel (support.nl@hsbcad.com)
Date: 26.06.2019  -  version 1.08

#End
#Type O
#NumBeamsReq 0
#NumPointsGrip 0
#DxaOut 0
#ImplInsert 1
#FileState 1
#MajorVersion 1
#MinorVersion 8
#KeyWords 
#BeginContents
/// <summary Lang=en>
/// This tsl create and edits comments.
/// </summary>

/// <insert>
/// </insert>

/// <remark Lang=en>
/// 
/// </remark>

/// <version  value="1.08" date="26.06.2019"></version>

/// <history>
/// AS - 1.00 - 
/// ....
/// AS - 1.08 - 26.06.2019 -	Create comment displays when adding comments.
/// </history>
Unit(1,"mm");

String commentDisplayScriptName = "hsb_CommentDisplay";

String modelMapKey = "ModelMap";
String commentsKey = "Comment[]";
String commentKey = "Comment";
String commentIdKey = "Id";
String entityKey = "Entity";
String geometryKey = "Geometry";
String geometryTypeKey = "GeometryType";
String locationKey = "Location";
String startPointKey = "StartPoint";
String endPointKey = "EndPoint";
String areaKey = "Location";
String textOriginKey = "TextOrigin";
String textDirectionKey = "TextOrientation";

String executionModes[] = 
{
	T("|Add comment|"),
	T("|Edit comments|")
};
PropString executionModeProp(0, executionModes, T("|Action|: "));
executionModeProp.setDescription(T("|Sets the execution mode of the comment manager.|"));

String category = "|Add Comment|";
String locationGeometries[] = 
{
	T("|No location|"),
	T("|Point|"),
	T("|Line segment|"),
	T("|Area|")
};
PropString locationGeometryProp(1, locationGeometries, T("|Location geometry|"), 0);
locationGeometryProp.setDescription(T("|Specifies what geometry to use for the location of the comment.|"));
locationGeometryProp.setCategory(category);

category = "|Position & Orientation|";
String textOrientations[] = 
{
	T("|Default|"),
	T("|Horizontal|"),
	T("|Vertical|"),
	T("|Perpendicular|")
};
PropString textOrientationProp(2, textOrientations, T("|Text orientation|"));
textOrientationProp.setDescription(T("|Sets the text direction of the comment.|") + T("|Default text direction for a point and an area is the entity X, for a line its the line direction.|"));
textOrientationProp.setCategory(category);


PropDouble horizontalOffset(0, U(0), T("|Horizontal offset|"));
horizontalOffset.setDescription(T("|Sets the horizontal offset.|") + T("|The offset is relative to the linked geometry, or in the entity X direction if there is no geometry linked.|"));
horizontalOffset.setCategory(category);

PropDouble verticalOffset(1, U(0), T("|Vertical offset|"));
verticalOffset.setDescription(T("|Sets the vertical offset.|") + T("|The offset is relative to the linked geometry, or in the entity Y direction if there is no geometry linked.|"));
verticalOffset.setCategory(category);


//-------------------------------------------------------------------
// Set properties if inserted with an execute key
String catalogNames[] = TslInst().getListOfCatalogNames(scriptName());
if( catalogNames.find(_kExecuteKey) != -1 ) 
{
	setPropValuesFromCatalog(_kExecuteKey);
}

if (_bOnInsert)
{
	if (insertCycleCount() > 1)
	{
		eraseInstance();
		return;
	}
	
	if ( _kExecuteKey == "" || catalogNames.find(_kExecuteKey) == -1 )
	{
		showDialog();
	}
}

int executionMode = executionModes.find(executionModeProp, 0);

if (_bOnInsert)
{
	int locationGeometry = locationGeometries.find(locationGeometryProp, 0);
	int textOrientation = textOrientations.find(textOrientationProp, 0);

	if (executionMode == 1 || (executionMode == 0 && locationGeometry == 0))
	{
		PrEntity ssE(TN("|Select a set of elements|"), Element());
		if ( ssE.go() )
		{
			_Element.append(ssE.elementSet());
		}
		
		return;
	}
	else
	{
		Element selectedElement = getElement(T("|Select an element|"));
		CoordSys selectedElementCoordSys = selectedElement.coordSys();
		Vector3d selectedElementX = selectedElementCoordSys.vecX();
		Vector3d selectedElementY = selectedElementCoordSys.vecY();
		Vector3d selectedElementZ = selectedElementCoordSys.vecZ();
		_Element.append(selectedElement);
		
		Point3d geometryOrg = selectedElementCoordSys.ptOrg();
		Vector3d geometryX = selectedElementX;
		Vector3d geometryZ = selectedElementZ;
		
		Map geometryMap;
		if (locationGeometry == 1)
		{
			geometryMap.setInt(geometryTypeKey, locationGeometry - 1);
			Point3d commentLocation = getPoint(T("|Select a position|"));
			geometryMap.setPoint3d(locationKey, commentLocation);
			
			geometryOrg = commentLocation;
		}
		else if (locationGeometry == 2)
		{
			geometryMap.setInt(geometryTypeKey, locationGeometry - 1);
			Point3d startPoint = getPoint(T("|Select start of line segment|"));
			geometryMap.setPoint3d(startPointKey, startPoint);
			
			Point3d endPoint;
			PrPoint endPointSelection(TN("|Select end point of line segment|"), startPoint); 
			if (endPointSelection.go()==_kOk) 
			 { ;
				endPoint = endPointSelection.value();
				geometryMap.setPoint3d(endPointKey, endPoint);
			}
			
			Vector3d lineDirection(endPoint - startPoint);
			lineDirection.normalize();
			geometryX = lineDirection;
			
			geometryOrg = (endPoint + startPoint) / 2;
		}
		else if (locationGeometry == 3)
		{
			PLine area(selectedElementZ);
			geometryMap.setInt(geometryTypeKey, locationGeometry - 1);
			PrEntity areaSelectionSet(T("|Select a poly line, right click to select two points as a diagonal|"), EntPLine());
			if (areaSelectionSet.go() == _kOk)
			{
				Entity selectedAreas[] = areaSelectionSet.set();
				if (selectedAreas.length() > 0)
				{
					area = ((EntPLine)selectedAreas[0]).getPLine();
				}
				else
				{ 
					reportMessage(TN("|Invalid area selected.|"));
					eraseInstance();
					return;
				}
			}
			else
			{
				Point3d startPoint = getPoint(T("|Select start of diagonal|"));
				Point3d endPoint;
				PrPoint endPointSelection(TN("|Select end of diagonal|"), startPoint);
				if (endPointSelection.go() == _kOk)
				{
					endPoint = endPointSelection.value();
				}
				endPoint = Plane(startPoint, selectedElementZ).closestPointTo(endPoint);
				
				area.createRectangle(LineSeg(startPoint, endPoint), selectedElementX, selectedElementY);
			}
			
			geometryMap.setPLine(areaKey, area);
			geometryOrg = Body(area, geometryZ, 0).ptCen();
		}
		
		Vector3d geometryY = geometryZ.crossProduct(geometryX);
		geometryY.normalize();
		Point3d textPosition = geometryOrg + geometryX * horizontalOffset + geometryY * verticalOffset;
		
		Vector3d textDirection = geometryX;
		if (textOrientation == 1)
		{
			textDirection = selectedElementX;
		}
		else if (textOrientation == 2)
		{
			textDirection = selectedElementY;
		}
		else if (textOrientation == 3)
		{
			textDirection = geometryY;
		}
		
		_Map.setPoint3d(textOriginKey, textPosition);
		_Map.setVector3d(textDirectionKey, textDirection);
		
		_Map.setMap(geometryKey, geometryMap);
	}
}


if (_Element.length()==0)
{
	eraseInstance();
	return;
}

// set some export flags
ModelMapComposeSettings mmFlags;

// compose ModelMap
ModelMap mm;

Entity ents[0];
for(int i=0;i<_Element.length();i++)
{
	ents.append(_Element[i]);
}
	
mm.setEntities(ents);
mm.dbComposeMap(mmFlags);

String strAssemblyPath = _kPathHsbInstall + "\\Utilities\\CadUtilities\\hsbCommentManagement\\hsbCommentManagement.dll";
String strType = "hsbSoft.Cad.UI.CommentManager";
String addCommentFunction = "AddComment";
String editCommentFunction = "EditComments";

Map mapIn;
mapIn.setMap(modelMapKey, mm.map());
if (_Map.hasMap(geometryKey))
{
	mapIn.setMap(geometryKey, _Map.getMap(geometryKey));
}
if (_Map.hasPoint3d(textOriginKey))
{
	mapIn.setPoint3d(textOriginKey, _Map.getPoint3d(textOriginKey));
}
if (_Map.hasVector3d(textDirectionKey))
{
	mapIn.setVector3d(textDirectionKey, _Map.getVector3d(textDirectionKey));
}


//mapIn.writeToDxxFile("C:\\Temp\\ToCommentManagerFromManagementTsl.dxx");
Map mapOut;
mapOut = callDotNetFunction2(strAssemblyPath, strType, executionMode == 0 ? addCommentFunction : editCommentFunction, mapIn);

//for (int m=0;m<mapOut.length();m++)
//{
//	reportNotice("\nKey: " + mapOut.keyAt(m));
//}

if (mapOut.hasMap(modelMapKey))
{
	// set some import flags
	ModelMapInterpretSettings mmImportFlags;
	mmImportFlags.resolveEntitiesByHandle(TRUE); // default FALSE
	
	// interpret ModelMap
	mm.setMap(mapOut.getMap(modelMapKey));
	//mm.writeToDxxFile("C:\\temp\\test.dxx");
	mm.dbInterpretMap(mmImportFlags);
	
	// report the entities imported/updated/modified
	Entity importedEnts[] = mm.entity();
	reportMessage (TN("|Number of entities imported|: ") + importedEnts.length());
	
	String strScriptName = scriptName();
	Vector3d vecUcsX(1, 0, 0);
	Vector3d vecUcsY(0, 1, 0);
	Beam lstBeams[0];
	Entity lstEntities[1];
	
	Point3d lstPoints[0];
	int lstPropInt[0];
	double lstPropDouble[0];
	String lstPropString[0];
	Map mapTsl;
	
	Map createdComments = mapOut.getMap(commentsKey);
	for (int c=0;c<createdComments.length();c++)
	{
		if (createdComments.keyAt(c) != commentKey) continue;
		
		Map createdComment = createdComments.getMap(c);
		Entity entity = createdComment.getEntity(entityKey);
		String commentId = createdComment.getString(commentIdKey);
		
		lstEntities[0] = entity;
		mapTsl.setString(commentIdKey, createdComment.getString(commentIdKey));
				
		TslInst commentDisplay;
		commentDisplay.dbCreate(commentDisplayScriptName, vecUcsX, vecUcsY, lstBeams, lstEntities, lstPoints, lstPropInt, lstPropDouble, lstPropString, _kModelSpace, mapTsl);
	}
}

eraseInstance();
return;


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