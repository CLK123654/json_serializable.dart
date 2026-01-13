// Copyright (c) 2018, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analyzer/dart/constant/value.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:source_helper/source_helper.dart';

import 'default_container.dart';
import 'helper_core.dart';
import 'type_helper.dart';
import 'type_helpers/config_types.dart';
import 'type_helpers/convert_helper.dart';
import 'unsupported_type_error.dart';
import 'utils.dart';

TypeHelperCtx typeHelperContext(
  HelperCore helperCore,
  FieldElement fieldElement,
) => TypeHelperCtx._(helperCore, fieldElement);

class TypeHelperCtx
    implements TypeHelperContextWithConfig, TypeHelperContextWithConvert {
  final HelperCore _helperCore;

  @override
  final FieldElement fieldElement;

  @override
  ClassElement get classElement => _helperCore.element;

  @override
  ClassConfig get config => _helperCore.config;

  @override
  ConvertData? get serializeConvertData => _pairFromContext.toJson;

  @override
  ConvertData? get deserializeConvertData => _pairFromContext.fromJson;

  late final _pairFromContext = _ConvertPair(fieldElement);

  TypeHelperCtx._(this._helperCore, this.fieldElement);

  @override
  void addMember(String memberContent) {
    _helperCore.addMember(memberContent);
  }

  @override
  Object? serialize(DartType targetType, String expression) => _run(
    targetType,
    expression,
    (TypeHelper th) => th.serialize(targetType, expression, this),
  );

  @override
  Object deserialize(
    DartType targetType,
    String expression, {
    String? defaultValue,
  }) {
    final value = _run(
      targetType,
      expression,
      (TypeHelper th) =>
          th.deserialize(targetType, expression, this, defaultValue != null),
    );

    return DefaultContainer.deserialize(
      value,
      nullable: targetType.isNullableType,
      defaultValue: defaultValue,
    );
  }

  Object _run(
    DartType targetType,
    String expression,
    Object? Function(TypeHelper) invoke,
  ) =>
      _helperCore.allTypeHelpers
              .map(invoke)
              .firstWhere(
                (r) => r != null,
                orElse: () =>
                    throw UnsupportedTypeError(targetType, expression),
              )
          as Object;
}

class _ConvertPair {
  static final _expando = Expando<_ConvertPair>();

  final ConvertData? fromJson, toJson;

  _ConvertPair._(this.fromJson, this.toJson);

  factory _ConvertPair(FieldElement element) {
    var pair = _expando[element];

    if (pair == null) {
      final obj = jsonKeyAnnotation(element);
      if (obj.isNull) {
        pair = _ConvertPair._(null, null);
      } else {
        final toJson = _convertData(obj.objectValue, element, false);
        final fromJson = _convertData(obj.objectValue, element, true);
        pair = _ConvertPair._(fromJson, toJson);
      }
      _expando[element] = pair;
    }
    return pair;
  }
}

