create database if not exists pandemic;
use pandemic;

select *
from infectious_cases
limit 20;

select count(*)
from infectious_cases;

describe infectious_cases;

create table entities (
	id int auto_increment primary key,
    entity varchar(255) not null,
    code varchar(10),
    unique (Entity, Code)
);

insert into entities (Entity, Code)
select distinct Entity, Code
from infectious_cases;

select *
from entities
limit 20;

create table infectious_cases_normalized (
	id int auto_increment primary key,
    entity_id int not null,
    year int,
    Number_yaws text,
    polio_cases int,
    cases_quinea_worm int,
    Number_rabies text,
    Number_malaria text,
    Number_hiv text,
    Number_tuberculosis text,
    Number_smallpox text,
    Number_cholera_cases text,
    foreign key (entity_id) references entities(id)
);

insert into infectious_cases_normalized (
    entity_id,
    Year,
    Number_yaws,
    polio_cases,
    cases_quinea_worm,
    Number_rabies,
    Number_malaria,
    Number_hiv,
    Number_tuberculosis,
    Number_smallpox,
    Number_cholera_cases
)
select
    e.id,
    i.Year,
    i.Number_yaws,
    i.polio_cases,
    i.cases_guinea_worm,
    i.Number_rabies,
    i.Number_malaria,
    i.Number_hiv,
    i.Number_tuberculosis,
    i.Number_smallpox,
    i.Number_cholera_cases
from infectious_cases as i
join entities as e
    on e.Entity = i.Entity
    and e.Code <=> i.Code;
    
select count(*) as normalized_rows
from infectious_cases_normalized;


select
    icn.id,
    e.Entity,
    e.Code,
    icn.Year,
    icn.Number_rabies,
    icn.Number_malaria
from infectious_cases_normalized as icn
join entities as e
    on icn.entity_id = e.id
limit 20;


select
    e.Entity,
    e.Code,
    avg(cast(icn.Number_rabies as decimal(10, 2))) as avg_rabies,
    min(cast(icn.Number_rabies as decimal(10, 2))) as min_rabies,
    max(cast(icn.Number_rabies as decimal(10, 2))) as max_rabies,
    sum(cast(icn.Number_rabies as decimal(10, 2))) as sum_rabies
from infectious_cases_normalized as icn
join entities as e
    on icn.entity_id = e.id
where icn.Number_rabies is not null
    and icn.Number_rabies <> ''
group by e.id, e.Entity, e.Code
order by avg_rabies desc
limit 10;

select
    Year,
    str_to_date(concat(Year, '-01-01'), '%Y-%m-%d') as year_date,
    curdate() as today_date,
    timestampdiff(
        year,
        str_to_date(concat(Year, '-01-01'), '%Y-%m-%d'),
        curdate()
    ) as year_difference
from infectious_cases_normalized
limit 20;

DELIMITER //

create function year_difference(input_year int)
returns int
deterministic
begin
    return timestampdiff(
        year,
        str_to_date(concat(input_year, '-01-01'), '%Y-%m-%d'),
        curdate()
    );
end //

DELIMITER ;

select
    Year,
    year_difference(Year) as year_difference
from infectious_cases_normalized
limit 20;