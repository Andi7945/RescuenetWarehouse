// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'summary_container.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$SummaryContainer {

 int get containerNr; String get name; String get description; String get type; int get value; double get weight; String get expirationDate; String get dangerousGoods; String get coldChain; String get moduleDestination; int get priority; SequentialBuild get sequentialBuild;
/// Create a copy of SummaryContainer
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SummaryContainerCopyWith<SummaryContainer> get copyWith => _$SummaryContainerCopyWithImpl<SummaryContainer>(this as SummaryContainer, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SummaryContainer&&(identical(other.containerNr, containerNr) || other.containerNr == containerNr)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.type, type) || other.type == type)&&(identical(other.value, value) || other.value == value)&&(identical(other.weight, weight) || other.weight == weight)&&(identical(other.expirationDate, expirationDate) || other.expirationDate == expirationDate)&&(identical(other.dangerousGoods, dangerousGoods) || other.dangerousGoods == dangerousGoods)&&(identical(other.coldChain, coldChain) || other.coldChain == coldChain)&&(identical(other.moduleDestination, moduleDestination) || other.moduleDestination == moduleDestination)&&(identical(other.priority, priority) || other.priority == priority)&&(identical(other.sequentialBuild, sequentialBuild) || other.sequentialBuild == sequentialBuild));
}


@override
int get hashCode => Object.hash(runtimeType,containerNr,name,description,type,value,weight,expirationDate,dangerousGoods,coldChain,moduleDestination,priority,sequentialBuild);

@override
String toString() {
  return 'SummaryContainer(containerNr: $containerNr, name: $name, description: $description, type: $type, value: $value, weight: $weight, expirationDate: $expirationDate, dangerousGoods: $dangerousGoods, coldChain: $coldChain, moduleDestination: $moduleDestination, priority: $priority, sequentialBuild: $sequentialBuild)';
}


}

/// @nodoc
abstract mixin class $SummaryContainerCopyWith<$Res>  {
  factory $SummaryContainerCopyWith(SummaryContainer value, $Res Function(SummaryContainer) _then) = _$SummaryContainerCopyWithImpl;
@useResult
$Res call({
 int containerNr, String name, String description, String type, int value, double weight, String expirationDate, String dangerousGoods, String coldChain, String moduleDestination, int priority, SequentialBuild sequentialBuild
});




}
/// @nodoc
class _$SummaryContainerCopyWithImpl<$Res>
    implements $SummaryContainerCopyWith<$Res> {
  _$SummaryContainerCopyWithImpl(this._self, this._then);

  final SummaryContainer _self;
  final $Res Function(SummaryContainer) _then;

/// Create a copy of SummaryContainer
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? containerNr = null,Object? name = null,Object? description = null,Object? type = null,Object? value = null,Object? weight = null,Object? expirationDate = null,Object? dangerousGoods = null,Object? coldChain = null,Object? moduleDestination = null,Object? priority = null,Object? sequentialBuild = null,}) {
  return _then(_self.copyWith(
containerNr: null == containerNr ? _self.containerNr : containerNr // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,value: null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as int,weight: null == weight ? _self.weight : weight // ignore: cast_nullable_to_non_nullable
as double,expirationDate: null == expirationDate ? _self.expirationDate : expirationDate // ignore: cast_nullable_to_non_nullable
as String,dangerousGoods: null == dangerousGoods ? _self.dangerousGoods : dangerousGoods // ignore: cast_nullable_to_non_nullable
as String,coldChain: null == coldChain ? _self.coldChain : coldChain // ignore: cast_nullable_to_non_nullable
as String,moduleDestination: null == moduleDestination ? _self.moduleDestination : moduleDestination // ignore: cast_nullable_to_non_nullable
as String,priority: null == priority ? _self.priority : priority // ignore: cast_nullable_to_non_nullable
as int,sequentialBuild: null == sequentialBuild ? _self.sequentialBuild : sequentialBuild // ignore: cast_nullable_to_non_nullable
as SequentialBuild,
  ));
}

}


/// Adds pattern-matching-related methods to [SummaryContainer].
extension SummaryContainerPatterns on SummaryContainer {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SummaryContainer value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SummaryContainer() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SummaryContainer value)  $default,){
final _that = this;
switch (_that) {
case _SummaryContainer():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SummaryContainer value)?  $default,){
final _that = this;
switch (_that) {
case _SummaryContainer() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int containerNr,  String name,  String description,  String type,  int value,  double weight,  String expirationDate,  String dangerousGoods,  String coldChain,  String moduleDestination,  int priority,  SequentialBuild sequentialBuild)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SummaryContainer() when $default != null:
return $default(_that.containerNr,_that.name,_that.description,_that.type,_that.value,_that.weight,_that.expirationDate,_that.dangerousGoods,_that.coldChain,_that.moduleDestination,_that.priority,_that.sequentialBuild);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int containerNr,  String name,  String description,  String type,  int value,  double weight,  String expirationDate,  String dangerousGoods,  String coldChain,  String moduleDestination,  int priority,  SequentialBuild sequentialBuild)  $default,) {final _that = this;
switch (_that) {
case _SummaryContainer():
return $default(_that.containerNr,_that.name,_that.description,_that.type,_that.value,_that.weight,_that.expirationDate,_that.dangerousGoods,_that.coldChain,_that.moduleDestination,_that.priority,_that.sequentialBuild);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int containerNr,  String name,  String description,  String type,  int value,  double weight,  String expirationDate,  String dangerousGoods,  String coldChain,  String moduleDestination,  int priority,  SequentialBuild sequentialBuild)?  $default,) {final _that = this;
switch (_that) {
case _SummaryContainer() when $default != null:
return $default(_that.containerNr,_that.name,_that.description,_that.type,_that.value,_that.weight,_that.expirationDate,_that.dangerousGoods,_that.coldChain,_that.moduleDestination,_that.priority,_that.sequentialBuild);case _:
  return null;

}
}

}

