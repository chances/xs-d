/// XS JavaScript Engine API
///
/// Authors: Chance Snow
/// Copyright: Copyright © 2020 Chance Snow. All rights reserved.
/// License: MIT License
module xs;

import std.conv : to;
import std.string : toStringz;

public import xs.bindings;

/// The type of a slot.
/// See_Also: <a href="https://github.com/Moddable-OpenSource/moddable/blob/OS201116/documentation/xs/XS%20in%20C.md#slot-types">Slot Types</a>
enum Type : _Anonymous_0 {
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
  /// JS `Symbol`
  symbol = xsSymbolType,
  /// JS `BigInt`
  bigInt = xsBigIntType,
  /// JS `BigInt` in ROM
  bigIntX = xsBigIntXType,
  /// JS reference type
  reference = xsReferenceType,
}

pragma(inline, true):

/// Returns the `Type` of a slot.
/// Params:
/// the=A reference to the target virtual machine
/// theSlot=The slot to test
/// Returns: The `Type` of a `theSlot`.
///
/// > **Note**: The macros in the XS in C API require a reference to the target virtual machine in a variable in the
/// > current scope with the name `the` of type `xsMachine*`.
///
/// See_Also: <a href="https://github.com/Moddable-OpenSource/moddable/blob/OS201116/documentation/xs/XS%20in%20C.md#slot-types">Slot Types</a>
Type xsTypeOf(xsMachine* the, xsSlot theSlot) {
  the.scratch = theSlot;
  return fxTypeOf(the, &the.scratch).to!uint.to!Type;
}

// Primitives

/// Returns an `undefined` slot
xsSlot xsUndefined(xsMachine* the) {
  fxUndefined(the, &the.scratch);
  return the.scratch;
}
/// Returns a `null` slot
xsSlot xsNull(xsMachine* the) {
  fxNull(the, &the.scratch);
  return the.scratch;
}
/// Returns a `false` slot
xsSlot xsFalse(xsMachine* the) {
  fxBoolean(the, &the.scratch, 0);
  return the.scratch;
}
/// Returns a `true` slot
xsSlot xsTrue(xsMachine* the) {
  fxBoolean(the, &the.scratch, 1);
  return the.scratch;
}

/// Returns a Boolean slot
xsSlot xsBoolean(xsMachine* the, bool value) {
  fxBoolean(the, &the.scratch, value);
  return the.scratch;
}
/// Convert a slot to a Boolean value
void xsToBoolean(xsMachine* the, xsSlot theSlot) {
  the.scratch = theSlot;
  fxToBoolean(the, &the.scratch);
}

/// Returns a Number slot given an `int`.
xsSlot xsInteger(xsMachine* the, int value) {
  fxInteger(the, &the.scratch, value);
  return the.scratch;
}
/// Convert a slot to a Number value represented as an `int`.
void xsToInteger(xsMachine* the, xsSlot theSlot) {
  the.scratch = theSlot;
  fxToInteger(the, &the.scratch);
}

/// Returns a Number slot given a `float`.
xsSlot xsNumber(xsMachine* the, float value) {
  fxNumber(the, &the.scratch, value);
  return the.scratch;
}
/// Convert a slot to a Number value.
void xsToNumber(xsMachine* the, xsSlot theSlot) {
  the.scratch = theSlot;
  fxToNumber(the, &the.scratch);
}

/// Returns a String slot given a `string`.
xsSlot xsString(xsMachine* the, string value) {
  fxString(the, &the.scratch, cast(char*) value.toStringz);
  return the.scratch;
}
/// Returns a StringBuffer slot given a `string`.
xsSlot xsStringBuffer(xsMachine* the, string buffer) {
  return xsStringBuffer(the, buffer.toStringz, buffer.length.to!int);
}
/// Returns a StringBuffer slot given a `char*`.
xsSlot xsStringBuffer(xsMachine* the, const char* buffer, int size) {
  fxStringBuffer(the, &the.scratch, cast(char*) buffer, size);
  return the.scratch;
}
/// Convert a slot to a String value.
void xsToString(xsMachine* the, xsSlot theSlot) {
  the.scratch = theSlot;
  fxToString(the, &the.scratch);
}
/// Convert a slot to a StringBuffer value given a `string`.
void xsToStringBuffer(xsMachine* the, xsSlot theSlot, string buffer) {
  xsToStringBuffer(the, theSlot, buffer.toStringz, buffer.length.to!int);
}
/// Convert a slot to a StringBuffer value given a `char*`.
void xsToStringBuffer(xsMachine* the, xsSlot theSlot, const char* buffer, int size) {
  the.scratch = theSlot;
  fxToStringBuffer(the, &the.scratch, cast(char*) buffer, size);
}

