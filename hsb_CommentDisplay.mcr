#Version 8
#BeginDescription
Modified by: Anno Sportel (support.nl@hsbcad.com)
Date: 13.11.2019  -  version 1.09

#End
#Type O
#NumBeamsReq 0
#NumPointsGrip 0
#DxaOut 0
#ImplInsert 1
#FileState 1
#MajorVersion 1
#MinorVersion 9
#KeyWords 
#BeginContents
/// <summary Lang=en>
/// This tsl displays comments which are attached to the elements as metadata.
/// </summary>

/// <insert>
/// </insert>

/// <remark Lang=en>
/// 
/// </remark>

/// <version  value="1.09" date="13.11.2019"></version>

/// <history>
/// AS - 1.00 - 25.06.2019 -	Tsl to display comments created.
/// AS - 1.01 - 25.06.2019 -		Add grip to point comment
/// AS - 1.02 - 26.06.2019 -	Add offset properties. 
/// AS - 1.03 - 26.06.2019 -	Edit sends id in an array to the edit command.
/// AS - 1.04 - 02.07.2019 -	Reverse the direction of the vertical and horizontal allignment.
/// AS - 1.05 - 28.08.2019 -	Correct multiline text.
/// AS - 1.06 - 04.09.2019 -	Add point visualisation. Create new comment Id when copied. Bugfix area move and copy.
/// AS - 1.07 - 05.09.2019 - 	Respect visualisation type for text.
/// AS - 1.08 - 05.09.2019 - 	Add option to change direction of comment.
/// AS - 1.09 - 13.11.2019 - 	Align text with device.
/// </history>

Unit(1,"mm");

String modelMapKey = "ModelMap";

String commentsMapKey = "Hsb_Comment";
String commentsKey = "Comment[]";
String commentKey = "Comment";
String commentIdsKey = "Id[]";
String commentIdKey = "Id";
String commentLinesKey = "Comment[]";
String commentLineKey = "Comment";
String tagsKey = "Tag[]";
String tagKey = "Tag";
String locationKey = "Location";
String geometryTypeKey = "GeometryType";
String geometryKey = "Geometry";
String startPointKey = "StartPoint";
String endPointKey = "EndPoint";
String textOriginKey = "TextOrigin";
String textOrienationKey = "TextOrientation";
String horizontalTextAlignmentKey = "HorizontalTextAlignment";
String verticalTextAlignmentKey = "VerticalTextAlignment";
String visualisationKey = "Visualisation";


String category = T("|Position & Orientation|");
String textOrientations[] = 
{
	T("|Unchanged|"),
	T("|Default|"),
	T("|Horizontal|"),
	T("|Vertical|"),
	T("|Perpendicular|")
};
PropString textOrientationProp(2, textOrientations, T("|Text orientation|"));
textOrientationProp.setDescription(T("|Sets the text direction of the comment.|") + T("|Default text direction for a point and an area is the entity X, for a line its the line direction.|"));
textOrientationProp.setCategory(category);

PropDouble horizontalOffset(1, U(0), T("|Horizontal offset|"));
horizontalOffset.setDescription(T("|Sets the horizontal offset.|") + T("|The offset is relative to the linked geometry, or in the entity X direction if there is no geometry linked.|"));
horizontalOffset.setCategory(category);

PropDouble verticalOffset(2, U(0), T("|Vertical offset|"));
verticalOffset.setDescription(T("|Sets the vertical offset.|") + T("|The offset is relative to the linked geometry, or in the entity Y direction if there is no geometry linked.|"));
verticalOffset.setCategory(category);


category = T("|Comment style|");
PropInt commentColor(0, 1, T("|Colour|"));
commentColor.setCategory(category);

PropDouble commentTextHeight(0, U(50), T("|Text height|"));
commentTextHeight.setCategory(category);


category = T("|Area profile|");
String gripTypes[] = {T("|Edge|"), T("|Corner|")};
PropString gripTypeProp(1, gripTypes, T("|Active grippoints|"));
gripTypeProp.setCategory(category);

