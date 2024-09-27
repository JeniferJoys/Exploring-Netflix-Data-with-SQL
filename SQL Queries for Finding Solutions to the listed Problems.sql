-- Netflix Data Analysis using SQL
-- 1. Compare the total number of Movies and TV Shows.

SELECT 
	type,
	COUNT(*)
FROM netflix
GROUP BY 1

-- 2. Determine the most frequent rating for Movies and TV Shows.

WITH RatingCounts AS (
    SELECT 
        type,
        rating,
        COUNT(*) AS rating_count
    FROM netflix
    GROUP BY type, rating
),
RankedRatings AS (
    SELECT 
        type,
        rating,
        rating_count,
        RANK() OVER (PARTITION BY type ORDER BY rating_count DESC) AS rank
    FROM RatingCounts
)
SELECT 
    type,
    rating AS most_frequent_rating
FROM RankedRatings
WHERE rank = 1;


-- 3. List all Movies released in a specified year (e.g., 2020).

SELECT * 
FROM netflix
WHERE release_year = 2020


-- 4. Identify the top 5 countries with the most content available on Netflix.

SELECT * 
FROM
(
	SELECT 
		-- country,
		UNNEST(STRING_TO_ARRAY(country, ',')) as country,
		COUNT(*) as total_content
	FROM netflix
	GROUP BY 1
)as t1
WHERE country IS NOT NULL
ORDER BY total_content DESC
LIMIT 5


-- 5. Find the longest Movie in the dataset.

SELECT 
	*
FROM netflix
WHERE type = 'Movie'
ORDER BY SPLIT_PART(duration, ' ', 1)::INT DESC


-- 6. Retrieve content added in the past 5 years.
SELECT
*
FROM netflix
WHERE TO_DATE(date_added, 'Month DD, YYYY') >= CURRENT_DATE - INTERVAL '5 years'


-- 7. List all Movies and TV Shows directed by Rajiv Chilaka.

SELECT *
FROM
(

SELECT 
	*,
	UNNEST(STRING_TO_ARRAY(director, ',')) as director_name
FROM 
netflix
)
WHERE 
	director_name = 'Rajiv Chilaka'



-- 8. Identify all TV Shows that have more than 5 seasons.

SELECT *
FROM netflix
WHERE 
	TYPE = 'TV Show'
	AND
	SPLIT_PART(duration, ' ', 1)::INT > 5


-- 9. Count the number of content items in each genre.

SELECT 
	UNNEST(STRING_TO_ARRAY(listed_in, ',')) as genre,
	COUNT(*) as total_content
FROM netflix
GROUP BY 1


-- 10. Calculate the average number of content releases in India on Netflix by year, and return the top 5 years with the highest averages.


SELECT 
	country,
	release_year,
	COUNT(show_id) as total_release,
	ROUND(
		COUNT(show_id)::numeric/
								(SELECT COUNT(show_id) FROM netflix WHERE country = 'India')::numeric * 100 
		,2
		)
		as avg_release
FROM netflix
WHERE country = 'India' 
GROUP BY country, 2
ORDER BY avg_release DESC 
LIMIT 5


-- 11. List all Movies classified as documentaries.
SELECT * FROM netflix
WHERE listed_in LIKE '%Documentaries'



-- 12. Find all content that lacks a director.
SELECT * FROM netflix
WHERE director IS NULL


-- 13. Determine how many Movies Salman Khan has appeared in over the last 10 years.

SELECT * FROM netflix
WHERE 
	casts LIKE '%Salman Khan%'
	AND 
	release_year > EXTRACT(YEAR FROM CURRENT_DATE) - 10


-- 14. Identify the top 10 actors who have starred in the most Movies produced in India.



SELECT 
	UNNEST(STRING_TO_ARRAY(casts, ',')) as actor,
	COUNT(*)
FROM netflix
WHERE country = 'India'
GROUP BY 1
ORDER BY 2 DESC
LIMIT 10

/*
Question 15:
Categorize content based on the presence of keywords 'kill' and 'violence' in the description. 
Label content with these keywords as 'Bad' and all others as 'Good', then count the items in each category.
*/


SELECT 
    category,
	TYPE,
    COUNT(*) AS content_count
FROM (
    SELECT 
		*,
        CASE 
            WHEN description ILIKE '%kill%' OR description ILIKE '%violence%' THEN 'Bad'
            ELSE 'Good'
        END AS category
    FROM netflix
) AS categorized_content
GROUP BY 1,2
ORDER BY 2




-- End of reports

