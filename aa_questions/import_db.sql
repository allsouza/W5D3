PRAGMA foreign_keys = ON;

DROP TABLE IF EXISTS users;

CREATE TABLE users (
    id INTEGER PRIMARY KEY,
    fname VARCHAR(100) NOT NULL,
    lname VARCHAR(100) NOT NULL
);

DROP TABLE if EXISTS questions;

CREATE TABLE questions (
    id INTEGER PRIMARY KEY,
    title TEXT NOT NULL,
    body TEXT NOT NULL,
    user_id INTEGER NOT NULL,

    FOREIGN KEY (user_id) REFERENCES users(id)
);

DROP TABLE if EXISTS question_follows;

CREATE TABLE question_follows (
    user_id INTEGER,
    question_id INTEGER,
    
    FOREIGN KEY (user_id) REFERENCES users(id),
    FOREIGN KEY (question_id) REFERENCES questions(id)
);

DROP TABLE if EXISTS replies;

CREATE TABLE replies (
    id INTEGER PRIMARY KEY,
    parent_id INTEGER,
    question_id INTEGER NOT NULL,
    user_id INTEGER NOT NULL,
    body TEXT NOT NULL,

    FOREIGN KEY (user_id) REFERENCES users(id),
    FOREIGN KEY (question_id) REFERENCES questions(id)
);

DROP TABLE if EXISTS question_likes;

CREATE TABLE question_likes (
    user_id INTEGER,
    question_id INTEGER,

    FOREIGN KEY (user_id) REFERENCES users(id),
    FOREIGN KEY (question_id) REFERENCES questions(id)
);

INSERT INTO users(fname, lname)
VALUES ('Andre', 'Souza'), ('Eugene', 'Moon');

INSERT INTO questions(title, body, user_id)
VALUES 
    ('DUMB QUESTION 1', 'Why is my code failing?', (
        SELECT id
        FROM users
        WHERE fname LIKE 'Andre'
    )),
    ('DUMB QUESTION 2', 'What happened to my tables?!', (
        SELECT id
        FROM users
        WHERE lname LIKE 'Moon'
    ));

INSERT INTO question_follows(user_id, question_id)
VALUES (1, 1), (1, 2), (2, 1);

INSERT INTO replies(parent_id, question_id, user_id, body)
VALUES
    (NULL, 1, 2, 'LOL NOOB'),
    (1, 1, 1, 'C''mon please halp!'),
    (NULL, 2, 2, 'Anyone???'),
    (3, 2, 1, 'Drop it likes it''s HOT!!');

INSERT INTO question_likes(user_id, question_id)
VALUES (1, 1), (1, 2), (2, 1);