String noYes[] = { T("|No|"), T("|Yes|")};
PropString drawAreaCommentFilledProp(0, noYes, T("|Draw area filled|"), 1);
drawAreaCommentFilledProp.setCategory(category);

PropInt opacityAreaComment(1, 50, T("|Opacity|"));
opacityAreaComment.setCategory(category);


if (_bOnInsert)
{
	if (insertCycleCount() > 1)
	{
		eraseInstance();
		return;
	}
	
	PrEntity elementSelectionSet(T("|Select a set of elements|"), Element());
	if (elementSelectionSet.go())
	{
		Element selectedElements[] = elementSelectionSet.elementSet();
		
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
		
		for (int e = 0; e < selectedElements.length(); e++)
		{
			Element selectedElement = selectedElements[e];
			if ( ! selectedElement.bIsValid()) continue;
			
			// Remove existing comment displays.
			TslInst attachedTsls[] = selectedElement.tslInst();
			for (int t = 0; t < attachedTsls.length(); t++)
			{
				TslInst tsl = attachedTsls[t];
				if (tsl.scriptName() == strScriptName)
				{
					tsl.dbErase();
				}
			}
			
			lstEntities[0] = selectedElement;
			
			Map commentsMap = selectedElement.subMapX(commentsMapKey);
			Map comments = commentsMap.getMap(commentsKey);
			for (int c = 0; c < comments.length(); c++)
			{
				Map comment = comments.getMap(c);
				mapTsl.setString(commentIdKey, comment.getString(commentIdKey));
				
				TslInst tslNew;
				tslNew.dbCreate(strScriptName, vecUcsX, vecUcsY, lstBeams, lstEntities, lstPoints, lstPropInt, lstPropDouble, lstPropString, _kModelSpace, mapTsl);
			}
		}
	}
	
	eraseInstance();
	return;
}

if (_Element.length()==0)
{
	eraseInstance();
	return;
}

String commentId = _Map.getString(commentIdKey);

double storedHorizontalOffset = _Map.getDouble("HorizontalOffset");
double storedVerticalOffset = _Map.getDouble("VerticalOffset");
int offsetsAreChanged = (storedHorizontalOffset != horizontalOffset) || (storedVerticalOffset != verticalOffset);

int drawAreaCommentFilled = noYes.find(drawAreaCommentFilledProp, 1);
int gripType = gripTypes.find(gripTypeProp,0);

Element el = _Element[0];

_Pt0 = el.ptOrg();
CoordSys elementCoordsys = el.coordSys();
Vector3d elementX = elementCoordsys.vecX();
Vector3d elementY = elementCoordsys.vecY();
Vector3d elementZ = elementCoordsys.vecZ();
Vector3d normal = elementZ;

Display commentDisplay(commentColor);
commentDisplay.textHeight(commentTextHeight);
commentDisplay.addHideDirection(-normal);

Display commentDisplayInside(commentColor);
commentDisplayInside.textHeight(commentTextHeight);
commentDisplayInside.addViewDirection(-normal);

assignToElementGroup(el, true, 0, 'E');

String doubleClick= "TslDoubleClick";
String editCommentCommand = T("../|Edit comment|");
addRecalcTrigger(_kContext, editCommentCommand);
if (_kExecuteKey == editCommentCommand || _kExecuteKey == doubleClick)
{
	// set some export flags
	ModelMapComposeSettings mmFlags;
	
	// compose ModelMap
	ModelMap mm;
	
	Entity ents[] = {el};
	
	mm.setEntities(ents);
	mm.dbComposeMap(mmFlags);
	
	String strAssemblyPath = _kPathHsbInstall + "\\Utilities\\CadUtilities\\hsbCommentManagement\\hsbCommentManagement.dll";
	String strType = "hsbSoft.Cad.UI.CommentManager";
	String editCommentFunction = "EditComment";
	
	Map mapIn;
	Map ids;
	ids.setString(commentIdKey, commentId);
	mapIn.setMap(commentIdsKey, ids);
	mapIn.setMap(modelMapKey, mm.map());
		
//	mapIn.writeToDxxFile("C:\\Temp\\ToCommentManager.dxx");
	Map mapOut;
	mapOut = callDotNetFunction2(strAssemblyPath, strType, editCommentFunction, mapIn);
	
	if (mapOut.hasMap(modelMapKey))
	{
		// set some import flags
		ModelMapInterpretSettings mmImportFlags;
		mmImportFlags.resolveEntitiesByHandle(TRUE); //default FALSE
		
		// interpret ModelMap
		mm.setMap(mapOut.getMap(modelMapKey));
		//mm.writeToDxxFile("C:\\temp\\test.dxx");
		mm.dbInterpretMap(mmImportFlags);
		
		// report the entities imported/updated/modified
		Entity importedEnts[] = mm.entity();
		reportMessage (TN("|Number of entities imported|: ") + importedEnts.length());
	}
}

