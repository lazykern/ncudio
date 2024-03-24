// This file is automatically generated, so please do not edit it.
// Generated by `flutter_rust_bridge`@ 2.0.0-dev.28.

// ignore_for_file: unused_import, unused_element, unnecessary_import, duplicate_ignore, invalid_use_of_internal_member, annotate_overrides, non_constant_identifier_names, curly_braces_in_flow_control_structures, prefer_const_literals_to_create_immutables, unused_field

import 'api/simple.dart';
import 'api/utils.dart';
import 'dart:async';
import 'dart:convert';
import 'frb_generated.io.dart' if (dart.library.html) 'frb_generated.web.dart';
import 'model.dart';
import 'package:flutter_rust_bridge/flutter_rust_bridge_for_generated.dart';

/// Main entrypoint of the Rust API
class RustLib extends BaseEntrypoint<RustLibApi, RustLibApiImpl, RustLibWire> {
  @internal
  static final instance = RustLib._();

  RustLib._();

  /// Initialize flutter_rust_bridge
  static Future<void> init({
    RustLibApi? api,
    BaseHandler? handler,
    ExternalLibrary? externalLibrary,
  }) async {
    await instance.initImpl(
      api: api,
      handler: handler,
      externalLibrary: externalLibrary,
    );
  }

  /// Dispose flutter_rust_bridge
  ///
  /// The call to this function is optional, since flutter_rust_bridge (and everything else)
  /// is automatically disposed when the app stops.
  static void dispose() => instance.disposeImpl();

  @override
  ApiImplConstructor<RustLibApiImpl, RustLibWire> get apiImplConstructor =>
      RustLibApiImpl.new;

  @override
  WireConstructor<RustLibWire> get wireConstructor =>
      RustLibWire.fromExternalLibrary;

  @override
  Future<void> executeRustInitializers() async {
    await api.frbInit();
  }

  @override
  ExternalLibraryLoaderConfig get defaultExternalLibraryLoaderConfig =>
      kDefaultExternalLibraryLoaderConfig;

  @override
  String get codegenVersion => '2.0.0-dev.28';

  static const kDefaultExternalLibraryLoaderConfig =
      ExternalLibraryLoaderConfig(
    stem: 'rust_lib_ncudio',
    ioDirectory: 'native/target/release/',
    webPrefix: 'pkg/',
  );
}

abstract class RustLibApi extends BaseApi {
  Future<void> deleteAllTracks({dynamic hint});

  Future<List<TrackDTO>> findTrackByAlbum({required int albumId, dynamic hint});

  Future<void> frbInit({dynamic hint});

  Future<Int32List> getAllTrackIdsSortedByAlbum({dynamic hint});

  Future<Int32List> getAllTrackIdsSortedByArtist({dynamic hint});

  Future<Int32List> getAllTrackIdsSortedByDuration({dynamic hint});

  Future<Int32List> getAllTrackIdsSortedByTitle({dynamic hint});

  Future<List<TrackDTO>> getAllTracks({dynamic hint});

  String getCachePath({dynamic hint});

  String getConfigPath({dynamic hint});

  String getDataPath({dynamic hint});

  String getDbUrl({dynamic hint});

  void initializeApp({dynamic hint});

  void initializeDb({dynamic hint});

  Future<String?> pickDirectory({dynamic hint});

  Future<void> syncDirectory({required String mountPoint, dynamic hint});

  String durationToString({required Duration duration, dynamic hint});

  bool trackQueryFilterCondition(
      {required String query, required TrackDTO track, dynamic hint});
}

class RustLibApiImpl extends RustLibApiImplPlatform implements RustLibApi {
  RustLibApiImpl({
    required super.handler,
    required super.wire,
    required super.generalizedFrbRustBinding,
    required super.portManager,
  });

  @override
  Future<void> deleteAllTracks({dynamic hint}) {
    return handler.executeNormal(NormalTask(
      callFfi: (port_) {
        final serializer = SseSerializer(generalizedFrbRustBinding);
        pdeCallFfi(generalizedFrbRustBinding, serializer,
            funcId: 14, port: port_);
      },
      codec: SseCodec(
        decodeSuccessData: sse_decode_unit,
        decodeErrorData: null,
      ),
      constMeta: kDeleteAllTracksConstMeta,
      argValues: [],
      apiImpl: this,
      hint: hint,
    ));
  }

  TaskConstMeta get kDeleteAllTracksConstMeta => const TaskConstMeta(
        debugName: "delete_all_tracks",
        argNames: [],
      );

