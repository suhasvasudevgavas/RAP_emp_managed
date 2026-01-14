@AbapCatalog.viewEnhancementCategory: [ #NONE ]

@AccessControl.authorizationCheck: #NOT_REQUIRED

@EndUserText.label: 'Interaface cds entity for location'

@Metadata.ignorePropagatedAnnotations: true

@ObjectModel.usageType: { serviceQuality: #X, sizeCategory: #S, dataClass: #MIXED }

define view entity zsvg_i_loc
  as select from DDCDS_CUSTOMER_DOMAIN_VALUE_T(
                   p_domain_name : 'ZSVG_DO_LOC')

{
  key domain_name,
  key value_position,

      @Semantics.language: true
  key language,

      value_low,

      @Semantics.text: true
      text as location_text
}
