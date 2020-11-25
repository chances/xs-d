import std.stdio;

import xs;

import hello;

mixin defaultFxAbort;

void main()
{
	writeln("XS Example - Hello, world!");

  const script = xsScript;
  auto machine = new Machine("Hello, world!", Machine.defaultCreation, [&script]);
  writefln("Executing '%s' JS VM...", machine.name);

  machine.scripts[0].run();

  writeln("Done.");
  destroy(machine);
}
