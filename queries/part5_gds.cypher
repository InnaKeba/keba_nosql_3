//5.1. PageRank на графі фільмів
// Крок 1: матеріалізуємо ребра фільм-фільм через спільних користувачів
MATCH (m1:Movie)<-[r1:RATED]-(u:User)-[r2:RATED]->(m2:Movie)
WHERE r1.rating >= 4 AND r2.rating >= 4 AND id(m1) < id(m2)
WITH m1, m2, count(u) AS weight
WHERE COUNT { (m1)<-[:RATED]-() } > 20
  AND COUNT { (m2)<-[:RATED]-() } > 20
WITH m1, m2, weight
ORDER BY weight DESC
LIMIT 50000
MERGE (m1)-[co:CO_RATED]-(m2)
SET co.weight = weight;

// Крок 2: створюємо проєкцію на основі матеріалізованих ребер
CALL gds.graph.project(
  'movieGraph',
  'Movie',
  { CO_RATED: { orientation: 'UNDIRECTED', properties: 'weight' } }
)
YIELD graphName, nodeCount, relationshipCount;

// Крок 3: Запуск самого алгоритму PageRank
CALL gds.pageRank.stream('movieGraph', {
    relationshipWeightProperty: 'weight'
})
YIELD nodeId, score
RETURN gds.util.asNode(nodeId).title AS MovieTitle, score AS PageRank
ORDER BY score DESC
LIMIT 10;

// Крок 4: видаляємо проєкцію та тимчасові ребра
CALL gds.graph.drop('movieGraph');
MATCH ()-[co:CO_RATED]-() DELETE co;

// 5.2. Виявлення спільнот (Louvain)
// Крок 1: матеріалізуємо ребра користувач-користувач через спільні фільми
MATCH (u1:User)-[r1:RATED]->(m:Movie)<-[r2:RATED]-(u2:User)
WHERE r1.rating = 5 AND r2.rating = 5 
  AND elementId(u1) < elementId(u2)
  AND COUNT { (m)<-[:RATED]-() } < 500
WITH u1, u2, count(m) AS weight
ORDER BY weight DESC
LIMIT 10000
MERGE (u1)-[sim:SIMILAR]-(u2)
SET sim.weight = weight;

// Крок 2: створюємо проєкцію
CALL gds.graph.project(
  'userSimilarity',
  'User',
  { SIMILAR: { orientation: 'UNDIRECTED', properties: 'weight' } }
)
YIELD graphName, nodeCount, relationshipCount;

// Крок 3: Запускаємо Louvain
CALL gds.louvain.write('userSimilarity', {
    relationshipWeightProperty: 'weight',
    writeProperty: 'communityId'
})
YIELD communityCount, modularity;

// Крок 4: Для кожної знайденої спільноти визначте три найпопулярніші жанри фільмів (на основі фільмів з високими оцінками користувачів)
MATCH (u:User)-[r:RATED]->(m:Movie)-[:HAS_GENRE]->(g:Genre)
WHERE r.rating >= 4 AND u.communityId IS NOT NULL
WITH u.communityId AS Community, count(DISTINCT u) AS UsersCount, g.name AS Genre, count(r) AS GenreCount
ORDER BY GenreCount DESC
WITH Community, UsersCount, collect(Genre)[0..3] AS TopGenres
RETURN Community, UsersCount, TopGenres
ORDER BY UsersCount DESC
LIMIT 10;

// Крок 5: видаляємо проєкцію та тимчасові ребра
CALL gds.graph.drop('userSimilarity');
MATCH ()-[sim:SIMILAR]-() DELETE sim;