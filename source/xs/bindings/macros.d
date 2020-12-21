/// Implements <a href="https://github.com/Moddable-OpenSource/moddable/blob/OS201116/xs/includes/xs.h#L156-L1244">macros from xs.h</a> as idiomatic D.
///
/// Authors: Chance Snow
/// Copyright: Copyright © 2020 Chance Snow. All rights reserved.
/// License: MIT License
module xs.bindings.macros;

import std.conv : to;
import std.string : format, toStringz;
import xs.bindings;
import xs.bindings.enums;

pragma(inline, true):

/// Pop a slot off the stack.
xsSlot fxPop(scope xsMachine* the) {
  return *(the.stack++);
}
/// Push a slot onto the stack.
void fxPush(scope xsMachine* the, xsSlot slot) {
  *(--the.stack) = slot;
}

debug {
  ///
  void xsOverflow(scope xsMachine* the, int count, string file = __FILE__, int line = __LINE__) {
	  fxOverflow(the, count, cast(char*) file.toStringz, line);
  }
} else {
  ///
  void xsOverflow(scope xsMachine* the, int count) {
	  fxOverflow(the, count, null, 0);
  }
}

// Slot

/// Returns the `Type` of a slot.
/// Params:
/// the=A machine
/// theSlot=The slot to test
/// Returns: The `Type` of a `theSlot`.
///
/// > **Note**: The macros in the XS in C API require a reference to the target virtual machine in a variable in the
/// > current scope with the name `the` of type `xsMachine*`.
///
/// See_Also: <a href="https://github.com/Moddable-OpenSource/moddable/blob/OS201116/documentation/xs/XS%20in%20C.md#slot-types">Slot Types</a>
JSType xsTypeOf(scope xsMachine* the, const xsSlot theSlot) {
  the.scratch = cast(xsSlot) theSlot;
  return fxTypeOf(the, &the.scratch).to!uint.to!JSType;
}

// Primitives

/// Returns an `undefined` slot
xsSlot xsUndefined(scope xsMachine* the) {
  fxUndefined(the, &the.scratch);
  return the.scratch;
}
/// Returns a `null` slot
xsSlot xsNull(scope xsMachine* the) {
  fxNull(the, &the.scratch);
  return the.scratch;
}
/// Returns a `false` slot
xsSlot xsFalse(scope xsMachine* the) {
  fxBoolean(the, &the.scratch, 0);
  return the.scratch;
}
/// Returns a `true` slot
xsSlot xsTrue(scope xsMachine* the) {
  fxBoolean(the, &the.scratch, 1);
  return the.scratch;
}

/// Returns a Boolean slot
xsSlot xsBoolean(scope xsMachine* the, bool value) {
  fxBoolean(the, &the.scratch, value);
  return the.scratch;
}
/// Convert a slot to a Boolean value
bool xsToBoolean(scope xsMachine* the, const xsSlot theSlot) {
  the.scratch = cast(xsSlot) theSlot;
  return fxToBoolean(the, &the.scratch).to!bool;
}

/// Returns a Number slot given an `int`.
xsSlot xsInteger(scope xsMachine* the, int value) {
  fxInteger(the, &the.scratch, value);
  return the.scratch;
}
/// Convert a slot to a Number value represented as an `int`.
xsIntegerValue xsToInteger(scope xsMachine* the, const xsSlot theSlot) {
  the.scratch = cast(xsSlot) theSlot;
  return fxToInteger(the, &the.scratch);
}

/// Returns a Number slot given an `uint`.
xsSlot xsUnsigned(scope xsMachine* the, uint value) {
  fxUnsigned(the, &the.scratch, value);
  return the.scratch;
}
/// Convert a slot to a Number value represented as an `uint`.
xsUnsignedValue xsToUnsigned(scope xsMachine* the, const xsSlot theSlot) {
  the.scratch = cast(xsSlot) theSlot;
  return fxToUnsigned(the, &the.scratch);
}

/// Returns a Number slot given a `double`.
xsSlot xsNumber(scope xsMachine* the, double value) {
  fxNumber(the, &the.scratch, value);
  return the.scratch;
}
/// Convert a slot to a Number value.
double xsToNumber(scope xsMachine* the, const xsSlot theSlot) {
  the.scratch = cast(xsSlot) theSlot;
  return fxToNumber(the, &the.scratch);
}

/// Returns a String slot given a `string`.
xsSlot xsString(scope xsMachine* the, string value) {
  fxString(the, &the.scratch, cast(char*) value.toStringz);
  return the.scratch;
}
/// Returns a StringBuffer slot given a `string`.
xsSlot xsStringBuffer(scope xsMachine* the, string buffer) {
  return xsStringBuffer(the, buffer.toStringz, buffer.length.to!int);
}
/// Returns a StringBuffer slot given a `char*`.
xsSlot xsStringBuffer(scope xsMachine* the, const char* buffer, int size) {
  fxStringBuffer(the, &the.scratch, cast(char*) buffer, size);
  return the.scratch;
}
/// Convert a slot to a String value.
char* xsToString(scope xsMachine* the, const xsSlot theSlot) {
  the.scratch = cast(xsSlot) theSlot;
  return fxToString(the, &the.scratch);
}
/// Convert a slot to a StringBuffer value given a `string`.
void xsToStringBuffer(scope xsMachine* the, xsSlot theSlot, string buffer) {
  xsToStringBuffer(the, theSlot, buffer.toStringz, buffer.length.to!int);
}
/// Convert a slot to a StringBuffer value given a `char*`.
void xsToStringBuffer(scope xsMachine* the, xsSlot theSlot, const char* buffer, int size) {
  the.scratch = theSlot;
  fxToStringBuffer(the, &the.scratch, cast(char*) buffer, size);
}

/// Returns an ArrayBuffer slot.
/// Params:
/// the=A machine
/// buffer=
/// size=The size of the data in bytes
xsSlot xsArrayBuffer(scope xsMachine* the, void* buffer, int size) {
  fxArrayBuffer(the, &the.scratch, buffer, size);
  return the.scratch;
}
/// Get the data of an ArrayBuffer.
/// Params:
/// theSlot=The ArrayBuffer slot
/// offset=The starting byte offset to get the data
/// size=The data size to copy in bytes
void xsGetArrayBufferData(T)(scope xsMachine* the, xsSlot theSlot, int offset, out T[] buffer, int size) {
  xsGetArrayBufferData(the, theSlot, offset, buffer.ptr, size);
}
/// ditto
void xsGetArrayBufferData(scope xsMachine* the, xsSlot theSlot, int offset, out void* buffer, int size) {
  the.scratch = theSlot;
  fxGetArrayBufferData(the, &the.scratch, offset, buffer, size);
}
/// Returns the size of the ArrayBuffer in bytes.
/// Params:
/// the=A machine
/// theSlot=The ArrayBuffer slot
int xsGetArrayBufferLength(scope ref xsMachine* the, xsSlot theSlot) {
  the.scratch = theSlot;
  return fxGetArrayBufferLength(the, &the.scratch);
}
/// Copies bytes into the ArrayBuffer.
/// Params:
/// the=A machine
/// theSlot=The ArrayBuffer slot
/// offset=The starting byte offset to get the data
void xsSetArrayBufferData(T)(scope xsMachine* the, xsSlot theSlot, int offset, T[] buffer) {
  xsSetArrayBufferData(the, theSlot, offset, buffer.ptr, T.sizeof * buffer.length.to!int);
}
/// ditto
void xsSetArrayBufferData(scope xsMachine* the, xsSlot theSlot, int offset, void* buffer, int size) {
  the.scratch = theSlot;
  fxSetArrayBufferData(the, &the.scratch, offset, buffer, size);
}
/// Set the length of an ArrayBuffer.
/// Params:
/// the=A machine
/// theSlot=The ArrayBuffer slot
/// length=The size of the ArrayBuffer data in bytes. If the size of the buffer is increased, the new data is initialized to 0.
void xsSetArrayBufferLength(scope xsMachine* the, xsSlot theSlot, int length) {
  the.scratch = theSlot;
  fxSetArrayBufferLength(the, &the.scratch, length);
}
/// Returns a pointer to the ArrayBuffer data.
///
/// For speed, the `xsToArrayBuffer` macro returns the value contained in the slot itself, a pointer to the buffer in the memory managed by XS.
/// Since the XS runtime can compact memory containing string values, the result of the `xsToArrayBuffer` macro cannot be used across or in other macros of XS in C.
///
/// Params:
/// the=A machine
/// theSlot=The ArrayBuffer slot
void* xsToArrayBuffer(scope xsMachine* the, xsSlot theSlot) {
  the.scratch = theSlot;
  return fxToArrayBuffer(the, &the.scratch);
}

