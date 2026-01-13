// Copyright (c) 2018, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analyzer/dart/element/type.dart';

import '../lambda_result.dart';
import '../type_helper.dart';

/// Information used by [ConvertHelper] when handling `JsonKey`-annotated
/// fields with `toJson` or `fromJson` values set.
///
/// For generic functions like fromJson<T>(String input) => A<T>(),
/// [genericTypeArgs] contains the inferred type arguments (e.g., ['T'])
/// that should be used when generating the function call in the output code.
class ConvertData {
  final String name;
  final DartType paramType;
  final DartType returnType;

  /// Type arguments to use when calling generic functions.
  /// For example, for a generic function fromJson<T>(), this might contain ['T'].
  /// This allows the generated code to call fromJson<T>() instead of fromJson().
  final List<String>? genericTypeArgs;

  ConvertData(
    this.name,
    this.paramType,
    this.returnType, [
    this.genericTypeArgs,
  ]);
}

abstract class TypeHelperContextWithConvert extends TypeHelperContext {
  ConvertData? get serializeConvertData;

  ConvertData? get deserializeConvertData;
}

/// Handles `JsonKey`-annotated fields with `toJson` or `fromJson` values set.
class ConvertHelper extends TypeHelper<TypeHelperContextWithConvert> {
  const ConvertHelper();

  @override
  Object? serialize(
    DartType targetType,
    String expression,
    TypeHelperContextWithConvert context,
  ) {
    final toJsonData = context.serializeConvertData;
    if (toJsonData == null) {
      return null;
    }

    final functionName = toJsonData.genericTypeArgs != null
        ? '${toJsonData.name}<${toJsonData.genericTypeArgs!.join(', ')}>'
        : toJsonData.name;

    return LambdaResult(expression, functionName);
  }

  @override
  Object? deserialize(
    DartType targetType,
    String expression,
    TypeHelperContextWithConvert context,
    bool defaultProvided,
  ) {
    final fromJsonData = context.deserializeConvertData;
    if (fromJsonData == null) {
      return null;
    }

    final functionName = fromJsonData.genericTypeArgs != null
        ? '${fromJsonData.name}<${fromJsonData.genericTypeArgs!.join(', ')}>'
        : fromJsonData.name;

    return LambdaResult(
      expression,
      functionName,
      asContent: fromJsonData.paramType,
    );
  }
}
