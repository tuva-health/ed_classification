/*
Denormalized view of each condition row with additional provider and patient level
information merged on based on the header level detail on the claim
*/


select
  c.claim_id
  , c.patient_id
  , c.condition_date
  , c.code
  , c.description
  , c.ccs_description_with_covid
  , c.condition_date_year
  , c.condition_date_year_month
  , c.claim_paid_amount_sum
  , c.classification
  -- claim level additions
  , mc.service_category_1
  , mc.service_category_2
  -- provider level additions
  , coalesce(fp.parent_organization_name, bp.parent_organization_name, fp.provider_name, bp.provider_name) as provider_parent_organization_name_with_provider_name
  , coalesce(fp.provider_name, bp.provider_name) as provider_name
  , coalesce(fp.parent_organization_name, bp.parent_organization_name) as provider_parent_organization_name
  , coalesce(fp.practice_state, bp.practice_state) as provider_practice_state
  , coalesce(fp.practice_zip_code, bp.practice_zip_code) as provider_practice_zip_code
  -- patient level additions
  , p.gender as patient_gender
  , p.birth_date as patient_birth_date
  , {{ dbt_date.periods_since('patient_birth_date', period_name='year') }} as patient_age
  , p.race as patient_race
  , p.state as patient_state

from {{ ref('ed_classified_condition_with_class') }} c
inner join {{ var('medical_claim') }} mc
      on c.claim_id = mc.claim_id
      and c.condition_date = mc.claim_line_end_date
      and mc.claim_line_number = 1
left join {{ var('provider') }} fp on mc.facility_npi = fp.npi and fp.deactivation_flag = 0
left join {{ var('provider') }} bp on mc.billing_npi = bp.npi and bp.deactivation_flag = 0
left join {{ var('patient') }} p on mc.patient_id = p.patient_id
