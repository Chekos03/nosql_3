// =========================
// USERS
// =========================

LOAD CSV WITH HEADERS
FROM 'file:///users.csv' AS row

MERGE (u:User {userId: toInteger(row.userId)})
SET
    u.gender = row.gender,
    u.age = toInteger(row.age),
    u.occupation = toInteger(row.occupation);

// =========================
// MOVIES
// =========================

LOAD CSV WITH HEADERS
FROM 'file:///movies.csv' AS row

MERGE (m:Movie {movieId: toInteger(row.movieId)})
SET
    m.title = row.title;


// =========================
// GENRES + HAS_GENRE
// =========================

LOAD CSV WITH HEADERS
FROM 'file:///movies.csv' AS row

MATCH (m:Movie {movieId: toInteger(row.movieId)})

WITH m, split(row.genres, '|') AS genres

UNWIND genres AS genreName

MERGE (g:Genre {name: genreName})

MERGE (m)-[:HAS_GENRE]->(g);


// =========================
// INDEXES
// =========================

CREATE INDEX user_id_index IF NOT EXISTS
FOR (u:User)
ON (u.userId);

CREATE INDEX movie_id_index IF NOT EXISTS
FOR (m:Movie)
ON (m.movieId);

CREATE INDEX genre_name_index IF NOT EXISTS
FOR (g:Genre)
ON (g.name);


// =========================
// RATED RELATIONSHIPS
// =========================

CALL apoc.periodic.iterate(
    "
    LOAD CSV WITH HEADERS
    FROM 'file:///ratings.csv' AS row
    RETURN row
    ",
    "
    MATCH (u:User {userId: toInteger(row.userId)})
    MATCH (m:Movie {movieId: toInteger(row.movieId)})
    MERGE (u)-[r:RATED]->(m)
    SET
        r.rating = toFloat(row.rating),
        r.timestamp = toInteger(row.timestamp)
    ",
    {
        batchSize: 10000,
        parallel: false
    }
);