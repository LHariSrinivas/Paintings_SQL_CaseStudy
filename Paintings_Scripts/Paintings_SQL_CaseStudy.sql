show databases;
use paintings;
show tables;

-- Solve the below SQL problems using the Famous Paintings & Museum dataset:

-- 1) Fetch all the paintings which are not displayed on any museums?
select distinct(name) as painting_name from work where museum_id is NULL;  
select distinct(work_id),artist_id, name, style from work where museum_id is NULL;  

-- 2) Are there museuems without any paintings?
select count(name) as museum_without_painting 
from work 
where museum_id is NOT NULL; #paintings without any museums

select * from museum where not exists (select museum_id from work where museum.museum_id = work.museum_id);
select * from museum left join work on museum.museum_id = work.museum_id where museum.museum_id is NULL; #museuems without any paintings

-- 3) How many paintings have an asking price of more than their regular price? 
select * from product_size where (sale_price > regular_price);

-- 4) Identify the paintings whose asking price is less than 50% of its regular price
select * from product_size where sale_price < (0.5*regular_price);

-- 5) Which canva size costs the most?
select (prod.sale_price), can.label as canvas_label from product_size as prod 
join canvas_size as can 
on prod.size_id = can.size_id
order by prod.sale_price desc, can.label limit 1;

#overcomplicated solution using window function
select cs.label as canva, ps.sale_price
	from (select *
		  , rank() over(order by sale_price desc) as rnk 
		  from product_size) ps
	join canvas_size cs on cs.size_id =ps.size_id
	where ps.rnk=1;

-- 6) Identify the museums with invalid city information in the given dataset

#use regular expressions since we are looking for an integer pattern in the city column
select name, city from museum where city regexp '^[0-9]'; 

-- 7) Fetch the top 10 most famous painting subject
select subject, count(subject) as famous_subject_count from subject
group by subject
having famous_subject_count >= 1
order by famous_subject_count DESC 
LIMIT 10;

-- 8) Identify the museums which are open on both Sunday and Monday. Display museum name, city.

SELECT DISTINCT m.name AS museum_name, m.city
FROM museum_hours mh
JOIN museum m ON m.museum_id = mh.museum_id
WHERE mh.day = 'Sunday'
  AND EXISTS (
    SELECT 1
    FROM museum_hours mh2
    WHERE mh2.museum_id = mh.museum_id
      AND mh2.day = 'Monday'
  );

-- 9) How many museums are open every single day?
select count(*) as museum_count from 
	(select museum_id, count(distinct(day)) as days 
    from museum_hours
	group by museum_id
	having days = 7) as open_daily;

-- 10) Which are the top 5 most popular museum? (Popularity is defined based on most no of paintings in a museum)
select museum_id, count(museum_id) from work 
group by museum_id
having count(museum_id) > 1
order by count(museum_id) DESC LIMIT 5;

-- 11) Who are the top 5 most popular artist? (Popularity is defined based on most no of paintings done by an artist)
select artist_id, count(artist_id) as artist_paintings from work
group by artist_id
having artist_paintings > 1
order by artist_paintings DESC LIMIT 5;

-- 12) Display the 3 least popular canva sizes

select cs.label, prod.size_id, count(prod.size_id) as size_count from product_size as prod 
join canvas_size as cs on prod.size_id = cs.size_id
where exists
	(select work.artist_id from product_size as prod join work on prod.work_id = work.work_id
	group by work.artist_id
	having count(work.artist_id) > 0
	order by count(work.artist_id) ASC LIMIT 3) 
group by prod.size_id, cs.label
having size_count >= 1
order by size_count ASC limit 3;

select cs.label, prod.size_id, count(prod.size_id) as size_count from product_size as prod 
join canvas_size as cs on prod.size_id = cs.size_id
where exists
	(select 1 from product_size as prod join work on prod.work_id = work.work_id
	group by work.artist_id
	having count(work.artist_id) > 0
	order by count(work.artist_id) ASC LIMIT 3) 
group by prod.size_id, cs.label
order by size_count ASC limit 3;

SELECT label, ranking, no_of_paintings
FROM (
    SELECT cs.size_id, cs.label, COUNT(1) AS no_of_paintings,
           DENSE_RANK() OVER (ORDER BY COUNT(1)) AS ranking
    FROM work w
    JOIN product_size ps ON ps.work_id = w.work_id
    JOIN canvas_size cs ON cs.size_id = CAST(ps.size_id AS CHAR)
    GROUP BY cs.size_id, cs.label
) x
WHERE x.ranking <= 3;

-- 13) Which museum is open for the longest during a day. Display museum name, state and hours open and which day?

