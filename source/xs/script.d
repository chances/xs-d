/// JavaScript program and module loaders.
///
/// Authors: Chance Snow
/// Copyright: Copyright © 2020 Chance Snow. All rights reserved.
/// License: MIT License
module xs.script;

import std.conv : to;
import std.range.primitives : isInputRange;

import xs;
import xs.bindings.enums;
import xs.bindings.structs;

package(xs) enum mxProgramStackIndex = 2;
package(xs) auto mxProgram(xsMachine* the) { return the.stackTop[-1 - mxProgramStackIndex]; }
package(xs) xsSlot* next(const xsSlot slot) {
  return cast(xsSlot*) slot.data[0];
}
package(xs) xsSlot* next(const xsSlot* slot) {
  return cast(xsSlot*) slot.data[0];
}

/// The kind of JS source code.
enum ScriptKind {
  ///
  program,
  ///
  module_,
}

package(xs) extern(C) {
  enum Flags : txU4 {
    mxParserFlags = mxCFlag | mxDebugFlag | mxProgramFlag,
    mxCFlag = 1 << 0,
    mxDebugFlag = 1 << 1,
    mxEvalFlag = 1 << 2,
    mxProgramFlag = 1 << 3,
    mxStrictFlag = 1 << 4,
    mxSuperFlag = 1 << 5,
    mxTargetFlag = 1 << 6,
    mxFieldFlag = 1 << 15,
  }

  /// A function which, given a pointer to some stream of characters, returns each successive character until [`EOF`](https://dlang.org/library/core/stdc/stdio/eof.html) is returned.
  ///
  /// i.e. A structure that satisfies [`isInputRange`](https://dlang.org/phobos/std_range_primitives.html#isInputRange)
  alias txGetter = int function(void* stream);
  txScript* fxParseScript(xsMachine* the, void* stream, txGetter getter, Flags flags);
  void fxDeleteScript(txScript* script);
  bool fxIsLoadingModule(xsMachine* the, xsSlot* realm, txID moduleID);
  void fxResolveModule(
    xsMachine* the, xsSlot* realm, txID moduleID, txScript* script, void* data, xsDestructor destructor
  );
  void fxRunScript(
    xsMachine* the, txScript* script,
    sxSlot* _this, sxSlot* _target, sxSlot* environment, sxSlot* object, sxSlot* module_
  );
  void fxRunModule(xsMachine* the, xsSlot* realm, txID moduleID, txScript* script);
  void fxRunImport(xsMachine* the, xsSlot* realm, txID id);

  xsSlot* fxNewRealmInstance(xsMachine* the);
}

private extern(C) int getter(T)(void* stream) if (isInputRange!T) {
  import core.stdc.stdio : EOF;
  import std.range : empty, front, popFront;

  T s = *(cast(T*) stream);
  if (s.empty) return EOF;
  const char_ = s.front;
  s.popFront();
  *(cast(T*) stream) = s;
  return char_.to!int;
}

// TODO: Switch to `fxStringGetter`?
private txGetter stringGetter = &getter!string;

///
class JSParseException : Exception {
  import std.exception : basicExceptionCtors;

  mixin basicExceptionCtors;
}

/// A JavaScript program or entry point module.
class Script {
  private Machine machine;
  package(xs) const txScript script;
  private const void* callback;

  /// The kind of JS source code of this script.
  const ScriptKind kind;
  ///
	const string path = "";
  ///
	const txS1[] symbolsBuffer;
  ///
	const txS1[] codeBuffer;
  ///
	const txS1[] hostsBuffer;

  /// Construct a new script given its source code and load it, executing its outer-most scope in the given `machine`.
  ///
  /// Throws: `JSParseException` when the script fails to parse
  /// Throws: `JSException` when the JS VM is aborted with the `xsUnhandledExceptionExit` status while executing the script's outer-most scope
  this(Machine machine, string source, string* path = null, ScriptKind kind = ScriptKind.program) {
    import std.exception : enforce;

    this.machine = machine;
    callback = null;
    this.kind = kind;
    if (path !is null) this.path = (*path).dup;

    // https://github.com/Moddable-OpenSource/moddable/blob/5639abb24b6d725554969dc0be5822edb54a4a08/documentation/xs/XS%20Platforms.md#eval
    auto sourceStream = source.dup;
    txScript* unmanagedScript = null;
    const zone = (scope xsMachine* the) => {
      auto parserFlags = Flags.mxParserFlags;
      if (kind == ScriptKind.module_) parserFlags |= Flags.mxStrictFlag;
      else assert(kind == ScriptKind.program);
      unmanagedScript = fxParseScript(the, &sourceStream, stringGetter, parserFlags);
    }();
    xsHostZone!zone(machine.the);
    enforce!JSParseException(unmanagedScript !is null, "Failed to parse script");

    script = *unmanagedScript.managedCopy;
    // The result of `fxParseScript` is not managed memory
    fxDeleteScript(unmanagedScript);

    symbolsBuffer = script.symbolsBuffer[0..script.symbolsSize];
    codeBuffer = script.codeBuffer[0..script.codeSize];
    hostsBuffer = script.hostsBuffer[0..script.hostsSize];

    run();
  }
  /// Construct a script given compiled VM byte code and load it, executing its outer-most scope in the given `machine`.
  ///
  /// Throws: `JSException` when the JS VM is aborted with the `xsUnhandledExceptionExit` status while executing the script's outer-most scope
  this(Machine machine, const txScript* byteCode, ScriptKind kind = ScriptKind.program) {
    import std.string : fromStringz;

    this.machine = machine;
    script = *byteCode;
    callback = script.callback;
    this.kind = kind;
    path = script.path.fromStringz.to!string;

    symbolsBuffer = script.symbolsBuffer[0..script.symbolsSize];
    codeBuffer = script.codeBuffer[0..script.codeSize];
    hostsBuffer = script.hostsBuffer[0..script.hostsSize];

    run();
  }

