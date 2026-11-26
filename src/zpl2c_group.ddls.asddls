@Metadata.allowExtensions: true
@Metadata.ignorePropagatedAnnotations: true
@EndUserText.label: 'Groep'
@ObjectModel: {
  sapObjectNodeType.name: 'ZPL2GROUP',
  semanticKey: [ 'GroupNumber' ]
}
@AccessControl.authorizationCheck: #MANDATORY
define root view entity ZPL2C_GROUP
  provider contract transactional_query
  as projection on ZPL2R_GROUP
  association [1..1] to ZPL2R_GROUP as _BaseEntity on $projection.UUID = _BaseEntity.UUID
{
  key UUID,
  GroupNumber,
  TemplateUUID,
  StartDate,
  LessonStartTime,
  CoachSAPUUID,
  CoachSoftSkillsUUID,
  TraineeCount,
  Status,
  Notes,
  LocalCreatedBy,
  LocalCreatedAt,
  LocalLastChangedBy,
  LocalLastChangedAt,
  LastChangedAt,
  _GroupBlock : redirected to composition child ZPL2C_GROUPBLOCK,
  _BaseEntity
}
