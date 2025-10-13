// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'summary_pdf.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$SummaryPdf {

 SummaryList get list; List<SummaryContainer> get containers;
/// Create a copy of SummaryPdf
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SummaryPdfCopyWith<SummaryPdf> get copyWith => _$SummaryPdfCopyWithImpl<SummaryPdf>(this as SummaryPdf, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SummaryPdf&&(identical(other.list, list) || other.list == list)&&const DeepCollectionEquality().equals(other.containers, containers));
}


@override
int get hashCode => Object.hash(runtimeType,list,const DeepCollectionEquality().hash(containers));

@override
String toString() {
  return 'SummaryPdf(list: $list, containers: $containers)';
}


}

/// @nodoc
abstract mixin class $SummaryPdfCopyWith<$Res>  {
  factory $SummaryPdfCopyWith(SummaryPdf value, $Res Function(SummaryPdf) _then) = _$SummaryPdfCopyWithImpl;
@useResult
$Res call({
 SummaryList list, List<SummaryContainer> containers
});


$SummaryListCopyWith<$Res> get list;

}
/// @nodoc
class _$SummaryPdfCopyWithImpl<$Res>
    implements $SummaryPdfCopyWith<$Res> {
  _$SummaryPdfCopyWithImpl(this._self, this._then);

  final SummaryPdf _self;
  final $Res Function(SummaryPdf) _then;

/// Create a copy of SummaryPdf
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? list = null,Object? containers = null,}) {
  return _then(_self.copyWith(
list: null == list ? _self.list : list // ignore: cast_nullable_to_non_nullable
as SummaryList,containers: null == containers ? _self.containers : containers // ignore: cast_nullable_to_non_nullable
as List<SummaryContainer>,
  ));
}
/// Create a copy of SummaryPdf
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SummaryListCopyWith<$Res> get list {
  
  return $SummaryListCopyWith<$Res>(_self.list, (value) {
    return _then(_self.copyWith(list: value));
  });
}
}


/// Adds pattern-matching-related methods to [SummaryPdf].
extension SummaryPdfPatterns on SummaryPdf {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SummaryPdf value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SummaryPdf() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SummaryPdf value)  $default,){
final _that = this;
switch (_that) {
case _SummaryPdf():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SummaryPdf value)?  $default,){
final _that = this;
switch (_that) {
case _SummaryPdf() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( SummaryList list,  List<SummaryContainer> containers)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SummaryPdf() when $default != null:
return $default(_that.list,_that.containers);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( SummaryList list,  List<SummaryContainer> containers)  $default,) {final _that = this;
switch (_that) {
case _SummaryPdf():
return $default(_that.list,_that.containers);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( SummaryList list,  List<SummaryContainer> containers)?  $default,) {final _that = this;
switch (_that) {
case _SummaryPdf() when $default != null:
return $default(_that.list,_that.containers);case _:
  return null;

}
}

}

/// @nodoc


class _SummaryPdf implements SummaryPdf {
  const _SummaryPdf({required this.list, required final  List<SummaryContainer> containers}): _containers = containers;
  

@override final  SummaryList list;
 final  List<SummaryContainer> _containers;
@override List<SummaryContainer> get containers {
  if (_containers is EqualUnmodifiableListView) return _containers;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_containers);
}


/// Create a copy of SummaryPdf
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SummaryPdfCopyWith<_SummaryPdf> get copyWith => __$SummaryPdfCopyWithImpl<_SummaryPdf>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SummaryPdf&&(identical(other.list, list) || other.list == list)&&const DeepCollectionEquality().equals(other._containers, _containers));
}


@override
int get hashCode => Object.hash(runtimeType,list,const DeepCollectionEquality().hash(_containers));

@override
String toString() {
  return 'SummaryPdf(list: $list, containers: $containers)';
}


}

/// @nodoc
abstract mixin class _$SummaryPdfCopyWith<$Res> implements $SummaryPdfCopyWith<$Res> {
  factory _$SummaryPdfCopyWith(_SummaryPdf value, $Res Function(_SummaryPdf) _then) = __$SummaryPdfCopyWithImpl;
@override @useResult
$Res call({
 SummaryList list, List<SummaryContainer> containers
});


@override $SummaryListCopyWith<$Res> get list;

}
/// @nodoc
class __$SummaryPdfCopyWithImpl<$Res>
    implements _$SummaryPdfCopyWith<$Res> {
  __$SummaryPdfCopyWithImpl(this._self, this._then);

  final _SummaryPdf _self;
  final $Res Function(_SummaryPdf) _then;

/// Create a copy of SummaryPdf
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? list = null,Object? containers = null,}) {
  return _then(_SummaryPdf(
list: null == list ? _self.list : list // ignore: cast_nullable_to_non_nullable
as SummaryList,containers: null == containers ? _self._containers : containers // ignore: cast_nullable_to_non_nullable
as List<SummaryContainer>,
  ));
}

/// Create a copy of SummaryPdf
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SummaryListCopyWith<$Res> get list {
  
  return $SummaryListCopyWith<$Res>(_self.list, (value) {
    return _then(_self.copyWith(list: value));
  });
}
}

// dart format on
