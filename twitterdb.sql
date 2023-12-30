DROP DATABASE IF EXISTS twitterdb; /* Eliminar base de datos si existe */
CREATE DATABASE twitterdb; /* Creando y usando base de datos */
use twitterdb;
DROP TABLE IF EXISTS user; /* Borrar tabla usuario si existe */
CREATE TABLE user(
    id INT NOT NULL AUTO_INCREMENT,
    handle VARCHAR(50) NOT NULL UNIQUE,
    email VARCHAR(50) NOT NULL UNIQUE,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    phonenumber CHAR(10) UNIQUE,
    created_at TIMESTAMP NOT NULL DEFAULT(NOW()),
    follower_count INT DEFAULT 0,
    PRIMARY KEY(id)
);
 /* Agregando informacion a la base de datos usuario */
INSERT INTO user(handle,email,first_name,last_name,phonenumber) 
VALUES 
('samuelalvarez','lineaddr2004@gmail.com','Samuel','Alvarez','6885636945'),
('maritzasilva','maritza2000@gmail.com','Maritza','Silva','5236953232'),
('nicolasgarcia','nicogarcia@gmail.com','Nicolas','Garcia','9952364521'),
('luisalvarez','luicito63@gmail.com','Luis','Alvarez','3186540632'),
('andresalvarez','luisandresalvarez2006@gmail.com','Andres','Alvarez','2589653213'),
('brucewayne','brucewayne2021@gmail.com','Bruce','Wayne','9563215687'),
('simonelnegro','simon2019@gmail.com','Simon','ElNegro','2586933654');

DROP TABLE IF EXISTS follower;
CREATE TABLE follower(
    id INT NOT NULL,
    followingIdFk INT NOT NULL,
    FOREIGN KEY(id) REFERENCES user(id),
    FOREIGN KEY(followingIdFk) REFERENCES user(id),
    PRIMARY KEY(id,followingIdFk)
);


/*Añadir Constraint a follower para checkear que un usuario no se pueda autoseguir*/
ALTER TABLE follower
ADD CONSTRAINT check_follower_id
CHECK(id <> followingIdFk); /* Que sea diferente entre si !=  */

/* Creando consultas */
SELECT id,followingIdFk FROM follower;
SELECT id FROM follower WHERE followingIdFk=1;
SELECT COUNT(id) AS followers FROM follower WHERE followingIdFk=1;

/* Top 3 usuarios con mayor numero de seguidores */
SELECT followingIdFk, COUNT(id) AS followers
FROM follower
GROUP BY followingIdFk
ORDER BY followers DESC
LIMIT 3;

/* Top 3 usuarios usando el Join */
SELECT user.id, user.handle, user.first_name, follower.followingIdFk, COUNT(follower.id) AS followers
FROM follower
JOIN user ON user.id = follower.followingIdFk
GROUP BY follower.followingIdFk
ORDER BY followers DESC
LIMIT 3;

CREATE TABLE tweet(
    id INT NOT NULL AUTO_INCREMENT,
    userIdFk INT NOT NULL,
    tweet_text VARCHAR(280) NOT NULL,
    num_likes INT DEFAULT 0,
    num_retweets INT DEFAULT 0,
    num_comments INT DEFAULT 0,
    created_at TIMESTAMP NOT NULL DEFAULT (NOW()),
    FOREIGN KEY (userIdFk) REFERENCES user(id),
    PRIMARY KEY(id)
);

INSERT INTO tweet(userIdFk,tweet_text)
VALUES
(1,'¡Hola, soy Samuel! ¿Que tal? 🥑'),
(2,'¡Hola, soy Maritza! ¿Que tal? 🌱'),
(3,'¡Hola, soy Nicolas! ¿Que tal? 🐶'),
(4,'¡Hola, soy Luis! ¿Que tal? 🥦'),
(5,'¡Hola, soy Andres! ¿Que tal? 🍕'),
(6,'¡Hola, soy Bruce! ¿Que tal? 🍗'),
(7,'¡Hola, soy Simon! ¿Que tal? 💎'),
(1,'¡Hola, Nicolas! ¿Que tal? ❓'),
(3,'¡Hola, Samuel! ¿Que tal? ❗');


/* ¿Cuantos tweets ha hecho un usuario? */
SELECT userIdFk,COUNT(*) AS tweet_count
FROM tweet
GROUP BY userIdFk;

/* SubConsulta Obtener los tweets de los usuarios que tienen mas de 2 seguidores */
SELECT id,tweet_text,userIdFk
FROM tweet
WHERE userIdFk IN (
    SELECT followingIdFk
    FROM follower
    GROUP BY followingIdFk
    HAVING  COUNT(*) > 2
);

/* Consultas usando DELETE */
DELETE FROM tweet WHERE id=9;
DELETE FROM tweet WHERE userIdFk=5;
DELETE FROM tweet WHERE tweet_text LIKE '%Luis%';

/* Consultas usando UPDATE */
UPDATE tweet SET num_comments=num_comments+1 WHERE id=2;
UPDATE tweet SET tweet_text=REPLACE(tweet_text, 'Samuel','Jose')
WHERE tweet_text LIKE '%Samuel%';

CREATE TABLE tweet_likes(
    userIdFk INT NOT NULL,
    tweetIdFk INT NOT NULL,
    FOREIGN KEY(userIdFk) REFERENCES user(id),
    FOREIGN KEY(tweetIdFk) REFERENCES tweet(id),
    PRIMARY KEY (userIdFk,tweetIdFk)
);

INSERT INTO tweet_likes(userIdFk,tweetIdFk)
VALUES
(1,2),
(2,1),
(3,4),
(4,3),
(5,6),
(6,5);

/* Obetener el numero de likes por cada tweet */
SELECT tweetIdFk,COUNT(*) AS like_count
FROM tweet_likes
GROUP BY tweetIdFk;


/* TRIGGERS */
DELIMITER $$

CREATE TRIGGER increase_follower
    AFTER INSERT ON follower
    FOR EACH ROW
    BEGIN
        UPDATE user SET follower_count = follower_count+1
        WHERE id=NEW.followingIdFk;
    END $$

DELIMITER ;

DELIMITER $$

CREATE TRIGGER decrease_follower
    AFTER INSERT ON follower
    FOR EACH ROW
    BEGIN
        UPDATE user SET follower_count = follower_count-1
        WHERE id=NEW.followingIdFk;
    END $$

DELIMITER ;


INSERT INTO follower(id,followingIdFk) 
VALUES
(1,3),
(3,1),
(1,6),
(6,1),
(1,7),
(7,1),
(1,2),
(2,1),
(1,4),
(4,1),
(1,5),
(5,1);