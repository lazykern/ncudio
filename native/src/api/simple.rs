use std::{fs, sync::OnceLock};

const CONFIG_PATH: &str = "/home/lazykern/.config/ncudio";
const CACHE_PATH: &str = "/home/lazykern/.cache/ncudio";
const DATA_PATH: &str = "/home/lazykern/.local/share/ncudio";


use std::path::PathBuf;

use jwalk::WalkDir;
use lofty::{Accessor, AudioFile, ItemKey, Probe, TaggedFileExt};
use migration::{Alias, Expr, OnConflict};
use rayon::iter::{ParallelBridge, ParallelIterator};
use sea_orm::{ActiveModelTrait, ActiveValue, EntityTrait, FromQueryResult, JoinType, QueryFilter, QuerySelect, Related, RelationTrait};

use crate::entity;

static DB: OnceLock<sea_orm::DatabaseConnection> = OnceLock::new();

#[flutter_rust_bridge::frb(sync)]
pub fn get_db_url() -> String {
    format!("sqlite://{}/ncudio.db", CONFIG_PATH)
}

#[flutter_rust_bridge::frb(sync)]
pub fn get_config_path() -> String {
    CONFIG_PATH.to_string()
}

#[flutter_rust_bridge::frb(sync)]
pub fn get_cache_path() -> String {
    CACHE_PATH.to_string()
}

#[flutter_rust_bridge::frb(sync)]
pub fn get_data_path() -> String {
    DATA_PATH.to_string()
}

#[flutter_rust_bridge::frb(init)]
pub fn frb_init() {
    // Default utilities - feel free to customize
    flutter_rust_bridge::setup_default_user_utils();
}

pub async fn initialze_app() {
    fs::create_dir_all(CACHE_PATH).unwrap();
    fs::create_dir_all(DATA_PATH).unwrap();

    let connection_options = sea_orm::ConnectOptions::new(get_db_url());
    let connection = sea_orm::SqlxSqliteConnector::connect(connection_options).await.unwrap();
    DB.set(connection).unwrap();
}

struct TrackData {
    title: Option<String>,
    album: Option<String>,
    album_artist: Option<String>,
    artist: Option<String>,
    duration: i32,
    file: String,
    directory: String,
    picture_id: Option<String>,
    mount_point: String,
}


fn parse_music_file<P: AsRef<std::path::Path>>(path: P, mount_point: &P) -> Option<TrackData> {
    let path = path.as_ref();
    let mount_point = mount_point.as_ref();

    if path.is_dir() {
        return None;
    }

    let ext = path.extension()?;

    if ext != "mp3" && ext != "flac" && ext != "wav" && ext != "ogg" {
        return None;
    }

    let probe = Probe::open(path).ok()?;
    let tagged_file = probe.read().ok()?;

    let properties = tagged_file.properties();

    let file = path.file_name()?.to_string_lossy().to_string();
    let dir_path = path.parent()?.to_string_lossy().to_string();
    let duration_ms = properties.duration().as_millis() as i32;

    let mut track_data = TrackData {
        title: None,
        album: None,
        album_artist: None,
        artist: None,
        duration: duration_ms,
        file,
        picture_id: None,
        directory: dir_path,
        mount_point: mount_point.to_string_lossy().to_string(),
    };

    let tag = match tagged_file.primary_tag() {
        Some(primary_tag) => primary_tag,
        None => match tagged_file.first_tag() {
            Some(first_tag) => first_tag,
            None => return Some(track_data),
        },
    };

    track_data.title = tag.title().map(|s| s.to_string());
    track_data.album = tag.album().map(|s| s.to_string());
    track_data.artist = tag.artist().map(|s| s.to_string());
    track_data.album_artist = tag.get_string(&ItemKey::AlbumArtist).map(|s| s.to_string());


    if let Some(picture) = tag.pictures().first() {
        let picture_id_digest = md5::compute(picture.data());
        let picture_id = format!("{:x}", picture_id_digest);
        let mut picture_path = PathBuf::from(CACHE_PATH).join(&picture_id);

        picture_path.set_extension("jpg");
        fs::write(&picture_path, picture.data()).ok();

        if picture_path.exists() {
            track_data.picture_id = Some(picture_id);
        }
    }

    Some(track_data)
}


pub fn pick_directory() -> Option<String> {
    rfd::FileDialog::new()
        .pick_folder()
        .map(|s| s.to_string_lossy().to_string())
}

