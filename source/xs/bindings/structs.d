/// Structures adapted from those in <a href="https://github.com/Moddable-OpenSource/moddable/blob/OS201116/xs/includes/xs.h">xs.h</a>.
///
/// Authors: Chance Snow
/// Copyright: Copyright © 2020 Chance Snow. All rights reserved.
/// License: MIT License
module xs.bindings.structs;

import xs.bindings;

alias txFlag = txU1;
alias txID = txS2;
alias txBoolean = txS4;
alias txInteger = txS4;
alias txKind = txS1;
alias txSize = txS4;
alias txNumber = double;
alias txString = char*;

package(xs) struct txBigInt {
	txU4* data;
	txU2 size;
	txU1 sign;
}

package(xs) union txValue {
	txBoolean boolean;
	txInteger integer;
	txNumber number;
	txString string_;
	txID symbol;
	txBigInt bigint;

	sxSlot* reference;

	sxSlot* closure;

  // https://github.com/Moddable-OpenSource/moddable/blob/OS201116/xs/sources/xsAll.h#L272
  struct module_anon { sxSlot* realm; txID id; }
  module_anon module_;
}

package(xs) struct sxSlot {
	sxSlot* next;
	union {
		struct {
			txKind kind;
			txFlag flag;
			txID ID;
		}
		txInteger KIND_FLAG_ID;
	}
// #if (!defined(linux)) && ((defined(__GNUC__) && defined(__LP64__)) || (defined(_MSC_VER) && defined(_M_X64)))
// 	// Made it aligned and consistent on all platforms
// 	txInteger dummy;
// #endif
	txValue value;
}

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

    import core.stdc.string : strlen;

    if (path !is null) {
      const pathSlice = path[0..path.strlen];
      script.path = cast(char*) malloc(pathSlice.length);
      assert(script.path);
      assert(pathSlice.copy(script.path[0..pathSlice.length]).length == 0);
    }

    return script;
  }

  txScript* managedCopy() @property const {
    import core.stdc.string : strlen;
    import std.algorithm : copy;

    auto pathSlice = path is null ? new char[0] : path[0..path.strlen];
    auto script = new txScript(
      cast(void*) callback,
      symbolsSize ? new txS1[symbolsSize].ptr : null, symbolsSize,
      codeSize ? new txS1[codeSize].ptr : null, codeSize,
      hostsSize ? new txS1[hostsSize].ptr : null, hostsSize,
      path is null ? null : new char[pathSlice.length].ptr, version_
    );
    assert(script);

    if (script.symbolsBuffer) {
      auto symbols = script.symbolsBuffer[0..symbolsSize];
      assert(symbolsBuffer[0..symbolsSize].copy(symbols).length == 0);
    }

    if (script.codeBuffer) {
      auto code = script.codeBuffer[0..codeSize];
      assert(codeBuffer[0..codeSize].copy(code).length == 0);
    }

    if (script.hostsBuffer) {
      auto hosts = script.hostsBuffer[0..hostsSize];
      assert(hostsBuffer[0..hostsSize].copy(hosts).length == 0);
    }

    if (path !is null) {
      assert(script.path);
      assert(pathSlice.copy(script.path[0..pathSlice.length]).length == 0);
    }

    return script;
  }
}
