//Запит для фільмів
LOAD CSV WITH HEADERS FROM 'file:///movies.csv' AS row
MERGE (m:Movie {movieId: toInteger(row.movieId)})
SET m.title = row.title;

//Запит для жанрів
LOAD CSV WITH HEADERS FROM 'file:///movies.csv' AS row
UNWIND split(row.genres, '|') AS genre
MERGE (g:Genre {name: genre});

//Індекси
CREATE INDEX user_id IF NOT EXISTS FOR (u:User) ON (u.userId);
CREATE INDEX movie_id IF NOT EXISTS FOR (m:Movie) ON (m.movieId);
CREATE INDEX genre_name IF NOT EXISTS FOR (g:Genre) ON (g.name);

//Завантаження ребер
LOAD CSV WITH HEADERS FROM 'file:///movies.csv' AS row
MATCH (m:Movie {movieId: toInteger(row.movieId)})
UNWIND split(row.genres, '|') AS genreName
MATCH (g:Genre {name: genreName})
MERGE (m)-[:HAS_GENRE]->(g);

CALL apoc.periodic.iterate(
  "LOAD CSV WITH HEADERS FROM 'file:///ratings.csv' AS row RETURN row",
  "MATCH (u:User {userId: toInteger(row.userId)})
   MATCH (m:Movie {movieId: toInteger(row.movieId)})
   MERGE (u)-[r:RATED]->(m)
   ON CREATE SET r.rating = toInteger(row.rating), r.timestamp = toInteger(row.timestamp)",
  {batchSize: 10000, parallel: false}
);

//Перевірка результатів
MATCH (u:User) RETURN count(u) AS users;
MATCH (m:Movie) RETURN count(m) AS movies;
MATCH ()-[r:RATED]->() RETURN count(r) AS ratings;