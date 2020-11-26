/// XS JavaScript Engine API
///
/// See the <a href="https://chances.github.io/xs-d">API Reference</a> and the official <a href="https://github.com/Moddable-OpenSource/moddable/blob/OS201116/documentation/xs/XS%20in%20C.md">XS in C</a> in the Moddable SDK's documentation.
///
/// Authors: Chance Snow
/// Copyright: Copyright © 2020 Chance Snow. All rights reserved.
/// License: MIT License
module xs;

import std.conv : to;
import std.exception : enforce;
import std.string : format, toStringz;

public import xs.bindings;
public import xs.bindings.enums;
public import xs.bindings.macros;
public import xs.bindings.structs;
public import xs.script;

private enum mdn = "https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects";

/// Thrown when a JS VM is aborted with the `xsUnhandledExceptionExit` status.
class JSException : Exception {
  /// The JS script or module file from which the exception was thrown.
  const string scriptFile;
  /// The line of the JS script or module file from which the exception was thrown.
  const ulong scriptLine;
  /// The exception value that was thrown from the VM.
  const JSValue exception;

  private const Script script_ = null;

  /// Constructs a new instace of JSException.
  this(string msg, const JSValue exception = null, string file = __FILE__, ulong line = cast(ulong)__LINE__) {
    super(msg, file, line);

    scriptFile = "NATIVE_CODE";
    scriptLine = 0;
    this.exception = exception;
  }
  /// Constructs a new instace of JSException given the `Script` from which this exception was thrown.
  this(string msg, const Script script, string file = __FILE__, ulong line = cast(ulong)__LINE__) {
    super(msg, file, line);

    this.script_ = script;
    scriptFile = script.path;
    // TODO: Get the thrown line from the VM
    scriptLine = 0;
    this.exception = exception;
  }

  /// The `Script` from which this exception was thrown.
  const(Script) script() @property const {
    return script_;
  }
}

/// A rudimentary Host VM abortion implementation that throws error messages back into the JS VM.
///
/// You <strong>MUST</strong> either mixin the template in your Host application or provide your own implementation.
///
/// Throws: `JSException` when a JS VM is aborted with the `xsUnhandledExceptionExit` status.
///
/// Examples:
/// ---
/// mixin defaultFxAbort;
/// ---
mixin template defaultFxAbort() {
  extern(C) void fxAbort(scope xsMachine* the, int status)
  {
    if (status == xsNotEnoughMemoryExit)
      the.xsUnknownError("not enough memory");
    else if (status == xsStackOverflowExit)
      the.xsUnknownError("stack overflow");
    else if (status == xsDeadStripExit)
      the.xsUnknownError("dead strip");
    else if (status == xsUnhandledExceptionExit) {
      xsTrace(the, "Unhandled JS exception\n");
      // TODO: Get the JS error that was thrown from the VM
      throw new JSException("unhandled exception");
    }
  }
}

version (unittest) {
  // TODO: Unit test default abort function
  mixin defaultFxAbort;
}

private {
  alias constSlot = const(xsSlot);
}

/// A JavaScript virtual machine.
class Machine {
  import std.typecons : Flag;

  private xsMachine* the_;
  package(xs) const xsSlot realm;
  private Script[] scripts_;

  /// Name of this VM.
  const string name;

  /// Default VM creation options.
  static xsCreation defaultCreation = {
    initialChunkSize: 128 * 1024 * 1024,
    incrementalChunkSize: 16 * 1024 * 1024,
    initialHeapCount: 4 * 1024 * 1024,
    incrementalHeapCount: 1 * 1024 * 1024,
    stackCount: 1024,
    keyCount: 2048+1024,
    nameModulo: 1993,
    symbolModulo: 127,
    parserBufferSize: 2 * 1024 * 1024,
    parserTableModulo: 1024,
  };

  import std.typecons : Tuple;