// Closures and References

// TODO: xsClosure
// #define xsClosure(scope xsMachine* the, _VALUE) \
// 	(fxClosure(the, &the.scratch, _VALUE), \
// 	the.scratch)
// TODO: xsToClosure
// #define xsToClosure(scope xsMachine* the, _SLOT) \
// 	(the.scratch = (_SLOT), \
// 	fxToClosure(the, &(the.scratch)))

// TODO: xsReference
// #define xsReference(scope xsMachine* the, _VALUE) \
// 	(fxReference(the, &the.scratch, _VALUE), \
// 	the.scratch)
// TODO: xsToReference
// #define xsToReference(scope xsMachine* the, _SLOT) \
// 	(the.scratch = (_SLOT), \
// 	fxToReference(the, &(the.scratch)))

// Instances and Prototypes

/// Index of standard JavaScript prototypes on a `xsMachine`'s stack.
enum int prototypesStackIndex = -75;
/// Returns a reference to the <a href="https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Object">Object</a> prototype instance created by the XS runtime.
/// See_Also: <a href="https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Object">Object</a> on MDN
xsSlot xsObjectPrototype(alias xsMachine* the)() { return the.stackPrototypes[prototypesStackIndex - 1]; }
/// Returns a reference to the <a href="https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Function">Function</a> prototype instance created by the XS runtime.
/// See_Also: <a href="https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Function">Function</a> on MDN
xsSlot xsFunctionPrototype(alias xsMachine* the)() { return the.stackPrototypes[prototypesStackIndex - 2]; }
/// Returns a reference to the <a href="https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Array">Array</a> prototype instance created by the XS runtime.
/// See_Also: <a href="https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Array">Array</a> on MDN
xsSlot xsArrayPrototype(alias xsMachine* the)() { return the.stackPrototypes[prototypesStackIndex - 3]; }
/// Returns a reference to the <a href="https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/String">String</a> prototype instance created by the XS runtime.
/// See_Also: <a href="https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/String">String</a> on MDN
xsSlot xsStringPrototype(alias xsMachine* the)() { return the.stackPrototypes[prototypesStackIndex - 4]; }
/// Returns a reference to the <a href="https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Boolean">Boolean</a> prototype instance created by the XS runtime.
/// See_Also: <a href="https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Boolean">Boolean</a> on MDN
xsSlot xsBooleanPrototype(alias xsMachine* the)() { return the.stackPrototypes[prototypesStackIndex - 5]; }
/// Returns a reference to the <a href="https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Number">Number</a> prototype instance created by the XS runtime.
/// See_Also: <a href="https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Number">Number</a> on MDN
xsSlot xsNumberPrototype(alias xsMachine* the)() { return the.stackPrototypes[prototypesStackIndex - 6]; }
/// Returns a reference to the <a href="https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Date">Date</a> prototype instance created by the XS runtime.
/// See_Also: <a href="https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Date">Date</a> on MDN
xsSlot xsDatePrototype(alias xsMachine* the)() { return the.stackPrototypes[prototypesStackIndex - 7]; }
/// Returns a reference to the <a href="https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/RegExp">RegExp</a> prototype instance created by the XS runtime.
/// See_Also: <a href="https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/RegExp">RegExp</a> on MDN
xsSlot xsRegExpPrototype(alias xsMachine* the)() { return the.stackPrototypes[prototypesStackIndex - 8]; }
/// Returns a reference to the Host prototype instance created by the XS runtime.
xsSlot xsHostPrototype(alias xsMachine* the)() { return the.stackPrototypes[prototypesStackIndex - 9]; }
/// Returns a reference to the <a href="https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Error">Error</a> prototype instance created by the XS runtime.
/// See_Also: <a href="https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Error">Error</a> on MDN
xsSlot xsErrorPrototype(alias xsMachine* the)() { return the.stackPrototypes[prototypesStackIndex - 10]; }
/// Returns a reference to the <a href="https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/EvalError">EvalError</a> prototype instance created by the XS runtime.
/// See_Also: <a href="https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/EvalError">EvalError</a> on MDN
xsSlot xsEvalErrorPrototype(alias xsMachine* the)() { return the.stackPrototypes[prototypesStackIndex - 11]; }
/// Returns a reference to the <a href="https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/RangeError">RangeError</a> prototype instance created by the XS runtime.
/// See_Also: <a href="https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/RangeError">RangeError</a> on MDN
xsSlot xsRangeErrorPrototype(alias xsMachine* the)() { return the.stackPrototypes[prototypesStackIndex - 12]; }
/// Returns a reference to the <a href="https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/ReferenceError">ReferenceError</a> prototype instance created by the XS runtime.
/// See_Also: <a href="https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/ReferenceError">ReferenceError</a> on MDN
xsSlot xsReferenceErrorPrototype(alias xsMachine* the)() { return the.stackPrototypes[prototypesStackIndex - 13]; }
/// Returns a reference to the <a href="https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/SyntaxError">SyntaxError</a> prototype instance created by the XS runtime.
/// See_Also: <a href="https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/SyntaxError">SyntaxError</a> on MDN
xsSlot xsSyntaxErrorPrototype(alias xsMachine* the)() { return the.stackPrototypes[prototypesStackIndex - 14]; }
/// Returns a reference to the <a href="https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/TypeError">TypeError</a> prototype instance created by the XS runtime.
/// See_Also: <a href="https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/TypeError">TypeError</a> on MDN
xsSlot xsTypeErrorPrototype(alias xsMachine* the)() { return the.stackPrototypes[prototypesStackIndex - 15]; }
/// Returns a reference to the <a href="https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/URIError">URIError</a> prototype instance created by the XS runtime.
/// See_Also: <a href="https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/URIError">URIError</a> on MDN
xsSlot xsURIErrorPrototype(alias xsMachine* the)() { return the.stackPrototypes[prototypesStackIndex - 16]; }
/// Returns a reference to the <a href="https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/AggregateError">AggregateError</a> prototype instance created by the XS runtime.
/// See_Also: <a href="https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/AggregateError">AggregateError</a> on MDN
xsSlot xsAggregateErrorPrototype(alias xsMachine* the)() { return the.stackPrototypes[prototypesStackIndex - 17]; }
/// Returns a reference to the <a href="https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Symbol">Symbol</a> prototype instance created by the XS runtime.
/// See_Also: <a href="https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Symbol">Symbol</a> on MDN
xsSlot xsSymbolPrototype(alias xsMachine* the)() { return the.stackPrototypes[prototypesStackIndex - 18]; }
/// Returns a reference to the <a href="https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/ArrayBuffer">ArrayBuffer</a> prototype instance created by the XS runtime.
/// See_Also: <a href="https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/ArrayBuffer">ArrayBuffer</a> on MDN
xsSlot xsArrayBufferPrototype(alias xsMachine* the)() { return the.stackPrototypes[prototypesStackIndex - 19]; }
/// Returns a reference to the <a href="https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/DataView">DataView</a> prototype instance created by the XS runtime.
/// See_Also: <a href="https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/DataView">DataView</a> on MDN
xsSlot xsDataViewPrototype(alias xsMachine* the)() { return the.stackPrototypes[prototypesStackIndex - 20]; }
/// Returns a reference to the <a href="https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/TypedArray">TypedArray</a> prototype instance created by the XS runtime.
/// See_Also: <a href="https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/TypedArray">TypedArray</a> on MDN
xsSlot xsTypedArrayPrototype(alias xsMachine* the)() { return the.stackPrototypes[prototypesStackIndex - 21]; }
/// Returns a reference to the <a href="https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Map">Map</a> prototype instance created by the XS runtime.
/// See_Also: <a href="https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Map">Map</a> on MDN
xsSlot xsMapPrototype(alias xsMachine* the)() { return the.stackPrototypes[prototypesStackIndex - 22]; }
/// Returns a reference to the <a href="https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Set">Set</a> prototype instance created by the XS runtime.
/// See_Also: <a href="https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Set">Set</a> on MDN
xsSlot xsSetPrototype(alias xsMachine* the)() { return the.stackPrototypes[prototypesStackIndex - 23]; }
/// Returns a reference to the <a href="https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/WeakMap">WeakMap</a> prototype instance created by the XS runtime.
/// See_Also: <a href="https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/WeakMap">WeakMap</a> on MDN
xsSlot xsWeakMapPrototype(alias xsMachine* the)() { return the.stackPrototypes[prototypesStackIndex - 24]; }
/// Returns a reference to the <a href="https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/WeakSet">WeakSet</a> prototype instance created by the XS runtime.
/// See_Also: <a href="https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/WeakSet">WeakSet</a> on MDN
xsSlot xsWeakSetPrototype(alias xsMachine* the)() { return the.stackPrototypes[prototypesStackIndex - 25]; }
/// Returns a reference to the <a href="https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Promise">Promise</a> prototype instance created by the XS runtime.
/// See_Also: <a href="https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Promise">Promise</a> on MDN
xsSlot xsPromisePrototype(alias xsMachine* the)() { return the.stackPrototypes[prototypesStackIndex - 26]; }
/// Returns a reference to the <a href="https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Proxy">Proxy</a> prototype instance created by the XS runtime.
/// See_Also: <a href="https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Proxy">Proxy</a> on MDN
xsSlot xsProxyPrototype(alias xsMachine* the)() { return the.stackPrototypes[prototypesStackIndex - 27]; }

