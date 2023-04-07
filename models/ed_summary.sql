/*
Total conditions, encounters, claims, patients, cost by ED classification
*/

-- {{ config(enabled=var('ed_classification_enabled',var('tuva_packages_enabled',True))) }}

with summary as (
   select
     classification_order
     , classification_name
     --, ccs_description_with_covid
     , count(*) as condition_row_count
     , count(distinct(encounter_id)) as encounter_count
     , count(distinct(claim_id)) as claim_count
     , count(distinct(patient_id)) as patient_count
     , sum(claim_paid_amount_sum) as claim_paid_amount_sum
   from {{ ref('ed_classification__johnston_conditions_with_class') }}
   inner join {{ ref('ed_classification_categories') }} using(classification)
   group by 1,2
)

select
    summary.*
    , 100 * ratio_to_report(claim_count) over() as percent_claim_row_count
    , 100 * ratio_to_report(claim_paid_amount_sum) over() as percent_claim_paid_amount_sum
from summary
order by classification_order asc
