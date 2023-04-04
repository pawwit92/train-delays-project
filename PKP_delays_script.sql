-- Czyszczenie kolumny delay z znaków 'min'
update delays 
set delay = replace(delay, 'min', '')
where delay like '%min'

-- Zamiana 0 na null w kolumnie delay
update delays 
set delay = 0
where delay is null

-- Zamiana 'nie dotyczy' na null w kolumnie arrival
update delays 
set arrival = null
where arrival not like '%:%'

-- Czyszczenie danych odstających
update delays 
set delay = null
where delay 

-- średnie opóźnienie dla poszczególnych przewoźnikow
select 
case 
	when d.delay is null then 0
	else d.delay
end
from delays d
order by 1 desc

select
	d.carrier
	, round(avg(d.delay), 1) avg_delay
	, max(d.delay) max_delay
--	, mode(d.delay) within group (order by d.carrier)
from delays d
group by 1

select distinct
	d.carrier 
	, d.delay 
from delays d
where d.carrier ilike '%tr%'
order by 2 desc

-- Klasyfikacja opóźnień z podziałem na stacje i przewoźnika
select
	d.carrier
	, sum(case 
		when d.delay is null then 1
		else 0
	end) "delay = 0 "
	, sum(case 
		when d.delay between 1 and 5 then 1
		else 0
	end) "1 < delay < 5"
	, sum(case 
		when d.delay between 6 and 15 then 1
		else 0
	end)  "6 < delay < 15"
	, sum(case 
		when delay between 16 and 30 then 1
		else 0
	end) "16 < delay < 30"
	, sum(case
		when delay between 31 and 60 then 1
		else 0
	end) "31 < delay < 60"
	, sum(case
		when delay between 61 and 90 then 1
		else 0
	end) "61 < delay < 90"
	, sum(case
		when delay between 91 and 120 then 1
		else 0
	end) "91 < delay < 120"
	, sum(case
		when delay between 91 and 120 then 1
		else 0
	end) " delay > 120"
from delays d 
group by 1

select distinct
	d."name"
from delays d
--where d.carrier ilike 'arr%'
order by 1

update delays 
set delay = null
where d."connection" in (select
	d."connection"
from delays d
group by 1
having min(d.delay) = max(d.delay))

update delays 
set delay = null
where (
		select 
			case 
				when min(d.delay) = max(d.delay) and min(d.delay) = avg(d.delay) then 1
				else 0
			end
		from delays d
		group by d."connection") = 1