/// Creates an array instance, and returns a reference to the new array instance.
///
/// Examples:
/// In ECMAScript:
/// ---
/// new Array(5);
/// ---
/// In D:
/// ---
/// machine.xsNewArray(5);
/// ---
xsSlot xsNewArray(scope xsMachine* the, int length) {
	fxNewArray(the, length);
	return the.fxPop;
}

/// Creates an object instance, and returns a reference to the new object instance.
///
/// Examples:
/// In ECMAScript:
/// ---
/// new Object();
/// ---
/// In D:
/// ---
/// machine.xsNewObject();
/// ---
xsSlot xsNewObject(scope xsMachine* the) {
	fxNewObject(the);
	return the.fxPop;
}

/// Tests whether an instance has a particular prototype, directly or indirectly (that is, one or more levels up in the prototype hierarchy).
///
/// The `xsIsInstanceOf` macro has no equivalent in ECMAScript; scripts test instances through constructors rather than directly through prototypes. A constructor is a function that has a prototype property that is used to test instances with `isPrototypeOf`.
///
/// Examples:
/// In ECMAScript:
/// ---
/// if (Object.prototype.isPrototypeOf(this)) return new Object();
/// ---
/// In D:
/// ---
/// if (machine.xsIsInstanceOf(xsThis, xsObjectPrototype)) xsResult = machine.xsNewObject();
/// ---
///
/// Returns: `true` if the instance has the prototype, `false` otherwise.
/// Params:
/// the=A machine
/// instance=A reference to the instance to test
/// prototype=A reference to the prototype to test
bool xsIsInstanceOf(scope xsMachine* the, const xsSlot instance, const xsSlot prototype) {
	the.xsOverflow(-2);
	the.fxPush(cast(xsSlot) prototype);
	the.fxPush(cast(xsSlot) instance);
	return fxIsInstanceOf(the).to!bool;
}

// Identifiers

///
enum XS_NO_ID = -1;

///
xsIndex xsID(scope xsMachine* the, string name) {
	return xsID(the, name.toStringz);
}
/// ditto
xsIndex xsID(scope xsMachine* the, const char* name) {
	return fxID(the, name);
}
///
xsIndex xsFindID(scope xsMachine* the, string name) {
	return xsFindID(the, name.toStringz);
}
/// ditto
xsIndex xsFindID(scope xsMachine* the, const char* name) {
	return fxFindID(the, cast(char*) name);
}
///
bool xsIsID(scope xsMachine* the, string name) {
	return xsIsID(the, name.toStringz);
}
/// ditto
bool xsIsID(scope xsMachine* the, const char* name) {
	return fxIsID(the, cast(char*) name).to!bool;
}
///
xsIndex xsToID(scope xsMachine* the, const xsSlot slot) {
	the.scratch = cast(xsSlot) slot;
	return fxToID(the, &the.scratch);
}
///
char* xsName(scope xsMachine* the, xsIndex id) {
	return fxName(the, id);
}

// Properties

// TODO: xsEnumerate
// #define xsEnumerate(_THIS) \
// 	(xsOverflow(-1), \
// 	fxPush(_THIS), \
// 	fxEnumerate(the), \
// 	fxPop())

/// Tests whether an instance has a property corresponding to a particular ECMAScript property name.
///
/// This macro is similar to the ECMAScript `in` keyword.
///
/// Params:
/// the=A machine
/// this_=A reference to the instance to test
/// id=The identifier of the property to test
/// Returns: `true` if the instance has the property, `false` otherwise
///
/// Examples:
/// In ECMAScript:
/// ---
/// if ("foo" in this)
/// ---
/// In D:
/// ---
/// if (xsHas(xsThis, xsID_foo));
/// ---
bool xsHas(scope xsMachine* the, const xsSlot this_, int id) {
	the.xsOverflow(-1);
	the.fxPush(cast(xsSlot) this_);
	return fxHasID(the, id).to!bool;
}

/// Tests whether an instance has a property corresponding to a particular ECMAScript property key.
///
/// Params:
/// the=A machine
/// this_=A reference to the instance to test
/// key=The key of the property to test
/// Returns: `true` if the instance has the property, `false` otherwise
///
/// Examples:
/// In ECMAScript:
/// ---
/// if (7 in this)
/// ---
/// In D:
/// ---
/// if (xsHasAt(xsThis, xsInteger(7)));
/// ---
bool xsHasAt(scope xsMachine* the, const xsSlot this_, const xsSlot key) {
	the.xsOverflow(-2);
	the.fxPush(cast(xsSlot) this_);
	the.fxPush(cast(xsSlot) key);
	return fxHasAt(the).to!bool;
}

/// Get a property or item of an instance.
///
/// Params:
/// the=A machine
/// this_=A reference to the instance that has the property or item
/// id=The identifier of the property or item to get
/// Returns:
/// A slot containing what is contained in the property or item, or `xsUndefined` if the property or item is not defined by the instance or its prototypes
///
/// Examples:
/// In ECMAScript:
/// ---
/// foo
/// this.foo
/// this[0]
/// ---
/// In D:
/// ---
/// xsGet(xsGlobal, xsID_foo);
/// xsGet(xsThis, xsID_foo);
/// xsGet(xsThis, 0);
/// ---
xsSlot xsGet(scope xsMachine* the, const xsSlot this_, int id) {
	the.xsOverflow(-1);
	the.fxPush(cast(xsSlot) this_);
	fxGetID(the, id);
	return the.fxPop();
}

