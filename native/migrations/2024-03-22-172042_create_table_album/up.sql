CREATE TABLE IF NOT EXISTS album (
    id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
    name TEXT NOT NULL,
    artist_id INTEGER,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    FOREIGN KEY (artist_id) REFERENCES artist(id)
    UNIQUE (name, artist_id)
);

CREATE INDEX IF NOT EXISTS index_album_name ON album(name);

CREATE INDEX IF NOT EXISTS index_album_artist_id ON album(artist_id);
CREATE UNIQUE INDEX IF NOT EXISTS idx_album_name_artist_id_unique ON album(name, artist_id);