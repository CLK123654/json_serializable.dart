// GENERATED CODE - DO NOT MODIFY BY HAND

// ignore_for_file: lines_longer_than_80_chars, text_direction_code_point_in_literal, inference_failure_on_function_invocation, inference_failure_on_collection_literal

part of 'generic_json_key.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SerializableJsonKey<T> _$SerializableJsonKeyFromJson<T>(
  Map<String, dynamic> json,
) => SerializableJsonKey<T>(a: _fromJson<T>(json['a'] as String));

Map<String, dynamic> _$SerializableJsonKeyToJson<T>(
  SerializableJsonKey<T> instance,
) => <String, dynamic>{'a': _toJson<T>(instance.a)};

SerializableConverter<T> _$SerializableConverterFromJson<T>(
  Map<String, dynamic> json,
) => SerializableConverter<T>(
  SimpleGenericConverter<T>().fromJson(json['value'] as String),
);

Map<String, dynamic> _$SerializableConverterToJson<T>(
  SerializableConverter<T> instance,
) => <String, dynamic>{
  'value': SimpleGenericConverter<T>().toJson(instance.value),
};