  /// Create and allocate a new JavaScript VM.
  this(
    string name, const xsCreation creationOptions = defaultCreation,
    const Tuple!(txScript*, ScriptKind)[] preloadedScripts = []
  ) {
    import std.algorithm : map;
    import std.array : array;

    the_ = enforce(
      xsCreateMachine(&creationOptions, name, cast(void*) this),
      format!"Could not create JS virtual machine '%s'"(name)
    );
    this.name = name;
    realm = *mxRealm(the_).slot;
    the_.archive = sxPreparation.from(creationOptions, name, "", preloadedScripts.map!(script => script[0]).array);
    foreach (preloadedScript; preloadedScripts) {
      scripts_ ~= new Script(this, preloadedScript[0], preloadedScript[1]);
    }
  }
  private this(xsMachine* the) {
    import std.traits : fullyQualifiedName;

    the_ = the;
    name = fullyQualifiedName!Machine ~ "~anonymous";
    realm = *mxRealm(the_).slot;
  }
  ~this() {
    // Only free managed contexts with contexts
    if (the && the.context) the.xsDeleteMachine();
  }

  /// Create a Machine given a `xsMachine`.
  static Machine from(xsMachine* the) {
    return new Machine(the);
  }

  xsMachine* the() @property const {
    return cast(xsMachine*) the_;
  }

  const(Script[]) scripts() @property const {
    return scripts_;
  }

  JSObject global() @property const {
    return new JSObject(cast(Machine) this, the.xsGlobal);
  }

  /// See_Also: `xs.bindings.macros.xsID`
  xsIndex id(string name) inout {
    return the.xsID(name);
  }

  ///
  xsIndex toId(const xsSlot slot) inout {
    auto the = cast(xsMachine*) the;
    return the.xsToID(slot);
  }

  ///
  string nameOf(xsIndex id) inout {
    import std.string : fromStringz;

    auto the = cast(xsMachine*) the;
    auto namePtr = the.xsName(id);
    return namePtr.fromStringz.to!string;
  }

  /// Returns a `JSValue` given a value slot.
  JSValue value(xsSlot slot) {
    return new JSValue(this, slot);
  }

  /// Returns a Boolean `JSValue` given a `bool` value.
  /// See_Also: `xs.bindings.macros.xsBoolean`
  JSValue boolean(bool value) {
    return this.value(the.xsBoolean(value));
  }

  /// Returns a Number `JSValue` given an `int` value.
  /// See_Also: `xs.bindings.macros.xsInteger`
  JSValue integer(int value) {
    return this.value(the.xsInteger(value));
  }

  /// Returns a Number `JSValue` given an `uint` value.
  /// See_Also: `xs.bindings.macros.xsUnsigned`
  JSValue unsigned(uint value) {
    return this.value(the.xsUnsigned(value));
  }

  /// Returns a Number `JSValue` given a `double` value.
  /// See_Also: `xs.bindings.macros.xsNumber`
  JSValue number(double value) {
    return this.value(the.xsNumber(value));
  }

  /// Returns a String `JSValue` given a `string` value.
  /// See_Also: `xs.bindings.macros.xsString`
  JSValue string_(string value) {
    return this.value(the.xsString(value));
  }

  /// Tests whether an instance has a property corresponding to a particular ECMAScript property name.
  ///
  /// This method is similar to the ECMAScript `in` keyword.
  ///
  /// Params:
  /// this_=A reference to the instance to test
  /// id=The identifier of the property to test
  /// Returns: `true` if the instance has the property, `false` otherwise
  bool has(const xsSlot this_, xsIndex id) {
    return the.xsHas(this_, id);
  }

  /// Get a property or item of an instance.
  ///
  /// Params:
  /// this_=A reference to the instance that has the property or item
  /// id=The identifier of the property or item to get
  /// Returns:
  /// A `JSValue` containing what is contained in the property or item.
  /// `JSValue.type` will equal `JSType.undefined` if the property or item is not defined by the instance or its prototypes.
  /// See_Also: `xs.bindings.macros.xsGet`
  JSValue get(const xsSlot this_, xsIndex id) {
    enforce(the.xsHas(this_, id), format!"property `%s[%s]` does not exist"(nameOf(toId(this_)), nameOf(id)));
    return new JSValue(this, the.xsGet(this_, id));
  }

  /// Set a property or item of an instance.
  ///
  /// Params:
  /// this_=A reference to the instance that will have the property or item
  /// id=The identifier of the property or item to set
  /// value=The value of the property or item to set
  /// See_Also: `xs.bindings.macros.xsSet`
  void set(const xsSlot this_, xsIndex id, const JSValue value) {
    the.xsSet(this_, id, value.slot);
  }

  /// Collect garbage values from this VM.
  void collectGarbage() {
    fxCollectGarbage(the);
  }
}

