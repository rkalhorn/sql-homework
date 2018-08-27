USE sakila;


-- 1a. Display the first and last names of all actors from the table `actor`.
SELECT first_name, last_name
FROM actor;


-- 1b. Display the first and last name of each actor in a single column in upper case letters. Name the column `Actor Name`.
SELECT UPPER(CONCAT(first_name, " ", last_name)) AS 'Actor Name'
FROM actor;


-- 2a. You need to find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe." 
-- What is one query would you use to obtain this information?
SELECT actor_id, first_name, last_name
From actor 
WHERE first_name = 'Joe'; 


-- 2b. Find all actors whose last name contain the letters `GEN`:
SELECT * FROM actor
WHERE last_name LIKE '%gen%';


-- 2c. Find all actors whose last names contain the letters `LI`. 
-- This time, order the rows by last name and first name, in that order:
SELECT * FROM actor
WHERE last_name LIKE '%li%'
ORDER BY last_name, first_name;


-- 2d. Using `IN`, display the `country_id` and `country` columns of the following countries: 
-- Afghanistan, Bangladesh, and China:
SELECT country, country_id
FROM country
WHERE country IN ('Afghanistan', 'Bangladesh', 'China');


-- 3a. You want to keep a description of each actor. 
-- You don't think you will be performing queries on a description, so create a column in the table `actor` named `description` and 
-- use the data type `BLOB` (Make sure to research the type `BLOB`, as the difference between it and `VARCHAR` are significant).
ALTER TABLE actor
ADD description BLOB;

SELECT * FROM actor;


-- 3b. Very quickly you realize that entering descriptions for each actor is too much effort. Delete the `description` column.
ALTER TABLE actor
DROP COLUMN description;


-- 4a. List the last names of actors, as well as how many actors have that last name.

SELECT last_name,
COUNT(*) AS `num`
FROM actor
GROUP BY last_name;


-- 4b. List last names of actors and the number of actors who have that last name, but only for names that are shared by at least two actors
SELECT last_name,
COUNT(*) AS `num`
FROM actor
GROUP BY last_name
HAVING COUNT(*) > 1;


-- 4c. The actor `HARPO WILLIAMS` was accidentally entered in the `actor` table as `GROUCHO WILLIAMS`. Write a query to fix the record.
UPDATE actor
SET first_name = 'HARPO'
WHERE (first_name = 'GROUCHO' AND last_name = 'WILLIAMS');


-- 4d. Perhaps we were too hasty in changing `GROUCHO` to `HARPO`. It turns out that `GROUCHO` was the correct name after all! 
-- In a single query, if the first name of the actor is currently `HARPO`, change it to `GROUCHO`.

-- Check that this will only effect one entry.
SELECT first_name,
COUNT(*) AS `num`
FROM actor
WHERE first_name = 'HARPO'
GROUP BY first_name;

-- without last_name = 'WILLIAMS' got error about being in safe mode.
UPDATE actor
SET first_name = 'GROUCHO'
WHERE first_name = 'HARPO' AND last_name = 'WILLIAMS';


-- 5a. You cannot locate the schema of the `address` table. 
-- Which query would you use to re-create it?
-- Hint: <https://dev.mysql.com/doc/refman/5.7/en/show-create-table.html>
DESCRIBE sakila.address;


-- 6a. Use `JOIN` to display the first and last names, as well as the address, of each staff member. Use the tables `staff` and `address`:
SELECT * FROM staff;
SELECT * FROM address;

SELECT staff.first_name, staff.last_name, address.address
FROM staff
INNER JOIN address ON staff.address_id = address.address_id;


-- 6b. Use `JOIN` to display the total amount rung up by each staff member in August of 2005. Use tables `staff` and `payment`.
SELECT * FROM staff;
SELECT * FROM payment;

SELECT staff.first_name, staff.last_name, SUM(payment.amount) AS 'total'
FROM staff
INNER JOIN payment ON staff.staff_id = payment.staff_id
GROUP BY staff.first_name, staff.last_name;


-- 6c. List each film and the number of actors who are listed for that film. Use tables `film_actor` and `film`. Use inner join.
SELECT * FROM film_actor;
SELECT * FROM film;

SELECT film.title, COUNT(film_actor.actor_id) AS 'total actors'
FROM film
INNER JOIN film_actor ON film.film_id = film_actor.film_id
GROUP BY film.film_id;


-- 6d. How many copies of the film `Hunchback Impossible` exist in the inventory system?
SELECT * FROM inventory;

SELECT film.title, COUNT(inventory.film_id) AS 'num copies'
FROM film
INNER JOIN inventory ON film.film_id = inventory.film_id
WHERE film.title = 'Hunchback Impossible';

-- 6e. Using the tables `payment` and `customer` and the `JOIN` command, list the total paid by each customer. 
-- List the customers alphabetically by last name:

-- ```
--  	![Total amount paid](Images/total_payment.png)
--  ```
SELECT * FROM payment;
SELECT * FROM customer;
 