  @override
  Future<List<TrackDTO>> findTrackByAlbum(
      {required int albumId, dynamic hint}) {
    return handler.executeNormal(NormalTask(
      callFfi: (port_) {
        final serializer = SseSerializer(generalizedFrbRustBinding);
        sse_encode_i_32(albumId, serializer);
        pdeCallFfi(generalizedFrbRustBinding, serializer,
            funcId: 15, port: port_);
      },
      codec: SseCodec(
        decodeSuccessData: sse_decode_list_track_dto,
        decodeErrorData: null,
      ),
      constMeta: kFindTrackByAlbumConstMeta,
      argValues: [albumId],
      apiImpl: this,
      hint: hint,
    ));
  }

  TaskConstMeta get kFindTrackByAlbumConstMeta => const TaskConstMeta(
        debugName: "find_track_by_album",
        argNames: ["albumId"],
      );

  @override
  Future<void> frbInit({dynamic hint}) {
    return handler.executeNormal(NormalTask(
      callFfi: (port_) {
        final serializer = SseSerializer(generalizedFrbRustBinding);
        pdeCallFfi(generalizedFrbRustBinding, serializer,
            funcId: 5, port: port_);
      },
      codec: SseCodec(
        decodeSuccessData: sse_decode_unit,
        decodeErrorData: null,
      ),
      constMeta: kFrbInitConstMeta,
      argValues: [],
      apiImpl: this,
      hint: hint,
    ));
  }

  TaskConstMeta get kFrbInitConstMeta => const TaskConstMeta(
        debugName: "frb_init",
        argNames: [],
      );

  @override
  Future<Int32List> getAllTrackIdsSortedByAlbum({dynamic hint}) {
    return handler.executeNormal(NormalTask(
      callFfi: (port_) {
        final serializer = SseSerializer(generalizedFrbRustBinding);
        pdeCallFfi(generalizedFrbRustBinding, serializer,
            funcId: 12, port: port_);
      },
      codec: SseCodec(
        decodeSuccessData: sse_decode_list_prim_i_32_strict,
        decodeErrorData: null,
      ),
      constMeta: kGetAllTrackIdsSortedByAlbumConstMeta,
      argValues: [],
      apiImpl: this,
      hint: hint,
    ));
  }

  TaskConstMeta get kGetAllTrackIdsSortedByAlbumConstMeta =>
      const TaskConstMeta(
        debugName: "get_all_track_ids_sorted_by_album",
        argNames: [],
      );

  @override
  Future<Int32List> getAllTrackIdsSortedByArtist({dynamic hint}) {
    return handler.executeNormal(NormalTask(
      callFfi: (port_) {
        final serializer = SseSerializer(generalizedFrbRustBinding);
        pdeCallFfi(generalizedFrbRustBinding, serializer,
            funcId: 11, port: port_);
      },
      codec: SseCodec(
        decodeSuccessData: sse_decode_list_prim_i_32_strict,
        decodeErrorData: null,
      ),
      constMeta: kGetAllTrackIdsSortedByArtistConstMeta,
      argValues: [],
      apiImpl: this,
      hint: hint,
    ));
  }

  TaskConstMeta get kGetAllTrackIdsSortedByArtistConstMeta =>
      const TaskConstMeta(
        debugName: "get_all_track_ids_sorted_by_artist",
        argNames: [],
      );

  @override
  Future<Int32List> getAllTrackIdsSortedByDuration({dynamic hint}) {
    return handler.executeNormal(NormalTask(
      callFfi: (port_) {
        final serializer = SseSerializer(generalizedFrbRustBinding);
        pdeCallFfi(generalizedFrbRustBinding, serializer,
            funcId: 13, port: port_);
      },
      codec: SseCodec(
        decodeSuccessData: sse_decode_list_prim_i_32_strict,
        decodeErrorData: null,
      ),
      constMeta: kGetAllTrackIdsSortedByDurationConstMeta,
      argValues: [],
      apiImpl: this,
      hint: hint,
    ));
  }

  TaskConstMeta get kGetAllTrackIdsSortedByDurationConstMeta =>
      const TaskConstMeta(
        debugName: "get_all_track_ids_sorted_by_duration",
        argNames: [],
      );

  @override
  Future<Int32List> getAllTrackIdsSortedByTitle({dynamic hint}) {
    return handler.executeNormal(NormalTask(
      callFfi: (port_) {
        final serializer = SseSerializer(generalizedFrbRustBinding);
        pdeCallFfi(generalizedFrbRustBinding, serializer,
            funcId: 10, port: port_);
      },
      codec: SseCodec(
        decodeSuccessData: sse_decode_list_prim_i_32_strict,
        decodeErrorData: null,
      ),
      constMeta: kGetAllTrackIdsSortedByTitleConstMeta,
      argValues: [],
      apiImpl: this,
      hint: hint,
    ));
  }

