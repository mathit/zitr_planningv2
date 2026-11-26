@AccessControl.authorizationCheck: #MANDATORY
@Metadata.allowExtensions: true
@EndUserText.label: '###GENERATED Core Data Service Entity'
define view entity ZPL2R_TEMPLATEITEM
  as select from ZPL2TEMPLATEITEM as TemplateItem
  association to parent ZPL2R_TMPLTEMODULE as _TemplateModule on $projection.ParentUuid = _TemplateModule.Uuid
  association [1..1] to ZPL2R_TEMPLATE as _Template on $projection.RootUuid = _Template.Uuid
{
  key uuid as UUID,
  parent_uuid as ParentUUID,
  root_uuid as RootUUID,
  title as Title,
  day_offset as DayOffset,
  time_from as TimeFrom,
  time_to as TimeTo,
  item_type as ItemType,
  location as Location,
  default_teacher_uuid as DefaultTeacherUUID,
  room_type as RoomType,
  _TemplateModule,
  _Template
}