/// @nodoc


class _SummaryContainer implements SummaryContainer {
  const _SummaryContainer({required this.containerNr, required this.name, required this.description, required this.type, required this.value, required this.weight, required this.expirationDate, required this.dangerousGoods, required this.coldChain, required this.moduleDestination, required this.priority, required this.sequentialBuild});
  

@override final  int containerNr;
@override final  String name;
@override final  String description;
@override final  String type;
@override final  int value;
@override final  double weight;
@override final  String expirationDate;
@override final  String dangerousGoods;
@override final  String coldChain;
@override final  String moduleDestination;
@override final  int priority;
@override final  SequentialBuild sequentialBuild;

/// Create a copy of SummaryContainer
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SummaryContainerCopyWith<_SummaryContainer> get copyWith => __$SummaryContainerCopyWithImpl<_SummaryContainer>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SummaryContainer&&(identical(other.containerNr, containerNr) || other.containerNr == containerNr)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.type, type) || other.type == type)&&(identical(other.value, value) || other.value == value)&&(identical(other.weight, weight) || other.weight == weight)&&(identical(other.expirationDate, expirationDate) || other.expirationDate == expirationDate)&&(identical(other.dangerousGoods, dangerousGoods) || other.dangerousGoods == dangerousGoods)&&(identical(other.coldChain, coldChain) || other.coldChain == coldChain)&&(identical(other.moduleDestination, moduleDestination) || other.moduleDestination == moduleDestination)&&(identical(other.priority, priority) || other.priority == priority)&&(identical(other.sequentialBuild, sequentialBuild) || other.sequentialBuild == sequentialBuild));
}


@override
int get hashCode => Object.hash(runtimeType,containerNr,name,description,type,value,weight,expirationDate,dangerousGoods,coldChain,moduleDestination,priority,sequentialBuild);

@override
String toString() {
  return 'SummaryContainer(containerNr: $containerNr, name: $name, description: $description, type: $type, value: $value, weight: $weight, expirationDate: $expirationDate, dangerousGoods: $dangerousGoods, coldChain: $coldChain, moduleDestination: $moduleDestination, priority: $priority, sequentialBuild: $sequentialBuild)';
}


}

/// @nodoc
abstract mixin class _$SummaryContainerCopyWith<$Res> implements $SummaryContainerCopyWith<$Res> {
  factory _$SummaryContainerCopyWith(_SummaryContainer value, $Res Function(_SummaryContainer) _then) = __$SummaryContainerCopyWithImpl;
@override @useResult
$Res call({
 int containerNr, String name, String description, String type, int value, double weight, String expirationDate, String dangerousGoods, String coldChain, String moduleDestination, int priority, SequentialBuild sequentialBuild
});




}
/// @nodoc
class __$SummaryContainerCopyWithImpl<$Res>
    implements _$SummaryContainerCopyWith<$Res> {
  __$SummaryContainerCopyWithImpl(this._self, this._then);

  final _SummaryContainer _self;
  final $Res Function(_SummaryContainer) _then;

/// Create a copy of SummaryContainer
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? containerNr = null,Object? name = null,Object? description = null,Object? type = null,Object? value = null,Object? weight = null,Object? expirationDate = null,Object? dangerousGoods = null,Object? coldChain = null,Object? moduleDestination = null,Object? priority = null,Object? sequentialBuild = null,}) {
  return _then(_SummaryContainer(
containerNr: null == containerNr ? _self.containerNr : containerNr // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,value: null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as int,weight: null == weight ? _self.weight : weight // ignore: cast_nullable_to_non_nullable
as double,expirationDate: null == expirationDate ? _self.expirationDate : expirationDate // ignore: cast_nullable_to_non_nullable
as String,dangerousGoods: null == dangerousGoods ? _self.dangerousGoods : dangerousGoods // ignore: cast_nullable_to_non_nullable
as String,coldChain: null == coldChain ? _self.coldChain : coldChain // ignore: cast_nullable_to_non_nullable
as String,moduleDestination: null == moduleDestination ? _self.moduleDestination : moduleDestination // ignore: cast_nullable_to_non_nullable
as String,priority: null == priority ? _self.priority : priority // ignore: cast_nullable_to_non_nullable
as int,sequentialBuild: null == sequentialBuild ? _self.sequentialBuild : sequentialBuild // ignore: cast_nullable_to_non_nullable
as SequentialBuild,
  ));
}


}

// dart format on
