Q1: Who is the senior most employee based on job title?

select [employee_id],[title],([first_name]+''+[last_name]) as full_name ,max([reports_to]) as N_reportto

from [dbo].[employee]

group by  [employee_id],[title],([first_name]+''+[last_name])

order by max([reports_to])  desc

========================================================================
Q2: Write a query that returns one city that has the highest sum of invoice totals.

select top 1 [city], sum([total]) as invoice_totals

from [dbo].[customer] c join [dbo].[invoice] i
on c.[customer_id] = i.[customer_id]

group by [city]

order by sum([total])  desc

========================================================================
Q3: Who is the best customer? The customer who has spent the most money will be declared the best customer.
Write a query that returns the person who has spent the most money.

select c.[customer_id],([first_name]+''+[last_name]) as full_name, sum([total]) as invoice_totals, count ([invoice_id]) as Num_invoices

from [dbo].[customer] c join [dbo].[invoice] i
on c.[customer_id] = i.[customer_id]

group by c.[customer_id],([first_name]+''+[last_name])

order by sum([total]) desc ,count ([invoice_id])  desc

========================================================================
Q4:  Return all the track names that have a song length longer than the average song length. 
Return the Name and Milliseconds for each track. Order by the song length with the longest songs listed first.

select [name],[milliseconds] 

from [dbo].[track]

where    [milliseconds] > (SELECT AVG([milliseconds]) FROM [dbo].[track])

order by [milliseconds]  desc

========================================================================
Q5: Create a Stored Procedure which take Artist name to show you important KPIs about the artist like number of Albums/ no  of fans / total revenue.

CREATE PROCEDURE Artist_name_KPIs
	@ArtistName varchar(255)
AS
BEGIN
    SELECT 
        ar.name AS ArtistName, COUNT(DISTINCT al.album_id) AS NumberOfAlbums
    FROM 
        artist ar JOIN album al 
		ON ar.artist_id = al.artist_id
    WHERE 
        ar.name = @ArtistName
    GROUP BY 
        ar.name;

    SELECT 
        ar.name AS ArtistName, COUNT(DISTINCT i.customer_id) AS NumberOfFans
    FROM 
        artist ar JOIN  album al
		ON ar.artist_id = al.artist_id
    JOIN 
        track t ON al.album_id = t.album_id
    JOIN 
        invoice_line il ON t.track_id = il.track_id
    JOIN 
        invoice i ON il.invoice_id = i.invoice_id
    WHERE 
        ar.name = @ArtistName
    GROUP BY 
        ar.name;

    SELECT 
        ar.name AS ArtistName, SUM(il.unit_price * il.quantity) AS TotalRevenue
    FROM 
        artist ar JOIN album al 
	ON ar.artist_id = al.artist_id
    JOIN 
        track t ON al.album_id = t.album_id
    JOIN 
        invoice_line il ON t.track_id = il.track_id
    WHERE 
        ar.name = @ArtistName
    GROUP BY 
        ar.name;

END
GO

Exec Artist_name_KPIs @ArtistName = 'Billy Cobham'

========================================================================
Q1: We want to find out the most popular music Genre for each country. 
We determine the most popular genre as the genre with the highest amount of purchases. Write a query that returns each country along with the top Genre. 
For countries where the maximum number of purchases is shared return all Genres.

select [name], sum() as Total_purchases

from [dbo].[genre]

group by [name]


WITH GenreSales AS (
    SELECT 
        c.country,
        g.name AS genre,
        COUNT(il.invoice_line_id) AS purchase_count
    FROM 
        customer c
    JOIN 
        invoice i ON c.customer_id = i.customer_id
    JOIN 
        invoice_line il ON i.invoice_id = il.invoice_id
    JOIN 
        track t ON il.track_id = t.track_id
    JOIN 
        genre g ON t.genre_id = g.genre_id
    GROUP BY 
        c.country, g.name
),
RankedGenres AS (
    SELECT 
        country,
        genre,
        purchase_count,
        DENSE_RANK() OVER (PARTITION BY country ORDER BY purchase_count DESC) AS genre_rank
    FROM 
        GenreSales
)
SELECT 
    country,
    genre,
    purchase_count
FROM 
    RankedGenres
WHERE 
    genre_rank = 1
ORDER BY 
    country;
========================================================================
Write a query that determines the customer that has spent the most on music for each country.
Write a query that returns the country along with the top customer and how much they spent. 
For countries where the top amount spent is shared, provide all customers who spent this amount


WITH CustomerSpending AS (
    SELECT 
        c.country,
        c.customer_id,
        c.first_name,
        c.last_name,
        SUM(il.unit_price * il.quantity) AS total_spent
    FROM 
        customer c
    JOIN 
        invoice i ON c.customer_id = i.customer_id
    JOIN 
        invoice_line il ON i.invoice_id = il.invoice_id
    GROUP BY 
        c.country, c.customer_id, c.first_name, c.last_name
),
RankedCustomers AS (
    SELECT 
        country,
        customer_id,
        first_name,
        last_name,
        total_spent,
        DENSE_RANK() OVER (PARTITION BY country ORDER BY total_spent DESC) AS rank
    FROM 
        CustomerSpending
)
SELECT 
    country,
    first_name,
    last_name,
    total_spent
FROM 
    RankedCustomers
WHERE 
    rank = 1
ORDER BY 
    country;


	
