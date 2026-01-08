@AccessControl.authorizationCheck: #NOT_REQUIRED

@EndUserText.label: 'Interaface cds entity for emp'

@Metadata.ignorePropagatedAnnotations: true

define root view entity zsvg_i_emp
  as select from zsvg_emp

  composition [0..*] of zsvg_i_proj as _proj

{
  key id                     as Id,

      fname                  as Fname,
      lname                  as Lname,
      dob                    as Dob,
      loc                    as Loc,

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

      _proj
}