int commentIndex = - 1;
Map commentsMap = el.subMapX(commentsMapKey);
Map comments = commentsMap.getMap(commentsKey);
Map comment;
for (int c = 0; c < comments.length(); c++)
{
	Map thisComment = comments.getMap(c);
	if (commentId == thisComment.getString(commentIdKey))
	{
		comment = thisComment;
		commentIndex = c;
		break;
	}
}


// Change the ID if the element is copied.
String storedHandle = _Map.getString("Handle");
String elementHandle = _Map.getString("ElementHandle");
if (elementHandle != "" && elementHandle != el.handle())
{
	commentId = createNewGuid();
	_Map.setString(commentIdKey, commentId);
	comment.setString(commentIdKey, commentId);
	storedHandle = "";
}
_Map.setString("|ElementHandle", el.handle());

// Copy the comment if this comment display turns out to be a copied comment display.
if (storedHandle != "" && storedHandle != _ThisInst.handle())
{
	// Copy the comment, by assigning a new id to it.
	commentId = createNewGuid();
	_Map.setString(commentIdKey, commentId);
	comment.setString(commentIdKey, commentId);
	// ... and appending it to the list of comments.
	comments.appendMap(commentKey, comment);
	commentIndex = comments.length() - 1;
}
_Map.setString("Handle", _ThisInst.handle());


//_PtG.setLength(0);
int resetGripPoints = (_PtG.length() == 0);

Point3d textOrigin = comment.getPoint3d(textOriginKey);
if (resetGripPoints)
{
	_PtG.append(textOrigin);
}

Map commentLines = comment.getMap(commentLinesKey);
String tags[0];
Map tagsMap = comment.getMap(tagsKey);
for (int t = 0; t < tagsMap.length(); t++)
{
	if (tagsMap.keyAt(t) != tagKey.makeUpper()) continue;
	tags.append(tagsMap.getString(t));
}

Map locationMap = comment.getMap(locationKey);
String geometryType = locationMap.getString(geometryTypeKey);
Map geometryMap = locationMap.getMap(geometryKey);

