/// Structures adapted from those in <a href="https://github.com/Moddable-OpenSource/moddable/blob/OS201116/xs/includes/xs.h">xs.h</a>.
///
/// Authors: Chance Snow
/// Copyright: Copyright © 2020 Chance Snow. All rights reserved.
/// License: MIT License
module xs.bindings.structs;

import xs.bindings;

alias txSize = txS4;
alias txString = char*;

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
}