  TaskConstMeta get kGetAllTrackIdsSortedByTitleConstMeta =>
      const TaskConstMeta(
        debugName: "get_all_track_ids_sorted_by_title",
        argNames: [],
      );

  @override
  Future<List<TrackDTO>> getAllTracks({dynamic hint}) {
    return handler.executeNormal(NormalTask(
      callFfi: (port_) {
        final serializer = SseSerializer(generalizedFrbRustBinding);
        pdeCallFfi(generalizedFrbRustBinding, serializer,
            funcId: 9, port: port_);
      },
      codec: SseCodec(
        decodeSuccessData: sse_decode_list_track_dto,
        decodeErrorData: null,
      ),
      constMeta: kGetAllTracksConstMeta,
      argValues: [],
      apiImpl: this,
      hint: hint,
    ));
  }

  TaskConstMeta get kGetAllTracksConstMeta => const TaskConstMeta(
        debugName: "get_all_tracks",
        argNames: [],
      );

  @override
  String getCachePath({dynamic hint}) {
    return handler.executeSync(SyncTask(
      callFfi: () {
        final serializer = SseSerializer(generalizedFrbRustBinding);
        return pdeCallFfi(generalizedFrbRustBinding, serializer, funcId: 3)!;
      },
      codec: SseCodec(
        decodeSuccessData: sse_decode_String,
        decodeErrorData: null,
      ),
      constMeta: kGetCachePathConstMeta,
      argValues: [],
      apiImpl: this,
      hint: hint,
    ));
  }

  TaskConstMeta get kGetCachePathConstMeta => const TaskConstMeta(
        debugName: "get_cache_path",
        argNames: [],
      );

  @override
  String getConfigPath({dynamic hint}) {
    return handler.executeSync(SyncTask(
      callFfi: () {
        final serializer = SseSerializer(generalizedFrbRustBinding);
        return pdeCallFfi(generalizedFrbRustBinding, serializer, funcId: 2)!;
      },
      codec: SseCodec(
        decodeSuccessData: sse_decode_String,
        decodeErrorData: null,
      ),
      constMeta: kGetConfigPathConstMeta,
      argValues: [],
      apiImpl: this,
      hint: hint,
    ));
  }

  TaskConstMeta get kGetConfigPathConstMeta => const TaskConstMeta(
        debugName: "get_config_path",
        argNames: [],
      );

  @override
  String getDataPath({dynamic hint}) {
    return handler.executeSync(SyncTask(
      callFfi: () {
        final serializer = SseSerializer(generalizedFrbRustBinding);
        return pdeCallFfi(generalizedFrbRustBinding, serializer, funcId: 4)!;
      },
      codec: SseCodec(
        decodeSuccessData: sse_decode_String,
        decodeErrorData: null,
      ),
      constMeta: kGetDataPathConstMeta,
      argValues: [],
      apiImpl: this,
      hint: hint,
    ));
  }

  TaskConstMeta get kGetDataPathConstMeta => const TaskConstMeta(
        debugName: "get_data_path",
        argNames: [],
      );

  @override
  String getDbUrl({dynamic hint}) {
    return handler.executeSync(SyncTask(
      callFfi: () {
        final serializer = SseSerializer(generalizedFrbRustBinding);
        return pdeCallFfi(generalizedFrbRustBinding, serializer, funcId: 1)!;
      },
      codec: SseCodec(
        decodeSuccessData: sse_decode_String,
        decodeErrorData: null,
      ),
      constMeta: kGetDbUrlConstMeta,
      argValues: [],
      apiImpl: this,
      hint: hint,
    ));
  }

  TaskConstMeta get kGetDbUrlConstMeta => const TaskConstMeta(
        debugName: "get_db_url",
        argNames: [],
      );

  @override
  void initializeApp({dynamic hint}) {
    return handler.executeSync(SyncTask(
      callFfi: () {
        final serializer = SseSerializer(generalizedFrbRustBinding);
        return pdeCallFfi(generalizedFrbRustBinding, serializer, funcId: 6)!;
      },
      codec: SseCodec(
        decodeSuccessData: sse_decode_unit,
        decodeErrorData: null,
      ),
      constMeta: kInitializeAppConstMeta,
      argValues: [],
      apiImpl: this,
      hint: hint,
    ));
  }

  TaskConstMeta get kInitializeAppConstMeta => const TaskConstMeta(
        debugName: "initialize_app",
        argNames: [],
      );

