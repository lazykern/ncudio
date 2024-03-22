use std::fs;

use diesel::{
    BoolExpressionMethods, Connection, ConnectionError, ExpressionMethods, QueryDsl, RunQueryDsl,
    SqliteConnection,
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

use crate::{
    model::{NewTrack, Track},
    schema,
};

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
pub fn initialze_app() {
    fs::create_dir_all(CACHE_PATH).unwrap();
    fs::create_dir_all(DATA_PATH).unwrap();
}

#[flutter_rust_bridge::frb(sync)]
pub fn initialize_db() {
    let mut connection = establish_connection().unwrap();
    run_migrations(&mut connection).unwrap();
}

fn parse_music_file<P: AsRef<std::path::Path>>(path: P, mount_point: &P) -> Option<NewTrack> {
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

    let mut new_track = NewTrack {
        picture_id: None,
        title: None,
        artist: None,
        album: None,
        duration_ms: duration_ms,
        file,
        directory: dir_path,
        mount_point: mount_point.to_string_lossy().to_string(),
    };

    let tag = match tagged_file.primary_tag() {
        Some(primary_tag) => primary_tag,
        None => match tagged_file.first_tag() {
            Some(first_tag) => first_tag,
            None => return Some(new_track),
        },
    };

    new_track.title = tag.title().map(|s| s.to_string());
    new_track.artist = tag.artist().map(|s| s.to_string());
    new_track.album = tag.album().map(|s| s.to_string());

    if let Some(picture) = tag.pictures().first() {
        let picture_id_digest = md5::compute(picture.data());
        let picture_id = format!("{:x}", picture_id_digest);
        let mut picture_path = PathBuf::from(CACHE_PATH).join(&picture_id);

        picture_path.set_extension("jpg");
        fs::write(&picture_path, picture.data()).ok();

        if picture_path.exists() {
            new_track.picture_id = Some(picture_id);
        }
    }

    Some(new_track)
}

pub fn sync_directory(mount_point: String) {
    use crate::schema::track;

    let mount_point = PathBuf::from(mount_point);

    let new_tracks: Vec<NewTrack> = WalkDir::new(&mount_point)
        .into_iter()
        .par_bridge()
        .filter_map(|e| e.ok())
        .filter_map(|e| parse_music_file(e.path(), &mount_point))
        .collect();

    let conn = &mut establish_connection().unwrap();

    for new_track in new_tracks {
        diesel::delete(
            track::table.filter(
                track::directory.eq(&new_track.mount_point).and(
                    track::directory
                        .eq(&new_track.directory)
                        .and(track::file.eq(&new_track.file)),
                ),
            ),
        )
        .execute(conn)
        .unwrap();

        match diesel::insert_into(track::table)
            .values(&new_track)
            .execute(conn)
        {
            Ok(_) => (),
            Err(e) => println!("Error inserting track: {:?}", e),
        }
    }
}

pub fn get_all_tracks() -> Vec<Track> {
    use crate::schema::track::dsl::*;

    let conn = &mut establish_connection().unwrap();

    track.load(conn).unwrap()
}

pub fn pick_directory() -> Option<String> {
    rfd::FileDialog::new()
        .pick_folder()
        .map(|s| s.to_string_lossy().to_string())
}
