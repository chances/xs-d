/// JavaScript script and module loaders.
///
/// Authors: Chance Snow
/// Copyright: Copyright © 2020 Chance Snow. All rights reserved.
/// License: MIT License
module xs.script;

import std.conv : to;

import xs;

package(xs) extern(C) {
  bool fxIsLoadingModule(xsMachine* the, xsSlot* realm, txID moduleID);
  void fxResolveModule(
    xsMachine* the, xsSlot* realm, txID moduleID, txScript* script, void* data, xsDestructor destructor
  );
  void fxRunModule(xsMachine* the, xsSlot* realm, txID moduleID, txScript* script);
  void fxRunImport(xsMachine* the, xsSlot* realm, txID id);

  xsSlot* fxNewRealmInstance(xsMachine* the);
}

package(xs) enum mxProgramStackIndex = 2;
package(xs) enum mxProgram(alias xsMachine* the) = the.stackTop[-1 - mxProgramStackIndex];

/// A JavaScript script or entry point module.
class Script {
  private Machine machine;
  package(xs) const txScript script;

  private const void* callback;
  ///
	const txS1[] symbolsBuffer;
  ///
	const txS1[] codeBuffer;
  ///
	const txS1[] hostsBuffer;
  ///
	const string path;

  /// Construct a new script given its source code.
  this(Machine machine, string path, const(byte[]) source) {
    this.machine = machine;
    this.script = txScript();

    callback = null;
    symbolsBuffer = [];
    codeBuffer = [];
    hostsBuffer = [];
    this.path = path;

    // TODO: https://github.com/Moddable-OpenSource/moddable/blob/5639abb24b6d725554969dc0be5822edb54a4a08/documentation/xs/XS%20Platforms.md#eval
    assert(0, "Not implemented");
  }

  package(xs) this(Machine machine, const txScript* script) {
    import std.string : fromStringz;

    this.machine = machine;
    this.script = *script;

    callback = script.callback;
    symbolsBuffer = script.symbolsBuffer[0..script.symbolsSize];
    codeBuffer = script.codeBuffer[0..script.codeSize];
    hostsBuffer = script.hostsBuffer[0..script.hostsSize];
    path = script.path.fromStringz.to!string;
  }

  ///
  void run() inout {
    auto zone = (scope xsMachine* the) => {
      // https://github.com/Moddable-OpenSource/moddable/blob/5639abb24b6d725554969dc0be5822edb54a4a08/documentation/xs/XS%20Platforms.md#modules
      fxRunModule(the, cast(xsSlot*) &machine.realm, XS_NO_ID, cast(txScript*) script.copy);
    }();
    machine.the.xsHostZone!zone;
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
  import std.exception : assertNotThrown;

  auto script = helloWorldScript();
  auto machine = new Machine("test-script", Machine.defaultCreation, [&script]);
  assertNotThrown(machine.scripts[0].run());

  destroy(machine);
}
