create schema project_2;
use	project_2;

-- looking at data from UNAID webiste and which contains data expenditure
select distinct * from UNAID_Data
limit 10;

-- country code and name - extracted to make a reference table for country codes
		-- this can then be used to get country name based on code

create table country_codes
select distinct Area, Area_ID from unaid_data;
select * from county_codes;

-- For the UNAID data which contains details on HIV expenditure per country,
		-- Extract data for the indicator field, 'HIV expenditure by key population', discard all other data
		-- indicator divided by population subgroup e.g. 'sex workers', 'drug users'
		-- to calculate population level expenditure, add the totals for each subgroup, for each country 

create temporary table HIV_expenditure
select * from Unaid_data
where indicator = 'HIV expenditure by key population';

-- sum the expenditure values of the different subgroups for each country/ year, giving 1 row per country and year

Create temporary table total_exp_cty_year;
select distinct area, area_ID, time_period as year, exp_K$ from
	(select area, area_id, time_period, sum(Data_value) as exp_K$ from HIV_expenditure
	where subgroup like '%Total%'
	group by area, area_id,  time_period) exp_total;

select * from exp_cty_year; -- check table created

-- cross expenditure table with number of cases

-- Now create new table with all years, nb-cases, nb-deaths, nb-facilities, expenditure
-- assumption made that the number of facilities does not change over the years 

create table composite; 
select 
	area, area_id, 
    exp.year, 
    exp_K$, 
    num.value as nb_cases, 
    mort.value as nb_deaths,
    fac.value as nb_fac_per_100k
from exp_cty_year exp
join number_ppl_with_hiv num
on area_id = num.country_code and exp.year = num.year
join mortality_hiv mort
on num.country_code = mort.country_code and mort.year = num.year
join facilities_hiv fac
on fac.country_code = num.country_code
where num.value <> '' and mort.value <> '';



-- table for year 2021

create table composite_2021
select distinct * from exp_nb_cas_death_fac
where year = 2021;


