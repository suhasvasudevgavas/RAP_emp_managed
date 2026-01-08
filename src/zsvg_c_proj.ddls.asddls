@AccessControl.authorizationCheck: #NOT_REQUIRED

@EndUserText.label: 'Projection cds entity for proj'

@Metadata.ignorePropagatedAnnotations: true

@Metadata.allowExtensions: true
define view entity zsvg_c_proj
  as projection on zsvg_i_proj

{
  key Id,
  key EmpId,

      Name,
      Loc,
      Alloc,
      StartDate,
      Active,
      EndDate,
      CreatedBy,
      CreatedAt,
      LastchangedBy,
      LastchangedAt,
      LocinstLastchangedAt,

      _emp : redirected to parent zsvg_c_emp
}