  @override
  void initializeDb({dynamic hint}) {
    return handler.executeSync(SyncTask(
      callFfi: () {
        final serializer = SseSerializer(generalizedFrbRustBinding);
        return pdeCallFfi(generalizedFrbRustBinding, serializer, funcId: 7)!;
      },
      codec: SseCodec(
        decodeSuccessData: sse_decode_unit,
        decodeErrorData: null,
      ),
      constMeta: kInitializeDbConstMeta,
      argValues: [],
      apiImpl: this,
      hint: hint,
    ));
  }

  TaskConstMeta get kInitializeDbConstMeta => const TaskConstMeta(
        debugName: "initialize_db",
        argNames: [],
      );

  @override
  Future<String?> pickDirectory({dynamic hint}) {
    return handler.executeNormal(NormalTask(
      callFfi: (port_) {
        final serializer = SseSerializer(generalizedFrbRustBinding);
        pdeCallFfi(generalizedFrbRustBinding, serializer,
            funcId: 16, port: port_);
      },
      codec: SseCodec(
        decodeSuccessData: sse_decode_opt_String,
        decodeErrorData: null,
      ),
      constMeta: kPickDirectoryConstMeta,
      argValues: [],
      apiImpl: this,
      hint: hint,
    ));
  }

  TaskConstMeta get kPickDirectoryConstMeta => const TaskConstMeta(
        debugName: "pick_directory",
        argNames: [],
      );

  @override
  Future<void> syncDirectory({required String mountPoint, dynamic hint}) {
    return handler.executeNormal(NormalTask(
      callFfi: (port_) {
        final serializer = SseSerializer(generalizedFrbRustBinding);
        sse_encode_String(mountPoint, serializer);
        pdeCallFfi(generalizedFrbRustBinding, serializer,
            funcId: 8, port: port_);
      },
      codec: SseCodec(
        decodeSuccessData: sse_decode_unit,
        decodeErrorData: null,
      ),
      constMeta: kSyncDirectoryConstMeta,
      argValues: [mountPoint],
      apiImpl: this,
      hint: hint,
    ));
  }

  TaskConstMeta get kSyncDirectoryConstMeta => const TaskConstMeta(
        debugName: "sync_directory",
        argNames: ["mountPoint"],
      );

  @override
  String durationToString({required Duration duration, dynamic hint}) {
    return handler.executeSync(SyncTask(
      callFfi: () {
        final serializer = SseSerializer(generalizedFrbRustBinding);
        sse_encode_Chrono_Duration(duration, serializer);
        return pdeCallFfi(generalizedFrbRustBinding, serializer, funcId: 18)!;
      },
      codec: SseCodec(
        decodeSuccessData: sse_decode_String,
        decodeErrorData: null,
      ),
      constMeta: kDurationToStringConstMeta,
      argValues: [duration],
      apiImpl: this,
      hint: hint,
    ));
  }

  TaskConstMeta get kDurationToStringConstMeta => const TaskConstMeta(
        debugName: "duration_to_string",
        argNames: ["duration"],
      );

  @override
  bool trackQueryFilterCondition(
      {required String query, required TrackDTO track, dynamic hint}) {
    return handler.executeSync(SyncTask(
      callFfi: () {
        final serializer = SseSerializer(generalizedFrbRustBinding);
        sse_encode_String(query, serializer);
        sse_encode_box_autoadd_track_dto(track, serializer);
        return pdeCallFfi(generalizedFrbRustBinding, serializer, funcId: 17)!;
      },
      codec: SseCodec(
        decodeSuccessData: sse_decode_bool,
        decodeErrorData: null,
      ),
      constMeta: kTrackQueryFilterConditionConstMeta,
      argValues: [query, track],
      apiImpl: this,
      hint: hint,
    ));
  }

  TaskConstMeta get kTrackQueryFilterConditionConstMeta => const TaskConstMeta(
        debugName: "track_query_filter_condition",
        argNames: ["query", "track"],
      );

  @protected
  Duration dco_decode_Chrono_Duration(dynamic raw) {
    // Codec=Dco (DartCObject based), see doc to use other codecs
    return dcoDecodeDuration(dco_decode_i_64(raw).toInt());
  }

  @protected
  DateTime dco_decode_Chrono_Naive(dynamic raw) {
    // Codec=Dco (DartCObject based), see doc to use other codecs
    return dcoDecodeTimestamp(ts: dco_decode_i_64(raw).toInt(), isUtc: true);
  }

  @protected
  String dco_decode_String(dynamic raw) {
    // Codec=Dco (DartCObject based), see doc to use other codecs
    return raw as String;
  }

