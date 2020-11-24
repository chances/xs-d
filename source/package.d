/// XS JavaScript Engine API
///
/// See the <a href="https://chances.github.io/xs-d">API Reference</a> and the official <a href="https://github.com/Moddable-OpenSource/moddable/blob/OS201116/documentation/xs/XS%20in%20C.md">XS in C</a> in the Moddable SDK's documentation.
///
/// Authors: Chance Snow
/// Copyright: Copyright © 2020 Chance Snow. All rights reserved.
/// License: MIT License
module xs;

import std.conv : to;
import std.string : format, toStringz;

public import xs.bindings;
public import xs.bindings.enums;
public import xs.bindings.macros;

///
extern(C) void fxAbort(xsMachine* the, int status)
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

private {
  alias constSlot = const(xsSlot);
}

/// A JavaScript virtual machine.
class Machine {
  package xsMachine* the;

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

  /// Create and allocate a new JS VM.
  this(string name, const xsCreation creationOptions = defaultCreation) {
    import std.exception : enforce;

    the = enforce(
      xsCreateMachine(&creationOptions, name, cast(void*) this),
      format!"Could not create JS virtual machine '%s'"(name)
    );
  }
  ~this() {
    if (the) the.xsDeleteMachine();
  }

  constSlot global() @property const {
    const slot = the.xsGlobal;
    return slot;
  }

  /// See_Also: `xs.bindings.macros.xsID`
  xsIndex id(string name) {
    return the.xsID(name);
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