pub async fn sync_directory(mount_point: String) {
    let mount_point = PathBuf::from(mount_point);

    let track_data_vec: Vec<TrackData> = WalkDir::new(&mount_point)
        .into_iter()
        .par_bridge()
        .filter_map(|e| e.ok())
        .filter_map(|e| parse_music_file(e.path(), &mount_point))
        .collect();

    let db = DB.get().unwrap();

    for track_data in track_data_vec {
        let mut track = entity::track::ActiveModel {
            id: ActiveValue::NotSet,
            title: ActiveValue::Set(track_data.title),
            album_id: ActiveValue::NotSet,
            artist_id: ActiveValue::NotSet,
            duration: ActiveValue::Set(track_data.duration),
            file_path: ActiveValue::Set(track_data.file),
            picture_id: ActiveValue::Set(track_data.picture_id),
            mount_point: ActiveValue::Set(track_data.mount_point),
            created_at: ActiveValue::NotSet,
        };

        let artist_model = match track_data.artist {
            Some(artist) => Some(
                crate::entity::artist::ActiveModel {
                    id: ActiveValue::NotSet,
                    name: ActiveValue::Set(artist),
                    created_at: ActiveValue::NotSet,
                },
            ),
            None => None,
        };

        let artist = match artist_model {
            Some(artist) => entity::artist::Entity::insert(artist)
            .on_conflict(OnConflict::column(entity::artist::Column::Name).do_nothing().to_owned())
            .exec_with_returning(db)
            .await.ok(),
            None => None,
        };

        let artist_id = match artist {
            Some(artist) => Some(artist.id),
            None => None,
        };

        let album_artist_model = match track_data.album_artist {
            Some(album_artist) => Some(
                crate::entity::artist::ActiveModel {
                    id: ActiveValue::NotSet,
                    name: ActiveValue::Set(album_artist),
                    created_at: ActiveValue::NotSet,
                },
            ),
            None => None,
        };

        let album_artist = match album_artist_model {
            Some(album_artist) => entity::artist::Entity::insert(album_artist)
            .on_conflict(OnConflict::column(entity::artist::Column::Name).do_nothing().to_owned())
            .exec_with_returning(db)
            .await.ok(),
            None => None,
        };

        let album_artist_id = match album_artist {
            Some(album_artist) => Some(album_artist.id),
            None => None,
        };

        track.artist_id = ActiveValue::Set(artist_id);

        let album_model = match track_data.album {
            Some(album) => Some(
                crate::entity::album::ActiveModel {
                    id: ActiveValue::NotSet,
                    name: ActiveValue::Set(album),
                    artist_id: ActiveValue::Set(album_artist_id),
                    created_at: ActiveValue::NotSet,
                },
            ),
            None => None,
        };

        let album = match album_model {
            Some(album) => entity::album::Entity::insert(album)
            .on_conflict(OnConflict::column(entity::album::Column::Name).do_nothing().to_owned())
            .exec_with_returning(db)
            .await.ok(),
            None => None,
        };

        let album_id = match album {
            Some(album) => Some(album.id),
            None => None,
        };

        track.album_id = ActiveValue::Set(album_id);

        entity::track::Entity::insert(track)
            .on_conflict(OnConflict::column(entity::track::Column::FilePath).do_nothing().to_owned())
            .exec(db)
            .await
            .ok();
    }
}

#[derive(FromQueryResult)]
pub struct TrackDTO {
    pub title: Option<String>,
    pub album: Option<String>,
    pub artist: Option<String>,
    pub duration: i32,
    pub file_path: String,
    pub picture_id: Option<String>,
    pub mount_point: String,
}
pub async fn get_all_tracks() -> Vec<TrackDTO> {
    let db = DB.get().unwrap();

    entity::track::Entity::find()
    .join_as_rev(
        JoinType::LeftJoin,
        entity::track::Relation::Album.def(),
        Alias::new("al"),
    )
    .join_as_rev(
        JoinType::LeftJoin,
        entity::track::Relation::Artist.def(),
        Alias::new("ar"),
    )
    .columns([
        entity::track::Column::Title,
        entity::track::Column::Duration,
        entity::track::Column::FilePath,
        entity::track::Column::PictureId,
        entity::track::Column::MountPoint,
    ])
    .column_as(
        Expr::col((Alias::new("al"), entity::album::Column::Name)),
        "album",
    )
    .column_as(
        Expr::col((Alias::new("ar"), entity::artist::Column::Name)),
        "artist",
    )
    .into_model::<TrackDTO>()
    .all(db)
    .await
    .unwrap()
}
