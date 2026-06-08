// =========================
// Query 1
// Thriller movies with average rating > 4.0
// =========================

MATCH (m:Movie)-[:HAS_GENRE]->(:Genre {name: "Thriller"})
MATCH (m)<-[r:RATED]-(:User)
WITH
    m,
    avg(r.rating) AS avgRating,
    count(r) AS ratingCount
WHERE avgRating > 4.0
RETURN
    m.movieId AS movieId,
    m.title AS title,
    round(avgRating * 100) / 100 AS avgRating,
    ratingCount
ORDER BY avgRating DESC, ratingCount DESC
LIMIT 10;



// =========================
// Query 2
// Users who rated 5 more than 50 movies
// =========================

MATCH (u:User)-[r:RATED]->(:Movie)
WHERE r.rating = 5

WITH
    u,
    count(r) AS fiveRatings

WHERE fiveRatings > 50

RETURN
    u.userId,
    u.gender,
    u.age,
    fiveRatings

ORDER BY fiveRatings DESC;



// =========================
// Query 3
// Movies liked by both users
// =========================

MATCH (u1:User {userId: 1})-[r1:RATED]->(m:Movie)
MATCH (u2:User {userId: 2})-[r2:RATED]->(m)

WHERE r1.rating >= 4
  AND r2.rating >= 4

RETURN
    m.movieId,
    m.title,
    r1.rating AS user1_rating,
    r2.rating AS user2_rating

ORDER BY m.title;


// =========================
// Query 4
// Best genres by average rating
// =========================

MATCH (g:Genre)<-[:HAS_GENRE]-(m:Movie)<-[r:RATED]-(:User)

WITH
    g,
    avg(r.rating) AS avgRating,
    count(r) AS totalRatings

WHERE totalRatings > 1000

RETURN
    g.name AS genre,
    round(avgRating * 100) / 100 AS avgRating,
    totalRatings

ORDER BY avgRating DESC;



// Query 5

MATCH (target:User {userId: 1})-[r1:RATED]->(m:Movie)<-[r2:RATED]-(other:User)

WHERE r1.rating >= 4
  AND r2.rating >= 4
  AND target <> other

WITH target, other, count(m) AS commonLikes

WHERE commonLikes >= 5

MATCH (other)-[r:RATED]->(recommended:Movie)

WHERE r.rating >= 4

AND NOT EXISTS {
    MATCH (target)-[:RATED]->(recommended)
}

WITH
    recommended,
    count(other) AS similarUsers,
    avg(r.rating) AS avgRating

RETURN
    recommended.movieId,
    recommended.title,
    similarUsers,
    round(avgRating * 100) / 100 AS avgRating

ORDER BY similarUsers DESC, avgRating DESC
LIMIT 20;


// Query 6
MATCH p = shortestPath(
    (u1:User {userId: 1})-[*..10]-(u2:User {userId: 50})
)
RETURN p;