use chrono::NaiveDateTime;

use crate::schema::track;

#[derive(diesel::Insertable)]
#[diesel(table_name = track)]
pub struct NewTrack {
    pub picture_id: Option<String>,
    pub title: Option<String>,
    pub artist: Option<String>,
    pub album: Option<String>,
    pub duration_ms: i32,
    pub file: String,
    pub directory: String,
    pub mount_point: String,
}

#[derive(diesel::Queryable)]
#[diesel(table_name = track)]
pub struct Track {
    pub id: i32,
    pub picture_id: Option<String>,
    pub title: Option<String>,
    pub artist: Option<String>,
    pub album: Option<String>,
    pub duration_ms: i32,
    pub file: String,
    pub directory: String,
    pub mount_point: String,
    pub created_at: NaiveDateTime,
}