  /// Execute this script's global scope.
  private void run() {
    auto zone = (scope xsMachine* the) => {
      if (kind == ScriptKind.module_)
        // https://github.com/Moddable-OpenSource/moddable/blob/OS201116/documentation/xs/XS%20Platforms.md#modules
        fxRunModule(the, cast(xsSlot*) &machine.realm, XS_NO_ID, script.copy);
      else {
        auto realmClosures = cast(sxSlot*) machine.realm.next.next;
        auto program = cast(sxSlot) the.mxProgram;
        fxRunScript(
          the, script.copy,
          cast(sxSlot*) &machine.realm, null,
          realmClosures.value.reference, null,
          program.value.reference
        );
      }
    }();
    try {
      machine.the.xsHostZone!zone;
    } catch (JSException unhandledInVm) {
      throw new JSException(unhandledInVm.msg, this, unhandledInVm.file, unhandledInVm.line);
    }
  }
}

version(unittest) {
  package:

  static ubyte[] helloWorldSymbols = [
    0x02, 0x00, 0x2f, 0x68, 0x6f, 0x6d, 0x65, 0x2f, 0x63, 0x68, 0x61, 0x6e, 0x63, 0x65, 0x73, 0x2f,
    0x47, 0x69, 0x74, 0x48, 0x75, 0x62, 0x2f, 0x78, 0x73, 0x2d, 0x64, 0x2f, 0x65, 0x78, 0x61, 0x6d,
    0x70, 0x6c, 0x65, 0x73, 0x2f, 0x68, 0x65, 0x6c, 0x6c, 0x6f, 0x2d, 0x77, 0x6f, 0x72, 0x6c, 0x64,
    0x2f, 0x73, 0x6f, 0x75, 0x72, 0x63, 0x65, 0x2f, 0x68, 0x65, 0x6c, 0x6c, 0x6f, 0x2e, 0x6a, 0x73,
    0x00, 0x74, 0x72, 0x61, 0x63, 0x65, 0x00
  ];
  static ubyte[] helloWorldCode = [
    0x53, 0x00, 0x00, 0x79, 0x01, 0x00, 0x0b, 0x00, 0x53, 0x00, 0x00, 0x79, 0x01, 0x00, 0xdd, 0x91,
    0x01, 0x00, 0x65, 0x01, 0x00, 0x27, 0xc6, 0x0d, 0x68, 0x65, 0x6c, 0x6c, 0x6f, 0x20, 0x77, 0x6f,
    0x72, 0x6c, 0x64, 0x0a, 0x00, 0xa9, 0x01, 0xa1, 0xa7
  ];

  txScript helloWorldScript() {
    txScript script = {
      null, cast(byte*) helloWorldSymbols.ptr, 71, cast(byte*) helloWorldCode.ptr, 41, null, 0, null,
      [XS_MAJOR_VERSION, XS_MINOR_VERSION, XS_PATCH_VERSION, 0]
    };
    return script;
  }
}

unittest {
  import std.exception : assertNotThrown, assertThrown;
  import std.typecons : tuple;

  auto machine = new Machine("test-script", Machine.defaultCreation);
  assertNotThrown!JSException(
    new Script(machine, "const foo = 'bar';")
  );
  assertThrown!JSException(
    new Script(machine, "throw new Error('unhandled err');")
  );
  destroy(machine);

  auto script = helloWorldScript();
  assertThrown!JSException(
    machine = new Machine("test-compiled-script", Machine.defaultCreation, [tuple(&script, ScriptKind.module_)])
  );
  destroy(machine);
}