/// Get a property or item of an array instance with a specified name, index or symbol.
///
/// Params:
/// the=A machine
/// this_=A reference to the object that has the property or item
/// key=The key of the property or item to get
/// Returns:
/// A slot containing what is contained in the property or item, or xsUndefined if the property or item is not defined by the instance or its prototypes
///
/// Examples:
/// In ECMAScript:
/// ---
/// this.foo[3]
/// ---
/// In D:
/// ---
/// xsVars(2);
/// xsVar(0) = xsGet(xsThis, xsID_foo);
/// xsVar(1) = xsGetAt(xsVar(0), xsInteger(3));
/// ---
xsSlot xsGetAt(scope xsMachine* the, const xsSlot this_, const xsSlot key) {
	the.xsOverflow(-2);
	the.fxPush(cast(xsSlot) this_);
	the.fxPush(cast(xsSlot) key);
	fxGetAt(the);
	return the.fxPop();
}

/// Set a property or item of an instance.
///
/// Params:
/// the=A machine
/// this_=A reference to the instance that will have the property or item
/// id=The identifier of the property or item to set
/// slot=The value of the property or item to set
///
/// Examples:
/// In ECMAScript:
/// ---
/// foo = 0
/// this.foo = 1
/// this[0] = 2
/// ---
/// In D:
/// ---
/// xsSet(xsGlobal, xsID_foo, xsInteger(0));
/// xsSet(xsThis, xsID_foo, xsInteger(1));
/// xsSet(xsThis, 0, xsInteger(2));
/// ---
void xsSet(scope xsMachine* the, const xsSlot this_, xsIndex id, const xsSlot slot) {
	the.xsOverflow(-2);
	the.fxPush(cast(xsSlot) slot);
	the.fxPush(cast(xsSlot) this_);
	fxSetID(the, id);
	the.stack++;
}

/// Set a property or item of an array instance by key.
///
/// Params:
/// the=A machine
/// this_=A reference to the object that has the property or item
/// key=The key of the property or item to set
/// slot=The value of the property or item to set
///
/// Examples:
/// In ECMAScript:
/// ---
/// this.foo[3] = 7
/// ---
/// In D:
/// ---
/// xsVars(1);
/// xsVar(0) = xsGet(xsThis, xsID_foo);
/// xsSetAt(xsVar(0), xsInteger(3), xsInteger(7));
/// ---
void xsSetAt(scope xsMachine* the, const xsSlot this_, const xsSlot key, const xsSlot slot) {
	the.xsOverflow(-3);
	the.fxPush(cast(xsSlot) slot);
	the.fxPush(cast(xsSlot) this_);
	the.fxPush(cast(xsSlot) key);
	fxSetAt(the);
	the.stack++;
}

/// For theAttributes, specify the constants corresponding to the attributes you want to set (the others being cleared).
///
/// The `xsDontDelete`, `xsDontEnum`, and `xsDontSet` attributes correspond to the ECMAScript DontDelete, DontEnum, and ReadOnly attributes.
/// By default a property can be deleted, enumerated, and set.
///
/// When a property is created, if the prototype of the instance has a property with the same name, its attributes are inherited;
/// otherwise, by default, a property can be deleted, enumerated, and set, and can be used by scripts.
///
/// Examples:
/// In ECMAScript:
/// ---
/// Object.defineProperty(this, "foo", 7, { writable: true, enumerable: true, configurable: true });
/// ---
/// In D:
/// ---
/// machine.xsDefine(xsThis, xsID_foo, xsInteger(7), xsDefault);
/// ---
void xsDefine(scope xsMachine* the, const xsSlot this_, xsIndex id, const xsSlot slot, xsAttribute attributes) {
	the.xsOverflow(-2);
	the.fxPush(cast(xsSlot) slot);
	the.fxPush(cast(xsSlot) this_);
	fxDefineID(the, id, attributes, attributes | xsDontDelete | xsDontSet);
	the.stack++;
}

///
void xsDefineAt(scope xsMachine* the, const xsSlot this_, const xsSlot key, const xsSlot slot, xsAttribute attributes) {
	the.xsOverflow(-3);
	the.fxPush(cast(xsSlot) slot);
	the.fxPush(cast(xsSlot) this_);
	the.fxPush(cast(xsSlot) key);
	fxDefineAt(the, attributes, attributes | xsDontDelete | xsDontSet);
	the.stack++;
}

/// Delete a property or item of an instance.
///
/// If the property or item is not defined by the instance, this macro has no effect.
///
/// Params:
/// the=A machine
/// this_=A reference to the instance that has the property or item
/// key=The key of the property or item to delete
///
/// Examples:
/// In ECMAScript:
/// ---
/// delete foo
/// delete this.foo
/// delete this[0]
/// ---
/// In D:
/// ---
/// the.xsDelete(xsGlobal, xsID_foo);
/// the.xsDelete(xsThis, xsID_foo);
/// the.xsDelete(xsThis, 0);
/// ---
void xsDelete(scope xsMachine* the, const xsSlot this_, int key) {
	the.xsOverflow(-1);
	the.fxPush(cast(xsSlot) this_);
	fxDeleteID(the, key);
	the.stack++;
}

/// Delete a property or item of an instance by key.
///
/// If the property or item is not defined by the instance, this macro has no effect.
///
/// Params:
/// the=A machine
/// this_=A reference to the instance that has the property or item
/// key=The key of the property or item to delete
///
/// Examples:
/// In ECMAScript:
/// ---
/// delete this.foo
/// delete this[0]
/// ---
/// In D:
/// ---
/// the.xsDeleteAt(xsThis, xsID_foo);
/// the.xsDeleteAt(xsThis, xsInteger(0));
/// ---
void xsDeleteAt(scope xsMachine* the, const xsSlot this_, const xsSlot key) {
	the.xsOverflow(-2);
	the.fxPush(cast(xsSlot) this_);
	the.fxPush(cast(xsSlot) key);
	fxDeleteAt(the);
	the.stack++;
}

///
enum int XS_FRAME_COUNT = 6;

/// Call a Function.
///
/// When a property or item of an instance is a reference to a function, you can call the function with the `xsCall` template.
/// If the property or item is not defined by the instance or its prototypes or is not a reference to a function, `xsCall` throws an exception.
///
/// Params:
/// the=A machine
/// this_=A reference to the instance that will have the property or item
/// id=The identifier of the property or item to call
/// params=The parameter slots to pass to the function
/// Returns: The function's return value slot.
///
/// Examples:
/// In ECMAScript:
/// ---
/// foo()
/// this.foo(1)
/// this[0](2, 3)
/// ---
/// In D:
/// ---
/// xsCall(xsGlobal, xsID_foo);
/// xsCall(xsThis, xsID_foo, xsInteger(1));
/// xsCall(xsThis, 0, xsInteger(2), xsInteger(3));
/// ---
xsSlot xsCall(scope xsMachine* the, const xsSlot this_, xsIndex id, const xsSlot[] params ...) {
  assert(params.length >= 0);
	the.xsOverflow(-XS_FRAME_COUNT - params.length.to!int);
	the.fxPush(cast(xsSlot) this_);
	fxCallID(the, id);
  foreach (param; params) fxPush(the, cast(xsSlot) param);
	fxRunCount(the, params.length.to!int);
	return the.fxPop();
}

/// Call a Function, ignoring its result.
///
/// Params:
/// the=A machine
/// this_=A reference to the instance that will have the property or item
/// id=The identifier of the property or item to call
/// params=The parameter slots to pass to the function
void xsCall_noResult(scope xsMachine* the, const xsSlot this_, xsIndex id, const xsSlot[] params ...) {
  assert(params.length >= 0);
	the.xsOverflow(-XS_FRAME_COUNT - params.length.to!int);
	the.fxPush(cast(xsSlot) this_);
	fxCallID(the, id);
  foreach (param; params) fxPush(the, cast(xsSlot) param);
	fxRunCount(the, params.length.to!int);
	the.stack++;
}

