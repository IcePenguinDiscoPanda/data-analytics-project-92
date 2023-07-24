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

with total_average as 
(select round(sum(p.price * s.quantity)/count(s.sales_id),0) as total_average_income
from employees e 
left join sales s 
on e.employee_id = s.sales_person_id 
join products p using (product_id)
)

select 
	concat(first_name, ' ',  last_name) as name, 
	round(sum(p.price * s.quantity)/count(s.sales_id),0) as average_income
	from employees e 
left join sales s 
on e.employee_id = s.sales_person_id 
join products p using (product_id)
group by 1
having average_income < (select total_average_income from total_average)
order by 2;

