-- Active: 1763136769886@@127.0.0.1@3306@worldcup
USE worldcup;
-- 13
SELECT 
    c.name,
    COUNT(g.goal_time) AS goals
FROM goals AS g
JOIN players AS p      ON g.player_id = p.id
JOIN countries AS c    ON p.country_id = c.id
WHERE g.pairing_id IN (39, 103)
GROUP BY c.name;
-- 14
SELECT 
p.kickoff,
 c.name my, c1.name enemy,
 c.ranking, c1.ranking,
 COUNT(cpl.name) my_goals
FROM pairings as p
    LEFT JOIN countries as c ON c.id = p.my_country_id
    LEFT JOIN countries as c1 ON c1.id = p.enemy_country_id

        LEFT JOIN goals as g ON g.pairing_id = p.id
        LEFT JOIN players as pl ON pl.id = g.player_id
        LEFT JOIN countries as cpl ON pl.country_id = cpl.id
WHERE c.group_name = 'C'
GROUP BY
    p.kickoff,
    c.name,
    c1.name,
    c.ranking,
    c.ranking,c1.ranking
ORDER BY
    p.kickoff,
    c.ranking;
-- 15
SELECT 
    p.kickoff,
    c.name  AS my,
    c1.name AS enemy,
    c.ranking  AS my_ranking,
    c1.ranking AS enemy_ranking,
    (
        SELECT COUNT(cpl.name)
        FROM goals AS g
        LEFT JOIN players   AS pl  ON pl.id = g.player_id
        LEFT JOIN countries AS cpl ON cpl.id = pl.country_id
        WHERE g.pairing_id = p.id
    ) AS my_goals
FROM pairings AS p
LEFT JOIN countries AS c  ON c.id  = p.my_country_id
LEFT JOIN countries AS c1 ON c1.id = p.enemy_country_id
WHERE c.group_name = 'C'
ORDER BY
    p.kickoff,
    c.ranking;
-- 16
SELECT         -- ここで連番を使える
    t.kickoff,
    t.my,
    t.enemy,
    t.my_goals,
    a.my_goals enemy_goals
FROM (
    SELECT
        ROW_NUMBER() OVER (
            ORDER BY p.kickoff, c.ranking
        ) AS seq,                   -- ★ ここで連番を作る
        p.kickoff,
        c.name  AS my,
        c1.name AS enemy,
        SUM(CASE WHEN cpl.id = p.my_country_id  THEN 1 ELSE 0 END) AS my_goals,
        SUM(CASE WHEN cpl.id = p.enemy_country_id THEN 1 ELSE 0 END) AS enemy_goals
    FROM pairings AS p
    LEFT JOIN countries AS c   ON c.id  = p.my_country_id
    LEFT JOIN countries AS c1  ON c1.id = p.enemy_country_id
    LEFT JOIN goals     AS g   ON g.pairing_id = p.id
    LEFT JOIN players   AS pl  ON pl.id = g.player_id
    LEFT JOIN countries AS cpl ON cpl.id = pl.country_id
    WHERE c.group_name = 'C'
    GROUP BY
        p.id,
        p.kickoff,
        c.name,
        c1.name
) AS t
LEFT JOIN (
SELECT 
    ROW_NUMBER() OVER (
        ORDER BY temp_p.kickoff, temp_c.ranking
    ) AS seq,  
    COUNT(temp_cpl.name) AS my_goals
FROM pairings as temp_p
LEFT JOIN countries as temp_c1 ON temp_c1.id = temp_p.my_country_id
LEFT JOIN countries as temp_c  ON temp_c.id = temp_p.enemy_country_id
LEFT JOIN goals     as temp_g  ON temp_g.pairing_id = temp_p.id
LEFT JOIN players   as temp_pl ON temp_pl.id = temp_g.player_id
LEFT JOIN countries as temp_cpl ON temp_pl.country_id = temp_cpl.id
WHERE temp_c.group_name = 'C'
GROUP BY
    temp_p.id,
    temp_p.kickoff,
    temp_c.ranking,
    temp_c1.ranking
ORDER BY
    temp_p.kickoff,
    temp_c.ranking
) as a ON a.seq = t.seq
LIMIT 16;

