// =========================
// Part 4. Supernodes
// Query 1. Nodes with highest degree
// =========================

MATCH (n)
WITH
    n,
    labels(n) AS labels,
    count { (n)--() } AS degree
RETURN
    labels,
    CASE
        WHEN "User" IN labels THEN toString(n.userId)
        WHEN "Movie" IN labels THEN n.title
        WHEN "Genre" IN labels THEN n.name
        ELSE toString(id(n))
    END AS nodeName,
    degree
ORDER BY degree DESC
LIMIT 20;

// for genre 
MATCH (g:Genre)

RETURN
    g.name,
    count { (g)--() } AS degree

ORDER BY degree DESC;


// for user
MATCH (u:User)

RETURN
    u.userId,
    count { (u)--() } AS degree

ORDER BY degree DESC
LIMIT 10;

