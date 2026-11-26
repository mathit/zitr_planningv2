@Metadata.allowExtensions: true
@Metadata.ignorePropagatedAnnotations: true
@EndUserText.label: 'Importbestand'
@AccessControl.authorizationCheck: #MANDATORY
define root view entity ZPL2C_IMPORT
  provider contract transactional_query
  as projection on ZPL2R_IMPORT
{
  key UUID,
  FileName,
  @Semantics.mimeType: true
  MimeType,
  @Semantics.largeObject: { mimeType: 'MimeType',
                            fileName: 'FileName',
                            acceptableMimeTypes: [ 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet' ],
                            contentDispositionPreference: #ATTACHMENT }
  Attachment,
  Status,
  Message,
  LocalCreatedBy,
  LocalCreatedAt,
  LocalLastChangedBy,
  LocalLastChangedAt,
  LastChangedAt
}
