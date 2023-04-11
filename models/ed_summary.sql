-- {{ config(enabled=var('ed_classification_enabled',var('tuva_packages_enabled',True))) }}

select
  classification_order
  , classification_name
  , ccs_description_with_covid
  , condition_date_year
  , condition_date_year_month
  , count(distinct(claim_id)) as claim_count
  , sum(claim_paid_amount_sum) as claim_paid_amount_sum

from {{ ref('ed_classification__johnston_conditions_with_class') }}
inner join {{ ref('ed_classification_categories') }} using(classification)
group by 1, 2, 3, 4, 5
