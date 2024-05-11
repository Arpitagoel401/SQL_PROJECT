select * from album
Q1 : Who is the senior most employee based on job title ?

select * from employee
order by levels desc
limit 1

Q2 : Which countries have the most invoices ?

select * from invoice

select count(*) as c,billing_country 
from invoice group by billing_country
order by c desc

Q3 : What are top 3 values of total invoice

select total from invoice
order by total desc
limit 3

Q4 : Which city has the best customers ? We would like to throw a promotional Music 
Festival in the city we made the most money.Write a query that returns one city that
has the highest sum of invoice totals. Return both the city name and sum of all the
invoice totals

select SUM(total) as invoice_total ,billing_city
from invoice group by billing_city
order by invoice_total desc

Q5 : Who is the best customer ? The customer who has spent the most money will be 
declared the best customer.Write a query that returns the person who has spent the
most money

select customer.customer_id,customer.first_name,customer.last_name ,
SUM(invoice.total) as total
from customer
join invoice on
customer.customer_id = invoice.customer_id
group by customer.customer_id
order by total desc
limit 1

-- Q6 : Write a query to return the email,first name,last name & genre of all Rock 
-- Music listeners. Return your list ordered alphabetically by email starting with A

select Distinct email,first_name,last_name 
From Customer
Join invoice on customer.customer_id = invoice.customer_id
Join invoice_line on invoice.invoice_id = invoice_line.invoice_id
where track_id IN(
SELECT track_id from track
join genre on track.genre_id = genre.genre_id
where genre.name Like 'Rock'
)
order by email;

--Lets invite the artists who have written the most rock music in our dataset .Write 
--a query that returns the Aritst name and total track count of the top 10 rock bands

select artist.artist_id,artist.name,COUNT(artist.artist_id) as 
number_of_songs from track
join album on album.album_id = track.album_id
join artist on artist.artist_id = album.artist_id
join genre on genre.genre_id = track.genre_id
where genre.name Like 'Rock'
group by artist.artist_id
order by number_of_songs desc
Limit 10;

-- Return all the track names that have a song length longer than the average song 
--lenth . Return the name and milliseconds for each track.Order by the song length 
-- with the longest songs listed first

select name,milliseconds
from track
where milliseconds > (
select Avg(milliseconds) as avg_track_length
from track
)
order by milliseconds desc;

-- Find how much amount spent by each customer on artists? Write a query to return 
-- customer name,artist name and total spent

With best_selling_artist As (
	select artist.artist_id As artist_id,artist.name As artist_name,
	SUM(invoice_line.unit_price*invoice_line.quantity)
	from invoice_line
	join track on track.track_id = invoice_line.track_id
	join album on album.album_id = track.album_id
	join artist on artist.artist_id = album.artist_id
	GROUP BY 1
	ORDER BY 3 desc
	Limit 1
	
)
select c.customer_id,c.first_name,c.last_name ,bsa.artist_name,
SUM(il.unit_price*il.quantity) AS amount_spent
from invoice i
join customer c on c.customer_id = i.customer_id
join invoice_line il on il.invoice_id = i.invoice_id
join track t on t.track_id = il.track_id
join album alb on alb.album_id = t.album_id
join best_selling_artist bsa on bsa.artist_id = alb.artist_id
group by 1,2,3,4
order by 5 desc;

-- We want to find out the most popular music genre for each country We determine 
--the most popular genre as the genre with the highest amount of purchases.Write a 
--query that returns each country along with the top genre . For countries where the
--maximum numnber of puchases is shared return all the genre

WITH popular_genre AS
(
	SELECT COUNT(invoice_line.quantity) AS purchases ,customer.country ,genre.name,
	genre.genre_id,ROW_NUMBER() over (partition by customer.country order by 
	COUNT(invoice_line.quantity) desc) as RowNo from invoice_line
	join invoice on invoice.invoice_id = invoice_line.invoice_id
	join customer on customer.customer_id = invoice.customer_id
	join track on track.track_id = invoice_line.track_id
	join genre on genre.genre_id = track.genre_id
	group by 2,3,4
	order by 2 asc,1 desc
)
select * from popular_genre where RowNo <=1

-- Method 2
WITH RECURSIVE
sales_per_country AS(
	select COUNT(*) AS purchases_per_genre ,customer.country ,genre.name,
	genre.genre_id from invoice_line
	join invoice on invoice.invoice_id = invoice_line.invoice_id
	join customer on customer.customer_id = invoice.customer_id
	join track on track.track_id = invoice_line.track_id
	join genre on genre.genre_id = track.genre_id
	group by 2,3,4
	order by 2 
),
	max_genre_per_country AS (select max(purchases_per_genre) AS max_genre_number,
	country from sales_per_country
	group by 2
	order by 2)
	
select sales_per_country.*
from sales_per_country
join max_genre_per_country on sales_per_country.country = max_genre_per_country.country
where sales_per_country.purchases_per_genre = max_genre_per_country.max_genre_number


--Write a query that determines the customer that has spent the most on music for 
--each country .Write a query that returns the country along with the top customer 
--and how much they spent .For countries where the top amount spent is shared , 
--provide all customers who spent this amount

WITH RECURSIVE
	customer_with_country AS(
	select customer.customer_id,first_name,last_name,billing_country,SUM(total)
	as total_spending from invoice
	join customer on customer.customer_id = invoice.customer_id
	group by 1,2,3,4
	order by 2,3 desc),
	
	country_max_spending as(
	select billing_country,MAX(total_spending) as max_spending
	from customer_with_country
	group by billing_country)
	
select cc.billing_country,cc.total_spending,cc.first_name,cc.last_name
from customer_with_country cc
join country_max_spending ms
on cc.billing_country=ms.billing_country
where cc.total_spending = ms.max_spending
order by 1;

--Method 2
WITH Customer_with_country as(
	select customer.customer_id,first_name,last_name,billing_country,SUM(total)
	as total_spending ,row_number() over(partition by billing_country order by
	SUM(total) desc )as RowNo
	from invoice
	join customer on customer.customer_id = invoice.customer_id
	group by 1,2,3,4
	order by 4 asc,5 desc
)
select * from Customer_with_country where RowNo<=1;






