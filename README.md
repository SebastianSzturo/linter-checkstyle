# linter-checkstyle

This package will lint your `.java` opened files in Atom through [checkstyle](http://checkstyle.sourceforge.net/).

## Installation

#### 1. Install ``checkstyle`` in your ``PATH``

On OSX just run
```
brew install checkstyle
```
For other platforms [see checkstyle's website.](http://checkstyle.sourceforge.net/)

#### 2. Install this package through Atom or apm.

```
apm install linter-checkstyle
```

## Settings
You can configure linter-checkstyle by editing ~/.atom/config.cson (choose Open Your Config in Atom menu):

    'linter-checkstyle':
      # The path to checkstyle. The default (checkstyle) should work as long as you have it
      # in your system PATH.
      'checkstyleExecutablePath': "checkstyle"
      # Check configuration file to use when executing checkstyle.
      'checkConfiguration': ''