unittest {
  auto machine = new Machine("test-machine");
  const global = machine.global.slot;
  assert(machine.the.xsToID(global));
  assert(machine.the.xsTypeOf(global) == JSType.reference);
  assert(machine.the.xsHas(global, machine.the.xsID("Number")));

  assert(!machine.the.xsHas(global, machine.id("foo")));
  auto foo = machine.the.xsGet(global, machine.id("foo"));
  assert(machine.the.xsTypeOf(foo) == JSType.undefined);

  machine.the.xsSet(global, machine.id("foo"), machine.the.xsInteger(1));
  assert(machine.the.xsHas(global, machine.id("foo")));
  foo = machine.the.xsGet(global, machine.id("foo"));
  assert(machine.the.xsTypeOf(foo) == JSType.integer);
  assert(machine.the.xsToInteger(foo) == 1);

  machine.the.xsSet(global, machine.id("bar"), machine.the.xsBoolean(true));
  assert(machine.the.xsHas(global, machine.id("bar")));
  auto bar = machine.the.xsGet(global, machine.id("bar"));
  assert(machine.the.xsTypeOf(bar) == JSType.boolean);
  assert(machine.the.xsToBoolean(bar));

  machine.collectGarbage();
  destroy(machine);
}

/// A JavaScript value reference.
class JSValue {
  protected Machine _machine;

  /// ID of this value in it's `Machine`.
  /// See_Also: `Machine.id`, `Machine.toId`
  const xsIndex id;
  /// Machine slot of this value.
  const xsSlot slot;

  /// Construct a reference to a slot value belonging to `machine`.
  this(Machine machine, const xsSlot value) {
    this._machine = machine;
    id = machine.toId(value);
    slot = value;
  }

  Machine machine() @property const {
    return cast(Machine) _machine;
  }

  JSType type() @property inout {
    return (cast(xsMachine*) machine.the).xsTypeOf(slot);
  }

  /// Convert this value to a `bool` value.
  /// See_Also: `xs.bindings.macros.xsToBoolean`
  bool boolean() @property const {
    enforce(type == JSType.boolean || type == JSType.reference, "Value is not a Boolean");
    return machine.the.xsToBoolean(slot);
  }

  /// Convert this value to an `int` value.
  /// See_Also: `xs.bindings.macros.xsToInteger`
  int integer() @property const {
    enforce(type == JSType.integer || type == JSType.reference, "Value is not an integral Number");
    return machine.the.xsToInteger(slot);
  }

  /// Convert this value to an `uint` value.
  /// See_Also: `xs.bindings.macros.xsToUnsigned`
  uint unsigned() @property const {
    enforce(type == JSType.integer || type == JSType.reference, "Value is not an integral Number");
    return machine.the.xsToUnsigned(slot);
  }

  /// Convert this value to a `double` value.
  /// See_Also: `xs.bindings.macros.xsToNumber`
  double number() @property const {
    enforce(type == JSType.number || type == JSType.reference, "Value is not a Number");
    return machine.the.xsToNumber(slot);
  }

  /// Convert this value to a `string` value.
  /// See_Also: `xs.bindings.macros.xsToString`
  string string_() @property const {
    import std.string : fromStringz;

    enforce((JSType.someString & type) == type || type == JSType.reference, "Value is not a String");
    return machine.the.xsToString(slot).fromStringz.to!string;
  }

  /// Whether this value is convertable to a `JSObject` value.
  bool convertableToObject() @property const {
    auto the = machine.the;
    return type == JSType.reference && xsIsInstanceOf(the, slot, xsObjectPrototype!the);
  }

  /// Convert this value to a `JSObject` value.
  JSObject object() @property inout {
    enforce(convertableToObject, "Value is not an Object reference");
    if (typeid(JSObject).isBaseOf(this.classinfo)) return cast(JSObject) this;
    return new JSObject(machine, slot);
  }
}

