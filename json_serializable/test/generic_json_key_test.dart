// Copyright (c) 2025, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:test/test.dart';

import 'generic_json_key.dart';

void main() {
  test(
    'should handle generic fromJson and toJson functions with minimal example',
    () {
      final instance = SerializableJsonKey<String>(a: A<String>());

      final json = instance.toJson();
      final decoded = SerializableJsonKey<String>.fromJson(json);

      expect(decoded.a.runtimeType.toString(), 'A<String>');
    },
  );

  test('should handle JsonConverter with generics using minimal example', () {
    final instance = SerializableConverter<String>('test_value');

    final json = instance.toJson();
    final decoded = SerializableConverter<String>.fromJson(json);

    expect(decoded.value, 'test_value');
  });
}
