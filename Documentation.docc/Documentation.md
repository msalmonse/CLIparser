# ``CLIparser``

CLIparser is a packge that helps in parsing the command line and the process environment.

## Overview

Parsing the command line has three phases:
1. Parse the environment for variables that have interesting data.
2. Parse the command line for commands, e.g. `git branch` has the command `branch`.
3. Parse the command line for options and arguments:
  1. Options have associated names e.g. for `git branch`, `--track` is an option.
     Options can have parameters.
  2. Arguments come after the end of the options.
All of the phases are optional and depend on the application.

Command line options and environment variables are defined using an OptToGet instance, one instance for
every option. The list of options is then compared to the command line or environment and a list of the
options found is returned.

## Topics

### Defining an option

- ``OptToGet(short: String?, long: String?, aka: [String]?, ClosedRange<UInt8>, options: [OptToGet.Options], tag: CLIparserTag?, usage: String?, argTag: String?, env: String?)``