unittest {
  import std.exception : assertThrown;

  auto machine = new Machine("test-jsvalue");
  const global = machine.global.slot;
  assert(machine.toId(global));

  const fooId = machine.id("foo");
  machine.set(global, fooId, machine.integer(1));
  assert(machine.has(global, fooId));
  auto foo = machine.get(global, fooId);
  assert(foo.id == machine.toId(foo.slot));
  assert(foo.type == JSType.integer);
  assert(foo.integer == 1);
  assert(foo.unsigned == 1);
  assertThrown(foo.number == 1);

  machine.set(global, foo.id, machine.unsigned(100));
  foo = machine.get(global, foo.id);
  assert(foo.type == JSType.integer);
  assert(foo.integer == 100);
  assert(foo.unsigned == 100);
  assertThrown(foo.number == 100);

  machine.set(global, foo.id, machine.number(110));
  foo = machine.get(global, foo.id);
  assert(foo.type == JSType.number);
  assertThrown(foo.integer == 100);
  assertThrown(foo.unsigned == 100);
  assert(foo.number == 110);

  machine.set(global, machine.id("bar"), machine.boolean(true));
  assert(machine.has(global, machine.id("bar")));
  const bar = machine.get(global, machine.id("bar"));
  assert(bar.type == JSType.boolean);
  assert(bar.boolean);

  machine.set(global, machine.id("foobar"), machine.string_("foobar"));
  assert(machine.has(global, machine.id("foobar")));
  const foobar = machine.get(global, machine.id("foobar"));
  assert(foobar.type == JSType.string);
  assert(foobar.string_ == "foobar");

  machine.collectGarbage();
  destroy(machine);
}

/// A JavaScript Object reference.
///
/// Adapted from <a href="https://developer.apple.com/documentation/javascriptcore/jsobjectref_h">`JSObjectRef`</a> in Apple's <a href="https://developer.apple.com/documentation/javascriptcore">JavaScriptCore</a>.
class JSObject : JSValue {
  import std.algorithm : map;
  import std.array : array;

  private void* _data;

  /// Constructs an Object given a value slot.
  ///
  /// Params:
  /// machine=A `Machine`.
  /// value=
  /// data=The Object’s private data.
  this(Machine machine, const xsSlot value, void* data = null) {
    super(machine, value);
    this._data = data;
  }

  /// Creates a JavaScript Object.
  ///
  /// Params:
  /// machine=A `Machine`.
  /// data=The Object’s private data.
  /// Returns: A `JSObject` with the given class and private data.
  static JSObject make(Machine machine, void* data = null) {
    auto objectSlot = xsNewObject(machine.the);
    // TODO: Set user data

    return new JSObject(machine, objectSlot, data);
  }

  /// Creates a JavaScript Array object.
  ///
  /// Params:
  /// machine=A `Machine`.
  /// length=Length of the returned Array.
  /// Returns: A `JSObject` that is an Array.
  static JSObject makeArray(Machine machine, uint length) {
    return new JSObject(machine, xsNewArray(machine.the, length));
  }

  /// Creates a JavaScript Date object, as if by invoking the built-in Date constructor.
  ///
  /// Params:
  /// machine=A `Machine`.
  /// arguments=Arguments to pass to the Date constructor.
  /// Returns: A `JSObject` that is a Date.
  ///
  /// Throws: `JSException` when the JS VM is aborted with the `xsUnhandledExceptionExit` status.
  static JSObject makeDate(Machine machine, JSValue[] arguments ...) {
    auto the = machine.the;
    auto objectSlot = xsNew(
      the, xsGlobal(the),
      machine.toId(xsDatePrototype!the),
      arguments.map!(arg => arg.slot).array
    );
    return new JSObject(machine, objectSlot);
  }

  /// Creates a JavaScript Error object, as if by invoking the built-in Error constructor.
  ///
  /// Params:
  /// machine=A `Machine`.
  /// arguments=Arguments to pass to the Error constructor.
  /// Returns: A `JSObject` that is an Error.
  ///
  /// Throws: `JSException` when the JS VM is aborted with the `xsUnhandledExceptionExit` status.
  static JSObject makeError(Machine machine, JSValue[] arguments ...) {
    auto the = machine.the;
    auto objectSlot = xsNew(
      the, xsGlobal(the),
      machine.toId(xsErrorPrototype!the),
      arguments.map!(arg => arg.slot).array
    );
    return new JSObject(machine, objectSlot);
  }

