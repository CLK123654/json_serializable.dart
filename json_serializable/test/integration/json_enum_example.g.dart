// GENERATED CODE - DO NOT MODIFY BY HAND

// ignore_for_file: lines_longer_than_80_chars, text_direction_code_point_in_literal, inference_failure_on_function_invocation, inference_failure_on_collection_literal

part of 'json_enum_example.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Issue559Regression _$Issue559RegressionFromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    requiredKeys: const ['status'],
    disallowNullValues: const ['status'],
  );
  return Issue559Regression(
    status: $enumDecodeNullableValues(
      Issue559RegressionEnum.values,
      json['status'],
      unknownValue: JsonKey.nullForUndefinedEnumValue,
    ),
  );
}

Map<String, dynamic> _$Issue1145RegressionAToJson(
  Issue1145RegressionA instance,
) => <String, dynamic>{
  'status': instance.status.map((k, e) => MapEntry(k.name, e)),
};

Map<String, dynamic> _$Issue1145RegressionBToJson(
  Issue1145RegressionB instance,
) => <String, dynamic>{'status': instance.status.map((e) => e?.name).toList()};

Issue1226Regression _$Issue1226RegressionFromJson(Map<String, dynamic> json) =>
    Issue1226Regression(
      durationType: $enumDecodeNullableValues(
        Issue1145RegressionEnum.values,
        json['durationType'],
      ),
    );

Map<String, dynamic> _$Issue1226RegressionToJson(
  Issue1226Regression instance,
) => <String, dynamic>{'durationType': ?instance.durationType?.name};

const _$StandAloneEnumEnumMap = {
  StandAloneEnum.alpha: 'a',
  StandAloneEnum.beta: 'b',
  StandAloneEnum.gamma: 'g',
  StandAloneEnum.delta: 'd',
};

const _$DayTypeEnumMap = {
  DayType.noGood: 'no-good',
  DayType.rotten: 'rotten',
  DayType.veryBad: 'very-bad',
};

const _$MyStatusCodeEnumMap = {
  MyStatusCode.success: 200,
  MyStatusCode.weird: 701,
};

const _$EnumValueFieldIndexEnumMap = {
  EnumValueFieldIndex.success: 0,
  EnumValueFieldIndex.weird: 701,
  EnumValueFieldIndex.oneMore: 2,
};
