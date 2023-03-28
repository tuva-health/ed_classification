-- Staging model for the input layer:
-- stg_condition input layer model.
-- This contains one row for every unique primary discharge diagnosis in the dataset.


-- {{ config(enabled=var('ed_classification_enabled',var('tuva_packages_enabled',True))) }}

select
   cast(encounter_id as {{ dbt.type_string() }}) as encounter_id
   , cast(claim_id as {{ dbt.type_string() }}) as claim_id
   , cast(patient_id as {{ dbt.type_string() }}) as patient_id
   , cast(code_type as {{ dbt.type_string() }}) as code_type
   , cast(code as {{ dbt.type_string() }}) as code
   , cast(description as {{ dbt.type_string() }}) as description
from {{ var('condition') }}
where diagnosis_rank = 1
and condition_type = 'discharge_diagnosis'
