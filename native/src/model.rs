use chrono::NaiveDateTime;

use crate::schema::*;

#[derive(diesel::Insertable, diesel::AsChangeset)]
#[diesel(table_name = track)]
pub struct NewTrack {
    pub picture_id: Option<String>,
    pub album_id: Option<i32>,
    pub artist_id: Option<i32>,
    pub title: Option<String>,
    pub duration_ms: i32,
    pub location: String,
    pub mount_point: String,
}

#[derive(diesel::Queryable, diesel::Selectable, diesel::Identifiable, diesel::Associations)]
#[belongs_to(Album, foreign_key = "album_id")]
#[belongs_to(Artist, foreign_key = "artist_id")]
#[diesel(table_name = track)]
pub struct Track {
    pub id: i32,
    pub picture_id: Option<String>,
    pub album_id: Option<i32>,
    pub artist_id: Option<i32>,
    pub title: Option<String>,
    pub duration_ms: i32,
    pub location: String,
    pub mount_point: String,
    pub created_at: NaiveDateTime,
}

#[derive(diesel::Insertable)]
#[diesel(table_name = album)]
pub struct NewAlbum {
    pub name: String,
    pub artist_id: Option<i32>,
}


#[derive(diesel::Queryable, diesel::Selectable, diesel::Identifiable)]
#[diesel(table_name = album)]
pub struct Album {
    pub id: i32,
    pub name: String,
    pub artist_id: Option<i32>,
    pub created_at: NaiveDateTime,
}

#[derive(diesel::Insertable)]
#[diesel(table_name = artist)]
pub struct NewArtist {
    pub name: String,
}

#[derive(diesel::Queryable, diesel::Selectable, diesel::Identifiable)]
#[diesel(table_name = artist)]
pub struct Artist {
    pub id: i32,
    pub name: String,
    pub created_at: NaiveDateTime,
}