// @generated automatically by Diesel CLI.

diesel::table! {
    album (id) {
        id -> Integer,
        name -> Text,
        artist_id -> Nullable<Integer>,
        created_at -> Timestamp,
    }
}

diesel::table! {
    artist (id) {
        id -> Integer,
        name -> Text,
        created_at -> Timestamp,
    }
}

diesel::table! {
    track (id) {
        id -> Integer,
        picture_id -> Nullable<Text>,
        album_id -> Nullable<Integer>,
        artist_id -> Nullable<Integer>,
        title -> Nullable<Text>,
        duration_ms -> Integer,
        location -> Text,
        mount_point -> Text,
        created_at -> Timestamp,
    }
}

diesel::joinable!(album -> artist (artist_id));
diesel::joinable!(track -> album (album_id));
diesel::joinable!(track -> artist (artist_id));

diesel::allow_tables_to_appear_in_same_query!(
    album,
    artist,
    track,
);
