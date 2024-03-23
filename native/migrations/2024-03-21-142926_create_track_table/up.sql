CREATE TABLE IF NOT EXISTS track (
    id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
    picture_id TEXT,
    album_id INTEGER,
    artist_id INTEGER,
    title TEXT,
    duration_ms INTEGER NOT NULL,
    location TEXT NOT NULL UNIQUE,
    mount_point TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    FOREIGN KEY (album_id) REFERENCES album(id),
    FOREIGN KEY (artist_id) REFERENCES artist(id)
);

CREATE INDEX IF NOT EXISTS index_track_title ON track(title);

CREATE INDEX IF NOT EXISTS index_track_album_id ON track(album_id);
CREATE INDEX IF NOT EXISTS index_track_artist_id ON track(artist_id);