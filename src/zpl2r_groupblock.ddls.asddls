@AccessControl.authorizationCheck: #MANDATORY
@Metadata.allowExtensions: true
@EndUserText.label: 'Groepblok'
define view entity ZPL2R_GROUPBLOCK
  as select from zpl2groupblock as GroupBlock
  association to parent ZPL2R_GROUP as _Group on $projection.ParentUUID = _Group.UUID
{
  key uuid as UUID,
  parent_uuid as ParentUUID,
  template_module_uuid as TemplateModuleUUID,
  block_name as BlockName,
  track as Track,
  sequence as Sequence,
  start_date as StartDate,
  duration_days as DurationDays,
  lead_teacher_uuid as LeadTeacherUUID,
  is_manual as IsManual,
  _Group
}
