@Metadata.allowExtensions: true
@Metadata.ignorePropagatedAnnotations: true
@Endusertext: {
  Label: '###GENERATED Core Data Service Entity'
}
@Objectmodel: {
  Sapobjectnodetype.Name: 'ZPL2TEMPLATE000', 
  Semantickey: [ 'TemplateName' ]
}
@AccessControl.authorizationCheck: #MANDATORY
define root view entity ZPL2C_TEMPLATE000
  provider contract TRANSACTIONAL_QUERY
  as projection on ZPL2R_TEMPLATE000
  association [1..1] to ZPL2R_TEMPLATE000 as _BaseEntity on $projection.UUID = _BaseEntity.UUID
{
  key UUID,
  TemplateName,
  Description,
  IsActive,
  @Semantics: {
    User.Createdby: true
  }
  LocalCreatedBy,
  @Semantics: {
    Systemdatetime.Createdat: true
  }
  LocalCreatedAt,
  @Semantics: {
    User.Localinstancelastchangedby: true
  }
  LocalLastChangedBy,
  @Semantics: {
    Systemdatetime.Localinstancelastchangedat: true
  }
  LocalLastChangedAt,
  @Semantics: {
    Systemdatetime.Lastchangedat: true
  }
  LastChangedAt,
  _TemplateModule : redirected to composition child ZPL2C_TMPLTMDLE,
  _BaseEntity
}
