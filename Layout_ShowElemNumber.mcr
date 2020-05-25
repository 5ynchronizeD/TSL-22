#Version 7
#BeginDescription
KR: 27-5-04: Show element information in PS
Change the first line in the script to change the dimstyle that is used.

#End
#Type O
#NumBeamsReq 0
#NumPointsGrip 0
#DxaOut 1
#ImplInsert 1
#MajorVersion 0
#MinorVersion 0
#KeyWords 
#BeginContents
String strDimStyle = "HSB-NUMBER"; // dimstyle was adjusted for display in paper space, sets textHeight

/////////////////////////

Unit(1,"mm"); // script uses mm

if (_bOnInsert) {
  
   _Pt0 = getPoint("Select location"); // select point
  Viewport vp = getViewport("Select the viewport from which the element is taken"); // select viewport
  _Viewport.append(vp);

  return;
}

// set the diameter of the 3 circles, shown during dragging
setMarbleDiameter(U(4));

// do something for the last appended viewport only
//if (_Viewport.length()==0) return; // _Viewport array has some elements
Viewport vp = _Viewport[_Viewport.length()-1]; // take last element of array
_Viewport[0] = vp; // make sure the connection to the first one is lost

// check if the viewport has hsb data
//if (!vp.element().bIsValid()) return;

Element el = vp.element();
String strText = el.number();

Display dp(-1); // use color of entity
dp.dimStyle(strDimStyle); 

// draw the text at insert point
dp.draw(strText ,_Pt0,_XW,_YW,1,1);







#End
#BeginThumbnail


#End
