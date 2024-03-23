use super::simple::TrackDTO;
use wana_kana::ConvertJapanese;

#[flutter_rust_bridge::frb(sync)]
pub fn track_query_filter(query: String, track: TrackDTO) -> bool {
    let query = query.to_lowercase();
    let track_name = track.title.unwrap_or_default().to_lowercase();
    let track_artist = track.artist.unwrap_or_default().to_lowercase();
    let track_album = track.album.unwrap_or_default().to_lowercase();

    if track_name.contains(&query) || track_artist.contains(&query) || track_album.contains(&query) {
        return true;
    }

    let query_kana = query.to_romaji();
    let track_name_kana = track_name.to_romaji();
    let track_artist_kana = track_artist.to_romaji();
    let track_album_kana = track_album.to_kana();

    if track_name_kana.contains(&query_kana) || track_artist_kana.contains(&query_kana) || track_album_kana.contains(&query_kana) {
        return true;
    }

    false
}