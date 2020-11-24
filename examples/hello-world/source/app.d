import std.stdio;

import xs;

mixin defaultFxAbort;

void main()
{
	writeln("XS Example - Hello, world!");

  auto machine = new Machine("Hello, world!");
  const global = machine.global;

  destroy(machine);
}