// TODO: xsArrayBuffer
// #define xsArrayBuffer(_BUFFER,_SIZE) \
// 	(fxArrayBuffer(the, &the.scratch, _BUFFER, _SIZE), \
// 	the.scratch)
// TODO: xsGetArrayBufferData
// #define xsGetArrayBufferData(xsSlot theSlot,_OFFSET,_BUFFER,_SIZE) \
// 	(the.scratch = theSlot, \
// 	fxGetArrayBufferData(the, &the.scratch, _OFFSET, _BUFFER, _SIZE))
// TODO: xsGetArrayBufferLength
// #define xsGetArrayBufferLength(xsSlot theSlot) \
// 	(the.scratch = theSlot, \
// 	fxGetArrayBufferLength(the, &the.scratch))
// TODO: xsSetArrayBufferData
// #define xsSetArrayBufferData(xsSlot theSlot,_OFFSET,_BUFFER,_SIZE) \
// 	(the.scratch = theSlot, \
// 	fxSetArrayBufferData(the, &the.scratch, _OFFSET, _BUFFER, _SIZE))
// TODO: xsSetArrayBufferLength
// #define xsSetArrayBufferLength(xsSlot theSlot,_LENGTH) \
// 	(the.scratch = theSlot, \
// 	fxSetArrayBufferLength(the, &the.scratch, _LENGTH))
// TODO: xsToArrayBuffer
// #define xsToArrayBuffer(xsSlot theSlot) \
// 	(the.scratch = theSlot, \
// 	fxToArrayBuffer(the, &the.scratch))

// Closures and References

// TODO: xsClosure
// #define xsClosure(_VALUE) \
// 	(fxClosure(the, &the->scratch, _VALUE), \
// 	the->scratch)
// TODO: xsToClosure
// #define xsToClosure(_SLOT) \
// 	(the->scratch = (_SLOT), \
// 	fxToClosure(the, &(the->scratch)))

// TODO: xsReference
// #define xsReference(_VALUE) \
// 	(fxReference(the, &the->scratch, _VALUE), \
// 	the->scratch)
// TODO: xsToReference
// #define xsToReference(_SLOT) \
// 	(the->scratch = (_SLOT), \
// 	fxToReference(the, &(the->scratch)))

// Instances and Prototypes

