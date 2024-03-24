use chrono::Duration;

use super::simple::TrackDTO;

#[flutter_rust_bridge::frb(sync)]
pub fn track_query_filter_condition(query: String, track: TrackDTO) -> bool {
    let query = query.to_lowercase();
    let track_name = track.title.unwrap_or_default().to_lowercase();
    let track_artist = track.artist.unwrap_or_default().to_lowercase();
    let track_album = track.album.unwrap_or_default().to_lowercase();

    if track_name.contains(&query) || track_artist.contains(&query) || track_album.contains(&query) {
        return true;
    }

    let query_kana = kakasi::convert(&query).romaji;

    if kakasi::convert(&track_name).romaji.contains(&query_kana) || kakasi::convert(&track_artist).romaji.contains(&query_kana) || kakasi::convert(&track_album).romaji.contains(&query_kana) {
        return true;
    }

    false
}

#[flutter_rust_bridge::frb(sync)]
pub fn duration_to_string(duration: Duration) -> String {
    let hours = duration.num_hours();
    let minutes = duration.num_minutes() % 60;
    let seconds = duration.num_seconds() % 60;

    if hours > 0 {
        format!("{:02}:{:02}:{:02}", hours, minutes, seconds)
    } else {
        format!("{:02}:{:02}", minutes, seconds)
    }
}