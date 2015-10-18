# navigation-history [![Build Status](https://travis-ci.org/Tyriar/navigation-history.svg?branch=master)](https://travis-ci.org/Tyriar/navigation-history)

An [Atom Editor](http://atom.io) package that allows navigating cursor history across multiple files.

Press <kbd>alt</kbd>+<kbd>-</kbd> to navigate back or <kbd>alt</kbd>+<kbd>shift</kbd>+<kbd>-</kbd> to navigate forward.

History entries are recorded when the cursor moves to a row other than the previous row or its surrounding rows. This helps keep the cursor history more useful by ignoring small navigations near the cursor like when using the arrow keys, home, end and typing new input.
