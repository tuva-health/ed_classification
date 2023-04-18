/*
Staging model for the input layer:
This contains one row for every unique primary discharge diagnosis in the dataset.
This is also filtered to ED claims.
*/

{{ config(enabled=var('ed_classification_enabled',var('tuva_packages_enabled',True))) }}

with ed_claims as (
  select
    claim_id
    , sum(paid_amount) as claim_paid_amount_sum
  from {{ var('medical_claim') }}
  where (place_of_service_code = '23' or revenue_center_code in ('0450', '0451', '0452', '0456', '0459', '0981'))
  and (encounter_type <> 'acute inpatient' or encounter_type is null)
  group by claim_id
)

select
   cast(encounter_id as {{ dbt.type_string() }}) as encounter_id
   , cast(claim_id as {{ dbt.type_string() }}) as claim_id
   , cast(patient_id as {{ dbt.type_string() }}) as patient_id
   , cast(code_type as {{ dbt.type_string() }}) as code_type
   , cast(code as {{ dbt.type_string() }}) as code
   , cast(condition.description as {{ dbt.type_string() }}) as description
   , cast(case
            when lower(condition.description) like '%covid%'
            then condition.description
            else mapping.ccs_description
           end
          as {{ dbt.type_string() }}) as ccs_description_with_covid
   , condition_date
   , cast(claim_paid_amount_sum as {{ dbt.type_float() }}) as claim_paid_amount_sum
from {{ var('condition') }} condition
inner join ed_claims using(claim_id)
left join {{ var('terminology_icd_10_cm_to_ccs_mapping') }} mapping on condition.code = mapping.icd_10_cm
where diagnosis_rank = 1
