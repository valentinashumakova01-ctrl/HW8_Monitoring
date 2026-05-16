-- SQL для демонстрации инцидента качества данных

-- Создаём таблицу с корректными данными
CREATE TABLE IF NOT EXISTS recommendations (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INTEGER NOT NULL,
    movie_id INTEGER NOT NULL,
    score FLOAT NOT NULL CHECK (score >= 0.0 AND score <= 1.0),
    genre VARCHAR(50) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Заполняем эталонными данными
INSERT INTO recommendations (user_id, movie_id, score, genre)
VALUES 
    (1, 101, 0.85, 'Comedy'),
    (2, 202, 0.42, 'Drama'),
    (3, 303, 0.91, 'Action'),
    (4, 404, 0.67, 'Documentary'),
    (5, 505, 0.33, 'Comedy');

-- SQL,вызывающий инциднт качества данных
-- Инцидент 1: Значение score выходит за допустимый диапазон
UPDATE recommendations SET score = score * 100 WHERE user_id = 1;

-- Инцидент 2: Вставка NULL и некорректных значений
INSERT INTO recommendations (user_id, movie_id, score, genre)
VALUES 
    (-1, 999, 1.5, 'Sci-Fi'),       -- отрицательный user_id, score > 1.0, невалидный жанр
    (0, 888, NULL, 'Sci-Fi'),        -- user_id=0, score=NULL
    (6, 777, -0.5, '');              -- отрицательный score, пустой жанр

-- Инцидент 3: Дублирование данных (сбой ETL)
INSERT INTO recommendations (user_id, movie_id, score, genre)
SELECT user_id, movie_id, score, genre FROM recommendations WHERE id <= 3;

-- Проверка: найти все нарушения

-- Нарушения score
SELECT * FROM recommendations WHERE score < 0.0 OR score > 1.0 OR score IS NULL;

-- Нарушения genre
SELECT * FROM recommendations WHERE genre NOT IN ('Comedy','Drama','Action','Documentary') OR genre IS NULL OR genre = '';

-- Нарушения user_id
SELECT * FROM recommendations WHERE user_id <= 0 OR user_id IS NULL;
