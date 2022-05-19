-- Student Number(s):	10396563
-- Student Name(s):		Jon Sveinbjornsson

USE jjsveinAssesment2;
GO

-- Tip:  When writing a view, it is easiest to write the SELECT statement first, and only add the CREATE VIEW 
--statement to the beginning once you have confirmed that the SELECT statement is working correctly.

/*  Session View (2 marks)
    Create a view that selects the following details of all sessions:
    X  • The session ID number, session date and time, and ticket price of the session.
    X  • The movie ID number, movie name and classification of the movie (e.g. “PG”).
    X  • The cinema ID number, cinema name, seating capacity and cinema type name of the cinema.

    This requires multiple joins.
*/

-- Write your Session View here
GO
IF OBJECT_ID('session_view', 'V') IS NOT NULL
BEGIN
	PRINT 'session_view table exists - dropping.' 
    DROP VIEW session_view;	
END
GO --Reference - https://stackoverflow.com/questions/1306009/how-can-i-check-if-a-view-exists-in-a-database						

CREATE VIEW session_view AS
SELECT session_id, session_date_time,price,movie.movie_id,movie_name,class ,cinema_rooms.cin_room_id,cin_room_name,seat_capacity,c_type_name
FROM (((movie 
INNER JOIN session ON movie.movie_id = session.movie_id)
INNER JOIN cinema_rooms ON session.cin_room_id = cinema_rooms.cin_room_id)
INNER JOIN cinema_type ON cinema_type.cin_type_id = cinema_rooms.cin_type_id)
GO

/*  Movie View (3 marks)
    Create a view that selects the following details of all movies (use column aliases as appropriate):

     X • All of the columns in the movie table except for the plot summary/overview column.
     X • The classification abbreviation (e.g. “PG”) and classification’s minimum age column.
     X   • Depending on your implementation, the minimum age may show 0 or NULL for G, PG and M ratings.
     X • The ID and name of the movie’s franchise, or NULL if the movie is not part of a franchise.
     X • A column containing a comma-separated list of the movie’s genres, e.g. “Action, Adventure”.
     X   • This will involve grouping your results and using the STRING_AGG() function.

    This requires multiple joins, and outer join(s) will be needed to ensure that all movies are included.
*/

-- Write your Movie View here
GO
IF OBJECT_ID('movie_view', 'V') IS NOT NULL--Reference - https://stackoverflow.com/questions/1306009/how-can-i-check-if-a-view-exists-in-a-database	
BEGIN
	PRINT 'movie_view table exists - dropping.' 
    DROP VIEW movie_view;		
END
GO 	

CREATE VIEW movie_view AS
select movie.movie_id, movie_name,release_date,duration_in_min,movie.class,min_age,movie.franchise_id,franchise_name,sequel_id,
(SELECT STRING_AGG(genre_name,', ')) AS genres
FROM ((((movie
INNER JOIN classification ON movie.class = classification.class)
LEFT JOIN franchise ON movie.franchise_ID = franchise.franchise_ID)
INNER JOIN movie_genre ON movie.movie_id = movie_genre.movie_id) 
INNER JOIN genre ON genre.genre_ID = movie_genre.genre_ID)
GROUP BY movie.movie_id, movie_name,release_date,duration_in_min,movie.class,min_age,movie.franchise_id,franchise_name,sequel_id




GO
/*	If you wish to create additional views to use in the queries which follow, include them in this file. */
-------------------------------------HELP TABLES FOR QUERY 8--------------------------------------------------------------------
GO
IF OBJECT_ID('revenue_per_session_passed', 'V') IS NOT NULL
BEGIN
	PRINT 'revenue_per_session_passed table exists - dropping.' 
    DROP VIEW revenue_per_session_passed;
END
GO --Reference - https://stackoverflow.com/questions/1306009/how-can-i-check-if-a-view-exists-in-a-database		

CREATE VIEW revenue_per_session_passed AS
SELECT movie.movie_name,session.session_date_time,ticket.quantity AS passed_tickets,session.price,(ticket.quantity*session.price) AS revenue,ticket.customer_ID
from ((movie
LEFT JOIN session on movie.movie_id = session.movie_id)
LEFT JOIN ticket on ticket.session_id = session.session_id)
WHERE GETDATE() > SESSION.session_date_time
GROUP BY movie.movie_name,session.session_date_time,ticket.quantity,session.price,ticket.customer_ID

GO
-------------------------------------------ANOTHER HELP TABLE FOR QUERY 8--------------------------------------------------------


IF OBJECT_ID('query_8_helper', 'V') IS NOT NULL
BEGIN
	PRINT 'query_8_helper table exists - dropping.'
    DROP VIEW query_8_helper;	
END
GO --Reference - https://stackoverflow.com/questions/1306009/how-can-i-check-if-a-view-exists-in-a-database	

CREATE VIEW query_8_helper AS
SELECT SUM(revenue_per_session_passed.revenue)AS revenue,movie.movie_name,sum(revenue_per_session_passed.passed_tickets) as quantity_passed
FROM revenue_per_session_passed,movie
WHERE movie.movie_name = revenue_per_session_passed.movie_name
group by movie.movie_name

GO

------------------------------------------------------HELP TABLES FOR QUERY 9 ------------------------------------------------------
IF OBJECT_ID('query9_review_count', 'V') IS NOT NULL
BEGIN
	PRINT 'query9_review_count exists - dropping.'
    DROP VIEW query9_review_count;	
END
GO
CREATE VIEW query9_review_count AS
SELECT Customer.customer_ID,count(movie_review.customer_ID) AS movies_reviewed
FROM customer left join movie_review on movie_review.customer_ID = Customer.customer_ID
GROUP BY Customer.customer_ID
--ORDER BY movies_reviewed desc

GO

IF OBJECT_ID('query9_ticket_count', 'V') IS NOT NULL
BEGIN
	PRINT 'query9_ticket_count - dropping.'
    DROP VIEW query9_ticket_count;	
END
GO
CREATE VIEW query9_ticket_count AS
SELECT Customer.customer_ID,sum(ticket.quantity) AS tickets_purchased
FROM customer left join ticket on Customer.customer_ID = ticket.customer_ID
GROUP BY ticket.customer_ID,Customer.customer_ID
--ORDER BY tickets_purchased DESC
GO

--how many different movies they have purchased tickets to see, 
IF OBJECT_ID('query9_distinct_movies', 'V') IS NOT NULL
BEGIN
	PRINT 'query9_distinct_movies - dropping.'
    DROP VIEW query9_distinct_movies;	
END
GO
CREATE VIEW query9_distinct_movies AS
SELECT DISTINCT customer.customer_id,count(session.movie_id) AS movies_viewed
FROM ((Customer
INNER JOIN ticket ON Customer.customer_ID = ticket.customer_ID)
LEFT JOIN SESSION ON ticket.session_id = session.session_id)
GROUP BY Customer.customer_ID
GO



IF OBJECT_ID('query9_early_movie', 'V') IS NOT NULL
BEGIN
	PRINT 'query9_early_movie - dropping.'
    DROP VIEW query9_early_movie;	
END
GO
CREATE VIEW query9_early_movie AS
SELECT Customer.customer_ID,min(session.session_date_time) AS earliest_movie
FROM ((Customer
INNER JOIN ticket ON Customer.customer_ID = ticket.customer_ID)
LEFT JOIN SESSION ON ticket.session_id = session.session_id)
GROUP BY Customer.customer_ID






