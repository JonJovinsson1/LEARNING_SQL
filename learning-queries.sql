-- Student Number(s):	10396563
-- Student Name(s):		Jon Sveinbjornsson

USE jjsveinAssesment2;

/*	Query 1 – Child Friendly Movies (2 marks)
	Write a query that selects the movie name, duration and classification of all movies that have a duration of up to 90 minutes and a classification of “G” or “PG”.
	Order the results by duration.
*/

-- Write Query 1 here

SELECT movie_name,duration_in_min,class
FROM movie
WHERE duration_in_min <= 90 AND (class = 'g' or class = 'pg')
ORDER BY duration_in_min asc


/*	Query 2 – Upcoming Standalone Movie Sessions (2 marks)
	Write a query that selects the movie name, session date and time, cinema type name and ticket price of all upcoming sessions (i.e. session date/time in the future) 
	showing movies that are not the sequel to any other movie and are not part of a franchise.  Order the results by session date/time.
*/

-- Write Query 2 here
SELECT movie_name,session_date_time,c_type_name,price
FROM (((movie
INNER JOIN session ON movie.movie_id = session.movie_id)
INNER JOIN cinema_rooms ON session.cin_room_id = cinema_rooms.cin_room_id)
INNER JOIN cinema_type ON cinema_type.cin_type_id = cinema_rooms.cin_type_id)
WHERE movie.sequel_id IS NULL
AND movie.franchise_ID IS NULL
AND CURRENT_TIMESTAMP < session.session_date_time 
ORDER BY session_date_time asc

--ADD MORE DATA TO PRODUCE MORE RESULTS



/*	Query 3 – Best Rated Movies (2 marks)
	Write a query that selects the movie ID number, movie name, release date, number of reviews, and average review rating (rounded to 1 decimal place) 
	of the top three movies (those with the highest average ratings).    
*/

-- Write Query 3 here

SELECT TOP 3 movie.movie_id,movie.movie_name,movie.release_date,COUNT(movie_review.rating)AS number_of_reviews,
	(select cast(round(avg(movie_review.rating),1)as float)) as rounded_average
FROM movie,movie_review
WHERE movie.movie_id = movie_review.movie_id 
GROUP BY movie.movie_id,movie.movie_name,movie.release_date 
ORDER BY rounded_average desc



/*	Query 4 – Long Movie Franchises (3 marks)
	Write a query that selects the franchise name and average movie duration (of movies in the franchise) of any franchises where the average duration 
	of movies in the franchise is longer than the average duration of all movies in the database.  Use a subquery to determine average duration of all movies.
*/
-- Write Query 4 here

SELECT franchise_name,AVG(duration_in_min) AS fran_av
FROM franchise INNER JOIN movie ON franchise.franchise_ID = movie.franchise_ID
GROUP BY franchise_name
HAVING AVG(duration_in_min) > (SELECT AVG(duration_in_min) FROM movie) 

--franchise averages = Alien 265, Marvel 117, American Pie = 109
--all movie average = 119


/*	Query 5 – Franchise Movie Descriptions (3 marks)
	Write a query that selects the information about movies that are part of a franchise and concatenates it into a column with an alias of “movie_description”.
	If the movie is not a sequel of another movie: 
	  “[movie name] ([release year]) is part of the [franchise name] franchise.”

	If the movie is a sequel of another movie:
	  “[movie name] ([release year]) is the sequel to [prior movie’s name] ([prior movie’s release year]) and is part of the [franchise name] franchise.”

	Order the results by franchise ID and release date, and be sure to include all movies that are part of a franchise even if they’re not the sequel of another movie.
	Remember to only include the release year.
*/
-- Write Query 5 here

SELECT IIF(movie1.sequel_id IS NULL,
		   CONCAT(movie1.movie_name,' (',movie1.release_date,') is part of the ',franchise.franchise_name,' franchise.'),
		   CONCAT(movie1.movie_name,' (',movie1.release_date,') is the sequel to ',sequel1.movie_name,' (',sequel1.release_date,') and is part of the ',franchise.franchise_name,' franchise')) 
		   AS movie_description
FROM ((movie movie1
LEFT JOIN movie sequel1 ON movie1.sequel_id = sequel1.movie_id)
INNER JOIN franchise ON movie1.franchise_ID = franchise.franchise_ID)
WHERE movie1.franchise_ID IS NOT NULL
ORDER BY franchise.franchise_ID,movie1.release_date,sequel1.release_date
--the order by column did not make an impact on the original query, is that because I dont have enough data?

/*	Query 6 – Underage Ticket Sales (3 marks)
	Write a query that that selects the full name (by concatenating their first name and last name) and date of birth of customers, as well as the movie name and minimum age 
	(of the movie’s classification) of any instances where a customer has purchased a ticket to an upcoming session screening a movie that they will be too young to watch.  
	Calculate the customer’s age at the time of the session when determining if they will be too young to watch the movie.  Eliminate any duplicates from the results.

*/
-- Write Query 6 here