  /// Creates a function with a given script as its body.
  ///
  /// Params:
  /// machine=A `Machine`.
  /// name=The function's name
  /// parameterNames=The names of the function's parameters.
  /// body_=The script to use as the function's body.
  ///
  /// Throws: `JSException` when a JS VM is aborted with the `xsUnhandledExceptionExit` status. For example, when a syntax error exception is thrown.
  /// See_Also: <a href="https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Function/Function">`Function` constructor</a> on MDN
  static JSObject makeFunction(Machine machine, string name, string[] parameterNames, string body_) {
    import std.algorithm : joiner;
    import std.array : array;

    assert(machine);
    assert(name.length, "Functions must have names");

    auto the = machine.the;
    auto functionSlot = xsNew(
      the, xsGlobal(the), machine.toId(xsFunctionPrototype!the),
      xsString(the, parameterNames.joiner(",").array.to!string), xsString(the, body_)
    );
    // Modify the function's name
    // https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Object/defineProperty
    xsDefine(
      the, functionSlot, machine.id("name"), xsString(the, name), Attribute.dontSet | Attribute.dontDelete
    );
    return new JSObject(machine, functionSlot);
  }

  /// Creates a function with the given callback, `Func` as its implementation.
  ///
  /// Params:
  /// machine=A `Machine`.
  ///
  /// See_Also: `isCallableAsHostZone`
  static JSObject makeFunction(Func)(Machine machine) if (isCallableAsHostZone!Func) {
    assert(machine);
    assert(0, "Not implemented");
  }

  /// Creates a JavaScript RegExp object, as if by invoking the built-in RegExp constructor.
  ///
  /// Params:
  /// machine=A `Machine`.
  static JSObject makeRegExp(Machine machine) {
    auto the = machine.the;
    auto objectSlot = xsNew(the, xsGlobal(the), machine.toId(xsRegExpPrototype!the));
    return new JSObject(machine, objectSlot);
  }

  /// This Object’s private data.
  void* data() @property const {
    return cast(void*) _data;
  }

  /// Gets this Object’s prototype.
  /// Returns: The prototype of this Object. If there are no inherited properties, `null` is returned.
  /// See_Also: <a href="https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Object/getPrototypeOf">`Object.getPrototypeOf`</a> on MDN
  JSValue prototype() @property const {
    auto obj = machine.global.getProperty("Object").object;
    auto getPrototypeOf = obj.getProperty("getPrototypeOf").object;
    auto prototype = getPrototypeOf.callAsFunction(obj, this);

    if (prototype.type == JSType.null_) return null;
    return prototype;
  }

  /// Gets this Object's prototype's constructor's name.
  ///
  /// Equivalent to this JS:
  /// ---
  /// Object.getPrototypeOf(value).constructor.name
  /// ---
  string prototypeName() @property const {
    return prototype.object.getProperty("constructor").object.getProperty("name").string_;
  }

  /// See_Also: <a href="https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Object/isExtensible">`Object.isExtensible`</a> on MDN
  bool extensible() @property const {
    auto the = machine.the;
    assert(xsIsInstanceOf(the, slot, xsObjectPrototype!the));
    auto obj = machine.global.getProperty("Object").object;
    auto isExtensible = obj.getProperty("isExtensible").object;
    auto result = isExtensible.callAsFunction(obj, this);
    return result.boolean;
  }

  /// Whether this Object can be called as a constructor.
  bool constructor() @property const {
    auto the = machine.the;
    return xsIsInstanceOf(the, slot, xsFunctionPrototype!the);
  }

  /// Whether this Object can be called as a function.
  bool function_() @property const {
    auto the = machine.the;
    return xsIsInstanceOf(the, slot, xsFunctionPrototype!the);
  }

  /// The names of this Object’s enumerable properties.
  /// See_Also: <a href="https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Object/getOwnPropertyNames">`Object.getOwnPropertyNames`</a> on MDN
  string[] propertyNames() @property const {
    return []; // TODO: Call `Object.getOwnPropertyNames`
  }

  /// Tests whether this Object has a given property.
  bool hasProperty(string key) {
    return machine.has(slot, machine.id(key));
  }

  /// Tests whether this Object has a property given its numeric index.
  bool hasPropertyAt(uint id) {
    return xsHasAt(machine.the, slot, machine.the.xsUnsigned(id));
  }

  /// Gets a property from this Object.
  JSValue getProperty(string key) {
    return machine.get(slot, machine.id(key));
  }

  /// Gets a property from this Object given its numeric index.
  JSValue getPropertyAt(uint id) {
    return new JSValue(machine, xsGetAt(machine.the, slot, machine.the.xsUnsigned(id)));
  }

