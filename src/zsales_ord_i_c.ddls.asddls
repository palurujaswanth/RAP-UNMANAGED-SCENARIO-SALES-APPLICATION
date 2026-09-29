@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Sales Order Item Consumption View'
@Search.searchable: true
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define view entity ZSALES_ORD_I_C
  as projection on ZSALES_ORD_I_I
{
  key SalesDocument,
  key SalesItemNumber,
      @Search.defaultSearchElement: true
      Material,
      Plant,
      @Semantics.quantity.unitOfMeasure: 'QuantityUnits'
      Quantity,
      QuantityUnits,
      LocalCreatedBy,
      LocalCreatedAt,
      LocalLastChangedBy,
      LocalLastChangedAt,
      LastChangedAt,

      /* Associations */
      _salesHeader : redirected to parent ZSALES_ORD_H_C
}
