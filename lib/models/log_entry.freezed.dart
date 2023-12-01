// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'log_entry.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

LogEntry _$LogEntryFromJson(Map<String, dynamic> json) {
  return _LogEntry.fromJson(json);
}

/// @nodoc
mixin _$LogEntry {
  String get id => throw _privateConstructorUsedError;
  String get itemId => throw _privateConstructorUsedError;
  String get containerId => throw _privateConstructorUsedError;
  int get count => throw _privateConstructorUsedError;
  @TimestampConverter()
  DateTime get date => throw _privateConstructorUsedError;
  String get user => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $LogEntryCopyWith<LogEntry> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LogEntryCopyWith<$Res> {
  factory $LogEntryCopyWith(LogEntry value, $Res Function(LogEntry) then) =
      _$LogEntryCopyWithImpl<$Res, LogEntry>;
  @useResult
  $Res call(
      {String id,
      String itemId,
      String containerId,
      int count,
      @TimestampConverter() DateTime date,
      String user});
}

/// @nodoc
class _$LogEntryCopyWithImpl<$Res, $Val extends LogEntry>
    implements $LogEntryCopyWith<$Res> {
  _$LogEntryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? itemId = null,
    Object? containerId = null,
    Object? count = null,
    Object? date = null,
    Object? user = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      itemId: null == itemId
          ? _value.itemId
          : itemId // ignore: cast_nullable_to_non_nullable
              as String,
      containerId: null == containerId
          ? _value.containerId
          : containerId // ignore: cast_nullable_to_non_nullable
              as String,
      count: null == count
          ? _value.count
          : count // ignore: cast_nullable_to_non_nullable
              as int,
      date: null == date
          ? _value.date
          : date // ignore: cast_nullable_to_non_nullable
              as DateTime,
      user: null == user
          ? _value.user
          : user // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$LogEntryImplCopyWith<$Res>
    implements $LogEntryCopyWith<$Res> {
  factory _$$LogEntryImplCopyWith(
          _$LogEntryImpl value, $Res Function(_$LogEntryImpl) then) =
      __$$LogEntryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String itemId,
      String containerId,
      int count,
      @TimestampConverter() DateTime date,
      String user});
}

/// @nodoc
class __$$LogEntryImplCopyWithImpl<$Res>
    extends _$LogEntryCopyWithImpl<$Res, _$LogEntryImpl>
    implements _$$LogEntryImplCopyWith<$Res> {
  __$$LogEntryImplCopyWithImpl(
      _$LogEntryImpl _value, $Res Function(_$LogEntryImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? itemId = null,
    Object? containerId = null,
    Object? count = null,
    Object? date = null,
    Object? user = null,
  }) {
    return _then(_$LogEntryImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      itemId: null == itemId
          ? _value.itemId
          : itemId // ignore: cast_nullable_to_non_nullable
              as String,
      containerId: null == containerId
          ? _value.containerId
          : containerId // ignore: cast_nullable_to_non_nullable
              as String,
      count: null == count
          ? _value.count
          : count // ignore: cast_nullable_to_non_nullable
              as int,
      date: null == date
          ? _value.date
          : date // ignore: cast_nullable_to_non_nullable
              as DateTime,
      user: null == user
          ? _value.user
          : user // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$LogEntryImpl implements _LogEntry {
  const _$LogEntryImpl(
      {required this.id,
      required this.itemId,
      required this.containerId,
      required this.count,
      @TimestampConverter() required this.date,
      required this.user});

  factory _$LogEntryImpl.fromJson(Map<String, dynamic> json) =>
      _$$LogEntryImplFromJson(json);

  @override
  final String id;
  @override
  final String itemId;
  @override
  final String containerId;
  @override
  final int count;
  @override
  @TimestampConverter()
  final DateTime date;
  @override
  final String user;

  @override
  String toString() {
    return 'LogEntry(id: $id, itemId: $itemId, containerId: $containerId, count: $count, date: $date, user: $user)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LogEntryImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.itemId, itemId) || other.itemId == itemId) &&
            (identical(other.containerId, containerId) ||
                other.containerId == containerId) &&
            (identical(other.count, count) || other.count == count) &&
            (identical(other.date, date) || other.date == date) &&
            (identical(other.user, user) || other.user == user));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, itemId, containerId, count, date, user);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$LogEntryImplCopyWith<_$LogEntryImpl> get copyWith =>
      __$$LogEntryImplCopyWithImpl<_$LogEntryImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$LogEntryImplToJson(
      this,
    );
  }
}

abstract class _LogEntry implements LogEntry {
  const factory _LogEntry(
      {required final String id,
      required final String itemId,
      required final String containerId,
      required final int count,
      @TimestampConverter() required final DateTime date,
      required final String user}) = _$LogEntryImpl;

  factory _LogEntry.fromJson(Map<String, dynamic> json) =
      _$LogEntryImpl.fromJson;

  @override
  String get id;
  @override
  String get itemId;
  @override
  String get containerId;
  @override
  int get count;
  @override
  @TimestampConverter()
  DateTime get date;
  @override
  String get user;
  @override
  @JsonKey(ignore: true)
  _$$LogEntryImplCopyWith<_$LogEntryImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
