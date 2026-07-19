//Запит 1. Знайти всі фільми жанру «Thriller» із середнім рейтингом вище 4.0
MATCH (m:Movie)-[:HAS_GENRE]->(g:Genre {name: 'Thriller'})
MATCH ()-[r:RATED]->(m)
WITH m, avg(toFloat(r.rating)) AS avgRating
WHERE avgRating > 4.0
RETURN m.title AS MovieTitle, avgRating
ORDER BY avgRating DESC;

//Запит 2. Знайти користувачів, які поставили оцінку 5 більш ніж 50 фільмам:
MATCH (u:User)-[r:RATED]->(m:Movie)
WHERE r.rating = 5
WITH u, count(m) AS fiveStarCount
WHERE fiveStarCount > 50
RETURN u.userId AS UserID, fiveStarCount
ORDER BY fiveStarCount DESC;

//Запит 3. Знайти фільми, які обидва користувачі (наприклад, userId=1 і userId=2) оцінили високо (рейтинг ≥ 4)
MATCH (u1:User {userId: 1})-[r1:RATED]->(m:Movie)<-[r2:RATED]-(u2:User {userId: 2})
WHERE r1.rating >= 4 AND r2.rating >= 4
RETURN m.title AS MovieTitle, r1.rating AS User1Rating, r2.rating AS User2Rating;

//Запит 4. Знайти жанри, чиї фільми стабільно отримують високі оцінки — середній рейтинг і кількість оцінок
MATCH (g:Genre)<-[:HAS_GENRE]-(m:Movie)<-[r:RATED]-()
WITH g.name AS Genre, count(r) AS TotalRatings, avg(toFloat(r.rating)) AS AvgRating
WHERE TotalRatings > 1000
RETURN Genre, TotalRatings, round(AvgRating, 2) AS AvgRating
ORDER BY AvgRating DESC;

//Запит 5. Рекомендація «користувачі зі схожими смаками також дивилися»: для заданого користувача знайти фільми,
// які він ще не дивився, але високо оцінили користувачі з подібними смаками
MATCH (u1:User {userId: 1})-[r1:RATED]->(m:Movie)<-[r2:RATED]-(simUser:User)
WHERE r1.rating >= 4 AND r2.rating >= 4
WITH u1, simUser, count(m) AS commonMovies
WHERE commonMovies >= 2
MATCH (simUser)-[r3:RATED]->(recMovie:Movie)
WHERE r3.rating >= 4 AND NOT (u1)-[:RATED]->(recMovie)
WITH recMovie, count(simUser) AS score
RETURN recMovie.title AS RecommendedMovie, score AS RecommendationScore
ORDER BY score DESC
LIMIT 10;

//Запит 6. Знайти найкоротший ланцюжок зв’язку між двома користувачами через спільні фільми
MATCH p = shortestPath((u1:User {userId: 1})-[:RATED*..10]-(u2:User {userId: 100}))
RETURN length(p) AS PathLength, 
       [n in nodes(p) | coalesce(n.userId, n.title)] AS PathNodes;