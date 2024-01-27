CREATE DATABASE MUSIC_STORE_ANALYSIS

SELECT * FROM ALBUM;
SELECT * FROM ARTIST;
SELECT * FROM CUSTOMER;
SELECT * FROM EMPLOYEE;
SELECT * FROM GENRE;
SELECT * FROM INVOICE;
SELECT * FROM INVOICE_LINE;
SELECT * FROM MEDIA_TYPE;
SELECT * FROM PLAYLIST;
SELECT * FROM PLAYLIST_TRACK;
SELECT * FROM TRACK;

--Q1. Who is the senior most employee based on jon title ?
SELECT TOP 1 * FROM EMPLOYEE
ORDER BY LEVELS DESC;

--Q2. Which countries have the most Invoices?
SELECT COUNT(BILLING_COUNTRY) AS MAX_INVOICE , BILLING_COUNTRY FROM INVOICE
GROUP BY BILLING_COUNTRY
ORDER BY MAX_INVOICE DESC;

--Q3. What are the top 3 values of total invoices?
SELECT TOP 3 TOTAL FROM INVOICE
ORDER BY TOTAL DESC;

/*4. Which city has the best customers? We would like to throw a promotional music festival in the city we made the mst money.
 Write a query that returns one city that has the highest sum of invoice totals. Returns both the city name & sum of all invoice totals?*/
 SELECT BILLING_CITY , SUM(TOTAL) AS INVOICE_TOTALS
 FROM INVOICE 
 GROUP BY BILLING_CITY
 ORDER BY INVOICE_TOTALS DESC;

 /*5. Who is the best Customer? The customer who has spent the most money will be declared the best customer.
      Write a query that returns the person who has spent the most money?*/

SELECT TOP 1 C.CUSTOMER_ID,C.FIRST_NAME,C.LAST_NAME,SUM(TOTAL) AS TOTAL_SPENT
FROM CUSTOMER AS C
JOIN
INVOICE AS I
ON C.CUSTOMER_ID = I.CUSTOMER_ID
GROUP BY C.CUSTOMER_ID,C.FIRST_NAME,C.LAST_NAME
ORDER BY TOTAL_SPENT DESC;

/* Q6. Write query to return the email,first name, last name & Genre of all rock music listeners.
Return your list ordered alphabetically by email starting with A?*/
SELECT DISTINCT EMAIL,FIRST_NAME,LAST_NAME
FROM CUSTOMER AS C1
JOIN
INVOICE AS I1
ON C1.customer_id = I1.customer_id
JOIN
invoice_line AS IL1
ON I1.invoice_id = IL1.invoice_id
WHERE TRACK_ID IN (SELECT TRACK_ID FROM TRACK AS T1			
					JOIN GENRE AS G1
					ON T1.genre_id = G1.genre_id
					WHERE G1.NAME LIKE 'Rock'
)
ORDER BY EMAIL;

/* Q7. Let's invite the artist who have written the most rock music in our dataset.
Write a query that returns the artist name and total track count of the top 10 rock bands? */
SELECT TOP 10 A.ARTIST_ID, A.NAME, COUNT(A.ARTIST_ID) AS COUNT_OF_SONGS
FROM TRACK AS T1
JOIN ALBUM AS A1
ON T1.album_id  = A1.album_id
JOIN ARTIST AS A
ON A1.artist_id = A.artist_id
JOIN GENRE AS G1
ON T1.genre_id = G1.genre_id
WHERE G1.NAME LIKE 'Rock'
GROUP BY A.ARTIST_ID, A.NAME
ORDER BY COUNT_OF_SONGS DESC

/* Q8. Return all the track names that have a song length longer than the average song length. Return the name and milliseconds for each track.
	Order by the song length with the longest songs listed first?*/
SELECT NAME,milliseconds
FROM TRACK
WHERE milliseconds > (
	SELECT AVG(MILLISECONDS) AS AVG_TRACK_LENGTH
	FROM TRACK)