/// Index of standard JavaScript prototypes on a `xsMachine`'s stack.
enum int prototypesStackIndex = -75;
/// The <a href="https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Object">Object</a> prototype.
/// See_Also: <a href="https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Object">Object</a> on MDN
enum xsSlot xsObjectPrototype(alias xsMachine* the) = the.stackPrototypes[prototypesStackIndex - 1];
/// The <a href="https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Function">Function</a> prototype.
/// See_Also: <a href="https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Function">Function</a> on MDN
enum xsSlot xsFunctionPrototype(alias xsMachine* the) = the.stackPrototypes[prototypesStackIndex - 2];
/// The <a href="https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Array">Array</a> prototype.
/// See_Also: <a href="https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Array">Array</a> on MDN
enum xsSlot xsArrayPrototype(alias xsMachine* the) = the.stackPrototypes[prototypesStackIndex - 3];
/// The <a href="https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/String">String</a> prototype.
/// See_Also: <a href="https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/String">String</a> on MDN
enum xsSlot xsStringPrototype(alias xsMachine* the) = the.stackPrototypes[prototypesStackIndex - 4];
/// The <a href="https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Boolean">Boolean</a> prototype.
/// See_Also: <a href="https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Boolean">Boolean</a> on MDN
enum xsSlot xsBooleanPrototype(alias xsMachine* the) = the.stackPrototypes[prototypesStackIndex - 5];
/// The <a href="https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Number">Number</a> prototype.
/// See_Also: <a href="https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Number">Number</a> on MDN
enum xsSlot xsNumberPrototype(alias xsMachine* the) = the.stackPrototypes[prototypesStackIndex - 6];
/// The <a href="https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Date">Date</a> prototype.
/// See_Also: <a href="https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Date">Date</a> on MDN
enum xsSlot xsDatePrototype(alias xsMachine* the) = the.stackPrototypes[prototypesStackIndex - 7];
/// The <a href="https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/RegExp">RegExp</a> prototype.
/// See_Also: <a href="https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/RegExp">RegExp</a> on MDN
enum xsSlot xsRegExpPrototype(alias xsMachine* the) = the.stackPrototypes[prototypesStackIndex - 8];
/// The <a href="https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Host">Host</a> prototype.
/// See_Also: <a href="https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Host">Host</a> on MDN
enum xsSlot xsHostPrototype(alias xsMachine* the) = the.stackPrototypes[prototypesStackIndex - 9];
/// The <a href="https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Error">Error</a> prototype.
/// See_Also: <a href="https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Error">Error</a> on MDN
enum xsSlot xsErrorPrototype(alias xsMachine* the) = the.stackPrototypes[prototypesStackIndex - 10];
/// The <a href="https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/EvalError">EvalError</a> prototype.
/// See_Also: <a href="https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/EvalError">EvalError</a> on MDN
enum xsSlot xsEvalErrorPrototype(alias xsMachine* the) = the.stackPrototypes[prototypesStackIndex - 11];
/// The <a href="https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/RangeError">RangeError</a> prototype.
/// See_Also: <a href="https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/RangeError">RangeError</a> on MDN
enum xsSlot xsRangeErrorPrototype(alias xsMachine* the) = the.stackPrototypes[prototypesStackIndex - 12];
/// The <a href="https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/ReferenceError">ReferenceError</a> prototype.
/// See_Also: <a href="https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/ReferenceError">ReferenceError</a> on MDN
enum xsSlot xsReferenceErrorPrototype(alias xsMachine* the) = the.stackPrototypes[prototypesStackIndex - 13];
/// The <a href="https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/SyntaxError">SyntaxError</a> prototype.
/// See_Also: <a href="https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/SyntaxError">SyntaxError</a> on MDN
enum xsSlot xsSyntaxErrorPrototype(alias xsMachine* the) = the.stackPrototypes[prototypesStackIndex - 14];
/// The <a href="https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/TypeError">TypeError</a> prototype.
/// See_Also: <a href="https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/TypeError">TypeError</a> on MDN
enum xsSlot xsTypeErrorPrototype(alias xsMachine* the) = the.stackPrototypes[prototypesStackIndex - 15];
/// The <a href="https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/URIError">URIError</a> prototype.
/// See_Also: <a href="https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/URIError">URIError</a> on MDN
enum xsSlot xsURIErrorPrototype(alias xsMachine* the) = the.stackPrototypes[prototypesStackIndex - 16];
/// The <a href="https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/AggregateError">AggregateError</a> prototype.
/// See_Also: <a href="https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/AggregateError">AggregateError</a> on MDN
enum xsSlot xsAggregateErrorPrototype(alias xsMachine* the) = the.stackPrototypes[prototypesStackIndex - 17];
/// The <a href="https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Symbol">Symbol</a> prototype.
/// See_Also: <a href="https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Symbol">Symbol</a> on MDN
enum xsSlot xsSymbolPrototype(alias xsMachine* the) = the.stackPrototypes[prototypesStackIndex - 18];
/// The <a href="https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/ArrayBuffer">ArrayBuffer</a> prototype.
/// See_Also: <a href="https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/ArrayBuffer">ArrayBuffer</a> on MDN
enum xsSlot xsArrayBufferPrototype(alias xsMachine* the) = the.stackPrototypes[prototypesStackIndex - 19];
/// The <a href="https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/DataView">DataView</a> prototype.
/// See_Also: <a href="https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/DataView">DataView</a> on MDN
enum xsSlot xsDataViewPrototype(alias xsMachine* the) = the.stackPrototypes[prototypesStackIndex - 20];
/// The <a href="https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/TypedArray">TypedArray</a> prototype.
/// See_Also: <a href="https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/TypedArray">TypedArray</a> on MDN
enum xsSlot xsTypedArrayPrototype(alias xsMachine* the) = the.stackPrototypes[prototypesStackIndex - 21];
/// The <a href="https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Map">Map</a> prototype.
/// See_Also: <a href="https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Map">Map</a> on MDN
enum xsSlot xsMapPrototype(alias xsMachine* the) = the.stackPrototypes[prototypesStackIndex - 22];
/// The <a href="https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Set">Set</a> prototype.
/// See_Also: <a href="https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Set">Set</a> on MDN
enum xsSlot xsSetPrototype(alias xsMachine* the) = the.stackPrototypes[prototypesStackIndex - 23];
/// The <a href="https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/WeakMap">WeakMap</a> prototype.
/// See_Also: <a href="https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/WeakMap">WeakMap</a> on MDN
enum xsSlot xsWeakMapPrototype(alias xsMachine* the) = the.stackPrototypes[prototypesStackIndex - 24];
/// The <a href="https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/WeakSet">WeakSet</a> prototype.
/// See_Also: <a href="https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/WeakSet">WeakSet</a> on MDN
enum xsSlot xsWeakSetPrototype(alias xsMachine* the) = the.stackPrototypes[prototypesStackIndex - 25];
/// The <a href="https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Promise">Promise</a> prototype.
/// See_Also: <a href="https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Promise">Promise</a> on MDN
enum xsSlot xsPromisePrototype(alias xsMachine* the) = the.stackPrototypes[prototypesStackIndex - 26];
/// The <a href="https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Proxy">Proxy</a> prototype.
/// See_Also: <a href="https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Proxy">Proxy</a> on MDN
enum xsSlot xsProxyPrototype(alias xsMachine* the) = the.stackPrototypes[prototypesStackIndex - 27];

