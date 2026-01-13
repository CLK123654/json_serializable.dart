// GENERATED CODE - DO NOT MODIFY BY HAND

// ignore_for_file: lines_longer_than_80_chars, text_direction_code_point_in_literal, inference_failure_on_function_invocation, inference_failure_on_collection_literal

part of 'input.type_enumtype.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SimpleClass _$SimpleClassFromJson(Map<String, dynamic> json) => SimpleClass(
  $enumDecodeValues(EnumType.values, json['value']),
  $enumDecodeNullableValues(EnumType.values, json['withDefault']) ??
      EnumType.alpha,
);

Map<String, dynamic> _$SimpleClassToJson(SimpleClass instance) =>
    <String, dynamic>{
      'value': instance.value.name,
      'withDefault': instance.withDefault.name,
    };

SimpleClassNullable _$SimpleClassNullableFromJson(Map<String, dynamic> json) =>
    SimpleClassNullable(
      $enumDecodeNullableValues(EnumType.values, json['value']),
      $enumDecodeNullableValues(EnumType.values, json['withDefault']) ??
          EnumType.alpha,
    );

Map<String, dynamic> _$SimpleClassNullableToJson(
  SimpleClassNullable instance,
) => <String, dynamic>{
  'value': instance.value?.name,
  'withDefault': instance.withDefault?.name,
};
