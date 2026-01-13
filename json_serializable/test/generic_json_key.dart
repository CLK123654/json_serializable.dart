// Copyright (c) 2025, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:json_annotation/json_annotation.dart';

part 'generic_json_key.g.dart';

class A<T> {}

A<T> fromJson<T>(String input) => A<T>();
String toJson<T>(A<T> input) => '$input';

// Wrapper functions to make the generic functions usable in annotations
A<T> _fromJson<T>(String input) => fromJson<T>(input);
String _toJson<T>(A<T> input) => toJson<T>(input);

@JsonSerializable()
class SerializableJsonKey<T> {
  const SerializableJsonKey({required this.a});

  @JsonKey(fromJson: _fromJson, toJson: _toJson)
  final A<T> a;

  factory SerializableJsonKey.fromJson(Map<String, dynamic> json) =>
      _$SerializableJsonKeyFromJson<T>(json);

  Map<String, dynamic> toJson() => _$SerializableJsonKeyToJson<T>(this);
}

class SimpleGenericConverter<T> implements JsonConverter<T, String> {
  const SimpleGenericConverter();

  @override
  T fromJson(String json) => json as T;

  @override
  String toJson(T object) => object.toString();
}

@JsonSerializable()
class SerializableConverter<T> {
  const SerializableConverter(this.value);

  // ignore: inference_failure_on_instance_creation
  @SimpleGenericConverter()
  final T value;

  factory SerializableConverter.fromJson(Map<String, dynamic> json) =>
      _$SerializableConverterFromJson<T>(json);

  Map<String, dynamic> toJson() => _$SerializableConverterToJson<T>(this);
}
