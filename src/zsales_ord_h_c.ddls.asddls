@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Sales Order Header Consumption View'
@Search.searchable: true
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define root view entity ZSALES_ORD_H_C
  provider contract transactional_query
  as projection on ZSALES_ORD_H_I
{
  key SalesDocument,
      SalesDocumentType,
      OrderReason,
      SalesOrganization,
      DistributionChannel,
      Division,
      @Search.defaultSearchElement: true
      SalesOffice,
      SalesGroup,
      @Semantics.amount.currencyCode: 'Currency'
      NetPrice,
      Currency,
      LocalCreatedBy,
      LocalCreatedAt,
      LocalLastChangedBy,
      LocalLastChangedAt,
      LastChangedAt,

      /* Associations */
      _salesItem : redirected to composition child ZSALES_ORD_I_C
}