Point3d geometryOrigin = elementCoordsys.ptOrg();
Vector3d geometryX = elementCoordsys.vecX();
Vector3d geometryY = elementCoordsys.vecY();
if (geometryType == "Area")
{
	PLine areaOutline(elementZ);
	if (_Map.hasPLine(locationKey))
	{
		areaOutline = _Map.getPLine(locationKey);
	}
	else
	{
		areaOutline = geometryMap.getPLine(locationKey);
	}
	_Map.setPLine(locationKey, areaOutline);
	
	PlaneProfile areaProfile(areaOutline);
	
	// Get the points based on the 'grip-type'. Corner or edge points.
	Point3d areaGrips[0];
	if ( gripType == 0 )
	{
		areaGrips.append(areaProfile.getGripEdgeMidPoints());
	}
	else if ( gripType == 1 )
	{
		areaGrips.append(areaProfile.getGripVertexPoints());
	}

// Reset the list of grippoints if one of the related properties is changed.
	if (_kNameLastChangedProp == T("|Active grippoints|") )
	{
		Point3d textOrigin = _PtG[0];
		_PtG.setLength(0);
		_PtG.append(textOrigin);
	}

// Set the grippoints.
	if ( _PtG.length() == 1 )
	{
		_PtG.append(areaGrips);
	}

// Update the planeprofile if one of the grippoints is moved.
	if ( _kNameLastChangedProp.left(4) == "_PtG" && _kNameLastChangedProp.right(2) != "G0") 
	{
		int indexMovedGrip = _kNameLastChangedProp.right(_kNameLastChangedProp.length() - 4).atoi();
		int movedSuccessfully = false;
		//_PtG[indexMovedGrip] = areaProfile.closestPointTo(_PtG[indexMovedGrip]);
		if ( gripType == 0 )
		{
			movedSuccessfully = areaProfile.moveGripEdgeMidPointAt(indexMovedGrip - 1, _PtG[indexMovedGrip] - areaGrips[indexMovedGrip - 1]);
		}
		else if ( gripType == 1 )
		{
			movedSuccessfully = areaProfile.moveGripVertexPointAt(indexMovedGrip - 1, _PtG[indexMovedGrip] - areaGrips[indexMovedGrip - 1]);
		}
	}
	
	commentDisplay.draw(areaProfile, drawAreaCommentFilled ? _kDrawFilled : _kDrawAsCurves, opacityAreaComment);
	
	PLine areaOutlines[] = areaProfile.allRings();
	if(areaOutlines.length() > 0)
	{
		areaOutline = areaOutlines[0];
	}
	
	geometryMap.setPLine(locationKey, areaOutline);
	
	geometryOrigin = Body(areaOutline, normal, 0).ptCen();
}
else if (geometryType == "Line")
{
	Point3d start = geometryMap.getPoint3d(startPointKey);
	Point3d end = geometryMap.getPoint3d(endPointKey);
		
	if (resetGripPoints)
	{
		_PtG.append(start);
		_PtG.append(end);
	}
	
	if (_PtG.length() < 3)
	{
		reportNotice("|Invalid line selected.|");
		eraseInstance();
		return;
	}
	LineSeg line(_PtG[1], _PtG[2]);
	commentDisplay.draw(line);
	
	geometryMap.setPoint3d(startPointKey, _PtG[1]);
	geometryMap.setPoint3d(endPointKey, _PtG[2]);
	
	geometryOrigin = (_PtG[1] + _PtG[2]) / 2;
	
	geometryX = Vector3d(_PtG[2] - _PtG[1]);
	geometryX.normalize();
	geometryY = normal.crossProduct(geometryX);
}
else if (geometryType == "Point")
{
	Point3d point = geometryMap.getPoint3d(locationKey);
	if (_PtG.length() < 2)
	{
		_PtG.append(point);
	}
	
	double pointSize = U(5);
	
	PLine rectangle(elementZ);
	rectangle.createRectangle(LineSeg(_PtG[1] - (elementX + elementY) * pointSize, _PtG[1] + (elementX + elementY) * pointSize), elementX, elementY);
	commentDisplay.draw(rectangle);
	Vector3d directions[] = { elementX, elementY, - elementX, - elementY};
	for (int d=0;d<directions.length();d++)
	{
		Vector3d direction = directions[d];
		PLine crossHair(_PtG[1] + direction * pointSize, _PtG[1] + direction * 5 * pointSize);
		commentDisplay.draw(crossHair);
	}
	
	geometryMap.setPoint3d(locationKey, _PtG[1]);
	geometryOrigin = _PtG[1];
}
else
{
	// No location. Nothing to draw.
	eraseInstance();
	return;
}

if (offsetsAreChanged)
{
	_PtG[0] = geometryOrigin + geometryX * horizontalOffset + geometryY * verticalOffset;
}

geometryX.vis(_PtG[0], 1);
geometryY.vis(_PtG[0], 3);

locationMap.setMap(geometryKey, geometryMap);
comment.setMap(locationKey, locationMap);

Vector3d textDirection = comment.getVector3d(textOrienationKey);
int textOrientation = textOrientations.find(textOrientationProp, 0);
if (textOrientation == 1)
{
	textDirection = geometryX;
}
else if (textOrientation == 2)
{
	textDirection = elementX;
}
else if (textOrientation == 3)
{
	textDirection = elementY;
}
else if (textOrientation == 4)
{
	textDirection = geometryY;
}