  /// Sets a property from this Object.
  void setProperty(string key, const JSValue value) {
    machine.set(slot, machine.id(key), value);
  }

  /// Sets a property from this Object given its numeric index.
  void setPropertyAt(uint id, const JSValue value) {
    xsSetAt(machine.the, slot, machine.the.xsUnsigned(id), value.slot);
  }

  /// Deletes a property from this Object.
  /// Returns: Whether the property was successfully deleted.
  bool deleteProperty(string key) {
    xsDelete(machine.the, slot, machine.id(key));
    return !hasProperty(key);
  }

  /// Deletes a property from this Object given its numeric index.
  /// Returns: Whether the property was successfully deleted.
  bool deletePropertyAt(uint id) {
    auto value = getPropertyAt(id);
    xsDeleteAt(machine.the, slot, machine.the.xsUnsigned(id));
    return !hasPropertyAt(id) || getPropertyAt(id).slot != value.slot;
  }

  /// Calls this Object as a constructor.
  ///
  /// Params:
  /// target=A reference to the Object that has this constructor
  /// params=The parameter values to pass to the constructor
  JSObject callAsContructor(JSObject target, JSValue[] params ...) {
    assert(constructor);
    auto the = machine.the;
    auto result = xsNew(the, target.slot, machine.toId(slot), params.map!(p => p.slot).array);
    if (result == the.xsNull) return null;
    assert(xsIsInstanceOf(the, result, xsObjectPrototype!the));
    return new JSObject(machine, result);
  }

  /// Calls this Object as a Function.
  ///
  /// Params:
  /// target=A reference to the Object that has this function
  /// params=The parameter values to pass to the function
  JSValue callAsFunction(JSObject target, const JSValue[] params ...) {
    assert(function_);
    auto result = machine.the.xsHostZone!((scope xsMachine* the) => {
      return xsCallFunction(the, target.slot, slot, params.map!(p => p.slot).array);
    }());
    if (result == machine.the.xsNull) return null;
    return new JSValue(machine, result);
  }

  /// Calls this Object as a Function.
  ///
  /// Params:
  /// target=A reference to the Object that has this function
  /// params=The parameter values to pass to the function
  void callAsFunction_noResult(JSObject target, JSValue[] params ...) {
    assert(function_);
    xsCall_noResult(machine.the, target.slot, machine.toId(slot), params.map!(p => p.slot).array);
  }
}

unittest {
  auto machine = new Machine("test-jsobject");
  auto global = machine.global;

  assert(global.hasProperty("Object"));
  assert(global.getProperty("Object").convertableToObject);
  assert(global.getProperty("Object").object.getProperty("isExtensible").object.function_);
  assert(global.getProperty("Object").object.constructor);

  global.setProperty("Host", JSObject.make(machine));
  assert(global.hasProperty("Host"));
  assert(global.getProperty("Host").convertableToObject);
  assert(global.getProperty("Host").object.prototypeName == "Object");

  assert(global.deleteProperty("Host"));
  assert(!global.hasProperty("Host"));

  assert(global.extensible);

  destroy(machine);
}

/// A set of JSObject property attributes. Combine multiple attributes with bitwise OR.
enum PropertyAttributes : xsAttribute {
  /// Specifies that a property has no special attributes.
  none = 0,
  /// Specifies that a property is read-only.
  readOnly = xsDontSet,
  /// Specifies that a property is read-only.
  dontSet = xsDontSet,
  /// Specifies that a property should not be enumerated by property enumerators and JavaScript `for...in` loops.
  dontEnumerate = xsDontEnum,
  /// Specifies that the delete operation should fail on a property.
  /// See_Also: `JSObject.deleteProperty`
  dontDelete = xsDontDelete,
  /// Specifies that a property is static.
  static_ = xsStatic,
  /// Specifies that a property is a getter Function.
  isGetter = xsIsGetter,
  /// Specifies that a property is a setter Function.
  isSetter = xsIsSetter,
  ///
  changeAll = xsChangeAll,
}

/// A set of `JSClass` attributes. Combine multiple attributes with bitwise OR.
/// See_Also: `ClassDefinition.attributes`
enum ClassAttributes {
  /// Specifies that a class has no special attributes.
  none = 0,
  /// Specifies that a class should not automatically generate a shared prototype for its instance objects.
  noAutomaticPrototype = 2
}

