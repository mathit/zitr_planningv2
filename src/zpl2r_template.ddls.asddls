@AccessControl.authorizationCheck: #MANDATORY
@Metadata.allowExtensions: true
@ObjectModel.sapObjectNodeType.name: 'ZPL2TEMPLATE'
@EndUserText.label: '###GENERATED Core Data Service Entity'
@ObjectModel.semanticKey: [ 'TemplateName' ]
define root view entity ZPL2R_TEMPLATE
  as select from ZPL2TEMPLATE as Template
  composition [1..*] of ZPL2R_TMPLTEMODULE as _TemplateModule
{
  key uuid as UUID,
  template_name as TemplateName,
  description as Description,
  is_active as IsActive,
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
  _TemplateModule
}
