@AbapCatalog.viewEnhancementCategory: [ #NONE ]

@AccessControl.authorizationCheck: #NOT_REQUIRED

@EndUserText.label: 'Interaface cds entity for proj'

@Metadata.ignorePropagatedAnnotations: true

@ObjectModel.usageType: { serviceQuality: #X, sizeCategory: #S, dataClass: #MIXED }

define view entity zsvg_i_proj
  as select from zsvg_proj
  association [0..1] to zsvg_i_loc        as _loc on $projection.Loc = _loc.value_low
  association        to parent zsvg_i_emp as _emp on $projection.EmpId = _emp.Id

{
  key id                     as Id,
  key emp_id                 as EmpId,

      name                   as Name,
      loc                    as Loc,
      _loc.location_text     as Location_text,
      alloc                  as Alloc,
      start_date             as StartDate,
      active                 as Active,
      end_date               as EndDate,

      @Semantics.user.createdBy: true
      created_by             as CreatedBy,

      @Semantics.systemDateTime.createdAt: true
      created_at             as CreatedAt,

      @Semantics.user.lastChangedBy: true
      lastchanged_by         as LastchangedBy,

      @Semantics.systemDateTime.lastChangedAt: true
      lastchanged_at         as LastchangedAt,

      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      locinst_lastchanged_at as LocinstLastchangedAt,

      _emp,
      _loc
}
