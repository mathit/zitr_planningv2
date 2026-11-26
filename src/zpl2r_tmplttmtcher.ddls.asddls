@AccessControl.authorizationCheck: #MANDATORY
@Metadata.allowExtensions: true
@EndUserText.label: '###GENERATED Core Data Service Entity'
define view entity ZPL2R_TMPLTTMTCHER
  as select from ZPL2TMPLTTMTCHER as TemplateItemTeacher
  association to parent ZPL2R_TMPLTITEM as _TemplateItem on $projection.ParentUuid = _TemplateItem.Uuid
  association [1..1] to ZPL2R_TEMPLATE000 as _Template on $projection.RootUuid = _Template.Uuid
{
  key uuid as UUID,
  parent_uuid as ParentUUID,
  root_uuid as RootUUID,
  teacher_uuid as TeacherUUID,
  _TemplateItem,
  _Template
}
