-- 1
SELECT m.id, m.title, m.releasedyear, COUNT(*)
FROM movie m
         INNER JOIN episode e ON m.id = e.mid
GROUP BY 1, 2, 3
ORDER BY 3 DESC;


-- 2
SELECT COUNT(DISTINCT episodenum)
FROM movie m
         INNER JOIN episode e ON m.id = e.mid
         INNER JOIN watch_history wh USING (mid, season, episodenum)
         INNER JOIN users u ON u.email = wh.uid
WHERE m.title = 'Cells at Work'
  AND u.name = 'Andrew';


-- 3
SELECT DISTINCT title,
                watch_count
FROM (SELECT m.id, m.title, e.episodenum, COUNT(e.episodenum) watch_count
      FROM movie m
               INNER JOIN episode e ON m.id = e.mid
               INNER JOIN watch_history wh USING (mid, season, episodenum)
               INNER JOIN users u ON u.email = wh.uid
      GROUP BY 1, 2, 3) AS ew_count
WHERE watch_count > 1;


-- 4
SELECT u.name, u.email
FROM users u
         INNER JOIN watch_history wh ON u.email = wh.uid
GROUP BY 1, 2
HAVING EXTRACT(HOUR FROM MIN(duration)) >= 1;


-- 5
SELECT m.title, e.etitle, g.type
FROM movie m
         INNER JOIN genre g ON g.id = m.gid
         LEFT JOIN episode e ON m.id = e.mid
WHERE m.vieweragelimit <= (SELECT DATE_PART('year', CURRENT_DATE) - MAX(birthyear)
                           FROM users
                           WHERE name = 'Andrew'
                              OR name = 'Nobita'
                              OR name = 'Monalisa');


-- 6
CREATE OR REPLACE FUNCTION countNumberOfViewers(mtitle varchar(50), eseason integer, enum integer)
    RETURNS integer AS
$$
DECLARE
    watch_count integer;
BEGIN
    SELECT COUNT(DISTINCT u.email)
    INTO watch_count
    FROM movie m
             INNER JOIN episode e ON m.id = e.mid
             LEFT JOIN watch_history wh USING (mid, season, episodenum)
             LEFT JOIN users u ON u.email = wh.uid
    WHERE m.title = mtitle
      AND e.season = eseason
      AND e.episodenum = enum;

    RETURN watch_count;
END;
$$ LANGUAGE plpgsql;


SELECT countNumberOfViewers('Kungfu Panda the Dragon Knight', 1, 2);


-- 7
CREATE OR REPLACE FUNCTION recommendedMoviePercentage(mtitle varchar(50))
    RETURNS integer AS
$$
DECLARE
    yes_count  integer;
    all_count  integer;
    percentage integer;
BEGIN
    SELECT SUM(CASE WHEN wh.recommended = 'YES' THEN 1 ELSE 0 END), COUNT(*)
    INTO yes_count, all_count
    FROM movie m
             INNER JOIN episode e ON m.id = e.mid
             INNER JOIN watch_history wh USING (mid, season, episodenum)
    WHERE m.title = mtitle;

    percentage := 100 * yes_count / all_count;
    RETURN percentage;
END;
$$ LANGUAGE plpgsql;


SELECT recommendedMoviePercentage('Cells at Work');


-- 8
CREATE OR REPLACE FUNCTION checkWatchingDuration()
    RETURNS trigger AS
$$
DECLARE
    e_duration time;
BEGIN
    SELECT eduration
    INTO e_duration
    FROM episode
    WHERE mid = NEW.mid
      AND season = NEW.season
      AND episodenum = NEW.episodenum;

    IF (NEW.duration > e_duration) THEN
        RAISE EXCEPTION
            'Durasi menonton suatu episode movie dari seorang pengguna tidak mungkin lebih besar dari durasi episode itu sendiri.';
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;


CREATE TRIGGER checkWatchingDurationTrigger
    BEFORE INSERT OR UPDATE
    ON watch_history
    FOR EACH ROW
EXECUTE PROCEDURE checkWatchingDuration();


INSERT INTO watch_history
VALUES (11, 'mipo@gmail.com', 10, 1, 3, '2020-10-28 10:00', '03:00:00', 'YES');


