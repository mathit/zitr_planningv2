@Metadata.allowExtensions: true
@Metadata.ignorePropagatedAnnotations: true
@Endusertext: {
  Label: '###GENERATED Core Data Service Entity'
}
@AccessControl.authorizationCheck: #MANDATORY
define view entity ZPL2C_TMPLTITEM
  as projection on ZPL2R_TMPLTITEM
  association [1..1] to ZPL2R_TMPLTITEM as _BaseEntity on $projection.UUID = _BaseEntity.UUID
{
  key UUID,
  ParentUUID,
  RootUUID,
  Title,
  DayOffset,
  TimeFrom,
  TimeTo,
  ItemType,
  Location,
  LeadTeacherUUID,
  RoomType,
  _TemplateItemTeacher : redirected to composition child ZPL2C_TMPLTTMTCHER,
  _TemplateModule : redirected to parent ZPL2C_TMPLTMDLE,
  _Template : redirected to ZPL2C_TEMPLATE000,
  _BaseEntity
}