ORDER BY milliseconds DESC;

--Q9. Find how much amount spent by each other on artists? Write a query to return customer name, artist name and total spent?
WITH BEST_SELLING_ARTIST AS(
SELECT TOP 1 A.ARTIST_ID AS ARTIST_ID , A.NAME AS ARTIST_NAME, SUM(IL.UNIT_PRICE*IL.QUANTITY) AS TOTAL_SALES
FROM INVOICE_LINE AS IL
JOIN TRACK AS T ON T.TRACK_ID = IL.TRACK_ID
JOIN ALBUM AS AL ON AL.ALBUM_ID = T.ALBUM_ID
JOIN ARTIST AS A ON A.ARTIST_ID = AL.ARTIST_ID
GROUP BY A.ARTIST_ID, A.NAME
ORDER BY TOTAL_SALES DESC
)
SELECT C.CUSTOMER_ID, C.FIRST_NAME, C.LAST_NAME, BSA.ARTIST_NAME, SUM(IL.UNIT_PRICE*IL.QUANTITY) AS AMOUNT_SPENT
FROM INVOICE AS I
JOIN CUSTOMER AS C ON C.CUSTOMER_ID = I.CUSTOMER_ID
JOIN INVOICE_LINE AS IL ON IL.INVOICE_ID = I.INVOICE_ID
JOIN TRACK AS T ON T.TRACK_ID = IL.TRACK_ID
JOIN ALBUM AS ALB ON ALB.ALBUM_ID = T.ALBUM_ID
JOIN BEST_SELLING_ARTIST AS BSA ON BSA.ARTIST_ID = ALB.ARTIST_ID
GROUP BY C.CUSTOMER_ID, C.FIRST_NAME, C.LAST_NAME, BSA.ARTIST_NAME
ORDER BY AMOUNT_SPENT DESC;

/* Q10 We want to find out the most popular music genre for each country. We determine the most popular genre as the genre with the highest amount
	of purchases. Write a query that returns each country along with the top Genre. For countries where the maximum number of 
	purchases is shared returns all Genres? */

WITH POPULAR_GENRE AS 
(
	SELECT COUNT(IL.QUANTITY) AS PURCHASES, C.COUNTRY, G.NAME, G.GENRE_ID,
	ROW_NUMBER() OVER(PARTITION BY C.COUNTRY ORDER BY COUNT(IL.QUANTITY) DESC) AS ROW_NUM
	FROM INVOICE_LINE AS IL
	JOIN INVOICE AS I ON I.INVOICE_ID = IL.invoice_id
	JOIN customer AS C ON C.customer_id = I.customer_id
	JOIN TRACK AS T ON T.TRACK_ID = IL.TRACK_ID
	JOIN GENRE AS G ON G.genre_id = T.genre_id
	GROUP BY C.COUNTRY, G.NAME, G.GENRE_ID
)
SELECT * FROM POPULAR_GENRE WHERE ROW_NUM <= 1

/* Q11 Write a query that determines the customer that has spent the most on music for each country. Write a query that returns the country along
	with the top customer and how much they spent. For countries where the top amount spent is shared, provide all customers who spent this amount?*/

WITH CUSTOMER_WITH_COUNTRY AS (
		SELECT C.CUSTOMER_ID,FIRST_NAME,LAST_NAME,BILLING_COUNTRY, SUM(TOTAL) AS TOTAL_SPENDING,
		ROW_NUMBER() OVER (PARTITION BY BILLING_COUNTRY ORDER BY SUM(TOTAL) DESC) AS ROW_NUM
		FROM INVOICE AS I 
		JOIN CUSTOMER AS C ON C.customer_id = I.customer_id
		GROUP BY C.CUSTOMER_ID,FIRST_NAME,LAST_NAME,BILLING_COUNTRY
	)
SELECT * FROM CUSTOMER_WITH_COUNTRY WHERE ROW_NUM <= 1

