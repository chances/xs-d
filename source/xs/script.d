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
