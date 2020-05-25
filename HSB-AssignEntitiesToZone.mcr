#Version 8
#BeginDescription
This tsl allows the user to assign one or more entities to a specific element.

Select an element
Select one or more entities
Specify the zone index, zone character and decide if it is an exclusive assignment or not.
The entities are assigned to the specified zone (index + character) The tsl will be erased from the drawing after execution.

#End
#Type O
#NumBeamsReq 0
#NumPointsGrip 0
#DxaOut 1
#ImplInsert 1
#FileState 0
#MajorVersion 1
#MinorVersion 0
#KeyWords 
#BeginContents
int arNTrueFalse[] = {TRUE, FALSE};
String arSYesNo[] = {T("Yes"), T("No")};
PropString sExclusive(0, arSYesNo, T("Add exclusive"));
int bExclusive = arNTrueFalse[arSYesNo.find(sExclusive,0)];

int arNZoneIndex[] = {0,1,2,3,4,5,6,7,8,9,10};
PropInt nZnIndex(0,arNZoneIndex,T("Zone index"),0);

String arSZoneCharacter[] = {
	"'E' for element tools",
	"'Z' for general items",
	"'T' for beam tools",
	"'I' for information",
	"'C' for construction",
	"'D' for dimension"
};
char arCZoneCharacter[] = {
	'E',
	'Z',
	'T',
	'I',
	'C',
	'D'
};
PropString sZoneCharacter(1,arSZoneCharacter,T("Zone character"));
char cZoneCharacter = arCZoneCharacter[arSZoneCharacter.find(sZoneCharacter,0)];

if( _bOnInsert ){
	_Element.append(getElement(T("Select the element to assign entities to")));
	
	PrEntity ssE(T("Select one, or more, entities"),Entity());
	
	if( ssE.go() ){
		_Entity.append(ssE.set());
	}
	
	showDialogOnce("|_Default|");
	return;
}

int nZoneIndex = nZnIndex;
if( nZoneIndex > 5 )
	nZoneIndex = 5 - nZoneIndex;

if( _Element.length() == 0 ){eraseInstance(); return;}
Element el = _Element[0];

for( int i=0;i<_Entity.length();i++ ){
	Entity ent = _Entity[i];
	if( ent.handle() == el.handle() )continue;
	
	ent.assignToElementGroup(el, bExclusive, nZoneIndex, cZoneCharacter);
}

eraseInstance();

#End
#BeginThumbnail


#End
