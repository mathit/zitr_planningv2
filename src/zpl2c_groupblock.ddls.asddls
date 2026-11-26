@Metadata.allowExtensions: true
@Metadata.ignorePropagatedAnnotations: true
@EndUserText.label: 'Groepblok'
@AccessControl.authorizationCheck: #MANDATORY
define view entity ZPL2C_GROUPBLOCK
  as projection on ZPL2R_GROUPBLOCK
  association [1..1] to ZPL2R_GROUPBLOCK as _BaseEntity on $projection.UUID = _BaseEntity.UUID
{
  key UUID,
  ParentUUID,
  TemplateModuleUUID,
  BlockName,
  Track,
  Sequence,
  StartDate,
  DurationDays,
  LeadTeacherUUID,
  IsManual,
  _Group : redirected to parent ZPL2C_GROUP,
  _BaseEntity
}
