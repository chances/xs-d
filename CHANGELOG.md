# Changelog

## v0.1.0-alpha.3

- Add runtime compilation/execution of JS snippets
- Add `JSObject` abstraction
- Add `JSClass` abstraction

## v0.1.0-alpha.2

Adds a "Hello, world!" example that runs `trace("hello world\n");` in a new VM.

### Additions

- Add a `Script` abstraction
- Add a `JSException` abstraction

### Fixes

- Fix module file structure for dependents

## v0.1.0-alpha.1

D bindings to the XS JavaScript engine.

- Added bindings to all functions and implement idiomatic D versions of most of the macros in [xs.h](https://github.com/Moddable-OpenSource/moddable/blob/OS201116/xs/includes/xs.h).

See the [API Reference](https://chances.github.io/xs-d) and the official [XS in C](https://github.com/Moddable-OpenSource/moddable/blob/OS201116/documentation/xs/XS%20in%20C.md) document in the Moddable SDK's documentation.