///
/// Params:
/// the=A machine
/// this_=A reference to the instance that will have the property or item
/// function_=A reference to the the property or item to call
/// params=The parameter slots to pass to the function
/// Returns: The function's return value slot.
///
/// Examples:
/// In ECMAScript:
/// ---
/// foo()
/// this.foo(1)
/// this[0](2, 3)
/// ---
/// In D:
/// ---
/// xsCallFunction(xsGlobal, foo);
/// xsCallFunction(xsThis, foo, xsInteger(1));
/// xsCallFunction(xsThis, 0, xsInteger(2), xsInteger(3));
/// ---
xsSlot xsCallFunction(scope xsMachine* the, const xsSlot function_, const xsSlot this_, const xsSlot[] params ...) {
  assert(params.length >= 0);
	xsOverflow(the, -XS_FRAME_COUNT - params.length.to!int);
	fxPush(the, cast(xsSlot) this_);
	fxPush(the, cast(xsSlot) function_);
	fxCall(the);
	foreach (param; params) fxPush(the, cast(xsSlot) param);
	fxRunCount(the, params.length.to!int);
	return fxPop(the);
}

///
/// Params:
/// the=A machine
/// this_=A reference to the instance that will have the constructor
/// constructor=A reference to the constructor to call
/// params=The parameter slots to pass to the constructor
xsSlot xsNew(scope xsMachine* the, const xsSlot this_, const xsSlot constructor, const xsSlot[] params ...) {
  assert(params.length >= 0);
	xsOverflow(the, -XS_FRAME_COUNT - params.length.to!int);
	fxPush(the, cast(xsSlot) this_);
  fxPush(the, cast(xsSlot) constructor);
	fxNew(the);
  foreach (param; params) fxPush(the, cast(xsSlot) param);
	fxRunCount(the, params.length.to!int);
	return fxPop(the);
}

// TODO: xsTest
// #define xsTest(_SLOT) \
// 	(xsOverflow(-1), \
// 	fxPush(_SLOT), \
// 	fxRunTest(the))

// Globals

///
inout(xsSlot) xsGlobal(scope inout xsMachine* the) {
  return the.stackTop[-1];
}

// Host Constructors, Functions and Objects

/// Creates a host constructor, and returns a reference to the new host constructor.
///
/// Params:
/// the=A machine
/// callback=The callback to execute
/// length=The number of parameters expected by the callback
/// prototype=A reference to the prototype of the instance to create
/// Returns: A reference to the new host constructor.
xsSlot xsNewHostConstructor(scope xsMachine* the, xsCallback callback, int length, const xsSlot prototype) {
	xsOverflow(the, -1);
	fxPush(the, cast(xsSlot) prototype);
	fxNewHostConstructor(the, callback, length, xsNoID);
	return fxPop(the);
}

/// Creates a named host constructor, and returns a reference to the new host constructor.
///
/// Params:
/// the=A machine
/// callback=The callback to execute
/// length=The number of parameters expected by the callback
/// prototype=A reference to the prototype of the instance to create
/// name=
/// Returns: A reference to the new host constructor.
xsSlot xsNewHostConstructorObject(scope xsMachine* the, xsCallback callback, int length, const xsSlot prototype, xsIndex name) {
	xsOverflow(the, -1);
	fxPush(the, cast(xsSlot) prototype);
	fxNewHostConstructor(the, callback, length, name);
	return fxPop(the);
}

/// Creates a host function, and returns a reference to the new host function.
///
/// A <i>host function</i> is a special kind of function, one whose implementation is in C rather than ECMAScript.
/// For a script, a host function is just like a function; however, when a script invokes a host function, a C callback is executed.
///
/// Params:
/// the=A machine
/// callback=The callback to execute
/// length=The number of parameters expected by the callback
/// Returns: A reference to the new host function.
///
/// See_Also:
/// $(UL
///   $(LI <a href="../../JSObject.makeFunction.html">`JSObject.makeFunction`</a>)
///   $(LI `isCallableAsHostZone`)
/// )
xsSlot xsNewHostFunction(scope xsMachine* the, xsCallback callback, int length) {
	fxNewHostFunction(the, callback, length, xsNoID);
	return fxPop(the);
}

// TODO: xsNewHostFunctionObject
// #define xsNewHostFunctionObject(xsCallback _CALLBACK,_LENGTH, _NAME) \
// 	(fxNewHostFunction(the, _CALLBACK, _LENGTH, _NAME), \
// 	fxPop())

// TODO: xsNewHostInstance
// #define xsNewHostInstance(_PROTOTYPE) \
// 	(xsOverflow(-1), \
// 	fxPush(_PROTOTYPE), \
// 	fxNewHostInstance(the), \
// 	fxPop())

/// Creates a host object, and returns a reference to the new host object.
///
/// A <i>host object</i> is a special kind of object with data that can be directly accessed only in C.
/// The data in a host object is invisible to scripts.
///
/// When the garbage collector is about to get rid of a host object, it executes the host object's destructor, if any.
/// No reference to the host object is passed to the destructor: a destructor can only destroy data.
///
/// Params:
/// the=A machine
/// destructor=The destructor to be executed by the garbage collector. Pass the host object's destructor, or `null` if it does not need a destructor.
/// Returns: A reference to the new host object.
xsSlot xsNewHostObject(scope xsMachine* the, xsDestructor destructor = null) {
	fxNewHostObject(the, destructor);
	return fxPop(the);
}

// TODO: xsGetHostChunk
// #define xsGetHostChunk(_SLOT) \
// 	(the.scratch = (_SLOT), \
// 	fxGetHostChunk(the, &(the.scratch)))
// TODO: xsSetHostChunk
// #define xsSetHostChunk(_SLOT,_DATA,_SIZE) \
// 	(the.scratch = (_SLOT), \
// 	fxSetHostChunk(the, &(the.scratch), _DATA, _SIZE))

///
void* xsGetHostData(scope xsMachine* the, const xsSlot slot) {
	the.scratch = cast(xsSlot) slot;
	return fxGetHostData(the, &the.scratch);
}
///
void xsSetHostData(scope xsMachine* the, const xsSlot slot, void* data) {
	the.scratch = cast(xsSlot) slot;
	fxSetHostData(the, &the.scratch, data);
}

///
xsDestructor xsGetHostDestructor(scope xsMachine* the, const xsSlot slot) {
	the.scratch = cast(xsSlot) slot;
	return fxGetHostDestructor(the, &the.scratch);
}
///
void xsSetHostDestructor(scope xsMachine* the, const xsSlot slot, xsDestructor destructor) {
	the.scratch = cast(xsSlot) slot;
	fxSetHostDestructor(the, &the.scratch, destructor);
}

// TODO: xsGetHostHandle
// #define xsGetHostHandle(_SLOT) \
// 	(the.scratch = (_SLOT), \
// 	fxGetHostHandle(the, &(the.scratch)))

// TODO: xsGetHostHooks
// #define xsGetHostHooks(_SLOT) \
// 	(the->scratch = (_SLOT), \
// 	fxGetHostHooks(the, &(the->scratch)))
// TODO: xsSetHostHooks
// #define xsSetHostHooks(_SLOT,_HOOKS) \
// 	(the->scratch = (_SLOT), \
// 	fxSetHostHooks(the, &(the->scratch), _HOOKS))

// TODO: xsBuildHosts
// #define xsBuildHosts(_COUNT, _BUILDERS) \
// 	(fxBuildHosts(the, _COUNT, _BUILDERS), \
// 	fxPop())

// Arguments and Variables

///
alias xsVars = fxVars;

///
xsSlot xsThis(xsMachine* the) { return the.frame[4]; }
///
xsSlot xsThis(xsMachine* the, const xsSlot value) { return the.frame[4] = cast(xsSlot) value; }
///
xsSlot xsFunction(xsMachine* the) { return the.frame[3]; }
///
xsSlot xsTarget(xsMachine* the) { return the.frame[2]; }
///
xsSlot xsResult(xsMachine* the) { return the.frame[1]; }
///
xsSlot xsArgc(xsMachine* the) { return the.frame[-1]; }
///
xsSlot xsArg(xsMachine* the, int index) { return (the.frame[-2 - fxCheckArg(the, index)]); }
///
xsSlot xsVarc(xsMachine* the) { return the.scope_[0]; }
///
xsSlot xsVar(xsMachine* the, int index) { return (the.scope_[-1 - fxCheckVar(the, index)]); }

