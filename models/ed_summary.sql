-- {{ config(enabled=var('ed_classification_enabled',var('tuva_packages_enabled',True))) }}

select
  classification_order
  , classification_name
  , ccs_description_with_covid
  , condition_date_year
  , condition_date_year_month
  , provider_parent_organization_name_with_provider_name
  , provider_practice_state
  , provider_practice_zip_code
  , patient_gender
  , patient_race
  , patient_state
  , count(distinct(claim_id)) as claim_count
  , sum(claim_paid_amount_sum) as claim_paid_amount_sum

from {{ ref('ed_classified_condition_with_claim') }}
inner join {{ ref('ed_classification_categories') }} using(classification)
group by 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11
