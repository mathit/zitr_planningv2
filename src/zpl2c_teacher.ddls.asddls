@Metadata.allowExtensions: true
@Metadata.ignorePropagatedAnnotations: true
@Endusertext: {
  Label: '###GENERATED Core Data Service Entity'
}
@Objectmodel: {
  Sapobjectnodetype.Name: 'ZPL2TEACHER', 
  Semantickey: [ 'ShortName' ]
}
@AccessControl.authorizationCheck: #MANDATORY
define root view entity ZPL2C_TEACHER
  provider contract TRANSACTIONAL_QUERY
  as projection on ZPL2R_TEACHER
  association [1..1] to ZPL2R_TEACHER as _BaseEntity on $projection.UUID = _BaseEntity.UUID
{
  key UUID,
  ShortName,
  FullName,
  Discipline,
  Email,
  IsExternal,
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
  _BaseEntity
}