// Garbage Collector

///
void xsCollectGarbage(scope xsMachine* the) {
	fxCollectGarbage(the);
}
///
void xsEnableGarbageCollection(scope xsMachine* the, bool enableIt) {
	fxEnableGarbageCollection(the, enableIt);
}
///
void xsRemember(scope xsMachine* the, const xsSlot slot) {
	fxRemember(the, cast(xsSlot*) &slot);
}
///
void xsForget(scope xsMachine* the, const xsSlot slot) {
	fxForget(the, cast(xsSlot*) &slot);
}
///
void xsAccess(scope xsMachine* the, const xsSlot slot) {
	fxAccess(the, cast(xsSlot*) &slot);
}

// Exceptions

debug {
  ///
  void xsThrow(scope xsMachine* the, const xsSlot slot, string file = __FILE__, int line = __LINE__) {
    the.stackTop[-2] = cast(xsSlot) slot;
    fxThrow(the, cast(char*) file.toStringz, line);
  }
} else {
  ///
  void xsThrow(scope xsMachine* the, const xsSlot slot) {
    the.stackTop[-2] = cast(xsSlot) slot;
    fxThrow(the, null, 0);
  }
}

// TODO: xsTry
// #define xsTry \
// 	xsJump __JUMP__; \
// 	__JUMP__.nextJump = the->firstJump; \
// 	__JUMP__.stack = the->stack; \
// 	__JUMP__.scope = the->scope; \
// 	__JUMP__.frame = the->frame; \
// 	__JUMP__.environment = NULL; \
// 	__JUMP__.code = the->code; \
// 	__JUMP__.flag = 0; \
// 	the->firstJump = &__JUMP__; \
// 	if (setjmp(__JUMP__.buffer) == 0) {

// TODO: xsCatch
// #define xsCatch \
// 		the->firstJump = __JUMP__.nextJump; \
// 	} \
// 	else for ( \
// 		the->stack = __JUMP__.stack, \
// 		the->scope = __JUMP__.scope, \
// 		the->frame = __JUMP__.frame, \
// 		the->code = __JUMP__.code, \
// 		the->firstJump = __JUMP__.nextJump; \
// 		(__JUMP__.stack); \
// 		__JUMP__.stack = NULL)

// Errors

debug {
	///
  void xsUnknownError(scope xsMachine* the, string message, string file = __FILE__, int line = __LINE__) {
    fxThrowMessage(the, cast(char*) file.toStringz, line, JSError.unknownError, cast(char*) message.toStringz);
  }
	///
  void xsEvalError(scope xsMachine* the, string message, string file = __FILE__, int line = __LINE__) {
    fxThrowMessage(the, cast(char*) file.toStringz, line, JSError.evalError, cast(char*) message.toStringz);
  }
	///
  void xsRangeError(scope xsMachine* the, string message, string file = __FILE__, int line = __LINE__) {
    fxThrowMessage(the, cast(char*) file.toStringz, line, JSError.rangeError, cast(char*) message.toStringz);
  }
	///
  void xsReferenceError(scope xsMachine* the, string message, string file = __FILE__, int line = __LINE__) {
    fxThrowMessage(the, cast(char*) file.toStringz, line, JSError.referenceError, cast(char*) message.toStringz);
  }
	///
  void xsSyntaxError(scope xsMachine* the, string message, string file = __FILE__, int line = __LINE__) {
    fxThrowMessage(the, cast(char*) file.toStringz, line, JSError.syntaxError, cast(char*) message.toStringz);
  }
	///
  void xsTypeError(scope xsMachine* the, string message, string file = __FILE__, int line = __LINE__) {
    fxThrowMessage(the, cast(char*) file.toStringz, line, JSError.typeError, cast(char*) message.toStringz);
  }
	///
  void xsURIError(scope xsMachine* the, string message, string file = __FILE__, int line = __LINE__) {
    fxThrowMessage(the, cast(char*) file.toStringz, line, JSError.uriError, cast(char*) message.toStringz);
  }
} else {
	///
  void xsUnknownError(scope xsMachine* the, string message) {
    fxThrowMessage(the, null, 0, JSError.unknownError, cast(char*) message.toStringz);
  }
	///
  void xsEvalError(scope xsMachine* the, string message) {
    fxThrowMessage(the, null, 0, JSError.evalError, cast(char*) message.toStringz);
  }
	///
  void xsRangeError(scope xsMachine* the, string message) {
    fxThrowMessage(the, null, 0, JSError.rangeError, cast(char*) message.toStringz);
  }
	///
  void xsReferenceError(scope xsMachine* the, string message) {
    fxThrowMessage(the, null, 0, JSError.referenceError, cast(char*) message.toStringz);
  }
	///
  void xsSyntaxError(scope xsMachine* the, string message) {
    fxThrowMessage(the, null, 0, JSError.syntaxError, cast(char*) message.toStringz);
  }
	///
  void xsTypeError(scope xsMachine* the, string message) {
    fxThrowMessage(the, null, 0, JSError.typeError, cast(char*) message.toStringz);
  }
	///
  void xsURIError(scope xsMachine* the, string message) {
    fxThrowMessage(the, null, 0, JSError.uriError, cast(char*) message.toStringz);
  }
}

// Platform

debug {
	void xsAssert(scope xsMachine* the, bool it, string file = __FILE__, int line = __LINE__) {
		if (!(it)) fxThrowMessage(the, cast(char*) file.toStringz, line, XS_UNKNOWN_ERROR, cast(char*) format!"%s"(it).toStringz);
  }
	void xsErrorPrintf(scope xsMachine* the, string message, string file = __FILE__, int line = __LINE__) {
		fxThrowMessage(the, cast(char*) file.toStringz, line, XS_UNKNOWN_ERROR, cast(char*) format!"%s"(message).toStringz);
  }
} else {
	void xsAssert(scope xsMachine* the, bool it) {
		if (!(it)) fxThrowMessage(the, null, 0, XS_UNKNOWN_ERROR, cast(char*) format!"%s"(it).toStringz);
  }
	void xsErrorPrintf(scope xsMachine* the, string message) {
		fxThrowMessage(the, null, 0, XS_UNKNOWN_ERROR, cast(char*) format!"%s"(message).toStringz);
  }
}

// Debugger

debug {
  ///
	void xsDebugger(scope xsMachine* the, string file = __FILE__, int line = __LINE__) {
		fxDebugger(the, cast(char*) file.toStringz, line);
  }
} else {
  ///
	void xsDebugger(scope xsMachine* the) {
		fxDebugger(the, null, 0);
  }
}

///
void xsTrace(scope xsMachine* the, string string_) {
	xsTrace(the, string_.toStringz);
}
/// ditto
void xsTrace(scope xsMachine* the, const char* string_) {
	fxReport(the, cast(char*) "%s"c.ptr, cast(char*) string_);
}
// TODO: xsTraceCenter
// void xsTraceCenter(scope xsMachine* the, const char* string_, _ID) {
// 	fxBubble(the, 0, string_, 0, _ID);
// }
// TODO: xsTraceLeft
// void xsTraceLeft(scope xsMachine* the, const char* string_, _ID) {
// 	fxBubble(the, 1, string_, 0, _ID);
// }
// TODO: xsTraceRight
// void xsTraceRight(scope xsMachine* the, const char* string_, _ID) {
// 	fxBubble(the, 2, string_, 0, _ID);
// }
// TODO: xsTraceCenterBytes
// void xsTraceCenterBytes(_BUFFER,_LENGTH,_ID) {
// 	fxBubble(the, 4, _BUFFER, _LENGTH, _ID);
// }
// TODO: xsTraceLeftBytes
// void xsTraceLeftBytes(_BUFFER,_LENGTH,_ID) {
// 	fxBubble(the, 5, _BUFFER, _LENGTH, _ID);
// }
// TODO: xsTraceRightBytes
// void xsTraceRightBytes(_BUFFER,_LENGTH,_ID) {
// 	fxBubble(the, 6, _BUFFER, _LENGTH, _ID);
// }

