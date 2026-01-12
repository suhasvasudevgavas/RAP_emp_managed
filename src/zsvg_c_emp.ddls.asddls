@AccessControl.authorizationCheck: #NOT_REQUIRED

@EndUserText.label: 'Projection cds entity for emp'

@Metadata.allowExtensions: true
@Metadata.ignorePropagatedAnnotations: true

define root view entity zsvg_c_emp
  provider contract transactional_query
  as projection on zsvg_i_emp

{
  key     Id,

          Fname,
          Lname,
          Dob,

          @ObjectModel.virtualElementCalculatedBy: 'ABAP:ZCL_SVG_VE_AGE'
  virtual Age : abap.int1,

          Loc,
          State,
          CreatedBy,
          CreatedAt,
          LastchangedBy,
          LastchangedAt,
          LocinstLastchangedAt,
          _proj : redirected to composition child zsvg_c_proj
}
