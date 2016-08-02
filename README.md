# Stream Aggregator

`stag` (stream aggregator) is for filtering and aggregating an input
stream (e.g., `stdin`) linewise -- like, say, a generated log -- such
that the bits that are important to you are picked out. This is done
using a simple declarative language (think the bastard child of SQL and
AWK).

## Usage

    stag STATEMENT
    stag -f file.stag

Ordinarily, one would provide the `stag` statement as a command line
argument. For readability and/or reproducibility's sake, the `stag`
statement can be loaded from file using the `-f` option.

By default, `stag` reads from standard input and would probably be used
as part of a Unix pipeline. It can be used to read from different
sources, by specifying as such in the `stag` statement. `stag` will run
until its input's EOF is reached, or it is terminated with Ctrl+D.

`stag` expects records to be EOL delimited (i.e., record-per-line), with
no additional "decoration" around records or fields. If that is not the
case, `sed` could be interposed to munge the input into the correct
format (for example, if parsing a CSV input, `sed` could strip leading
and trailing quotes, if any, and `stag`'s field separator could be set
to `/"?,"?/`).

For a full description of the `stag` language, please refer to the
formal specification. Otherwise, herein follows illustrative examples:

<!--
### Scalar Functions

#### String Functions

* `length(INPUT)` String length [Normalised Unicode characters? Bytes?]
* `substring(INPUT, X, Y)`
* ...

[Do we assume all input is UTF8?]

#### Mathematical Functions

* ...

#### Datetime Functions

* ...

[Others? Conditional expressions, like SQL CASE?...]

### Aggregation Functions

Function | Input Type         | Output Type        | Description
-------- | ------------------ | ------------------ | -------------------
`count`  | Any                | Numeric            | Count of input
`sum`    | Numeric            | Numeric            | Sum of input
`mean`   | Numeric            | Numeric            | Arithmetic mean of input
`max`    | Numeric / Datetime | Numeric / Datetime | Maximum input
`min`    | Numeric / Datetime | Numeric / Datetime | Minimum input
`first`  | Any                | Any                | First value in input
`last`   | Any                | Any                | Last value in input

[Others? Standard deviation? Median? Percentiles?...]
-->

## Example

Let's say your input looks like this:

    [Timestamp]  [IP Address]  [Some message]

Then the following:

    stag '$2, max($1) as "Latest" when not $2 = "127.0.0.1"'

Would show the latest hit timestamp, by IP address, for any non-local
connection. Or, say, if you wanted to see the total hit count bucketed
by hour:

    stag 'extract_hour($1) as "Hour", sum($2) as "Hits"'

Alternatively, if you have some text file named `foo.txt`, the following
will have the same result as `wc -l`:

    stag 'count($0) from "foo.txt"'

[Think of more/better examples!... Better yet, acquire potential use
cases and see if the language is sufficiently expressive to fulfil their
requirements...]

## License

Copyright (c) 2016 Genome Research Ltd.

This program is free software: you can redistribute it and/or modify it
under the terms of the GNU General Public License as published by the
Free Software Foundation, either version 3 of the License, or (at your
option) any later version.

This program is distributed in the hope that it will be useful, but
WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General
Public License for more details.

You should have received a copy of the GNU General Public License along
with this program. If not, see <http://www.gnu.org/licenses/>.
