XSC := ../../thirdparty/moddable/build/bin/lin/debug/xsc

# TODO: All this sed voodoo seems fragile... Integrate runtime compilation of modules?
# https://github.com/Moddable-OpenSource/moddable/blob/5639abb24b6d725554969dc0be5822edb54a4a08/documentation/xs/XS%20Platforms.md#eval
source/hello.d: source/hello.js
	$(XSC) source/hello.js -d -p -o source
	cp source/hello.xs.c source/hello.d
	# Replace #include with import
	@sed -i "s/#include \"hello.xs.h\"/import xs;\n\npackage:/" source/hello.d
	# Fix NULLs
	@sed -i "s/NULL,/null,/g" source/hello.d
	# xsSymbols declaration
	@sed -i "s/txS1 xsSymbols\[\S*\]/int[] xsSymbols/g" source/hello.d
	# xsCode declaration
	@sed -i "s/txS1 xsCode\[\S*\]/int[] xsCode/g" source/hello.d
	# Fix Braces
	@sed -i 's/ = \S$$/\ = [/g' source/hello.d
	@sed -i "s/^\};/\];/g" source/hello.d
	# xsScript
	@sed -i "s/txScript xsScript = {/txScript xsScript() {\n  txScript script = {\n   /g" source/hello.d
	@sed -i "s/xsSymbols,/cast(byte*) xsSymbols.ptr,/" source/hello.d
	@sed -i "s/xsCode,/cast(byte*) xsCode.ptr,/" source/hello.d
	@sed -i "s/{ XS_MAJOR_VERSION/\[XS_MAJOR_VERSION/" source/hello.d
	@sed -i "s/null, \[XS_MAJOR_VERSION,/null,\n    \[XS_MAJOR_VERSION,/" source/hello.d
	@sed -i "s/XS_PATCH_VERSION, 0 }/XS_PATCH_VERSION, 0]/" source/hello.d
	@sed -i "s/XS_PATCH_VERSION, 0]  };/XS_PATCH_VERSION, 0]\n  };\n  return script;\n}/" source/hello.d
	@echo Done.
