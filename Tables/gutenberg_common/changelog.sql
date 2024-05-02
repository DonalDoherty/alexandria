CREATE TABLE IF NOT EXISTS gutenberg_common.user (
    user_uid SERIAL PRIMARY KEY,
    user_email TEXT NOT NULL,
    user_password TEXT NOT NULL,
    user_firstname TEXT NOT NULL,
    user_lastname TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO gutenberg_common.user(user_email, user_password, user_firstname, user_lastname)
VALUES('testuser@fakewebsite.com', '10d1d6842b5e0041a01505ba8c04d0ea0ff3fe046b6d88831db0e292327db888', 'Test', 'User');

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

INSERT INTO gutenberg_common.user(user_email, user_password, user_firstname, user_lastname)
VALUES('demo@fakewebsite.com', '46fb9cf091683f102718ac61df347e3a2f497c1109b76feacd5b1adb6380e91a', 'Demo', 'User');

INSERT INTO gutenberg_common.reading_list (user_id, title)
VALUES (
    (SELECT user_uid 
    FROM gutenberg_common.user
    WHERE user_email = 'demo@fakewebsite.com'),
    'Demo Reading List');

INSERT INTO gutenberg_common.book(isbn13, isbn10, title, author, publisher, publication_date, edition, genre, language)
VALUES ('9780142437247', '0142437247', 'Moby Dick', 'Herman Melville', 'Penguin Classics', '2001-10-01', '1st', 'Fiction', 'English');

INSERT INTO gutenberg_common.reading_list_matrix(reading_list_id, book_id, status_id)
VALUES (
    (
        SELECT reading_list_uid
        FROM gutenberg_common.reading_list
        WHERE user_id = (
            SELECT user_uid 
            FROM gutenberg_common.user
            WHERE user_email = 'demo@fakewebsite.com'
            )
        AND title = 'Demo Reading List'
    ), 
    (
        SELECT book_uid
        FROM gutenberg_common.book
        WHERE isbn13 = '9780142437247'
    ), 
    (
        SELECT lu_book_status_uid
        FROM gutenberg_common.lu_book_status
        WHERE description = 'Unread'
    )
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