select mus.name, mus.state, mh.day, 
max(timediff(
	str_to_date(close, '%h:%i:%p'), 
    str_to_date(open,'%h:%i:%p')
    )) as hours_open
from museum_hours as mh
join museum as mus on mh.museum_id = mus.museum_id
group by mus.name, mus.state, mh.day
order by hours_open DESC limit 1;

-- 14) Which museum has the most no of most popular painting style?
#popular painting style
select style, count(style) as popular_style from work
group by style
having count(style) >=1
order by count(style) DESC;

#museum which has the most popular style
select mus.name, mus.museum_id, work.style, count(work.style) as count_popular_style from museum mus
join work on mus.museum_id = work.museum_id
group by work.style, mus.name, mus.museum_id
having count(work.style) >=1
order by count(work.style) DESC limit 1;

-- 15) Identify the artists whose paintings are displayed in multiple countries

SELECT art.full_name, count(distinct(mus.country)) as no_of_countries,
GROUP_CONCAT(DISTINCT mus.country ORDER BY mus.country) AS displayed_countries
																				/*here group concat basically groups all the countries 
																				according to the given condition 
																				and returns the result with comma as the delimiter*/
FROM artist AS art
JOIN work ON art.artist_id = work.artist_id
JOIN museum mus ON work.museum_id = mus.museum_id
GROUP BY art.full_name
HAVING COUNT(DISTINCT mus.country) > 1
order by no_of_countries DESC;

-- 16) Display the country and the city with most no of museums. Output 2 seperate columns to mention the city and country. If there are multiple value, seperate them with comma.

select mus.museum_id, mus.country, mus.city, count(mus.museum_id) as museum_count from museum mus
join work on mus.museum_id = work.museum_id
group by mus.museum_id, mus.country, mus.city
order by museum_count DESC LIMIT 1;

-- 17) Identify the artist and the museum where the most expensive and least expensive painting is placed. Display the artist name, sale_price, painting name, museum name, museum city and canvas label

select * from product_size;
select * from artist;
select * from work;
select * from museum;
(select art.full_name, work.name, ps.sale_price, mus.name, mus.city from product_size as ps
join work on ps.work_id = work.work_id
join artist as art on art.artist_id = work.artist_id
join museum as mus on mus.museum_id = work.museum_id
order by ps.sale_price DESC LIMIT 1)
UNION ALL
(select art.full_name, work.name, ps.sale_price, mus.name, mus.city from product_size as ps
join work on ps.work_id = work.work_id
join artist as art on art.artist_id = work.artist_id
join museum as mus on mus.museum_id = work.museum_id
order by ps.sale_price ASC LIMIT 1);

WITH RankedPaintings AS (
    SELECT
        art.full_name as artist_name,
        ps.sale_price as sale_price,
        work.name as painting_name,
        mus.name as museum_name,
        mus.city as city,
        ROW_NUMBER() OVER (ORDER BY ps.sale_price DESC) AS DescRank,
        ROW_NUMBER() OVER (ORDER BY ps.sale_price ASC) AS AscRank
    FROM artist art
    JOIN work ON art.artist_id = work.artist_id
    JOIN product_size ps ON w.work_id = ps.work_id
    JOIN museum m ON w.museum_id = m.museum_id
)
SELECT
    artist_name, sale_price, painting_name, museum_name, city
FROM
    RankedPaintings
WHERE
    DescRank = 1 OR AscRank = 1;

-- 18) Which country has the 5th highest no of paintings?



-- 19) Which are the 3 most popular and 3 least popular painting styles?
#operating independently
(select style, count(style) as popular_style from work
where style is not null
group by style
order by count(style) ASC limit 3)
union all
(select style, count(style) as popular_style from work
where style is not null
group by style
order by count(style) DESC limit 3);

#using rank window function
(Select style, count(style), rank() over(order by count(style) DESC) as 'rank', 'Most Popular' as remarks from work
where style is not null 
group by style
having count(style) > 0
order by count(style) DESC
LIMIT 3)
union all
(Select style, count(style), rank() over(order by count(style) ASC) as 'rank', 'Least Popular' as remarks from work
where style is not null 
group by style
having count(style) > 0
order by count(style) ASC
LIMIT 3);

-- 20) Which artist has the most no of Portraits paintings outside USA?. Display artist name, no of paintings and the artist nationality.

SELECT art.artist_id, art.full_name, count(work.work_id) as no_of_paintings_outside_USA, art.nationality
FROM artist AS art
JOIN work ON art.artist_id = work.artist_id
JOIN museum mus ON work.museum_id = mus.museum_id
where mus.country NOT LIKE "USA"
GROUP BY art.artist_id, art.full_name, art.nationality
order by no_of_paintings_outside_USA DESC;