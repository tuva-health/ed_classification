/*
Filter conditions to those that were classified and pick the classification
with the greatest probability (that's the greatest logic). This logic removes
any rows that were not classified.
*/

{{ config(enabled=var('ed_classification_enabled',var('tuva_packages_enabled',True))) }}

select
   a.encounter_id
   , a.claim_id
   , a.patient_id
   , a.code_type
   , a.code
   , a.description
   , a.ccs_description_with_covid
   , a.condition_date
   , cast({{ dbt_date.date_part("year", "condition_date") }} as {{ dbt.type_string() }}) as condition_date_year
   , cast({{ dbt_date.date_part("year", "condition_date") }} as {{ dbt.type_string() }})
     || lpad(cast({{ dbt_date.date_part("month", "condition_date") }} as {{ dbt.type_string() }}), 2, '0')
     as condition_date_year_month
   , a.claim_paid_amount_sum
   , case greatest(edcnnpa, edcnpa, epct, noner, injury, psych, alcohol, drug)
          when edcnnpa then 'edcnnpa'
          when edcnpa then 'edcnpa'
          when epct then 'epct'
          when noner then 'noner'
          when injury then 'injury'
          when psych then 'psych'
          when alcohol then 'alcohol'
          when drug then 'drug'
          else 'unclassified'
   end as classification
from {{ ref('ed_classified_condition') }} a
where ed_classification_capture = 1
