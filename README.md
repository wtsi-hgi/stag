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
format (for example, if parsing a CSV file, `sed` could strip leading
and trailing quotes, if any, and `stag`'s field separator could be set
to `/"?,"?/`).

## `stag` Language

A `stag` statement is not dissimilar to an SQL `select ... group by ...`
statement. The grammar is defined using the following ABNF (per
RFC5234):

    ;; stag Statement

    statement        = out-list
                       [ from-clause ]
                       [ split-clause ]
                       [ when-clause ]
                       [ sort-clause ]
                       [ extend-clause ]

    ;; Output List

    out-list         = out-column *( "," out-column )

    out-column       = expression [ alias ]

    alias            = "as" string-literal 

    expression       = expr-block / "(" expr-block ")"

    expr-block       = data
                     / literal
                     / prefix-fn
                     / expression infix-fn expression

    prefix-fn        = symbol_literal "(" [ arg_list ] ")"

    arg-list         = expression *( "," expression )

    infix-fn         = "+"  ; Addition / Concatenation
                     / "-" / "*" / "/" / "%" / "^"  ; Arithmetic

    ;; From Clause

    from-clause      = "from" ( filepath / fd )
  
    filepath         = string-literal

    fd               = "&" 1*DIGIT

    ;; Split By Clause

    split-clause     = "split by" regex-literal

    ;; When Clause

    when-clause      = "when" condition

    condition        = logic-block / "(" logic-block ")"

    logic-block      = predicate *( junction condition )

    junction         = "and" / "or"

    predicate        = [ "not" ] expression test

    test             = ( "=" / "<" / ">" / "<=" / ">=" / "!=" ) expression
                     / "in" "(" arg-list ")"
                     / "~=" regex-literal

    ;; Sort Clause

    sort-clause      = "sort on" sort-column *( "," sort-column )

    sort-column      = column-ref [ sort-order ]

    sort-order       = "asc" / "desc"

    ;; Extension Clause

    extend-clause    = "using" 1*filepath

    ;; Data References

    data             = column-id / record

    column-id        = "$" 1*DIGIT  ; 1-indexed

    column-ref       = "%" 1*DIGIT  ; 1-indexed of output columns

    record           = "$0"

    ;; Literals

    literal          = numeric-literal / string-literal / datetime-literal / regex-literal

    numeric-literal  = number [ "e" number ]

    number           = integer [ "." 1*DIGIT ]

    integer          = [ "-" ] 1*DIGIT

    string-literal   = DQUOTE <Escaped String> DQUOTE

    datetime-literal = DQUOTE <Timestamp per RFC3339> DQUOTE

    regex-literal    = "/" <PCRE Definition> "/"

    symbol_literal   = ( ALPHA / "_" ) *( ALPHA / DIGIT / "_" )

    ;; Miscellaneous

    comment          = "#" <Everything until EOL>

    escaping         = "\" ( "n" \ "t" \ "\" \ "r" \ DQUOTE \ "u" 2*6HEXDIG )

A more complete description can [one day] be found in the documentation.

Notes:

* All keywords (except registered functions) are case-insensitive.
  Whitespace rules aren't mentioned above, but follow normal/familiar
  expectations.

* The `out-list` must contain at least one aggregation function,
  appropriately applied.

* Unlike SQL, there is no `group by` clause, as this can be inferred
  from the `out-list`. If scalar columns form part of the `out-list`
  then these define the grouping tuple; otherwise, aggregation will be
  applied to all records.

* If the `from-clause` is omitted, then it defaults to `from &0` (i.e.,
  read from stdin).

* If the `split-clause` is omitted, then it defaults to
  `split by /\t|\s{2,}/` (i.e., split on tabs or two-or-more
  whitespaces).

* Date/time stamps are per RFC3339, using any of the rules: `date-time`,
  `full-time`, `partial-time` or `full-date`.

* All column data comes in as a string, but duck typed when used in,
  say, a comparator according to the literal. [Write up how type
  coercion should work...]

* There is no equivalent of the SQL `having` clause as `stag` is
  designed for interactive use, inasmuch as it provides a live
  aggregation of the stream. If, however, it is a non-terminal element
  of a pipeline -- and the stream terminates -- something like `awk`
  could be used to provide such post-aggregation filtering.

* The extension clause allows the definition of custom scalar and
  aggregation functions, imported from an external source files. [Custom
  functions should be written in Racket?]

### Scalar Functions

...

### Aggregation Functions

...

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
