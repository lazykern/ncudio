// @generated automatically by Diesel CLI.

diesel::table! {
    track (id) {
        id -> Integer,
        picture_id -> Nullable<Text>,
        title -> Nullable<Text>,
        artist -> Nullable<Text>,
        album -> Nullable<Text>,
        duration_ms -> Integer,
        file -> Text,
        directory -> Text,
        mount_point -> Text,
        created_at -> Timestamp,
    }
}