// #define xsNewArray(_LENGTH) \
// 	(fxNewArray(the,_LENGTH), \
// 	fxPop())

// #define xsNewObject() \
// 	(fxNewObject(the), \
// 	fxPop())

// #define xsIsInstanceOf(_SLOT,_PROTOTYPE) \
// 	(xsOverflow(-2), \
// 	fxPush(_PROTOTYPE), \
// 	fxPush(_SLOT), \
// 	fxIsInstanceOf(the))

// Identifiers

///
enum XS_NO_ID = -1;

// TODO: xsID
// #define xsID(_NAME) \
// 	fxID(the, _NAME)
// TODO: xsFindID
// #define xsFindID(_NAME) \
// 	fxFindID(the, _NAME)
// TODO: xsIsID
// #define xsIsID(_NAME) \
// 	fxIsID(the, _NAME)
// TODO: xsToID
// #define xsToID(_SLOT) \
// 	(the->scratch = (_SLOT), \
// 	fxToID(the, &(the->scratch)))
// TODO: xsName
// #define xsName(_ID) \
// 	fxName(the, _ID)

// Properties

// TODO: xsEnumerate
// #define xsEnumerate(_THIS) \
// 	(xsOverflow(-1), \
// 	fxPush(_THIS), \
// 	fxEnumerate(the), \
// 	fxPop())

// TODO: xsHas
// #define xsHas(_THIS,_ID) \
// 	(xsOverflow(-1), \
// 	fxPush(_THIS), \
// 	fxHasID(the, _ID))

// TODO: xsHasAt
// #define xsHasAt(_THIS,_AT) \
// 	(xsOverflow(-2), \
// 	fxPush(_THIS), \
// 	fxPush(_AT), \
// 	fxHasAt(the))

// TODO: xsGet
// #define xsGet(_THIS,_ID) \
// 	(xsOverflow(-1), \
// 	fxPush(_THIS), \
// 	fxGetID(the, _ID), \
// 	fxPop())

