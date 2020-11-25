/// Enumerations adapted from constants in <a href="https://github.com/Moddable-OpenSource/moddable/blob/OS201116/xs/includes/xs.h">xs.h</a>.
///
/// Authors: Chance Snow
/// Copyright: Copyright © 2020 Chance Snow. All rights reserved.
/// License: MIT License
module xs.bindings.enums;

import xs.bindings;

/// The type of a slot.
/// See_Also: <a href="https://github.com/Moddable-OpenSource/moddable/blob/OS201116/documentation/xs/XS%20in%20C.md#slot-types">Slot Types</a>
enum JSType{
  /// JS `undefined`
  undefined = xsUndefinedType,
  /// JS `null`
  null_ = xsNullType,
  /// JS `boolean`
  boolean = xsBooleanType,
  /// JS `Number` represented as an integer
  integer = xsIntegerType,
  /// JS `Number`
  number = xsNumberType,
  /// JS String
  string = xsStringType,
  /// JS String in ROM
  stringX = xsStringXType,
  /// Some JS String, either a reference or in ROM
  someString = xsStringType | xsStringXType,
  /// JS `Symbol`
  symbol = xsSymbolType,
  /// JS `BigInt`
  bigInt = xsBigIntType,
  /// JS `BigInt` in ROM
  bigIntX = xsBigIntXType,
  /// JS reference type
  reference = xsReferenceType,
}

///
enum JSError {
  ///
  noError = 0,
  ///
  unknownError = 1,
  ///
  evalError = 2,
  ///
  rangeError = 3,
  ///
  referenceError = 4,
  ///
  syntaxError = 5,
  ///
  typeError = 6,
  ///
  uriError = 7,
  ///
  errorCount = 8,
}

///
enum MachineError {
	///
  debuggerExit = 0,
  ///
  notEnoughMemoryExit = 1,
  ///
  stackOverflowExit = 2,
  ///
  fatalCheckExit = 3,
  ///
  deadStripExit = 4,
  ///
  unhandledExceptionExit = 5,
  ///
  noMoreKeysExit = 6,
  ///
  tooMuchComputationExit = 7,
}

/// The attributes of a property.
enum Attribute : xsAttribute {
  /// Specifies that a property has no special attributes.
  /// See_Also: `PropertyAttributes.none`
	default_ = 0,
  /// Specifies that the delete operation should fail on a property.
  /// See_Also: `JSObject.deleteProperty`
	dontDelete = 2,
  /// Specifies that a property should not be enumerated by property enumerators and JavaScript `for...in` loops.
	dontEnum = 4,
  /// Specifies that a property is read-only.
	dontSet = 8,
  /// Specifies that a property is static.
	static_ = 16,
  /// Specifies that a property is a getter Function.
	isGetter = 32,
  /// Specifies that a property is a setter Function.
	isSetter = 64,
  ///
	changeAll = 30
}