// TODO: xsLog
// void xsLog(scope xsMachine* the, string format, ...) {
// 	fxReport(the, cast(char*) format.toStringz, args);
// }

// TODO: xsLogDebug
// #if defined(mxDebug) || 1
// 	#define xsLogDebug(...) \
// 		fxReport(__VA_ARGS__)
// #else
// 	#define xsLogDebug(...)
// #endif

// Machine

/// Returns a machine if successful, otherwise `null`.
///
/// Regarding the parameters of the machine that are specified in the `xsCreation` structure:
/// $(UL
///   $(LI A machine manages strings and bytecodes in chunks. The initial chunk size is the initial size of the memory allocated to chunks. The incremental chunk size tells the runtime how to expand the memory allocated to chunks.)
///   $(LI A machine uses a heap and a stack of slots. The initial heap count is the initial number of slots allocated to the heap. The incremental heap count tells the runtime how to increase the number of slots allocated to the heap. The stack count is the number of slots allocated to the stack.)
///   $(LI The symbol count is the number of symbols the machine will use. The symbol modulo is the size of the hash table the machine will use for symbols. A symbol binds a string value and an identifier; see `xsID`.)
/// )
///
/// Params:
/// creation=The parameters of the machine
/// name=The name of the machine as a string
/// context=The initial context of the machine, or `null`
///
/// Examples:
/// The following example illustrates the use of `xsCreateMachine` and `xsDeleteMachine`.
/// ---
/// int main(int argc, char* argv[]) {
///   typedef struct {
///   	int argc;
///   	char** argv;
///   } xsContext;
///
///   void xsMainContext(xsMachine* theMachine, int argc, char* argv[])
///   {
///   	xsContext* aContext;
///
///   	aContext = malloc(sizeof(xsContext));
///   	if (aContext) {
///   		aContext->argc = argc;
///   		aContext->argv = argv;
///   		xsSetContext(theMachine, aContext);
///   		xsSetContext(theMachine, NULL);
///   		free(aContext);
///   	}
///   	else
///   		fprintf(stderr, "### Cannot allocate context\n");
///   }
///
/// 	xsCreation aCreation = {
/// 		128 * 1024 * 1024,	/* initialChunkSize */
/// 		16 * 1024 * 1024, 	/* incrementalChunkSize */
/// 		4 * 1024 * 1024, 	/* initialHeapCount */
/// 		1 * 1024 * 1024,	/* incrementalHeapCount */
/// 		1024,			/* stack count */
/// 		2048+1024,		/* key count */
/// 		1993,			/* name modulo */
/// 		127			/* symbol modulo */
/// 	};
/// 	xsMachine* aMachine;
///
/// 	aMachine = xsCreateMachine(&aCreation, "machine", NULL);
/// 	if (aMachine) {
/// 		xsMainContext(aMachine, argc, argv);
/// 		xsDeleteMachine(aMachine);
/// 	}
/// 	else
/// 		fprintf(stderr, "### Cannot allocate machine\n");
/// 	return 0;
/// }
/// ---
xsMachine* xsCreateMachine(const xsCreation* creation, string name, void* context = null) {
  return xsCreateMachine(cast(xsCreation*) creation, name.toStringz, context);
}
/// ditto
xsMachine* xsCreateMachine(const xsCreation* creation, const char* name, void* context = null) {
	return fxCreateMachine(cast(xsCreation*) creation, cast(char*) name, context);
}

/// Free a `xsMachine`.
///
/// The destructors of all the host objects are executed, and all the memory allocated by the machine is freed.
///
/// Params:
/// the=A machine
///
/// Examples:
/// The following example illustrates the use of `xsCreateMachine` and `xsDeleteMachine`.
/// ---
/// int main(int argc, char* argv[]) {
///   typedef struct {
///   	int argc;
///   	char** argv;
///   } xsContext;
///
///   void xsMainContext(xsMachine* theMachine, int argc, char* argv[])
///   {
///   	xsContext* aContext;
///
///   	aContext = malloc(sizeof(xsContext));
///   	if (aContext) {
///   		aContext->argc = argc;
///   		aContext->argv = argv;
///   		xsSetContext(theMachine, aContext);
///   		xsSetContext(theMachine, NULL);
///   		free(aContext);
///   	}
///   	else
///   		fprintf(stderr, "### Cannot allocate context\n");
///   }
///
/// 	xsCreation aCreation = {
/// 		128 * 1024 * 1024,	/* initialChunkSize */
/// 		16 * 1024 * 1024, 	/* incrementalChunkSize */
/// 		4 * 1024 * 1024, 	/* initialHeapCount */
/// 		1 * 1024 * 1024,	/* incrementalHeapCount */
/// 		1024,			/* stack count */
/// 		2048+1024,		/* key count */
/// 		1993,			/* name modulo */
/// 		127			/* symbol modulo */
/// 	};
/// 	xsMachine* aMachine;
///
/// 	aMachine = xsCreateMachine(&aCreation, "machine", NULL);
/// 	if (aMachine) {
/// 		xsMainContext(aMachine, argc, argv);
/// 		xsDeleteMachine(aMachine);
/// 	}
/// 	else
/// 		fprintf(stderr, "### Cannot allocate machine\n");
/// 	return 0;
/// }
/// ---
void xsDeleteMachine(scope xsMachine* the) {
	fxDeleteMachine(the);
}

/// Clone a `xsMachine`.
/// Params:
/// creation=The parameters of the cloned machine
/// machine=The machine to clone
/// name=The name of the machine as a string
/// context=The initial context of the machine, or `null`
///
/// See_Also: `xsCreateMachine`
xsMachine* xsCloneMachine(xsCreation* creation, xsMachine* machine, string name, void* context = null) {
  return xsCloneMachine(creation, machine, name.toStringz, context);
}
/// ditto
xsMachine* xsCloneMachine(xsCreation* creation, xsMachine* machine, const char* name, void* context = null) {
	return fxCloneMachine(creation, machine, cast(char*) name, context);
}

// TODO: xsPrepareMachine
// xsMachine* xsPrepareMachine(xsCreation* creation, _PREPARATION, string name, void* context = null, _ARCHIVE) {
// 	xsPrepareMachine(creation, _PREPARATION, name.toStringz, context, _ARCHIVE);
// }
// xsMachine* xsPrepareMachine(xsCreation* creation, _PREPARATION, const char* name, void* context = null, _ARCHIVE) {
// 	fxPrepareMachine(creation, _PREPARATION, cast(char*) name, context, _ARCHIVE);
// }

///
/// Params:
/// the=A machine
void xsShareMachine(scope xsMachine* the) {
	fxShareMachine(the);
}

// Context

/// Returns a context.
///
/// The machine will call your C code primarily through callbacks. In your callbacks, you can set and get a _context_: a pointer to an area where you can store and retrieve information for the machine.
///
/// Params:
/// the=A machine
void* xsGetContext(scope xsMachine* the) {
	return the.context;
}

/// Sets a context.
///
/// The machine will call your C code primarily through callbacks. In your callbacks, you can set and get a _context_: a pointer to an area where you can store and retrieve information for the machine.
///
/// Params:
/// the=A machine
/// context=A context
void xsSetContext(scope xsMachine* the, void* context) {
	the.context = (context);
}

// Host

/// Detect whether `T` is the `xsMachine` struct.
enum bool isXsMachine(T) = __traits(isSame, T, xsMachine);

/// Detect whether `T` is a pointer to the `xsMachine` struct.
enum bool isXsMachinePtr(T) = __traits(isSame, T, xsMachine*);

import std.meta : staticIndexOf, templateAnd, templateNot, templateOr;
import std.traits : isCallable, Parameters, ParameterIdentifierTuple, ParameterStorageClass,
  ParameterStorageClassTuple, QualifierOf, ReturnType;

