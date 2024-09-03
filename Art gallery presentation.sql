select *
from artist;

select *
from canvas_size;

select *
from image_link;

select *
from museum;

select *
from museum_hours;

select *
from product_size;

select *
from subject;

select *
from work;
-- 1. Identify the artists whose artworks are displayed in multiple countries.---------
select art.full_name, art.artist_id,
count(distinct mus.country) as country_count
from artist as art
inner join work as wk on art.artist_id = wk.artist_id
inner join museum as mus on wk.museum_id = mus.museum_id
group by art.artist_id, art.full_name
having count(distinct mus.country) > 1;

-- 2. Retrieve the top 10 most popular themes of artwork-----------
select sub.subject,
count(sub.work_id) as subject_count
from subject as sub 
group by sub.subject
order by subject_count desc
limit 10;

-- 3. Identify the artworks with a selling price less than half of their listed price.----------
select ps.work_id, ps.size_id, ps.sale_price, ps.regular_price
from product_size as ps
where ps.sale_price < 0.5 * ps.regular_price;

-- 4. Remove duplicate entries from the artwork, product_dimensions, theme, and image tables. ----------
delete wk1
from work as wk1
inner join work as wk2
on wk1.work_id > wk2.work_id
and wk1.name = wk2.name
and wk1.artist_id = wk2.artist_id
and wk1.style = wk2.style
and wk1.museum_id = wk2.museum_id;

-- 5. Identify the galleries open on both Saturday and Sunday. Display gallery name and city.-----------
select mus.name as gallery_name, mus.city
from museum as mus
inner join museum_hours as muh_sat on mus.museum_id = muh_sat.museum_id
inner join museum_hours as muh_sun on mus.museum_id = muh_sun.museum_id
where muh_sat.day = 'Saturday' and muh_sat.open is not null and muh_sat.close is not null
and muh_sun.day = 'Sunday' and muh_sun.open is not null and muh_sun.close is not null;

-- 6. How many galleries are open every day of the week?----------
select day, count(name) as single_daily_count
from museum as mus
join museum_hours as muh on mus.museum_id = muh.museum_id
group by day
order by single_daily_count;

-- 7. Which canvas size has the highest cost?--------------
select cas.size_id, cas.width, cas.height, cas.label, 
max(prds.regular_price) as highest_price
from canvas_size as cas
inner join product_size as prds on cas.size_id = prds.size_id
group by cas.size_id, cas.width, cas.height, cas.label
order by highest_price desc
limit 1;

-- 8. Are there any galleries that do not have any artworks on display?-----------
SELECT 
    mus.museum_id, mus.name AS gallery_name, mus.city
FROM
    museum AS mus
        LEFT JOIN
    work AS wk ON mus.museum_id = wk.museum_id
WHERE
    wk.museum_id IS NULL;

-- 9. Identify the galleries with incorrect city information in the dataset.---------
-- Assuming the incorrect city information are those that are empty or null-------
select mus.museum_id, mus.name as gallery_name, mus.city
from museum as mus
where mus.city is null or mus.city not like '(a-z)%';

-- 10. Which gallery has the highest number of artworks in the most popular style?-------

select mus.name, wk.style, count(wk.style) as popular_painting_style
from work as wk
join museum as mus on wk.museum_id = mus.museum_id
group by mus.name, wk.style
order by popular_painting_style desc
limit 1;


-- 11. Which are the top 5 most visited galleries? (Popularity is based on the number of artworks displayed in a gallery)--------------
select mus.museum_id, mus.name as gallery_name, mus.city, 
count(wk.work_id) as artwork_count
from museum as mus
inner join work as wk on mus.museum_id = wk.museum_id
group by mus.museum_id, mus.name, mus.city
order by artwork_count desc
limit 5;

-- 12. How many artworks have a selling price higher than their listed price-----------


-- 13. The Gallery_Hours table has one invalid entry. Identify and delete it--------
select muh.museum_id, muh.day, muh.open, muh.close
from museum_hours as muh
where muh.museum_id is null
or muh.day is null
or muh.open is null
or muh.close is null
or muh.day not in ('Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday','Sunday');

delete from museum_hours
where museum_id is null
or day is null
or open is null
or close is null
or day not in ('Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday');

