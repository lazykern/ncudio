CREATE TABLE IF NOT EXISTS track (
    id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
    picture_id TEXT,
    title TEXT,
    artist TEXT,
    album TEXT,
    duration_ms INTEGER NOT NULL,
    file TEXT NOT NULL,
    directory TEXT NOT NULL,
    mount_point TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL
);