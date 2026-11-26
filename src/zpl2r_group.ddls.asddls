@AccessControl.authorizationCheck: #MANDATORY
@Metadata.allowExtensions: true
@ObjectModel.sapObjectNodeType.name: 'ZPL2GROUP'
@EndUserText.label: 'Groep'
@ObjectModel.semanticKey: [ 'GroupNumber' ]
define root view entity ZPL2R_GROUP
  as select from zpl2group as Groep
  composition [0..*] of ZPL2R_GROUPBLOCK as _GroupBlock
{
  key uuid as UUID,
  group_number as GroupNumber,
  template_uuid as TemplateUUID,
  start_date as StartDate,
  lesson_start_time as LessonStartTime,
  coach_sap_uuid as CoachSAPUUID,
  coach_soft_skills_uuid as CoachSoftSkillsUUID,
  trainee_count as TraineeCount,
  status as Status,
  notes as Notes,
  @Semantics.user.createdBy: true
  local_created_by as LocalCreatedBy,
  @Semantics.systemDateTime.createdAt: true
  local_created_at as LocalCreatedAt,
  @Semantics.user.localInstanceLastChangedBy: true
  local_last_changed_by as LocalLastChangedBy,
  @Semantics.systemDateTime.localInstanceLastChangedAt: true
  local_last_changed_at as LocalLastChangedAt,
  @Semantics.systemDateTime.lastChangedAt: true
  last_changed_at as LastChangedAt,
  _GroupBlock
}
