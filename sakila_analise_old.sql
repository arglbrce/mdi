/* análise de granularidade */
use sakila;
select 'base table', count(*) from rental
union all
select 'fact table1', count(*) from (
select  r.rental_id as hash, date(rental_date) as rental_date, DATE_FORMAT(rental_date,  '%H') as rental_hour,  film_id, store_id, r.staff_id, r.customer_id, datediff(now(), rental_date) as age_rental,  datediff(now(), return_date) as age_return, sum(p.amount) as amount
from rental r left join inventory i
 on (r.inventory_id = i.inventory_id) 
left join payment p on (r.rental_id = p.rental_id) 
 group by r.rental_id , date(rental_date) , DATE_FORMAT(rental_date,  '%H'),  film_id, store_id, r.staff_id, r.customer_id, date(return_date)
 ) a
union all
select 'fact table2', count(*) from (
select distinct date(rental_date) as rental_date,  film_id, customer_id 
from rental r left join inventory i
 on (r.inventory_id = i.inventory_id)) a

/* *********************** */
/* análise de consistência */
select 'base table', sum(amount) from payment
union all
select 'fact table', sum(amount) from rental r left join payment p 
on (r.rental_id = p.rental_id)

/* pagamento extra por cliente */
select customer_id, sum(amount) extra_amount from payment where rental_id is null 
group by customer_id

/* pagamento sem aluguel */
select sum(amount) as extra_amont from payment where rental_id is null 

select customer_id, count(*) base_rateio
from rental where customer_id in 
( select customer_id from payment where rental_id is null )
group by customer_id

select rental_id, customer_id, 1 criterio_rateio
from rental where customer_id in 
( select customer_id from payment where rental_id is null )
group by rental_id, customer_id

/* *********************** */
 /* dimensões */
 /* customer */
 select customer_id, concat(first_name,' ', last_name) as name , city, country	
 from customer c left join address a on (c.address_id = a.address_id)
 left join city t on (a.city_id = t.city_id)
 left join country u on (u.country_id = t.country_id)
 
 /* store */
 select store_id, address from store s left join address a on (s.address_id = a.address_id)
 
 /* film */
 select f.film_id, title, category, actor from film f 
 left join (select film_id, GROUP_CONCAT(y.name) as category from film_category fm left join category y on (fm.category_id = y.category_id) group by film_id) c on (f.film_id = c.film_id)
 left join (select film_id,  GROUP_CONCAT(concat(first_name,' ', last_name)) as actor from film_actor fa left join actor t on (fa.actor_id = t.actor_id) group by film_id) a on  (f.film_id = a.film_id) 
  
 /* staff */
 select staff_id, concat(first_name,' ', last_name) as name  from staff
 
 /* date */
 select  distinct date(rental_date) from rental 
 
 /* hour */
 /* convert hora para inteiro (UNSIGNED) usando função CAST */
 select distinct cast( DATE_FORMAT(rental_date,  '%H') as unsigned ) as hour_id, 
	DATE_FORMAT(rental_date,  '%H') as hour from rental
 /* hour */
 /* convert hora para inteiro (UNSIGNED) usando função CONVERT */
select distinct convert( DATE_FORMAT(rental_date,  '%H') , unsigned ) as hour_id, 
	DATE_FORMAT(rental_date,  '%H') as hour from rental
 
/*
select 'fact table1', count(*) from (
select  distinct date(rental_date),
DATE_FORMAT(rental_date,  '%H') as rental_hour from rental ) fact
*/

