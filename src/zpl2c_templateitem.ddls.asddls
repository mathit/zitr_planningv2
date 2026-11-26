@Metadata.allowExtensions: true
@Metadata.ignorePropagatedAnnotations: true
@Endusertext: {
  Label: '###GENERATED Core Data Service Entity'
}
@AccessControl.authorizationCheck: #MANDATORY
define view entity ZPL2C_TEMPLATEITEM
  as projection on ZPL2R_TEMPLATEITEM
  association [1..1] to ZPL2R_TEMPLATEITEM as _BaseEntity on $projection.UUID = _BaseEntity.UUID
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
  DefaultTeacherUUID,
  RoomType,
  _TemplateModule : redirected to parent ZPL2C_TMPLTEMODULE,
  _Template : redirected to ZPL2C_TEMPLATE,
  _BaseEntity
}
