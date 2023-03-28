-- This selects all the icd9 and icd10 codes from the johnston seed files
-- and merges them onto a set of primary discharge diagnoses
-- ED classification columns are listed once as a variable because
-- they are used in selection multiple times

-- {{ config(enabled=var('ed_classification_enabled',var('tuva_packages_enabled',True))) }}

{% set colnames = ["edcnnpa", "edcnpa", "epct", "noner", "injury", "psych", "alcohol", "drug"] %}

with condition as (
  select * from {{ ref('ed_classification__stg_condition') }}
)
, icd9 as (
  select
     icd9 as code
     {% for colname in colnames %}
     , {{colname}}
     {% endfor %}
  from {{ ref('johnston_icd9') }}
)
, icd10 as (
  select
     icd10 as code
     {% for colname in colnames %}
     , {{colname}}
     {% endfor %}
  from {{ ref('johnston_icd10') }}
)

select
   a.*
   {% for colname in colnames %}
   , icd.{{colname}}
   {% endfor %}
from condition a
inner join icd10 icd
on a.code = icd.code and a.code_type = 'icd-10-cm'
   union all
select
   a.*
   {% for colname in colnames %}
   , icd.{{colname}}
   {% endfor %}
from condition a
inner join icd9 icd
on a.code = icd.code and a.code_type = 'icd-9-cm'