SELECT customer.first_name, customer.last_name, SUM(payment.amount) AS 'total'
FROM customer
INNER JOIN payment ON customer.customer_id = payment.customer_id
GROUP BY customer.customer_id
ORDER BY customer.last_name;


-- 7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence.
-- As an unintended consequence, films starting with the letters `K` and `Q` have also soared in popularity. 
-- Use subqueries to display the titles of movies starting with the letters `K` and `Q` whose language is English.
SELECT * FROM film;
SELECT * FROM language;

SELECT title
 FROM film
 WHERE title LIKE 'K%' OR title LIKE 'Q%' 
 AND language_id = (
	SELECT language_id 
    FROM language
    WHERE name = 'English');
 

-- 7b. Use subqueries to display all actors who appear in the film `Alone Trip`.
SELECT * FROM actor;
SELECT * FROM film;
SELECT * FROM film_actor;

SELECT first_name, last_name
FROM actor
WHERE actor_id IN (
	SELECT actor_id
	FROM film_actor
    WHERE film_id = (
		SELECT film_id
        FROM film
        WHERE title = 'Alone Trip'
        )
	);
	

-- 7c. You want to run an email marketing campaign in Canada, for which you will need the names and email addresses of all Canadian customers. 
-- Use joins to retrieve this information.
SELECT * FROM customer;
SELECT * FROM country;
SELECT * FROM city;
SELECT * FROM address;

SELECT first_name, last_name, email
FROM customer
JOIN address ON customer.address_id =  address.address_id
JOIN city ON address.city_id = city.city_id
JOIN country on country.country_id = city.country_id
WHERE country = 'Canada';


-- 7d. Sales have been lagging among young families, and you wish to target all family movies for a promotion. 
-- Identify all movies categorized as family films.

-- There are some errors with this query - Dumbo Lust is listed as a family movie but it is rated NC-17, maybe better to look at ratings too.
SELECT * FROM film_category;
SELECT * FROM film;
SELECT * FROM category;

SELECT title
FROM film
JOIN film_category ON film.film_id = film_category.film_id
JOIN category ON film_category.category_id = category.category_id
WHERE name = 'Family';

-- 7e. Display the most frequently rented movies in descending order.
SELECT * FROM rental;
SELECT * FROM inventory;
SELECT * FROM film;

SELECT title, COUNT(film.film_id) as 'rental_count'
FROM film
JOIN inventory ON film.film_id = inventory.film_id
JOIN rental ON inventory.inventory_id = rental.inventory_id
GROUP BY title
ORDER BY rental_count DESC;


-- 7f. Write a query to display how much business, in dollars, each store brought in.
SELECT * FROM saff;
SELECT * FROM payment;

SELECT store_id, SUM(amount)
FROM payment
JOIN staff ON staff.staff_id = payment.staff_id
GROUP BY store_id;


-- 7g. Write a query to display for each store its store ID, city, and country.
SELECT * FROM store;
SELECT * FROM address;
SELECT * FROM city;
SELECT * FROM country;

SELECT store_id, city, country
FROM store
JOIN address ON store.address_id = address.address_id 
JOIN city ON city.city_id = address.city_id
JOIN country ON city.country_id = country.country_id;


-- 7h. List the top five genres in gross revenue in descending order. 
-- (**Hint**: you may need to use the following tables: category, film_category, inventory, payment, and rental.)
SELECT * FROM category;
SELECT * FROM film_category;
SELECT * FROM inventory;
SELECT * FROM payment;
SELECT * FROM rental;

SELECT name AS 'top_five', SUM(amount) as 'gross_rev'
FROM payment
JOIN rental ON rental.rental_id = payment.rental_id
JOIN inventory ON inventory.inventory_id = rental.inventory_id
JOIN film_category ON film_category.film_id = inventory.film_id
JOIN category ON category.category_id = film_category.category_id
GROUP BY name 
ORDER BY gross_rev DESC 
Limit 5;


-- 8a. In your new role as an executive, you would like to have an easy way of viewing the Top five genres by gross revenue. 
-- Use the solution from the problem above to create a view. If you haven't solved 7h, you can substitute another query to create a view.

CREATE VIEW top_five_genres_gross_rev AS
SELECT name AS 'top_five', SUM(amount) as 'gross_rev'
FROM payment
JOIN rental ON rental.rental_id = payment.rental_id
JOIN inventory ON inventory.inventory_id = rental.inventory_id
JOIN film_category ON film_category.film_id = inventory.film_id
JOIN category ON category.category_id = film_category.category_id
GROUP BY name 
ORDER BY gross_rev DESC 
Limit 5;


-- 8b. How would you display the view that you created in 8a?
SELECT * FROM top_five_genres_gross_rev;


-- 8c. You find that you no longer need the view `top_five_genres`. Write a query to delete it.
DROP VIEW top_five_genres_gross_rev;
