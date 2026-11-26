@Metadata.allowExtensions: true
@Metadata.ignorePropagatedAnnotations: true
@Endusertext: {
  Label: '###GENERATED Core Data Service Entity'
}
@AccessControl.authorizationCheck: #MANDATORY
define view entity ZPL2C_TMPLTEMODULE
  as projection on ZPL2R_TMPLTEMODULE
  association [1..1] to ZPL2R_TMPLTEMODULE as _BaseEntity on $projection.UUID = _BaseEntity.UUID
{
  key UUID,
  ParentUUID,
  ModuleName,
  Sequence,
  Track,
  DurationDays,
  AnchorDay,
  PrerequisiteModuleUUID,
  IsSwappable,
  _TemplateItem : redirected to composition child ZPL2C_TEMPLATEITEM,
  _Template : redirected to parent ZPL2C_TEMPLATE,
  _BaseEntity
}