ConvertData? _convertData(DartObject obj, FieldElement element, bool isFrom) {
  final paramName = isFrom ? 'fromJson' : 'toJson';
  final objectValue = obj.getField(paramName);

  if (objectValue == null || objectValue.isNull) {
    return null;
  }

  final executableElement = objectValue.toFunctionValue()!;

  if (executableElement.formalParameters.isEmpty ||
      executableElement.formalParameters.first.isNamed ||
      executableElement.formalParameters.where((pe) => !pe.isOptional).length >
          1) {
    throwUnsupported(
      element,
      'The `$paramName` function `${executableElement.name}` must have one '
      'positional parameter.',
    );
  }

  final returnType = executableElement.returnType;
  final argType = executableElement.formalParameters.first.type;
  if (isFrom) {
    final hasDefaultValue = !jsonKeyAnnotation(
      element,
    ).read('defaultValue').isNull;

    if (returnType is TypeParameterType) {
      // We keep things simple in this case. We rely on inferred type arguments
      // to the `fromJson` function.
      // TODO: consider adding error checking here if there is confusion.
    } else if (executableElement.typeParameters.isNotEmpty) {
      // Handle generic functions like fromJson<T>(String input) => A<T>()
      _validateGenericFunction(
        executableElement,
        returnType,
        element.type,
        paramName,
        element,
        isFrom: true,
      );
    } else if (!returnType.isAssignableTo(element.type)) {
      if (returnType.promoteNonNullable().isAssignableTo(element.type) &&
          hasDefaultValue) {
        // noop
      } else {
        final returnTypeCode = typeToCode(returnType);
        final elementTypeCode = typeToCode(element.type);
        throwUnsupported(
          element,
          'The `$paramName` function `${executableElement.name}` return type '
          '`$returnTypeCode` is not compatible with field type '
          '`$elementTypeCode`.',
        );
      }
    }
  } else {
    if (argType is TypeParameterType) {
      // We keep things simple in this case. We rely on inferred type arguments
      // to the `fromJson` function.
      // TODO: consider adding error checking here if there is confusion.
    } else if (executableElement.typeParameters.isNotEmpty) {
      // Handle generic functions like toJson<T>(A<T> input) => String
      _validateGenericFunction(
        executableElement,
        argType,
        element.type,
        paramName,
        element,
        isFrom: false,
      );
    } else if (!element.type.isAssignableTo(argType)) {
      final argTypeCode = typeToCode(argType);
      final elementTypeCode = typeToCode(element.type);
      throwUnsupported(
        element,
        'The `$paramName` function `${executableElement.name}` argument type '
        '`$argTypeCode` is not compatible with field type'
        ' `$elementTypeCode`.',
      );
    }
  }

  // Extract generic type arguments for generic functions
  // Only add generic type arguments if the function's type parameters
  // correspond to the class's type parameters. This handles cases like:
  // - @JsonKey(fromJson: fromJson<T>, toJson: toJson<T>) where T is from the class
  // But NOT cases like:
  // - @JsonKey(fromJson: _dataFromJson<T, S, U>) where the function has its own generics
  List<String>? genericTypeArgs;
  if (executableElement.typeParameters.isNotEmpty) {
    final classElement = element.enclosingElement as ClassElement;
    if (classElement.typeParameters.isNotEmpty) {
      // Check if the function's type parameters match the class's type parameters
      // This is a heuristic: if the names match and the counts are the same,
      // assume they should use the class's type parameters
      final functionTypeParamNames = executableElement.typeParameters
          .map((tp) => tp.name)
          .toSet();
      final classTypeParamNames = classElement.typeParameters
          .map((tp) => tp.name)
          .toSet();

      if (functionTypeParamNames.length == classTypeParamNames.length &&
          functionTypeParamNames.containsAll(classTypeParamNames)) {
        genericTypeArgs = classElement.typeParameters
            .map((tp) => tp.name!)
            .toList();
      }
      // Otherwise, let the function be called without explicit type arguments
      // Dart's type inference will handle it
    }
  }

  return ConvertData(
    executableElement.qualifiedName,
    argType,
    returnType,
    genericTypeArgs,
  );
}

/// Validates that a generic function is compatible with the target type.
///
/// This function handles the case where @JsonKey specifies generic functions
/// like fromJson<T>(String input) => A<T>() or toJson<T>(A<T> input) => String.
/// We validate that:
/// 1. The function has at most one type parameter
/// 2. The function actually uses its type parameter in the relevant type signature
/// 3. The function signature follows expected patterns
///
/// The actual type compatibility is verified at runtime by Dart's type system
/// when the generated code calls these functions with inferred generic arguments.
///
/// For example, for fromJson<T>(String input) => A<T>(), we need to ensure
/// that A<T> is compatible with the field type when T is inferred from the
/// field type's generic arguments.
void _validateGenericFunction(
  ExecutableElement executableElement,
  DartType functionType,
  DartType targetType,
  String paramName,
  FieldElement element, {
  required bool isFrom,
}) {
  // For generic functions, we perform basic validation to ensure the function
  // signature makes sense. We rely on Dart's type inference to handle the
  // actual generic argument matching during code generation.

  if (executableElement.typeParameters.length > 1) {
    throw UnsupportedTypeError(
      targetType,
      'Generic functions with more than one type parameter are not supported.',
    );
  }

  final typeParam = executableElement.typeParameters.single;

  // Check if the function type contains the type parameter
  bool containsTypeParam(DartType type) {
    if (type is TypeParameterType) {
      return type.element == typeParam;
    }
    if (type is ParameterizedType) {
      return type.typeArguments.any(containsTypeParam);
    }
    return false;
  }

  if (!containsTypeParam(functionType)) {
    throwUnsupported(
      element,
      'The `$paramName` function `${executableElement.name}` is generic but '
      'does not use its type parameter in the ${isFrom ? 'return' : 'argument'} type.',
    );
  }

  // For now, we accept generic functions as long as they follow the basic pattern.
  // The actual type compatibility will be checked at runtime or by the Dart
  // compiler when the generated code is compiled.
}
