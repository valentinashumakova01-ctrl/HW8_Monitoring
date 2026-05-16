-- SQL для демонстрации инцидента качества данных
DROP TABLE IF EXISTS recommendations;

CREATE TABLE recommendations (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INTEGER NOT NULL,
    movie_id INTEGER NOT NULL,
    score FLOAT,
    genre VARCHAR(50),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO recommendations (user_id, movie_id, score, genre) VALUES 
    (1, 101, 0.85, 'Comedy'),
    (2, 202, 0.42, 'Drama'),
    (3, 303, 0.91, 'Action'),
    (4, 404, 0.67, 'Documentary'),
    (5, 505, 0.33, 'Comedy');

UPDATE recommendations SET score = 150 WHERE id = 1;

INSERT INTO recommendations (user_id, movie_id, score, genre) VALUES 
    (6, 111, -5, 'Comedy'),
    (-1, 999, 0.5, 'Sci-Fi'),
    (7, 888, NULL, NULL);

INSERT INTO recommendations (user_id, movie_id, score, genre)
SELECT user_id, movie_id, score, genre FROM recommendations WHERE id <= 3;

SELECT id, user_id, score, genre,
  CASE 
    WHEN score < 0 OR score > 1 OR score IS NULL THEN 'BAD_SCORE'
    WHEN genre NOT IN ('Comedy','Drama','Action','Documentary') OR genre IS NULL THEN 'BAD_GENRE'
    WHEN user_id <= 0 THEN 'BAD_USER'
    ELSE 'OK'
  END AS issue
FROM recommendations
WHERE issue != 'OK';
