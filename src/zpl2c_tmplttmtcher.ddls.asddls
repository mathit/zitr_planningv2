@Metadata.allowExtensions: true
@Metadata.ignorePropagatedAnnotations: true
@Endusertext: {
  Label: '###GENERATED Core Data Service Entity'
}
@AccessControl.authorizationCheck: #MANDATORY
define view entity ZPL2C_TMPLTTMTCHER
  as projection on ZPL2R_TMPLTTMTCHER
  association [1..1] to ZPL2R_TMPLTTMTCHER as _BaseEntity on $projection.UUID = _BaseEntity.UUID
{
  key UUID,
  ParentUUID,
  RootUUID,
  TeacherUUID,
  _TemplateItem : redirected to parent ZPL2C_TMPLTITEM,
  _Template : redirected to ZPL2C_TEMPLATE000,
  _BaseEntity
}