/// `isCallableAsHostZone` parameter requirements helper templates
private enum bool hasScopeStorage(alias T) = (T & ParameterStorageClass.scope_) == ParameterStorageClass.scope_;
private template illegallyEscapesScope(Param, alias ParamStorage) {
  alias notHasScopeStorage = templateNot!(hasScopeStorage!ParamStorage);
  enum bool illegallyEscapesScope = notHasScopeStorage!ParamStorage && isXsMachinePtr!Param;
}

/// Detect whether `T` is callable as a Host zone, in lieu of <a href="https://github.com/Moddable-OpenSource/moddable/blob/OS201116/documentation/xs/XS%20in%20C.md#xsbeginhost-and-xsendhost">`xsBeginHost` and `xsEndHost`</a>.
/// See_Also:
/// $(UL
///   $(LI `xsHostZone`)
///   $(LI <a href="../../JSObject.makeFunction.html">`JSObject.makeFunction`</a>)
///   $(LI From the <a href="https://github.com/Moddable-OpenSource/moddable/blob/OS201116/documentation/xs/XS%20in%20C.md#xs-in-c">XS in C</a> Moddable SDK <a href="https://github.com/Moddable-OpenSource/moddable/tree/OS201116/documentation#readme">Documentation</a>:)
///   $(UL
///     $(LI <a href="https://github.com/Moddable-OpenSource/moddable/blob/OS201116/documentation/xs/XS%20in%20C.md#host">Host</a>)
///     $(LI <a href="https://github.com/Moddable-OpenSource/moddable/blob/OS201116/documentation/xs/XS%20in%20C.md#xsbeginhost-and-xsendhost">`beginHost` and `endHost`</a>)
///   )
/// )
template isCallableAsHostZone(T...) if (T.length == 1 && isCallable!T) {
  import std.meta : allSatisfy;
  import std.traits : Parameters;

  alias TParams = Parameters!T;
  static assert(TParams.length == 1, "A Host zone entry point must have a single parameter of type `scope xsMachine*`");
  static if(illegallyEscapesScope!(TParams[0], ParameterStorageClassTuple!T[0])) {
    static assert(0, "The VM parameter of a Host zone entry point must use the scope storage class. " ~
      "\n\ti.e. Add the `scope` storage class to the `xsMachine*` parameter of the function or delegate" ~
      "\n\tSee https://dlang.org/spec/function.html#parameters");
  }
  enum bool isCallableAsHostZone = allSatisfy!(isXsMachinePtr, TParams);
}

/// Used to set up and clean up a stack frame, so that you can use all the macros of XS in C in between, provided in lieu of `xsBeginHost` and `xsEndHost`.
///
/// Uncaught exceptions that occur within `Func` do not propagate beyond the execution of `xsHostZone`.
///
/// Returns: The result of `Func`, or `void` if `Func` has no return type.
/// Throws: <a href="../../JSException.html">`JSException`</a> when the JS VM is aborted with the `xsUnhandledExceptionExit` status while executing `Func`.
/// See_Also:
/// From the <a href="https://github.com/Moddable-OpenSource/moddable/blob/OS201116/documentation/xs/XS%20in%20C.md#xs-in-c">XS in C</a> Moddable SDK <a href="https://github.com/Moddable-OpenSource/moddable/tree/OS201116/documentation#readme">Documentation</a>:
/// $(UL
///   $(LI <a href="https://github.com/Moddable-OpenSource/moddable/blob/OS201116/documentation/xs/XS%20in%20C.md#host">Host</a>)
///   $(LI <a href="https://github.com/Moddable-OpenSource/moddable/blob/OS201116/documentation/xs/XS%20in%20C.md#xsbeginhost-and-xsendhost">`beginHost` and `endHost`</a>)
/// )
///
/// Examples:
/// ---
/// long xsWndProc(HWND hwnd, uint m, uint w, long l)
/// {
/// 	long result = 0;
/// 	xsMachine* aMachine = GetWindowLongPtr(hwnd, GWL_USERDATA);
///   auto zone = (xsMachine* the) => {
/// 		result = the.xsToInteger(the.xsCall(
///       the.xsGlobal, xsID_dispatch,
/// 			the.xsInteger(m), the.xsInteger(w), the.xsInteger(l)
///     ));
/// 	}();
/// 	aMachine.xsHostZone!zone;
/// 	return result;
/// }
/// ---
ReturnType!Func xsHostZone(alias Func)(scope xsMachine* the) if (isCallableAsHostZone!Func) {
  enum bool voidReturnType = is(ReturnType!Func == void);
  static if (!voidReturnType) ReturnType!Func result;
  while(true) {
    auto hostThe = the;
    xsJump hostJump = {
      nextJump: hostThe.firstJump,
      stack: hostThe.stack,
      scope_: hostThe.scope_,
      frame: hostThe.frame,
      environment: null,
      code: hostThe.code,
      flag: 0,
    };
    void resetState() {
      hostThe.stack = hostJump.stack;
      hostThe.scope_ = hostJump.scope_;
      hostThe.frame = hostJump.frame;
      hostThe.code = hostJump.code;
      hostThe.firstJump = hostJump.nextJump;
    }
    hostThe.firstJump = &hostJump;
    if (setjmp(hostJump.buffer.ptr) == 0) {
      xsMachine* zonedThe = fxBeginHost(the);

      /// Call user-land host code
      static if (voidReturnType)
        Func(zonedThe);
      else static if (!voidReturnType)
        result = Func(zonedThe);
      else static assert(0, "Unreachable by design; " ~ __traits(identifier, T) ~ " has unsupported return type");

      fxEndHost(zonedThe);
      zonedThe = null;
    } else {
      try {
        fxAbort(hostThe, xsUnhandledExceptionExit);
      } catch (Exception ex) {
        resetState();
        throw ex;
      }
    }
    resetState();
    break;
  }
  static if (!voidReturnType) return result;
}

// TODO: xsArrayCacheBegin
// #define xsArrayCacheBegin(_ARRAY) \
// 	(fxPush(_ARRAY), \
// 	fxArrayCacheBegin(the, the.stack), \
// 	the.stack++)
// TODO: xsArrayCacheEnd
// #define xsArrayCacheEnd(_ARRAY) \
// 	(fxPush(_ARRAY), \
// 	fxArrayCacheEnd(the, the.stack), \
// 	the.stack++)
// TODO: xsArrayCacheItem
// #define xsArrayCacheItem(_ARRAY,_ITEM) \
// 	(fxPush(_ARRAY), \
// 	fxPush(_ITEM), \
// 	fxArrayCacheItem(the, the.stack + 1, the.stack), \
// 	the.stack += 2)

// TODO: xsDemarshall
// #define xsDemarshall(_DATA) \
// 	(fxDemarshall(the, (_DATA), 0), \
// 	fxPop())
// TODO: xsDemarshallAlien
// #define xsDemarshallAlien(_DATA) \
// 	(fxDemarshall(the, (_DATA), 1), \
// 	fxPop())
// TODO: xsMarshall
// #define xsMarshall(_SLOT) \
// 	(xsOverflow(-1), \
// 	fxPush(_SLOT), \
// 	fxMarshall(the, 0))
// TODO: xsMarshallAlien
// #define xsMarshallAlien(_SLOT) \
// 	(xsOverflow(-1), \
// 	fxPush(_SLOT), \
// 	fxMarshall(the, 1))

// TODO: xsIsProfiling
// #define xsIsProfiling() \
// 	fxIsProfiling(the)
// TODO: xsStartProfiling
// #define xsStartProfiling() \
// 	fxStartProfiling(the)
// TODO: xsStopProfiling
// #define xsStopProfiling() \
// 	fxStopProfiling(the)

// TODO: xsAwaitImport
// #define xsAwaitImport(_NAME,_FLAG) \
// 	(xsOverflow(-1), \
// 	fxStringX(the, --the.stack, (xsStringValue)_NAME), \
// 	fxAwaitImport(the, _FLAG), \
// 	fxPop())
