@AccessControl.authorizationCheck: #MANDATORY
@Metadata.allowExtensions: true
@EndUserText.label: 'Importbestand'
define root view entity ZPL2R_IMPORT
  as select from zpl2import as Import
{
  key uuid as UUID,
  file_name as FileName,
  @Semantics.mimeType: true
  mime_type as MimeType,
  @Semantics.largeObject: { mimeType: 'MimeType',
                            fileName: 'FileName',
                            acceptableMimeTypes: [ 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet' ],
                            contentDispositionPreference: #ATTACHMENT }
  attachment as Attachment,
  status as Status,
  message as Message,
  @Semantics.user.createdBy: true
  local_created_by as LocalCreatedBy,
  @Semantics.systemDateTime.createdAt: true
  local_created_at as LocalCreatedAt,
  @Semantics.user.localInstanceLastChangedBy: true
  local_last_changed_by as LocalLastChangedBy,
  @Semantics.systemDateTime.localInstanceLastChangedAt: true
  local_last_changed_at as LocalLastChangedAt,
  @Semantics.systemDateTime.lastChangedAt: true
  last_changed_at as LastChangedAt
}
