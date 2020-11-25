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

// TODO: https://github.com/Moddable-OpenSource/moddable/blob/5639abb24b6d725554969dc0be5822edb54a4a08/documentation/xs/XS%20Platforms.md#eval

/// A rudimentary Host VM abortion implementation that throws error messages back into the JS VM.
///
/// You <strong>MUST</strong> either mixin the template in your Host application or provide your own implementation.
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
      xsTrace(the, "unhandled exception\n");
    }
  }
}

version (unittest) {
  mixin defaultFxAbort;
}

private {
  alias constSlot = const(xsSlot);
}

/// A JavaScript virtual machine.
class Machine {
  private xsMachine* the_;

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
  };

  /// Create and allocate a new JavaScript VM.
  this(string name, const xsCreation creationOptions = defaultCreation) {
    the_ = enforce(
      xsCreateMachine(&creationOptions, name, cast(void*) this),
      format!"Could not create JS virtual machine '%s'"(name)
    );
  }
  ~this() {
    if (the) the.xsDeleteMachine();
  }

  xsMachine* the() @property const {
    return cast(xsMachine*) the_;
  }

  constSlot global() @property const {
    const slot = the.xsGlobal;
    return slot;
  }

  /// See_Also: `xs.bindings.macros.xsID`
  xsIndex id(string name) {
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
  auto machine = new Machine("test");
  const global = machine.global;
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
  private Machine machine;

  /// ID of this value in it's `Machine`.
  /// See_Also: `Machine.id`, `Machine.toId`
  const xsIndex id;
  /// Machine slot of this value.
  const xsSlot slot;

  /// Construct a reference to a slot value belonging to `machine`.
  this(Machine machine, const xsSlot value) {
    this.machine = machine;
    id = machine.toId(value);
    slot = value;
  }

  JSType type() @property inout {
    return (cast(xsMachine*) machine.the).xsTypeOf(slot);
  }

  /// Convert this value to a `bool` value.
  /// See_Also: `xs.bindings.macros.xsToBoolean`
  bool boolean() @property const {
    enforce(type == JSType.boolean, "Value is not a Boolean");
    return machine.the.xsToBoolean(slot);
  }

  /// Convert this value to an `int` value.
  /// See_Also: `xs.bindings.macros.xsToInteger`
  int integer() @property const {
    enforce(type == JSType.integer, "Value is not an integral Number");
    return machine.the.xsToInteger(slot);
  }

  /// Convert this value to an `uint` value.
  /// See_Also: `xs.bindings.macros.xsToUnsigned`
  uint unsigned() @property const {
    enforce(type == JSType.integer, "Value is not an integral Number");
    return machine.the.xsToUnsigned(slot);
  }

  /// Convert this value to a `double` value.
  /// See_Also: `xs.bindings.macros.xsToNumber`
  double number() @property const {
    enforce(type == JSType.integer, "Value is not a Number");
    return machine.the.xsToNumber(slot);
  }

  /// Convert this value to a `string` value.
  /// See_Also: `xs.bindings.macros.xsToString`
  string string_() @property const {
    import std.string : fromStringz;

    enforce((JSType.someString & type) == type, "Value is not a String");
    return machine.the.xsToString(slot).fromStringz.to!string;
  }
}

unittest {
  auto machine = new Machine("test");
  const global = machine.global;
  assert(machine.toId(global));

  const fooId = machine.id("foo");
  machine.set(global, fooId, machine.integer(1));
  assert(machine.has(global, fooId));
  auto foo = machine.get(global, fooId);
  assert(foo.id == machine.toId(foo.slot));
  assert(foo.type == JSType.integer);
  assert(foo.integer == 1);
  assert(foo.number == 1);

  machine.set(global, foo.id, machine.unsigned(100));
  foo = machine.get(global, foo.id);
  assert(foo.type == JSType.integer);
  assert(foo.unsigned == 100);
  assert(foo.number == 100);

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
