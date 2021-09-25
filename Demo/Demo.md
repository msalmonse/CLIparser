#  CLIparser Demo

The demo is a simple command that does nothing but looks a bit like `git` in that it has
a command followed by options.
It starts in [`main.swift`](Demo/main.swift) with the creation of an `ArgumentList`:
```
let argList = ArgumentList(options: [.longOnly])
```
The `ArgumentList` initializer actually takes 3 parameters but the default values are
right for many cases. These defaults set the internal argument list to the command
line arguments and the start index into those arguments to 1.
The `.longOnly` option indicates that long options can begin
with a single `-`. Single letter options are still allowed but they can't be combined as
with e.g. `ls`.

`argList` is used to fetch the command using the `commandParser` method in
[`Commands.swift`](Demo/Commands.swift):
```
commandParser(commands)
```
`commands` is a list of `CmdToGet` objects, each contains a list of words that are
compared with the arguments in `ArgumentList`. If a match is found then the matching
`CmdToGet` is returned, if none is found then `nil` is returned. An empty list always matches. As a side effect the index into the argument list is advanced in
preparation for options parsing.

The `tag` property is not used during parsing and can be anything but I like using `enum`'s. As it doesn't have a defined type it needs to be downcast to a `CommandType`.
If the returned `CmdToGet` is `nil` then `.unspec` is returned.

Having determined the command we need to determine the options. They are parsed in
[`Options.swift`](Demo/Options.swift) using:
```
optionsParse(toGet, OptionType.positional)
```
The `toGet` parameter is similar to the `commands` parameter for `commandParser` just more
complex. The second parameter is used to tag any arguments not associated with options.
Each `OptToGet` object has a tag and this is used to handle the list of options found
that we get back from `optionsParser`. The values associated with the options are
wrapped in an `OptValueAt` object and the reason for that is to be able to associate
any errors with the argument that caused it.

Some options have no values like `short`, others like `verbose` are set to the number of
times that they appear on the command line. Finally options like `status` are flags
that can be preceded by `no` to invert their meaning.
