/*
Highlights any lack of alignment between the ED records being used
for ED classification and the service category fields.
*/

select
   service_category_1
   , service_category_2
   , count(*) as condition_count

from {{ ref('ed_classified_condition_with_claim') }}
group by 1, 2
order by count(*) desc