  @protected
  Album dco_decode_album(dynamic raw) {
    // Codec=Dco (DartCObject based), see doc to use other codecs
    final arr = raw as List<dynamic>;
    if (arr.length != 4)
      throw Exception('unexpected arr length: expect 4 but see ${arr.length}');
    return Album(
      id: dco_decode_i_32(arr[0]),
      name: dco_decode_String(arr[1]),
      artistId: dco_decode_opt_box_autoadd_i_32(arr[2]),
      createdAt: dco_decode_Chrono_Naive(arr[3]),
    );
  }

  @protected
  Artist dco_decode_artist(dynamic raw) {
    // Codec=Dco (DartCObject based), see doc to use other codecs
    final arr = raw as List<dynamic>;
    if (arr.length != 3)
      throw Exception('unexpected arr length: expect 3 but see ${arr.length}');
    return Artist(
      id: dco_decode_i_32(arr[0]),
      name: dco_decode_String(arr[1]),
      createdAt: dco_decode_Chrono_Naive(arr[2]),
    );
  }

  @protected
  bool dco_decode_bool(dynamic raw) {
    // Codec=Dco (DartCObject based), see doc to use other codecs
    return raw as bool;
  }

  @protected
  Album dco_decode_box_autoadd_album(dynamic raw) {
    // Codec=Dco (DartCObject based), see doc to use other codecs
    return dco_decode_album(raw);
  }

  @protected
  Artist dco_decode_box_autoadd_artist(dynamic raw) {
    // Codec=Dco (DartCObject based), see doc to use other codecs
    return dco_decode_artist(raw);
  }

  @protected
  int dco_decode_box_autoadd_i_32(dynamic raw) {
    // Codec=Dco (DartCObject based), see doc to use other codecs
    return raw as int;
  }

  @protected
  TrackDTO dco_decode_box_autoadd_track_dto(dynamic raw) {
    // Codec=Dco (DartCObject based), see doc to use other codecs
    return dco_decode_track_dto(raw);
  }

  @protected
  int dco_decode_i_32(dynamic raw) {
    // Codec=Dco (DartCObject based), see doc to use other codecs
    return raw as int;
  }

  @protected
  int dco_decode_i_64(dynamic raw) {
    // Codec=Dco (DartCObject based), see doc to use other codecs
    return dcoDecodeI64OrU64(raw);
  }

  @protected
  Int32List dco_decode_list_prim_i_32_strict(dynamic raw) {
    // Codec=Dco (DartCObject based), see doc to use other codecs
    return raw as Int32List;
  }

  @protected
  Uint8List dco_decode_list_prim_u_8_strict(dynamic raw) {
    // Codec=Dco (DartCObject based), see doc to use other codecs
    return raw as Uint8List;
  }

  @protected
  List<TrackDTO> dco_decode_list_track_dto(dynamic raw) {
    // Codec=Dco (DartCObject based), see doc to use other codecs
    return (raw as List<dynamic>).map(dco_decode_track_dto).toList();
  }

  @protected
  String? dco_decode_opt_String(dynamic raw) {
    // Codec=Dco (DartCObject based), see doc to use other codecs
    return raw == null ? null : dco_decode_String(raw);
  }

  @protected
  Album? dco_decode_opt_box_autoadd_album(dynamic raw) {
    // Codec=Dco (DartCObject based), see doc to use other codecs
    return raw == null ? null : dco_decode_box_autoadd_album(raw);
  }

  @protected
  Artist? dco_decode_opt_box_autoadd_artist(dynamic raw) {
    // Codec=Dco (DartCObject based), see doc to use other codecs
    return raw == null ? null : dco_decode_box_autoadd_artist(raw);
  }

  @protected
  int? dco_decode_opt_box_autoadd_i_32(dynamic raw) {
    // Codec=Dco (DartCObject based), see doc to use other codecs
    return raw == null ? null : dco_decode_box_autoadd_i_32(raw);
  }

  @protected
  TrackDTO dco_decode_track_dto(dynamic raw) {
    // Codec=Dco (DartCObject based), see doc to use other codecs
    final arr = raw as List<dynamic>;
    if (arr.length != 10)
      throw Exception('unexpected arr length: expect 10 but see ${arr.length}');
    return TrackDTO(
      id: dco_decode_i_32(arr[0]),
      title: dco_decode_opt_String(arr[1]),
      artist: dco_decode_opt_box_autoadd_artist(arr[2]),
      album: dco_decode_opt_box_autoadd_album(arr[3]),
      number: dco_decode_opt_box_autoadd_i_32(arr[4]),
      disc: dco_decode_opt_box_autoadd_i_32(arr[5]),
      durationMs: dco_decode_i_32(arr[6]),
      location: dco_decode_String(arr[7]),
      mountPoint: dco_decode_String(arr[8]),
      pictureId: dco_decode_opt_String(arr[9]),
    );
  }

