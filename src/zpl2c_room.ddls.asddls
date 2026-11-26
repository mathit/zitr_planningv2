@Metadata.allowExtensions: true
@Metadata.ignorePropagatedAnnotations: true
@Endusertext: {
  Label: '###GENERATED Core Data Service Entity'
}
@Objectmodel: {
  Sapobjectnodetype.Name: 'ZPL2ROOM', 
  Semantickey: [ 'RoomName' ]
}
@AccessControl.authorizationCheck: #MANDATORY
define root view entity ZPL2C_ROOM
  provider contract TRANSACTIONAL_QUERY
  as projection on ZPL2R_ROOM
  association [1..1] to ZPL2R_ROOM as _BaseEntity on $projection.UUID = _BaseEntity.UUID
{
  key UUID,
  RoomName,
  Capacity,
  RoomEmail,
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