/// Describes a statically declared function property.
///
/// Adapted from <a href="https://developer.apple.com/documentation/javascriptcore/jsstaticfunction">`JSStaticFunction`</a> in Apple's <a href="https://developer.apple.com/documentation/javascriptcore">JavaScriptCore</a>.
struct JSStaticFunction {
  ///
  string name;
  /// A set of property attributes. Combine multiple attributes with bitwise OR.
  PropertyAttributes attributes;
  ///
  xsCallback callAsFunction;
}

/// Describes a statically declared value property.
///
/// Adapted from <a href="https://developer.apple.com/documentation/javascriptcore/jsstaticvalue">`JSStaticValue`</a> in Apple's <a href="https://developer.apple.com/documentation/javascriptcore">JavaScriptCore</a>.
struct JSStaticValue {
  ///
  string name;
  /// A set of property attributes. Combine multiple attributes with bitwise OR.
  PropertyAttributes attributes;
  /// Invoked when getting this property’s value.
  ///
  /// If this function returns `null`, the get request forwards to object’s statically declared properties, then its parent class chain (which includes the default Object class), then its prototype chain.
  xsCallback getProperty;
  /// Invoked when setting this property’s value.
  ///
  /// If this function returns `null`, the get request forwards to object’s statically declared properties, then its parent class chain (which includes the default Object class), then its prototype chain.
  xsCallback setProperty;
}

/// Properties and callbacks that define a type of Object.
/// All fields other than the version field are optional. Any pointer may be `null`.
///
/// Adapted from <a href="https://developer.apple.com/documentation/javascriptcore/jsclassdefinition">`JSClassDefinition`</a> in Apple's <a href="https://developer.apple.com/documentation/javascriptcore">JavaScriptCore</a>.
struct ClassDefinition {
  ///
  string name;
  ///
  JSClass parentClass;
  /// A set of attributes. Combine multiple attributes with bitwise OR.
  ClassAttributes attributes;
  /// Invoked when an object is first created.
  xsCallback initialize;
  /// Invoked when an object is finalized (prepared for garbage collection). An Object may be finalized on any thread.
  xsCallback finalize;
  ///
  xsDestructor destructor;
  // xsCallback callAsConstructor; TODO: Not a thing in XS?
  // xsCallback callAsFunction; TODO: Not a thing in XS?
  // xsCallback hasInstance; TODO: Not a thing in XS?
  /// Invoked when determining whether an Object has a property.
  xsCallback hasProperty;
  ///
  xsCallback getPropertyNames;
  /// Invoked when getting a property’s value.
  ///
  /// If this function returns `null`, the get request forwards to object’s statically declared properties, then its parent class chain (which includes the default Object class), then its prototype chain.
  xsCallback getProperty;
  /// Invoked when setting a property’s value.
  ///
  /// If this function returns `null`, the get request forwards to object’s statically declared properties, then its parent class chain (which includes the default Object class), then its prototype chain.
  xsCallback setProperty;
  ///
  xsCallback deleteProperty;
  // xsCallback convertToType; TODO: Not a thing in XS?
  /// Statically declared function properties on the class' prototype.
  JSStaticFunction[] staticFunctions;
  /// Statically declared value properties on the class' prototype.
  JSStaticValue[] staticValues;
  ///
  int version_;
}

/// A JavaScript class. Subclass a D class with `JSClass` to expose it to a JS VM.
///
/// Use with `JSObject.make` to construct objects with custom behavior.
///
/// Adapted from <a href="https://developer.apple.com/documentation/javascriptcore/jsclassref">`JSClassRef`</a> in Apple's <a href="https://developer.apple.com/documentation/javascriptcore">JavaScriptCore</a>.
abstract class JSClass {
  private JSObject _instance;
  ///
  const ClassDefinition definition;

  /// Constructs a JavaScript class suitable for use with `JSObject.make`.
  this(ClassDefinition definition) {
    this.definition = definition;
  }

  /// Retains this JavaScript class.
  void retain() {
    remember();
  }
  /// Remembers this JavaScript class.
  void remember() {
    xsRemember(_instance.machine.the, _instance.slot);
  }

  /// Releases this JavaScript class.
  void release() {
    forget();
  }
  /// Forgets this JavaScript class.
  void forget() {
    xsForget(_instance.machine.the, _instance.slot);
  }
}