  @protected
  int dco_decode_u_8(dynamic raw) {
    // Codec=Dco (DartCObject based), see doc to use other codecs
    return raw as int;
  }

  @protected
  void dco_decode_unit(dynamic raw) {
    // Codec=Dco (DartCObject based), see doc to use other codecs
    return;
  }

  @protected
  Duration sse_decode_Chrono_Duration(SseDeserializer deserializer) {
    // Codec=Sse (Serialization based), see doc to use other codecs
    var inner = sse_decode_i_64(deserializer);
    return Duration(microseconds: inner);
  }

  @protected
  DateTime sse_decode_Chrono_Naive(SseDeserializer deserializer) {
    // Codec=Sse (Serialization based), see doc to use other codecs
    var inner = sse_decode_i_64(deserializer);
    return DateTime.fromMicrosecondsSinceEpoch(inner, isUtc: true);
  }

  @protected
  String sse_decode_String(SseDeserializer deserializer) {
    // Codec=Sse (Serialization based), see doc to use other codecs
    var inner = sse_decode_list_prim_u_8_strict(deserializer);
    return utf8.decoder.convert(inner);
  }

  @protected
  Album sse_decode_album(SseDeserializer deserializer) {
    // Codec=Sse (Serialization based), see doc to use other codecs
    var var_id = sse_decode_i_32(deserializer);
    var var_name = sse_decode_String(deserializer);
    var var_artistId = sse_decode_opt_box_autoadd_i_32(deserializer);
    var var_createdAt = sse_decode_Chrono_Naive(deserializer);
    return Album(
        id: var_id,
        name: var_name,
        artistId: var_artistId,
        createdAt: var_createdAt);
  }

  @protected
  Artist sse_decode_artist(SseDeserializer deserializer) {
    // Codec=Sse (Serialization based), see doc to use other codecs
    var var_id = sse_decode_i_32(deserializer);
    var var_name = sse_decode_String(deserializer);
    var var_createdAt = sse_decode_Chrono_Naive(deserializer);
    return Artist(id: var_id, name: var_name, createdAt: var_createdAt);
  }

  @protected
  bool sse_decode_bool(SseDeserializer deserializer) {
    // Codec=Sse (Serialization based), see doc to use other codecs
    return deserializer.buffer.getUint8() != 0;
  }

  @protected
  Album sse_decode_box_autoadd_album(SseDeserializer deserializer) {
    // Codec=Sse (Serialization based), see doc to use other codecs
    return (sse_decode_album(deserializer));
  }

  @protected
  Artist sse_decode_box_autoadd_artist(SseDeserializer deserializer) {
    // Codec=Sse (Serialization based), see doc to use other codecs
    return (sse_decode_artist(deserializer));
  }

  @protected
  int sse_decode_box_autoadd_i_32(SseDeserializer deserializer) {
    // Codec=Sse (Serialization based), see doc to use other codecs
    return (sse_decode_i_32(deserializer));
  }

  @protected
  TrackDTO sse_decode_box_autoadd_track_dto(SseDeserializer deserializer) {
    // Codec=Sse (Serialization based), see doc to use other codecs
    return (sse_decode_track_dto(deserializer));
  }

  @protected
  int sse_decode_i_32(SseDeserializer deserializer) {
    // Codec=Sse (Serialization based), see doc to use other codecs
    return deserializer.buffer.getInt32();
  }

  @protected
  int sse_decode_i_64(SseDeserializer deserializer) {
    // Codec=Sse (Serialization based), see doc to use other codecs
    return deserializer.buffer.getInt64();
  }

  @protected
  Int32List sse_decode_list_prim_i_32_strict(SseDeserializer deserializer) {
    // Codec=Sse (Serialization based), see doc to use other codecs
    var len_ = sse_decode_i_32(deserializer);
    return deserializer.buffer.getInt32List(len_);
  }

  @protected
  Uint8List sse_decode_list_prim_u_8_strict(SseDeserializer deserializer) {
    // Codec=Sse (Serialization based), see doc to use other codecs
    var len_ = sse_decode_i_32(deserializer);
    return deserializer.buffer.getUint8List(len_);
  }

