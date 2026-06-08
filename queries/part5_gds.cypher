MATCH (m1:Movie)<-[r1:RATED]-(u:User)-[r2:RATED]->(m2:Movie)
WHERE r1.rating >= 4
  AND r2.rating >= 4
  AND id(m1) < id(m2)

WITH m1, m2, count(u) AS weight

WHERE size([(m1)<-[:RATED]-() | 1]) > 20
  AND size([(m2)<-[:RATED]-() | 1]) > 20

WITH m1, m2, weight
ORDER BY weight DESC
LIMIT 50000

MERGE (m1)-[co:CO_RATED]-(m2)
SET co.weight = weight;


CALL gds.graph.project(
    'movieGraph',
    'Movie',
    {
        CO_RATED: {
            orientation: 'UNDIRECTED',
            properties: 'weight'
        }
    }
)
YIELD graphName, nodeCount, relationshipCount;


CALL gds.pageRank.stream('movieGraph', {
    relationshipWeightProperty: 'weight'
})
YIELD nodeId, score

MATCH (m:Movie)
WHERE id(m) = nodeId

RETURN
    m.movieId AS movieId,
    m.title AS title,
    round(score * 1000) / 1000 AS pageRank

ORDER BY pageRank DESC
LIMIT 10;

CALL gds.graph.drop('movieGraph');

MATCH ()-[co:CO_RATED]-()
DELETE co;


MATCH ()-[co:CO_RATED]-()
DELETE co;

//зменшив рейтинг, ліміт, да додав вагу, так як було велике навантаження та була помилка 
MATCH (u1:User)-[r1:RATED]->(m:Movie)<-[r2:RATED]-(u2:User)
WHERE r1.rating = 5
  AND r2.rating = 5
  AND id(u1) < id(u2)

WITH u1, u2, count(m) AS weight
WHERE weight >= 5

WITH u1, u2, weight
ORDER BY weight DESC
LIMIT 10000

MERGE (u1)-[sim:SIMILAR]-(u2)
SET sim.weight = weight;

// створюю гдс проекцію
CALL gds.graph.project(
    'userSimilarity',
    'User',
    {
        SIMILAR: {
            orientation: 'UNDIRECTED',
            properties: 'weight'
        }
    }
)
YIELD graphName, nodeCount, relationshipCount;


//запускаю louvain

CALL gds.louvain.stream('userSimilarity', {
    relationshipWeightProperty: 'weight'
})
YIELD nodeId, communityId

MATCH (u:User)
WHERE id(u) = nodeId

RETURN
    communityId,
    count(u) AS usersCount

ORDER BY usersCount DESC
LIMIT 10;

// знаходимо топ-3 жанри 
CALL gds.louvain.stream('userSimilarity', {
    relationshipWeightProperty: 'weight'
})
YIELD nodeId, communityId

MATCH (u:User)
WHERE id(u) = nodeId

WITH communityId, collect(u) AS users
ORDER BY size(users) DESC
LIMIT 4

UNWIND users AS u

MATCH (u)-[r:RATED]->(:Movie)-[:HAS_GENRE]->(g:Genre)
WHERE r.rating >= 4

WITH
    communityId,
    g.name AS genre,
    count(*) AS genreCount

ORDER BY communityId, genreCount DESC

WITH
    communityId,
    collect({
        genre: genre,
        count: genreCount
    })[0..3] AS topGenres

RETURN
    communityId,
    topGenres

ORDER BY communityId;

//5.3
MATCH (u1:User {userId: 4169})
MATCH (u2:User {userId: 4277})

CALL gds.shortestPath.dijkstra.stream(
    'userSimilarity',
    {
        sourceNode: id(u1),
        targetNode: id(u2),
        relationshipWeightProperty: 'weight'
    }
)
YIELD totalCost, nodeIds

RETURN
    totalCost,
    size(nodeIds) AS pathLength;