SELECT CONCAT(Customer.first_name,' ',Customer.last_name) AS full_name, customer.birthday,movie.movie_name,classification.min_age
FROM ((((Customer
INNER JOIN ticket ON ticket.customer_ID = Customer.customer_ID)
LEFT JOIN session ON session.session_id = ticket.session_id)
LEFT JOIN movie ON movie.movie_id = session.movie_id)
INNER JOIN classification ON movie.class = classification.class)
WHERE CURRENT_TIMESTAMP < session.session_date_time 
AND DATEDIFF(YEAR,Customer.birthday,session.session_date_time)<=classification.min_age 
GROUP BY Customer.first_name,customer.last_name,customer.birthday, movie.movie_name,classification.min_age
-- THE GROUP BY WORKED TO REMOVE A DUPLICATE OF ERICA HENDRIX BUT DOES NOT DELETE THE DATA.


/*	Query 7 – Session Sales Statistics (4 marks)
	Write a query that selects the movie name, session date/time, cinema and cinema type name concatenated together (as pictured) of all sessions,
	as well as the number of tickets sold to the session, the cinema’s seating capacity, and the percentage of filled seats 
	(using tickets sold and cinema capacity, as pictured – rounded to the nearest 
	whole number, and with “%” concatenated to the end).
	Order the results by session date/time and cinema name.
*/
-- Write Query 7 here

SELECT CONCAT(movie.movie_name,', ',session.session_date_time,', ',cinema_rooms.cin_room_name,', ',cinema_type.c_type_name) AS movie_info
,session.session_id,session.session_date_time,COALESCE(sum(quantity),0) as tickets_sold,cinema_rooms.seat_capacity,
CONCAT(COALESCE(ROUND(((sum(quantity)/cast(seat_capacity as float)))*100,0,0),0),'%') AS percent_of_filled_seats
FROM ((((session
INNER JOIN movie ON session.movie_id = movie.movie_id)
LEFT JOIN ticket ON session.session_id = ticket.session_id)
LEFT JOIN cinema_rooms ON session.cin_room_id = cinema_rooms.cin_room_id)
LEFT JOIN cinema_type ON cinema_type.cin_type_id = cinema_rooms.cin_type_id)
GROUP BY session.session_id,session.session_date_time,movie.movie_name,cinema_rooms.cin_room_name,cinema_type.c_type_name
,cinema_rooms.seat_capacity
ORDER BY session.session_date_time, cinema_rooms.cin_room_name



/*	Query 8 – Revenue Per Movie (4 marks)
	Write a query that selects the movie name, release year, number of tickets sold and total revenue of all movies.
	Only include sessions with a date/time in the past when calculating the ticket count and revenue.  
	Calculate total revenue by adding the prices of all tickets sold for each session, per movie.
	  e.g.  If a movie sold 2 tickets to a session with a ticket price of $15 and 4 tickets to a session with a ticket
	  price of $25, the total revenue (assuming no other sessions for that movie) would be $130.

	Movies that have never sold a ticket for any of their sessions (or have had no sessions) should be included in the 
	results with 0 in the tickets sold and total revenue columns.
	Order the results by total revenue, in descending order.
*/
-- Write Query 8 here

SELECT movie.movie_name,movie.release_date,COALESCE(query_8_helper.quantity_passed,0)AS num_tickets_sold,CONCAT('$',COALESCE(query_8_helper.revenue,0)) AS revenue
FROM movie LEFT JOIN query_8_helper 
ON movie.movie_name = query_8_helper.movie_name
GROUP BY movie.movie_name,movie.release_date,query_8_helper.quantity_passed,query_8_helper.revenue


/*	Query 9 – Customer Statistics (4 marks)
	X Write a query that that selects the customer ID and name of customers concatenated into “first name and last initial” format (e.g. “John S.”),
	X as well as how many reviews they have written, 
	X how many tickets they have purchased, 
	X how many different movies they have purchased tickets to see, 
	and the date of the first session they purchased a ticket to attend (based on session date/time).  

	Be sure to include all customers, even if they have not written any reviews or purchased any tickets.
	Order the results by the number of tickets purchased, in descending order .
*/

-- Write Query 9 here

SELECT Customer.customer_ID,CONCAT(Customer.first_name,' ',UPPER(LEFT(customer.last_name,1)),'.')AS customer_name,query9_review_count.movies_reviewed
,COALESCE(query9_ticket_count.tickets_purchased,0) AS tickets_purchased,COALESCE(query9_distinct_movies.movies_viewed,0) AS different_movies
,query9_early_movie.earliest_movie
FROM Customer 
LEFT JOIN query9_review_count ON Customer.customer_ID = query9_review_count.customer_id
LEFT JOIN query9_ticket_count ON Customer.customer_ID = query9_ticket_count.customer_id
LEFT JOIN query9_distinct_movies ON Customer.customer_ID = query9_distinct_movies.customer_id
LEFT JOIN query9_early_movie ON Customer.customer_ID = query9_early_movie.customer_id
ORDER BY query9_ticket_count.tickets_purchased desc