-- 17
SELECT         -- ここで連番を使える
    t.kickoff,
    t.my,
    t.enemy,
    t.my_goals,
    a.my_goals enemy_goals,
    t.my_goals - a.my_goals as diff
FROM (
    SELECT
        ROW_NUMBER() OVER (
            ORDER BY p.kickoff, c.ranking
        ) AS seq,                   -- ★ ここで連番を作る
        p.kickoff,
        c.name  AS my,
        c1.name AS enemy,
        SUM(CASE WHEN cpl.id = p.my_country_id  THEN 1 ELSE 0 END) AS my_goals,
        SUM(CASE WHEN cpl.id = p.enemy_country_id THEN 1 ELSE 0 END) AS enemy_goals
    FROM pairings AS p
    LEFT JOIN countries AS c   ON c.id  = p.my_country_id
    LEFT JOIN countries AS c1  ON c1.id = p.enemy_country_id
    LEFT JOIN goals     AS g   ON g.pairing_id = p.id
    LEFT JOIN players   AS pl  ON pl.id = g.player_id
    LEFT JOIN countries AS cpl ON cpl.id = pl.country_id
    WHERE c.group_name = 'C'
    GROUP BY
        p.id,
        p.kickoff,
        c.name,
        c1.name
) AS t
LEFT JOIN (
SELECT 
    ROW_NUMBER() OVER (
        ORDER BY temp_p.kickoff, temp_c.ranking
    ) AS seq,  
    COUNT(temp_cpl.name) AS my_goals
FROM pairings as temp_p
LEFT JOIN countries as temp_c1 ON temp_c1.id = temp_p.my_country_id
LEFT JOIN countries as temp_c  ON temp_c.id = temp_p.enemy_country_id
LEFT JOIN goals     as temp_g  ON temp_g.pairing_id = temp_p.id
LEFT JOIN players   as temp_pl ON temp_pl.id = temp_g.player_id
LEFT JOIN countries as temp_cpl ON temp_pl.country_id = temp_cpl.id
WHERE temp_c.group_name = 'C'
GROUP BY
    temp_p.id,
    temp_p.kickoff,
    temp_c.ranking,
    temp_c1.ranking
ORDER BY
    temp_p.kickoff,
    temp_c.ranking
) as a ON a.seq = t.seq
LIMIT 16;
--18
SELECT
    DATE_ADD(kickoff, INTERVAL 12 HOUR) AS kickoff,      
    kickoff AS kickoff_jp                                
FROM pairings
WHERE my_country_id = 1
  AND enemy_country_id = 4;


SELECT 
    g.id,
    g.pairing_id,
    p.* ,
    c.name my,c1.name enemy,
    pl.country_id,
    cpl.name
FROM goals AS g
LEFT JOIN pairings as p ON g.pairing_id = p.id
LEFT JOIN countries as c ON c.id = p.enemy_country_id
LEFT JOIN countries as c1 ON c1.id = p.my_country_id
LEFT JOIN players as pl ON pl.id = g.player_id
LEFT JOIN countries as cpl ON cpl.id = pl.country_id
WHERE c.name IN ('ギリシャ ','日本') AND c1.name IN ('ギリシャ','日本')

-- 18
SELECT p.*,goals.id FROM goals
LEFT JOIN pairings AS p ON p.id = goals.pairing_id;



SELECT 
    ROW_NUMBER() OVER (
        ORDER BY temp_p.kickoff, temp_c.ranking
    ) AS seq,  
    COUNT(temp_cpl.name) AS my_goals
FROM pairings as temp_p
LEFT JOIN countries as temp_c1 ON temp_c1.id = temp_p.my_country_id
LEFT JOIN countries as temp_c  ON temp_c.id = temp_p.enemy_country_id
LEFT JOIN goals     as temp_g  ON temp_g.pairing_id = temp_p.id
LEFT JOIN players   as temp_pl ON temp_pl.id = temp_g.player_id
LEFT JOIN countries as temp_cpl ON temp_pl.country_id = temp_cpl.id
WHERE temp_c.group_name = 'C'
GROUP BY
    temp_p.id,
    temp_p.kickoff,
    temp_c.ranking,
    temp_c1.ranking
ORDER BY
    temp_p.kickoff,
    temp_c.ranking;
