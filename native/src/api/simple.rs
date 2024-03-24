use std::{collections::HashMap, fs, ops::Deref};

use diesel::{
    BoolExpressionMethods, Connection, ExpressionMethods, JoinOnDsl, NullableExpressionMethods, QueryDsl, RunQueryDsl, SqliteConnection
};
use diesel_migrations::{embed_migrations, EmbeddedMigrations, MigrationHarness};

const MIGRATIONS: EmbeddedMigrations = embed_migrations!("migrations");
type DB = diesel::sqlite::Sqlite;
const CONFIG_PATH: &str = "/home/lazykern/.config/ncudio";
const CACHE_PATH: &str = "/home/lazykern/.cache/ncudio";
const DATA_PATH: &str = "/home/lazykern/.local/share/ncudio";

use std::path::PathBuf;

use jwalk::WalkDir;
use lofty::{Accessor, AudioFile, Probe, TaggedFileExt};
use rayon::iter::{ParallelBridge, ParallelIterator};

use crate::model::{Album, Artist, NewTrack, Track};

#[flutter_rust_bridge::frb(sync)]
pub fn get_db_url() -> String {
    format!("sqlite://{}/ncudio.db", DATA_PATH)
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

fn establish_connection() -> Result<SqliteConnection, diesel::ConnectionError> {
    fs::create_dir_all(CONFIG_PATH).unwrap();
    SqliteConnection::establish(&get_db_url())
}

fn run_migrations(connection: &mut impl MigrationHarness<DB>) -> Result<(), ()> {
    match connection.run_pending_migrations(MIGRATIONS) {
        Ok(m) => {
            for migration in m.iter() {
                println!("Ran migration: {}", migration);
            }
            Ok(())
        }
        Err(e) => {
            println!("Error running migrations: {:?}", e);
            return Err(());
        }
    }
}

#[flutter_rust_bridge::frb(init)]
pub fn frb_init() {
    // Default utilities - feel free to customize
    flutter_rust_bridge::setup_default_user_utils();
}

#[flutter_rust_bridge::frb(sync)]
pub fn initialize_app() {
    fs::create_dir_all(CACHE_PATH).unwrap();
    fs::create_dir_all(DATA_PATH).unwrap();
}

#[flutter_rust_bridge::frb(sync)]
pub fn initialize_db() {
    let mut connection = establish_connection().unwrap();
    run_migrations(&mut connection).unwrap();
}

struct ParsedTrack {
    title: Option<String>,
    artist: Option<String>,
    album: Option<String>,
    number: Option<i32>,
    disc: Option<i32>,
    duration_ms: i32,
    location: String,
    mount_point: String,
    picture_id: Option<String>,
}

fn parse_music_file<P: AsRef<std::path::Path>>(path: P, mount_point: &P) -> Option<ParsedTrack> {
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

    let location = path.to_string_lossy().to_string();
    let duration_ms = properties.duration().as_millis() as i32;

    let mut parsed_track = ParsedTrack {
        picture_id: None,
        title: None,
        number: None,
        disc: None,
        artist: None,
        album: None,
        location,
        duration_ms,
        mount_point: mount_point.to_string_lossy().to_string(),
    };

    let tag = match tagged_file.primary_tag() {
        Some(primary_tag) => primary_tag,
        None => match tagged_file.first_tag() {
            Some(first_tag) => first_tag,
            None => return Some(parsed_track),
        },
    };

    parsed_track.title = tag.title().map(|s| s.to_string());
    parsed_track.artist = tag.artist().map(|s| s.to_string());
    parsed_track.album = tag.album().map(|s| s.to_string());
    parsed_track.number = tag.track().map(|n| n as i32);
    parsed_track.disc = tag.disk().map(|n| n as i32);

    if let Some(picture) = tag.pictures().first() {
        let picture_id_digest = md5::compute(picture.data());
        let picture_id = format!("{:x}", picture_id_digest);
        let mut picture_path = PathBuf::from(CACHE_PATH).join(&picture_id);

        picture_path.set_extension("jpg");
        fs::write(&picture_path, picture.data()).ok();

        if picture_path.exists() {
            parsed_track.picture_id = Some(picture_id);
        }
    }

    Some(parsed_track)
}

pub fn sync_directory(mount_point: String) {
    use crate::model;
    use crate::schema::album::dsl as album_dsl;
    use crate::schema::artist::dsl as artist_dsl;
    use crate::schema::track::dsl as track_dsl;

    let mount_point = PathBuf::from(mount_point);

    let parsed_tracks: Vec<ParsedTrack> = WalkDir::new(&mount_point)
        .into_iter()
        .par_bridge()
        .filter_map(|e| e.ok())
        .filter_map(|e| parse_music_file(e.path(), &mount_point))
        .collect();

    let conn = &mut establish_connection().unwrap();

    for parsed_tracks in parsed_tracks {
        let new_artist = match parsed_tracks.artist {
            Some(artist) => Some(model::NewArtist { name: artist }),
            None => None,
        };
        let artist: Option<model::Artist> = match new_artist {
            Some(new_artist) => {
                let artist = artist_dsl::artist
                    .filter(artist_dsl::name.eq(&new_artist.name))
                    .first(conn)
                    .ok();

                match artist {
                    Some(artist) => Some(artist),
                    None => {
                        let _ = diesel::insert_into(artist_dsl::artist)
                            .values(&new_artist)
                            .execute(conn);
                        artist_dsl::artist
                            .filter(artist_dsl::name.eq(&new_artist.name))
                            .first(conn)
                            .ok()
                    }
                }
            }
            None => None,
        };

        let new_album = match parsed_tracks.album {
            Some(album) => Some(model::NewAlbum {
                name: album,
                artist_id: artist.as_ref().map(|a| a.id),
            }),
            None => None,
        };

        let album: Option<model::Album> = match new_album {
            Some(new_album) => {
                let album = album_dsl::album
                    .filter(album_dsl::name.eq(&new_album.name))
                    .first(conn)
                    .ok();

                match album {
                    Some(album) => Some(album),
                    None => {
                        let _ = diesel::insert_into(album_dsl::album)
                            .values(&new_album)
                            .execute(conn);
                        album_dsl::album
                            .filter(album_dsl::name.eq(&new_album.name))
                            .first(conn)
                            .ok()
                    }
                }
            }
            None => None,
        };

        let new_track = NewTrack {
            picture_id: parsed_tracks.picture_id,
            album_id: album.as_ref().map(|a| a.id),
            artist_id: artist.as_ref().map(|a| a.id),
            number: parsed_tracks.number,
            disc: parsed_tracks.disc,
            title: parsed_tracks.title,
            duration_ms: parsed_tracks.duration_ms,
            location: parsed_tracks.location,
            mount_point: parsed_tracks.mount_point,
        };

        let res = diesel::insert_into(track_dsl::track)
            .values(&new_track)
            .on_conflict(track_dsl::location).do_update()
            .set(&new_track)
            .execute(conn);

        if let Err(e) = res {
            println!("Error inserting track: {:?}", e);
        }
    }
}

pub struct TrackDTO {
    pub id: i32,
    pub title: Option<String>,
    pub artist: Option<Artist>,
    pub album: Option<Album>,
    pub number: Option<i32>,
    pub disc: Option<i32>,
    pub duration_ms: i32,
    pub location: String,
    pub mount_point: String,
    pub picture_id: Option<String>,
}

pub fn get_all_tracks() -> Vec<TrackDTO> {
    use crate::schema;

    let conn = &mut establish_connection().unwrap();

    let tracks: Vec<Track> = schema::track::table.load(conn).unwrap();

    populate_tracks(conn, tracks)
}

pub fn get_all_track_ids_sorted_by_title() -> Vec<i32> {
    use crate::schema::track::dsl as track_dsl;

    let conn = &mut establish_connection().unwrap();

    track_dsl::track
        .select(track_dsl::id)
        .order_by((track_dsl::title, track_dsl::album_id, track_dsl::artist_id, track_dsl::disc, track_dsl::number))
        .load(conn)
        .unwrap()
}

pub fn get_all_track_ids_sorted_by_artist() -> Vec<i32> {
    use crate::schema::track::dsl as track_dsl;
    use crate::schema;

    let conn = &mut establish_connection().unwrap();

    track_dsl::track
        .select(track_dsl::id)
        .left_join(
            schema::artist::table.on(schema::track::artist_id.eq(schema::artist::id.nullable())),
        )
        .order_by((schema::artist::name, schema::track::album_id, schema::track::disc, schema::track::number))
        .load(conn)
        .unwrap()
}

pub fn get_all_track_ids_sorted_by_album() -> Vec<i32> {
    use crate::schema::track::dsl as track_dsl;
    use crate::schema;

    let conn = &mut establish_connection().unwrap();

    track_dsl::track
        .select(track_dsl::id)
        .left_join(
            schema::album::table.on(schema::track::album_id.eq(schema::album::id.nullable())),
        )
        .order_by((schema::album::name, schema::track::disc, schema::track::number))
        .load(conn)
        .unwrap()
}

pub fn get_all_track_ids_sorted_by_duration() -> Vec<i32> {
    use crate::schema::track::dsl as track_dsl;

    let conn = &mut establish_connection().unwrap();

    track_dsl::track
        .select(track_dsl::id)
        .order_by((track_dsl::duration_ms, track_dsl::title))
        .load(conn)
        .unwrap()
}

fn populate_tracks(conn: &mut SqliteConnection, tracks: Vec<Track>) -> Vec<TrackDTO> {
    use crate::schema::album::dsl as album_dsl;
    use crate::schema::artist::dsl as artist_dsl;

    let mut artist_cache: HashMap<i32, Artist> = HashMap::new();
    let mut album_cache:HashMap<i32, Album> = HashMap::new();
    let mut track_dtos = Vec::new();

    for track in tracks {
        let artist: Option<Artist> = match track.artist_id {
            Some(artist_id) => {
                if let Some(artist) = artist_cache.get(&artist_id) {
                    Some(artist.clone())
                } else {
                    let artist: Option<Artist> = artist_dsl::artist
                        .filter(artist_dsl::id.eq(artist_id))
                        .first(conn)
                        .ok();

                    match artist {
                        Some(artist) => {
                            artist_cache.insert(artist_id, artist.clone());
                            Some(artist)
                        }
                        None => None,
                    }
                }
            }
            None => None,
        };

        let album = match track.album_id {
            Some(album_id) => {
                if let Some(album) = album_cache.get(&album_id) {
                    Some(album.clone())
                } else {
                    let album: Option<Album> = album_dsl::album
                        .filter(album_dsl::id.eq(album_id))
                        .first(conn)
                        .ok();

                    match album {
                        Some(album) => {
                            album_cache.insert(album_id, album.clone());
                            Some(album)
                        }
                        None => None,
                    }
                }
            }
            None => None,
        };

        track_dtos.push(TrackDTO {
            id: track.id,
            title: track.title,
            artist,
            album,
            number: track.number,
            disc: track.disc,
            duration_ms: track.duration_ms,
            location: track.location,
            mount_point: track.mount_point,
            picture_id: track.picture_id,
        });
    };

    track_dtos
}

pub fn delete_all_tracks() {
    use crate::schema::track::dsl as track_dsl;

    let conn = &mut establish_connection().unwrap();

    diesel::delete(track_dsl::track).execute(conn).unwrap();
}

pub fn find_track_by_album(album_id: i32) -> Vec<TrackDTO> {
    use crate::schema::track::dsl as track_dsl;

    let conn = &mut establish_connection().unwrap();

    let tracks: Vec<Track> = track_dsl::track
        .filter(track_dsl::album_id.eq(album_id))
        .order_by((track_dsl::number, track_dsl::disc))
        .load(conn)
        .unwrap();

    populate_tracks(conn, tracks)
}

pub fn pick_directory() -> Option<String> {
    rfd::FileDialog::new()
        .pick_folder()
        .map(|s| s.to_string_lossy().to_string())
}
