Vim can read .zip files natively, using its zip plugin. But that plugin
wasn't designed to work with Python zip files (.egg files). This plugin
fixes that.

Python tracebacks which point to .egg files tend to look like this:

"/path/to/some.egg/inner/path/to/file.py". This plugin converts those
paths into "zipfile:/path/to/some.egg::inner/path/to/file.py", which
Vim's zip plugin can then read and write into.

## Requirements
- A Vim version with zip plugin support
- A shell with `unzip` installed - Reference: https://stackoverflow.com/a/6459074

Note: Based loosely on https://github.com/bogado/file-line
