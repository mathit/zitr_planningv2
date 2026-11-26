@AccessControl.authorizationCheck: #MANDATORY
@Metadata.allowExtensions: true
@EndUserText.label: '###GENERATED Core Data Service Entity'
define view entity ZPL2R_TMPLTMDLE
  as select from ZPL2TMPLTMDLE000 as TemplateModule
  association to parent ZPL2R_TEMPLATE000 as _Template on $projection.ParentUuid = _Template.Uuid
  composition [1..*] of ZPL2R_TMPLTITEM as _TemplateItem
{
  key uuid as UUID,
  parent_uuid as ParentUUID,
  module_name as ModuleName,
  sequence as Sequence,
  track as Track,
  duration_days as DurationDays,
  anchor_day as AnchorDay,
  prerequisite_module_uuid as PrerequisiteModuleUUID,
  is_swappable as IsSwappable,
  _TemplateItem,
  _Template
}