-- 14. Display the 3 least common canvas sizes----------------
select cs.size_id, cs.width, cs.height, cs.label, count(prds.work_id) as usage_count
from canvas_size as cs
left join product_size as prds on cs.size_id = prds.size_id
group by cs.size_id, cs.width, cs.height, cs.label
order by usage_count asc
limit 3;

-- 15. Who are the top 5 most prolific artists? (Popularity is based on the number of artworks created by an artist)--
select art.artist_id, art.full_name, count(wk.work_id) as artwork_count
from artist as art
inner join work as wk on art.artist_id = wk.artist_id
group by art.artist_id, art.full_name
order by artwork_count desc
limit 5;

 -- 16. Which gallery is open the longest each day? Display gallery name, state, hours open, and which day.-----
 select mus.name as gallery_name, mus.state, muh.day,
 timestampdiff(hour, muh.open, muh.close) as hours_open
 from museum as mus
 inner join museum_hours as muh on mus.museum_id = muh.museum_id
 order by hours_open desc
 limit 1;
 
 -- 17. List all the artworks that are not currently exhibited in any galleries.---------
 select wk.work_id, wk.name as artwork_name, wk.artist_id, wk.style
 from work as wk
 left join museum as mus on wk.museum_id = mus.museum_id
 where wk.museum_id is null;
 
 -- 18. Which country has the fifth-highest number of artworks?----------
 select mus.country, count(wk.work_id) as artwork_count
 from work as wk
 inner join museum as mus on wk.museum_id = mus.museum_id
 group by mus.country
 order by artwork_count desc
 limit 1 offset 4;
 
 -- 19. Which are the 3 most popular and 3 least popular styles of artwork?-----------
				-- most popular------
 select wk.style, count(wk.work_id) as artwork_count 
 from work as wk
 group by wk.style
 order by artwork_count desc
 limit 3;
				-- least popular------
select wk.style, count(wk.work_id) as artwork_count 
 from work as wk
 group by wk.style
 order by artwork_count asc
 limit 3;
			-- Combining both------
 (select wk.style, count(wk.work_id) as artwork_count 
 from work as wk
 group by wk.style
 order by artwork_count desc
 limit 3)
 union
 (select wk.style, count(wk.work_id) as artwork_count 
 from work as wk
 group by wk.style
 order by artwork_count asc
 limit 3);
 
 
-- 20. Display the country and city with the highest number of galleries. Output two separate columns for 
-- city and country. If there are multiple values, separate them with commas--
select country, city, count(name) as max_no_of_museum
from museum
group by country, city having count(name) > 1
order by max_no_of_museum;

-- 21. Identify the artist and gallery with the highest and lowest priced artwork. Display artist name, sale 
-- price, artwork name, gallery name, gallery city, and canvas label.-----------
		-- For least expensive-----------
with artwork_prices as (select prds.work_id, prds.sale_price, wk.name as artwork_name,
art.full_name as artist_name, mus.name as gallery_name, mus.city as gallery_city,
cs.label as canvas_label
from product_size as prds
inner join work as wk on prds.work_id = wk.work_id
inner join artist as art on wk.artist_id = art.artist_id
inner join museum as mus on wk.museum_id = mus.museum_id
inner join canvas_size as cs on prds.size_id = cs.size_id)
select artist_name, sale_price, artwork_name, gallery_name, gallery_city, canvas_label
from artwork_prices 
where sale_price = (select min(sale_price)
from artwork_prices)
limit 1;
		-- For most expensive---------
with artwork_prices as (select prds.work_id, prds.sale_price, wk.name as artwork_name,
art.full_name as artist_name, mus.name as gallery_name, mus.city as gallery_city,
cs.label as canvas_label
from product_size as prds
inner join work as wk on prds.work_id = wk.work_id
inner join artist as art on wk.artist_id = art.artist_id
inner join museum as mus on wk.museum_id = mus.museum_id
inner join canvas_size as cs on prds.size_id = cs.size_id)
select artist_name, sale_price, artwork_name, gallery_name, gallery_city, canvas_label
from artwork_prices 
where sale_price = (select max(sale_price)
from artwork_prices);

-- Which artist has the most Portraits artworks outside the USA? Display artist name, number of 
-- artworks, and artist nationality----------
select art.full_name, count(wk.name) as highest_no_of_paintings, art.nationality
from work as wk
join artist as art on wk.artist_id = art.artist_id
group by art.full_name, art.nationality
order by highest_no_of_paintings desc
limit 1;