  @protected
  List<TrackDTO> sse_decode_list_track_dto(SseDeserializer deserializer) {
    // Codec=Sse (Serialization based), see doc to use other codecs

    var len_ = sse_decode_i_32(deserializer);
    var ans_ = <TrackDTO>[];
    for (var idx_ = 0; idx_ < len_; ++idx_) {
      ans_.add(sse_decode_track_dto(deserializer));
    }
    return ans_;
  }

  @protected
  String? sse_decode_opt_String(SseDeserializer deserializer) {
    // Codec=Sse (Serialization based), see doc to use other codecs

    if (sse_decode_bool(deserializer)) {
      return (sse_decode_String(deserializer));
    } else {
      return null;
    }
  }

  @protected
  Album? sse_decode_opt_box_autoadd_album(SseDeserializer deserializer) {
    // Codec=Sse (Serialization based), see doc to use other codecs

    if (sse_decode_bool(deserializer)) {
      return (sse_decode_box_autoadd_album(deserializer));
    } else {
      return null;
    }
  }

  @protected
  Artist? sse_decode_opt_box_autoadd_artist(SseDeserializer deserializer) {
    // Codec=Sse (Serialization based), see doc to use other codecs

    if (sse_decode_bool(deserializer)) {
      return (sse_decode_box_autoadd_artist(deserializer));
    } else {
      return null;
    }
  }

  @protected
  int? sse_decode_opt_box_autoadd_i_32(SseDeserializer deserializer) {
    // Codec=Sse (Serialization based), see doc to use other codecs

    if (sse_decode_bool(deserializer)) {
      return (sse_decode_box_autoadd_i_32(deserializer));
    } else {
      return null;
    }
  }

  @protected
  TrackDTO sse_decode_track_dto(SseDeserializer deserializer) {
    // Codec=Sse (Serialization based), see doc to use other codecs
    var var_id = sse_decode_i_32(deserializer);
    var var_title = sse_decode_opt_String(deserializer);
    var var_artist = sse_decode_opt_box_autoadd_artist(deserializer);
    var var_album = sse_decode_opt_box_autoadd_album(deserializer);
    var var_number = sse_decode_opt_box_autoadd_i_32(deserializer);
    var var_disc = sse_decode_opt_box_autoadd_i_32(deserializer);
    var var_durationMs = sse_decode_i_32(deserializer);
    var var_location = sse_decode_String(deserializer);
    var var_mountPoint = sse_decode_String(deserializer);
    var var_pictureId = sse_decode_opt_String(deserializer);
    return TrackDTO(
        id: var_id,
        title: var_title,
        artist: var_artist,
        album: var_album,
        number: var_number,
        disc: var_disc,
        durationMs: var_durationMs,
        location: var_location,
        mountPoint: var_mountPoint,
        pictureId: var_pictureId);
  }

  @protected
  int sse_decode_u_8(SseDeserializer deserializer) {
    // Codec=Sse (Serialization based), see doc to use other codecs
    return deserializer.buffer.getUint8();
  }

  @protected
  void sse_decode_unit(SseDeserializer deserializer) {
    // Codec=Sse (Serialization based), see doc to use other codecs
  }

  @protected
  void sse_encode_Chrono_Duration(Duration self, SseSerializer serializer) {
    // Codec=Sse (Serialization based), see doc to use other codecs
    sse_encode_i_64(self.inMicroseconds, serializer);
  }

  @protected
  void sse_encode_Chrono_Naive(DateTime self, SseSerializer serializer) {
    // Codec=Sse (Serialization based), see doc to use other codecs
    sse_encode_i_64(self.microsecondsSinceEpoch, serializer);
  }

  @protected
  void sse_encode_String(String self, SseSerializer serializer) {
    // Codec=Sse (Serialization based), see doc to use other codecs
    sse_encode_list_prim_u_8_strict(utf8.encoder.convert(self), serializer);
  }

  @protected
  void sse_encode_album(Album self, SseSerializer serializer) {
    // Codec=Sse (Serialization based), see doc to use other codecs
    sse_encode_i_32(self.id, serializer);
    sse_encode_String(self.name, serializer);
    sse_encode_opt_box_autoadd_i_32(self.artistId, serializer);
    sse_encode_Chrono_Naive(self.createdAt, serializer);
  }

  @protected
  void sse_encode_artist(Artist self, SseSerializer serializer) {
    // Codec=Sse (Serialization based), see doc to use other codecs
    sse_encode_i_32(self.id, serializer);
    sse_encode_String(self.name, serializer);
    sse_encode_Chrono_Naive(self.createdAt, serializer);
  }

  @protected
  void sse_encode_bool(bool self, SseSerializer serializer) {
    // Codec=Sse (Serialization based), see doc to use other codecs
    serializer.buffer.putUint8(self ? 1 : 0);
  }

