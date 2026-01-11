// Copyright (c) 2018, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// @dart=3.8

part of '_json_serializable_test_input.dart';

class A<T> {}

A<T> fromJson<T>(String input) => A<T>();

String toJson<T>(A<T> input) => '$input';

@ShouldGenerate(r'''
Serializable<T> _$SerializableFromJson<T>(Map<String, dynamic> json) =>
    Serializable<T>(a: fromJson(json['a'] as String));

Map<String, dynamic> _$SerializableToJson<T>(Serializable<T> instance) =>
    <String, dynamic>{'a': toJson(instance.a)};
''')
@JsonSerializable()
class Serializable<T> {
  const Serializable({required this.a});
  @JsonKey(fromJson: fromJson, toJson: toJson)
  final A<T> a;
}

class Slug<T> {}

class Asd<T> extends Slug<T> {}

class Lol<T> extends Slug<T> {}

class Rofl<T> extends Slug<T> {}

class Lmao<T> extends Slug<T> {}

class SlugConverter<T> extends JsonConverter<Slug<T>, String> {
  const SlugConverter();

  @override
  String toJson(Slug<T> object) {
    return object.runtimeType.toString();
  }

  @override
  Slug<T> fromJson(String json) {
    throw UnimplementedError();
  }
}

@ShouldGenerate(r'''
SerializableConverter<T> _$SerializableConverterFromJson<T>(
  Map<String, dynamic> json,
) => SerializableConverter<T>(
  SlugConverter<T>().fromJson(json['slug'] as String),
);

Map<String, dynamic> _$SerializableConverterToJson<T>(
  SerializableConverter<T> instance,
) => <String, dynamic>{'slug': SlugConverter<T>().toJson(instance.slug)};
''')
@JsonSerializable()
class SerializableConverter<T> {
  const SerializableConverter(this.slug);
  @SlugConverter<T>()
  final Slug<T> slug;
}

