/// Structures adapted from those in <a href="https://github.com/Moddable-OpenSource/moddable/blob/OS201116/xs/includes/xs.h">xs.h</a>.
///
/// Authors: Chance Snow
/// Copyright: Copyright © 2020 Chance Snow. All rights reserved.
/// License: MIT License
module xs.bindings.structs;

import xs.bindings;

alias txID = txS2;
alias txSize = txS4;
alias txString = char*;

/// Empty checksum of a prepared VM
static txU1[16] emptyChecksum = [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0];

///
struct sxPreparation {
	txS1[4] version_;

	txSize aliasCount;
	xsSlot[] heap;
	xsSlot[] stack;

	txID[] colors;
	xsSlot[] keys;
	txSize nameModulo;
	xsSlot[] names;
	txSize symbolModulo;
	xsSlot[] symbols;

	string base;
	txScript*[] scripts;

	xsCreation creation;
	string main;

	txU1[16] checksum;

  static sxPreparation* from(const xsCreation creationOptions, string name, string base, const(txScript*[]) scripts) {
    return new sxPreparation(
      XS_VERSION, 0,
      new xsSlot[creationOptions.incrementalHeapCount],
      new xsSlot[creationOptions.stackCount], [],
      new xsSlot[creationOptions.keyCount],
      creationOptions.nameModulo,
      new xsSlot[creationOptions.nameModulo],
      creationOptions.symbolModulo,
      new xsSlot[creationOptions.symbolModulo],
      base,
      cast(txScript*[]) scripts,
      creationOptions,
      name, // Main
      emptyChecksum // TODO: Perform a checksum of preloaded scripts and other state
    );
  }
}

///
struct txScript {
	void* callback;
	txS1* symbolsBuffer;
	txSize symbolsSize;
	txS1* codeBuffer;
	txSize codeSize;
	txS1* hostsBuffer;
	txSize hostsSize;
	txString path;
	txS1[4] version_;

  txScript* copy() @property const {
    import core.stdc.stdlib : malloc;
    import std.algorithm : copy;

    auto script = cast(txScript*) malloc(txScript.sizeof);
    assert(script);
    script.callback = cast(void*) callback;
    script.version_ = version_;

    script.symbolsBuffer = cast(txS1*) malloc(symbolsSize);
    script.symbolsSize = symbolsSize;
    assert(script.symbolsBuffer);
    auto symbols = script.symbolsBuffer[0..symbolsSize];
    assert(symbolsBuffer[0..symbolsSize].copy(symbols).length == 0);

    script.codeBuffer = cast(txS1*) malloc(codeSize);
    script.codeSize = codeSize;
    assert(script.codeBuffer);
    auto code = script.codeBuffer[0..codeSize];
    assert(codeBuffer[0..codeSize].copy(code).length == 0);

    script.hostsBuffer = cast(txS1*) malloc(hostsSize);
    script.hostsSize = hostsSize;
    assert(script.hostsBuffer);
    auto hosts = script.hostsBuffer[0..hostsSize];
    assert(hostsBuffer[0..hostsSize].copy(hosts).length == 0);

    return script;
  }
}