Vector3d textUpDirection = normal.crossProduct(textDirection);

int horizontalTextAlignment = (comment.getInt(horizontalTextAlignmentKey) - 1) * -1; // 0 = Right, 1 = Center, 2 = Left
int verticalTextAlignment = (comment.getInt(verticalTextAlignmentKey) - 1) * -1; // 0 = Top, 1 = Center, 2 = Bottom
// Note: the visualisation is only affecting text.
int visualisation = comment.getInt(visualisationKey); // 0 = Visible, 1 = Collapsed, 2 = None

_ThisInst.setAllowGripAtPt0(false);

String linesToDisplay[0];
for (int l = 0; l < commentLines.length(); l++)
{
	String s = commentLines.keyAt(l).makeLower();
	if ( commentLines.keyAt(l).makeLower() != commentLineKey.makeLower()) continue;
	linesToDisplay.append(commentLines.getString(l));
}

if (visualisation == 0)
{
	for (int l = 0; l < linesToDisplay.length(); l++)
	{
		double verticalFlag = verticalTextAlignment;
		if (verticalTextAlignment == 0)
		{
			verticalFlag += (0.5 * linesToDisplay.length() - l - 0.5) * 3;
		}
		else if (verticalTextAlignment > 0)
		{
			verticalFlag += (linesToDisplay.length() - 1 - l) * 3;
		}
		else
		{
			verticalFlag = verticalTextAlignment - l * 3;
		}
		
		String commentLine = linesToDisplay[l];
		commentDisplay.draw(commentLine, _PtG[0], textDirection, textUpDirection, horizontalTextAlignment, verticalFlag);
		commentDisplayInside.draw(commentLine, _PtG[0], textDirection, textUpDirection, horizontalTextAlignment, verticalFlag, _kDevice);
	}
}
else if (visualisation == 1)
{
	double collapsedRadius = U(50);
	PLine circle(elementZ);
	circle.createCircle(_PtG[0], elementZ, collapsedRadius);
	PlaneProfile collapsedSymbol(elementCoordsys);
	collapsedSymbol.joinRing(circle, _kAdd);

	PLine dot(elementZ);
	dot.createCircle(_PtG[0] + elementY * 0.5 * collapsedRadius, elementZ,  0.2* collapsedRadius);
	collapsedSymbol.joinRing(dot, _kSubtract);
	
	PLine infoBar(elementZ);
	infoBar.createRectangle(LineSeg(_PtG[0] - elementX * 0.2 * collapsedRadius - elementY * 0.7 * collapsedRadius, _PtG[0] + elementX * 0.2 * collapsedRadius + elementY * 0.2 * collapsedRadius), elementX, elementY);
	collapsedSymbol.joinRing(infoBar, _kSubtract);
	
	PlaneProfile infoSymbol(elementCoordsys);
	infoSymbol.joinRing(dot, _kAdd);
	infoSymbol.joinRing(infoBar, _kAdd);
	
	Display collapsedDisplay = commentDisplay;
	collapsedDisplay.color(5);
	collapsedDisplay.draw(collapsedSymbol, _kDrawFilled);
	collapsedDisplay.color(255);
	collapsedDisplay.draw(infoSymbol, _kDrawFilled);
}


comment.setPoint3d(textOriginKey, _PtG[0]);
comment.setVector3d(textOrienationKey, textDirection);
comments.appendMap(commentKey, comment);
comments.removeAt(commentIndex, false);
commentsMap.setMap(commentsKey, comments);
el.setSubMapX(commentsMapKey, commentsMap);

double currentHorizontalOffset = geometryX.dotProduct(_PtG[0] - geometryOrigin);
horizontalOffset.set(currentHorizontalOffset);
_Map.setDouble("HorizontalOffset", currentHorizontalOffset);
double currentVerticalOffset = geometryY.dotProduct(_PtG[0] - geometryOrigin);
verticalOffset.set(currentVerticalOffset);
_Map.setDouble("VerticalOffset", currentVerticalOffset);

textOrientationProp.set(textOrientations[0]);
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