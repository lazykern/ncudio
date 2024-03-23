// This file is automatically generated, so please do not edit it.
// Generated by `flutter_rust_bridge`@ 2.0.0-dev.28.

// ignore_for_file: invalid_use_of_internal_member, unused_import, unnecessary_import

import '../frb_generated.dart';
import 'package:flutter_rust_bridge/flutter_rust_bridge_for_generated.dart';
import 'simple.dart';

bool trackQueryFilter(
        {required String query, required TrackDTO track, dynamic hint}) =>
    RustLib.instance.api
        .trackQueryFilter(query: query, track: track, hint: hint);

List<TrackDTO> sortTracksByTitle(
        {required List<TrackDTO> tracks, dynamic hint}) =>
    RustLib.instance.api.sortTracksByTitle(tracks: tracks, hint: hint);

List<TrackDTO> sortTracksByArtist(
        {required List<TrackDTO> tracks, dynamic hint}) =>
    RustLib.instance.api.sortTracksByArtist(tracks: tracks, hint: hint);

List<TrackDTO> sortTracksByAlbum(
        {required List<TrackDTO> tracks, dynamic hint}) =>
    RustLib.instance.api.sortTracksByAlbum(tracks: tracks, hint: hint);

List<TrackDTO> sortTracksByDuration(
        {required List<TrackDTO> tracks, dynamic hint}) =>
    RustLib.instance.api.sortTracksByDuration(tracks: tracks, hint: hint);
