CREATE TABLE IF NOT EXISTS gutenberg_common.user (
    user_uid SERIAL PRIMARY KEY,
    user_email TEXT NOT NULL,
    user_password TEXT NOT NULL,
    user_firstname TEXT NOT NULL,
    user_lastname TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS gutenberg_common.book (
    book_uid SERIAL PRIMARY KEY,
    isbn13 VARCHAR(13) UNIQUE,
    isbn10 VARCHAR(10) UNIQUE,
    title TEXT,
    author TEXT,
    publisher TEXT,
    publication_date DATE,
    edition TEXT,
    genre TEXT,
    language TEXT,
    page_count INT,
    summary TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

ALTER TABLE gutenberg_common.user
ADD CONSTRAINT user_email_unique UNIQUE (user_email);

CREATE TABLE IF NOT EXISTS gutenberg_common.reading_list (
    reading_list_uid SERIAL PRIMARY KEY,
    user_id INT NOT NULL REFERENCES gutenberg_common.user(user_uid),
    title TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS gutenberg_common.lu_book_status (
    lu_book_status_uid SERIAL PRIMARY KEY,
    description TEXT NOT NULL UNIQUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO gutenberg_common.lu_book_status (description)
VALUES 
('Unread'), 
('In Progress'), 
('Finished');

CREATE TABLE IF NOT EXISTS gutenberg_common.reading_list_matrix (
    reading_list_matrix_uid SERIAL PRIMARY KEY,
    reading_list_id INT NOT NULL REFERENCES gutenberg_common.reading_list(reading_list_uid),
    book_id INT NOT NULL REFERENCES gutenberg_common.book(book_uid),
    status_id INT NOT NULL REFERENCES gutenberg_common.lu_book_status(lu_book_status_uid),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Creating registration key table to limit registrations

CREATE TABLE IF NOT EXISTS gutenberg_common.registration_key (
    registration_key_uid SERIAL PRIMARY KEY,
    key_code TEXT NOT NULL,
    used BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

ALTER TABLE gutenberg_common.registration_key
ADD CONSTRAINT registration_key_code_unique UNIQUE (key_code);

ALTER TABLE gutenberg_common.book 
ADD CONSTRAINT book_isbn_not_null 
CHECK (isbn13 IS NOT NULL OR isbn10 IS NOT NULL);

ALTER TABLE gutenberg_common.book 
ALTER COLUMN title SET NOT NULL,
ALTER COLUMN author SET NOT NULL;

--Setting cascade rules for foreign keys
ALTER TABLE gutenberg_common.reading_list
DROP CONSTRAINT IF EXISTS reading_list_user_id_fkey;

ALTER TABLE gutenberg_common.reading_list_matrix 
ADD CONSTRAINT reading_list_user_id_fkey FOREIGN KEY (user_id) 
REFERENCES gutenberg_common.user(user_uid)
ON DELETE CASCADE;

ALTER TABLE gutenberg_common.reading_list_matrix
DROP CONSTRAINT IF EXISTS reading_list_matrix_book_id_fkey;

ALTER TABLE gutenberg_common.reading_list_matrix
DROP CONSTRAINT IF EXISTS reading_list_matrix_reading_list_id_fkey;

ALTER TABLE gutenberg_common.reading_list_matrix 
ADD CONSTRAINT reading_list_matrix_book_id_fkey FOREIGN KEY (book_id) 
REFERENCES gutenberg_common.book(book_uid)
ON DELETE CASCADE;

ALTER TABLE gutenberg_common.reading_list_matrix 
ADD CONSTRAINT reading_list_matrix_reading_list_id_fkey FOREIGN KEY (reading_list_id) 
REFERENCES gutenberg_common.reading_list(reading_list_uid)
ON DELETE CASCADE;

ALTER TABLE gutenberg_common.reading_list_matrix
ADD CONSTRAINT reading_list_matrix_book_id_reading_list_id_unique UNIQUE (book_id, reading_list_id);

-- Adding Unique Constraint to Reading List Title/UserId --
ALTER TABLE gutenberg_common.reading_list
ADD CONSTRAINT reading_list_title_user_id_unique UNIQUE (title, user_id);

-- Inserting Demo Book Data --
DELETE FROM gutenberg_common.book;
INSERT INTO gutenberg_common.book(isbn13, isbn10, title, author, publisher, publication_date, edition, genre, language, page_count, summary)
VALUES 
('9780141199078', '0141199075', 'Pride and Prejudice', 'Jane Austen', 'Penguin Classics', '1813-01-28', '1st', 'Classic Literature', 'English', 432, 'A romantic comedy of manners.'),
('9780445083769', '044508376X', 'To Kill a Mockingbird', 'Harper Lee', 'Harper Perennial Modern Classics', '1960-07-11', '1st', 'Classic Literature', 'English', 336, 'A powerful exploration of racial injustice and moral growth.'),
('9780812416299', '0812416295', '1984', 'George Orwell', 'Signet Classic', '1949-06-08', '1st', 'Classic Literature', 'English', 328, 'A dystopian novel exploring totalitarianism and surveillance.'),
('9780316769174', '0275965074', 'The Catcher in the Rye', 'J.D. Salinger', 'Back Bay Books', '1951-07-16', '1st', 'Classic Literature', 'English', 277, 'A coming-of-age novel.'),
('9780743273565', '0743273567', 'The Great Gatsby', 'F. Scott Fitzgerald', 'Scribner', '1925-04-10', '1st', 'Classic Literature', 'English', 180, 'Exploration of the American Dream and excess in the Jazz Age.'),
('9780142437247', '0142437247', 'Moby-Dick', 'Herman Melville', 'Penguin Classics', '1851-10-18', '1st', 'Classic Literature', 'English', 720, 'A tale of obsession and revenge.'),
('9780141040387', '0141040386', 'Jane Eyre', 'Charlotte Brontë', 'Penguin Classics', '1847-10-16', '1st', 'Classic Literature', 'English', 624, 'A bildungsroman.'),
('9780451530660', null, 'Dracula', 'Bram Stoker', 'Signet Classics', '1897-05-26', '1st', 'Classic Literature', 'English', 448, 'Gothic horror novel.'),
('9780486415871', '0486415872', 'Crime and Punishment', 'Fyodor Dostoevsky', 'Dover Publications', '1866-11-14', '1st', 'Classic Literature', 'English', 576, 'Psychological thriller exploring morality and redemption.'),
('9780143131847', '0143131842', 'Frankenstein', 'Mary Shelley', 'Penguin Classics', '1818-01-01', '1st', 'Classic Literature', 'English', 288, 'An exploration of creation and humanity.'),
('9780140444308', null, 'Les Misérables', 'Victor Hugo', 'Penguin Classics', '1862-01-01', '1st', 'Classic Literature', 'English', 1463, 'A story of love, redemption, and revolution.'),
('9781481928571', '1481928570', 'The Picture of Dorian Gray', 'Oscar Wilde', 'Simon & Schuster', '1890-07-20', '1st', 'Classic Literature', 'English', 254, 'A tale of vanity, hedonism, and the consequences of one man''s actions.'),
('9781548169879', '1548169870', 'Wuthering Heights', 'Emily Brontë', 'Penguin Classics', '1847-12-19', '1st', 'Classic Literature', 'English', 416, 'A tale of love, revenge, and the supernatural.'),
('9781541013315', '154101331X', 'Great Expectations', 'Charles Dickens', 'Penguin Classics', '1861-12-01', '1st', 'Classic Literature', 'English', 544, 'A bildungsroman.'),
('9780141439648', '0141439645', 'The Adventures of Huckleberry Finn', 'Mark Twain', 'Penguin Classics', '1884-12-10', '1st', 'Classic Literature', 'English', 327, 'A picaresque novel.'),
('9780143105442', '0143105442', 'The Scarlet Letter', 'Nathaniel Hawthorne', 'Penguin Classics', '1850-03-16', '1st', 'Classic Literature', 'English', 256, 'Exploration of sin, guilt, and redemption.'),
('9780141439549', '0141439548', 'Middlemarch', 'George Eliot', 'Penguin Classics', '1871-12-01', '1st', 'Classic Literature', 'English', 912, 'A study of provincial life.'),
('9780140440782', '014044078X', 'The Brothers Karamazov', 'Fyodor Dostoevsky', 'Penguin Classics', '1880-11-19', '1st', 'Classic Literature', 'English', 796, 'A philosophical novel.'),
('9780140449174', '0140449175', 'Anna Karenina', 'Leo Tolstoy', 'Penguin Classics', '1877-01-01', '1st', 'Classic Literature', 'English', 864, 'Exploration of themes such as love, family, and morality.');

-- Inserting Demo User Data --
DELETE FROM gutenberg_common.user;
INSERT INTO gutenberg_common.user(user_email, user_password, user_firstname, user_lastname)
VALUES 
('demo1@demo.com', '$2a$10$bHbtbwIDVGSwa9ZozCAodOBtRa4y9qiUiEjWjS0g73gAUkhvIqV9i', 'Demo', 'First'),
('demo2@demo.com', '$2a$10$bHbtbwIDVGSwa9ZozCAodOBtRa4y9qiUiEjWjS0g73gAUkhvIqV9i', 'Demo', 'Second');

-- Inserting Demo Reading List Data --
DELETE FROM gutenberg_common.reading_list;
INSERT INTO gutenberg_common.reading_list(user_id, title)
VALUES 
(
    (
        SELECT user_uid 
        FROM gutenberg_common.user
        WHERE user_email = 'demo1@demo.com'
    ),
    'Demo Reading List 1'
),
(
    (
        SELECT user_uid 
        FROM gutenberg_common.user
        WHERE user_email = 'demo1@demo.com'
    ),
    'Demo Reading List 2'
),
(
    (
        SELECT user_uid 
        FROM gutenberg_common.user
        WHERE user_email = 'demo2@demo.com'
    ),
    'Demo Reading List 3'
),
(
    (
        SELECT user_uid 
        FROM gutenberg_common.user
        WHERE user_email = 'demo2@demo.com'
    ),
    'Demo Reading List 4'
);

-- Inserting Demo Books Into Demo Reading Lists --
DELETE FROM gutenberg_common.reading_list_matrix;
INSERT INTO gutenberg_common.reading_list_matrix(reading_list_id, book_id, status_id)
VALUES 
(
    (
        SELECT reading_list_uid
        FROM gutenberg_common.reading_list
        WHERE user_id = (
            SELECT user_uid 
            FROM gutenberg_common.user
            WHERE user_email = 'demo1@demo.com'
            )
        AND title = 'Demo Reading List 1'
    ), 
    (
        SELECT book_uid
        FROM gutenberg_common.book
        WHERE isbn13 = '9780141199078'
    ), 
    (
        SELECT lu_book_status_uid
        FROM gutenberg_common.lu_book_status
        WHERE description = 'Unread'
    )
),
(
    (
        SELECT reading_list_uid
        FROM gutenberg_common.reading_list
        WHERE user_id = (
            SELECT user_uid 
            FROM gutenberg_common.user
            WHERE user_email = 'demo1@demo.com'
            )
        AND title = 'Demo Reading List 1'
    ), 
    (
        SELECT book_uid
        FROM gutenberg_common.book
        WHERE isbn13 = '9780445083769'
    ), 
    (
        SELECT lu_book_status_uid
        FROM gutenberg_common.lu_book_status
        WHERE description = 'In Progress'
    )
),
(
    (
        SELECT reading_list_uid
        FROM gutenberg_common.reading_list
        WHERE user_id = (
            SELECT user_uid 
            FROM gutenberg_common.user
            WHERE user_email = 'demo1@demo.com'
            )
        AND title = 'Demo Reading List 1'
    ), 
    (
        SELECT book_uid
        FROM gutenberg_common.book
        WHERE isbn13 = '9780812416299'
    ), 
    (
        SELECT lu_book_status_uid
        FROM gutenberg_common.lu_book_status
        WHERE description = 'Finished'
    )
),
(
    (
        SELECT reading_list_uid
        FROM gutenberg_common.reading_list
        WHERE user_id = (
            SELECT user_uid 
            FROM gutenberg_common.user
            WHERE user_email = 'demo1@demo.com'
            )
        AND title = 'Demo Reading List 2'
    ), 
    (
        SELECT book_uid
        FROM gutenberg_common.book
        WHERE isbn13 = '9780316769174'
    ), 
    (
        SELECT lu_book_status_uid
        FROM gutenberg_common.lu_book_status
        WHERE description = 'Unread'
    )
),
(
    (
        SELECT reading_list_uid
        FROM gutenberg_common.reading_list
        WHERE user_id = (
            SELECT user_uid 
            FROM gutenberg_common.user
            WHERE user_email = 'demo1@demo.com'
            )
        AND title = 'Demo Reading List 2'
    ), 
    (
        SELECT book_uid
        FROM gutenberg_common.book
        WHERE isbn13 = '9780743273565'
    ), 
    (
        SELECT lu_book_status_uid
        FROM gutenberg_common.lu_book_status
        WHERE description = 'In Progress'
    )
),
(
    (
        SELECT reading_list_uid
        FROM gutenberg_common.reading_list
        WHERE user_id = (
            SELECT user_uid 
            FROM gutenberg_common.user
            WHERE user_email = 'demo1@demo.com'
            )
        AND title = 'Demo Reading List 2'
    ), 
    (
        SELECT book_uid
        FROM gutenberg_common.book
        WHERE isbn13 = '9780142437247'
    ), 
    (
        SELECT lu_book_status_uid
        FROM gutenberg_common.lu_book_status
        WHERE description = 'Finished'
    )
),
(
    (
        SELECT reading_list_uid
        FROM gutenberg_common.reading_list
        WHERE user_id = (
            SELECT user_uid 
            FROM gutenberg_common.user
            WHERE user_email = 'demo2@demo.com'
            )
        AND title = 'Demo Reading List 3'
    ), 
    (
        SELECT book_uid
        FROM gutenberg_common.book
        WHERE isbn13 = '9780141040387'
    ), 
    (
        SELECT lu_book_status_uid
        FROM gutenberg_common.lu_book_status
        WHERE description = 'Unread'
    )
),
(
    (
        SELECT reading_list_uid
        FROM gutenberg_common.reading_list
        WHERE user_id = (
            SELECT user_uid 
            FROM gutenberg_common.user
            WHERE user_email = 'demo2@demo.com'
            )
        AND title = 'Demo Reading List 3'
    ), 
    (
        SELECT book_uid
        FROM gutenberg_common.book
        WHERE isbn13 = '9780451530660'
    ), 
    (
        SELECT lu_book_status_uid
        FROM gutenberg_common.lu_book_status
        WHERE description = 'In Progress'
    )
),
(
    (
        SELECT reading_list_uid
        FROM gutenberg_common.reading_list
        WHERE user_id = (
            SELECT user_uid 
            FROM gutenberg_common.user
            WHERE user_email = 'demo2@demo.com'
            )
        AND title = 'Demo Reading List 3'
    ), 
    (
        SELECT book_uid
        FROM gutenberg_common.book
        WHERE isbn13 = '9780486415871'
    ), 
    (
        SELECT lu_book_status_uid
        FROM gutenberg_common.lu_book_status
        WHERE description = 'Finished'
    )
),
(
    (
        SELECT reading_list_uid
        FROM gutenberg_common.reading_list
        WHERE user_id = (
            SELECT user_uid 
            FROM gutenberg_common.user
            WHERE user_email = 'demo2@demo.com'
            )
        AND title = 'Demo Reading List 4'
    ), 
    (
        SELECT book_uid
        FROM gutenberg_common.book
        WHERE isbn13 = '9780143131847'
    ), 
    (
        SELECT lu_book_status_uid
        FROM gutenberg_common.lu_book_status
        WHERE description = 'Unread'
    )
),
(
    (
        SELECT reading_list_uid
        FROM gutenberg_common.reading_list
        WHERE user_id = (
            SELECT user_uid 
            FROM gutenberg_common.user
            WHERE user_email = 'demo2@demo.com'
            )
        AND title = 'Demo Reading List 4'
    ), 
    (
        SELECT book_uid
        FROM gutenberg_common.book
        WHERE isbn13 = '9780140444308'
    ), 
    (
        SELECT lu_book_status_uid
        FROM gutenberg_common.lu_book_status
        WHERE description = 'In Progress'
    )
),
(
    (
        SELECT reading_list_uid
        FROM gutenberg_common.reading_list
        WHERE user_id = (
            SELECT user_uid 
            FROM gutenberg_common.user
            WHERE user_email = 'demo2@demo.com'
            )
        AND title = 'Demo Reading List 4'
    ), 
    (
        SELECT book_uid
        FROM gutenberg_common.book
        WHERE isbn13 = '9781481928571'
    ), 
    (
        SELECT lu_book_status_uid
        FROM gutenberg_common.lu_book_status
        WHERE description = 'Finished'
    )
);
