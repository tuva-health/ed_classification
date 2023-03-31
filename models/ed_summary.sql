-- Total conditions, encounters, claims, patients by ED classification

-- {{ config(enabled=var('ed_classification_enabled',var('tuva_packages_enabled',True))) }}

with summary as (
   select
     classification_order
     , classification_name
     , count(*) as condition_row_ct
     , count(distinct(encounter_id)) as encounter_ct
     , count(distinct(claim_id)) as claim_ct
     , count(distinct(patient_id)) as patient_ct
     , sum(claim_paid_amount_sum) as claim_paid_amount_sum
   from {{ ref('ed_classification__johnston_conditions_with_class') }}
   inner join {{ ref('ed_classification_categories') }} using(classification)
   group by 1,2
)

select
    summary.*
    , 100 * ratio_to_report(claim_ct) over() as pct_claim_row_ct
    , 100 * ratio_to_report(claim_paid_amount_sum) over() as pct_claim_paid_amount_sum
from summary
order by classification_order desc
