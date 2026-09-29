@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Sales Order Item Interface View'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
  serviceQuality: #X,
  sizeCategory: #S,
  dataClass: #MIXED
}
define view entity ZSALES_ORD_I_I
  as select from zsales_ord_i
  association to parent ZSALES_ORD_H_I as _salesHeader 
    on $projection.SalesDocument = _salesHeader.SalesDocument
{
  key salesdocument         as SalesDocument,
  key salesitemnumber       as SalesItemNumber,
      material              as Material,
      plant                 as Plant,
      @Semantics.quantity.unitOfMeasure: 'QuantityUnits'
      quantity              as Quantity,
      quantityunits         as QuantityUnits,
      @Semantics.user.createdBy: true
      local_created_by      as LocalCreatedBy,
      @Semantics.systemDateTime.createdAt: true
      local_created_at      as LocalCreatedAt,
      @Semantics.user.lastChangedBy: true
      local_last_changed_by as LocalLastChangedBy,
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      local_last_changed_at as LocalLastChangedAt,
      last_changed_at       as LastChangedAt,

      /* Association to parent */
      _salesHeader
}