  @protected
  void sse_encode_box_autoadd_album(Album self, SseSerializer serializer) {
    // Codec=Sse (Serialization based), see doc to use other codecs
    sse_encode_album(self, serializer);
  }

  @protected
  void sse_encode_box_autoadd_artist(Artist self, SseSerializer serializer) {
    // Codec=Sse (Serialization based), see doc to use other codecs
    sse_encode_artist(self, serializer);
  }

  @protected
  void sse_encode_box_autoadd_i_32(int self, SseSerializer serializer) {
    // Codec=Sse (Serialization based), see doc to use other codecs
    sse_encode_i_32(self, serializer);
  }

  @protected
  void sse_encode_box_autoadd_track_dto(
      TrackDTO self, SseSerializer serializer) {
    // Codec=Sse (Serialization based), see doc to use other codecs
    sse_encode_track_dto(self, serializer);
  }

  @protected
  void sse_encode_i_32(int self, SseSerializer serializer) {
    // Codec=Sse (Serialization based), see doc to use other codecs
    serializer.buffer.putInt32(self);
  }

  @protected
  void sse_encode_i_64(int self, SseSerializer serializer) {
    // Codec=Sse (Serialization based), see doc to use other codecs
    serializer.buffer.putInt64(self);
  }

  @protected
  void sse_encode_list_prim_i_32_strict(
      Int32List self, SseSerializer serializer) {
    // Codec=Sse (Serialization based), see doc to use other codecs
    sse_encode_i_32(self.length, serializer);
    serializer.buffer.putInt32List(self);
  }

  @protected
  void sse_encode_list_prim_u_8_strict(
      Uint8List self, SseSerializer serializer) {
    // Codec=Sse (Serialization based), see doc to use other codecs
    sse_encode_i_32(self.length, serializer);
    serializer.buffer.putUint8List(self);
  }

  @protected
  void sse_encode_list_track_dto(
      List<TrackDTO> self, SseSerializer serializer) {
    // Codec=Sse (Serialization based), see doc to use other codecs
    sse_encode_i_32(self.length, serializer);
    for (final item in self) {
      sse_encode_track_dto(item, serializer);
    }
  }

  @protected
  void sse_encode_opt_String(String? self, SseSerializer serializer) {
    // Codec=Sse (Serialization based), see doc to use other codecs

    sse_encode_bool(self != null, serializer);
    if (self != null) {
      sse_encode_String(self, serializer);
    }
  }

  @protected
  void sse_encode_opt_box_autoadd_album(Album? self, SseSerializer serializer) {
    // Codec=Sse (Serialization based), see doc to use other codecs

    sse_encode_bool(self != null, serializer);
    if (self != null) {
      sse_encode_box_autoadd_album(self, serializer);
    }
  }

  @protected
  void sse_encode_opt_box_autoadd_artist(
      Artist? self, SseSerializer serializer) {
    // Codec=Sse (Serialization based), see doc to use other codecs

    sse_encode_bool(self != null, serializer);
    if (self != null) {
      sse_encode_box_autoadd_artist(self, serializer);
    }
  }

  @protected
  void sse_encode_opt_box_autoadd_i_32(int? self, SseSerializer serializer) {
    // Codec=Sse (Serialization based), see doc to use other codecs

    sse_encode_bool(self != null, serializer);
    if (self != null) {
      sse_encode_box_autoadd_i_32(self, serializer);
    }
  }

  @protected
  void sse_encode_track_dto(TrackDTO self, SseSerializer serializer) {
    // Codec=Sse (Serialization based), see doc to use other codecs
    sse_encode_i_32(self.id, serializer);
    sse_encode_opt_String(self.title, serializer);
    sse_encode_opt_box_autoadd_artist(self.artist, serializer);
    sse_encode_opt_box_autoadd_album(self.album, serializer);
    sse_encode_opt_box_autoadd_i_32(self.number, serializer);
    sse_encode_opt_box_autoadd_i_32(self.disc, serializer);
    sse_encode_i_32(self.durationMs, serializer);
    sse_encode_String(self.location, serializer);
    sse_encode_String(self.mountPoint, serializer);
    sse_encode_opt_String(self.pictureId, serializer);
  }

  @protected
  void sse_encode_u_8(int self, SseSerializer serializer) {
    // Codec=Sse (Serialization based), see doc to use other codecs
    serializer.buffer.putUint8(self);
  }

  @protected
  void sse_encode_unit(void self, SseSerializer serializer) {
    // Codec=Sse (Serialization based), see doc to use other codecs
  }
}