// TODO: xsGetAt
// #define xsGetAt(_THIS,_AT) \
// 	(xsOverflow(-2), \
// 	fxPush(_THIS), \
// 	fxPush(_AT), \
// 	fxGetAt(the), \
// 	fxPop())

// TODO: xsSet
// #define xsSet(_THIS,_ID,_SLOT) \
// 	(xsOverflow(-2), \
// 	fxPush(_SLOT), \
// 	fxPush(_THIS), \
// 	fxSetID(the, _ID), \
// 	the->stack++)

// TODO: xsSetAt
// #define xsSetAt(_THIS,_AT,_SLOT) \
// 	(xsOverflow(-3), \
// 	fxPush(_SLOT), \
// 	fxPush(_THIS), \
// 	fxPush(_AT), \
// 	fxSetAt(the), \
// 	the->stack++)

// TODO: xsDefine
// #define xsDefine(_THIS,_ID,_SLOT,_ATTRIBUTES) \
// 	(xsOverflow(-2), \
// 	fxPush(_SLOT), \
// 	fxPush(_THIS), \
// 	fxDefineID(the, _ID, _ATTRIBUTES, _ATTRIBUTES | xsDontDelete | xsDontEnum | xsDontSet), \
// 	the->stack++)

// TODO: xsDefineAt
// #define xsDefineAt(_THIS,_AT,_SLOT,_ATTRIBUTES) \
// 	(xsOverflow(-3), \
// 	fxPush(_SLOT), \
// 	fxPush(_THIS), \
// 	fxPush(_AT), \
// 	fxDefineAt(the, _ATTRIBUTES, _ATTRIBUTES | xsDontDelete | xsDontEnum | xsDontSet), \
// 	the->stack++)

// TODO: xsDelete
// #define xsDelete(_THIS,_ID) \
// 	(xsOverflow(-1), \
// 	fxPush(_THIS), \
// 	fxDeleteID(the, _ID), \
// 	the->stack++)

// TODO: xsDeleteAt
// #define xsDeleteAt(_THIS,_AT) \
// 	(xsOverflow(-2), \
// 	fxPush(_THIS), \
// 	fxPush(_AT), \
// 	fxDeleteAt(the), \
// 	the->stack++)

///
enum int XS_FRAME_COUNT = 6;

// TODO: xsCall with D-lang variadic arguments
// #define xsCall0(_THIS,_ID) \
// 	(xsOverflow(-XS_FRAME_COUNT-0), \
// 	fxPush(_THIS), \
// 	fxCallID(the, _ID), \
// 	fxRunCount(the, 0), \
// 	fxPop())

// TODO: xsCall_noResult with D-lang variadic arguments
// #define xsCall0_noResult(_THIS,_ID) \
// 	(xsOverflow(-XS_FRAME_COUNT-0), \
// 	fxPush(_THIS), \
// 	fxCallID(the, _ID), \
// 	fxRunCount(the, 0), \
// 	the->stack++)

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
xsMachine* xsCreateMachine(xsCreation* creation, string name, void* context = null) {
  return xsCreateMachine(creation, name.toStringz, context);
}
/// ditto
xsMachine* xsCreateMachine(xsCreation* creation, const char* name, void* context = null) {
	return fxCreateMachine(creation, cast(char*) name, context);
}

/// Free a `xsMachine`.
///
/// The destructors of all the host objects are executed, and all the memory allocated by the machine is freed.
///
/// Params:
/// the=A machine
void xsDeleteMachine(xsMachine* the) {
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
void xsShareMachine(xsMachine* the) {
	fxShareMachine(the);
}

/* Context */

/// Returns a context.
/// Params:
/// the=A machine
///
/// The machine will call your C code primarily through callbacks. In your callbacks, you can set and get a _context_: a pointer to an area where you can store and retrieve information for the machine.
void* xsGetContext(xsMachine* the) {
	return the.context;
}

/// Sets a context.
/// Params:
/// the=A machine
/// context=A context
///
/// The machine will call your C code primarily through callbacks. In your callbacks, you can set and get a _context_: a pointer to an area where you can store and retrieve information for the machine.
void xsSetContext(xsMachine* the, void* context) {
	the.context = (context);
}
