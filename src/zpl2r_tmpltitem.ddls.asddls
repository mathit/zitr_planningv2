@AccessControl.authorizationCheck: #MANDATORY
@Metadata.allowExtensions: true
@EndUserText.label: '###GENERATED Core Data Service Entity'
define view entity ZPL2R_TMPLTITEM
  as select from ZPL2TMPLTITEM000 as TemplateItem
  association to parent ZPL2R_TMPLTMDLE as _TemplateModule on $projection.ParentUuid = _TemplateModule.Uuid
  association [1..1] to ZPL2R_TEMPLATE000 as _Template on $projection.RootUuid = _Template.Uuid
  composition [1..*] of ZPL2R_TMPLTTMTCHER as _TemplateItemTeacher
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
  lead_teacher_uuid as LeadTeacherUUID,
  room_type as RoomType,
  _TemplateItemTeacher,
  _TemplateModule,
  _Template
}
