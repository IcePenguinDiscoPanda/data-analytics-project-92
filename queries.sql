--запрос, который считает общее количество покупателей

select
    count(customer_id) as customers_count 
from customers c;


--топ 10 продавцов с наибольшей выручкой

select 
    concat(first_name, ' ',  last_name) as name, 
    count (s.sales_id) operations, 
    round(sum(p.price * s.quantity),0) income 
from employees e 
left join sales s 
on e.employee_id = s.sales_person_id 
join products p using (product_id)
group by concat(first_name, ' ',  last_name)
order by income desc
limit 10;


--продавцы со средней выручкой меньше общей средней

with interim_table as 
(
select
	concat(e.first_name, ' ', e.last_name) as name,
	round(avg(s.quantity * p.price),0) as average_income
from employees e 
left join sales s 
on e.employee_id = s.sales_person_id 
join products p using (product_id)
group by 1
),
total_avg_amount as
(
select avg(average_income) as total_avg_income
from interim_table
)
select name, average_income
from interim_table
where average_income < (select total_avg_income 
		        from total_avg_amount)
order by 2 asc;


--данные по выручке по каждому продавцу по дню недели

with sorted_by_day_id as (
select 
	concat(first_name, ' ',  last_name) as name, 
	to_char(sale_date, 'DAY') as weekday,
	to_char(sale_date, 'ID') as weekday_id,
	round(sum(p.price * s.quantity),0) as income
from employees e 
left join sales s 
on e.employee_id = s.sales_person_id 
join products p using (product_id)
group by concat(first_name, ' ',  last_name), to_char(sale_date, 'DAY'), to_char(sale_date, 'ID')
order by weekday_id, name
)
select 
	name, 
	weekday, 
	income 
from sorted_by_day_id;


--количество покупателей в разных возрастных группах

with age_category_count as
(
select
 CASE 
	 WHEN age between 16 and 25 THEN '16-25'
	 WHEN age between 26 and 40 THEN '26-40' 
	 WHEN age > 40 THEN '40+' 
	 ELSE 'не попали в целевую группу'
 END as age_category
from customers c
)
select 
	age_category,
	count(*) 
from age_category_count
group by age_category
order by age_category;


--количество покупателей и выручка по месяцам

select 
	to_char(s.sale_date, 'YYYY-MM') date,
	count(distinct s.customer_id) total_customers,
	sum(s.quantity * p.price) income
from sales s 
join products p using (product_id)
group by 1
order by 1;


--покупатели, первая покупка которых пришлась на акцию (цена 0)

with prom as 
(
select
	c.customer_id, 
	c.first_name || ' ' || c.last_name as customer,
	s.sale_date,
	e.first_name || ' ' || e.last_name as seller,
	p.price * s.quantity as amount,
	row_number () over (partition by c.first_name || ' ' || c.last_name) as rn
from sales s 
join products p using (product_id) 
join customers c using (customer_id)
join employees e on e.employee_id = s.sales_person_id 
order by 1, 3
)
select 
	customer, 
	sale_date, 
	seller
from prom 
where rn = 1 and amount = 0
order by customer_id;
