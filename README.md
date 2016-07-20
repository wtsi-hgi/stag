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
sources (e.g., files), by specifying as such in the `stag` statement.
`stag` will run until its input's EOF is reached, or it is terminated
with Ctrl+D.

## `stag` Language

A `stag` statement is not dissimilar to an SQL `select ... group by ...`
statement. The grammar is defined using the following ABNF (per
RFC5234):

    ;; stag Statement

    statement        = [ from-clause ]
                       [ split-clause ]
                       "into" out-list
                       [ when-clause ]

    ;; From Clause

    from-clause      = "from" ( filepath / fd )
  
    filepath         = string-literal

    fd               = "&" 1*DIGIT

    ;; Split By Clause

    split-clause     = "split by" regex-literal

    ;; Output List

    out-list         = 1*( expression [ alias ] )

    alias            = "as" string-literal 

    expression       = expr-block / "(" expr-block ")"

    expr-block       = data
                     / literal
                     / prefix-fn 1*expression  ; per function arity
                     / expression infix-fn expression

    prefix-fn        = <Registered Functions and Aggregators>

    infix-fn         = "+" / "-" / "*" / "/"
                     ; Others? Bitwise operators; exponention; etc...

    ;; When Clause

    when-clause      = "when" condition

    condition        = logic-block / "(" logic-block ")"

    logic-block      = predicate *( junction condition )

    junction         = "and" / "or"

    predicate        = [ "not" ] expression test

    test             = ( "=" / "<" / ">" / "<=" / ">=" / "!=" ) expression
                     / "in" "(" 1*expression ")"
                     / "~=" regex-literal

    ;; Data References

    data             = col-id / record

    col-id           = "$" 1*DIGIT  ; 1-indexed

    record           = "$0"

    ;; Literals

    literal          = numeric-literal / string-literal / datetime-literal / regex-literal

    numeric-literal  = number [ "e" number ]

    number           = integer [ "." 1*DIGIT ]

    integer          = [ "-" ] 1*DIGIT

    string-literal   = DQUOTE <Escaped String> DQUOTE

    datetime-literal = DQUOTE <Timestamp per RFC3339> DQUOTE

    regex-literal    = "/" <PCRE Definition> "/"

    ;; Miscellaneous

    comment          = "#" <Everything until EOL>

    escaping         = "\" ( "n" \ "t" \ "\" \ "r" \ DQUOTE \ "u" 2*6HEXDIG )

A more complete description can [one day] be found in the documentation.

Notes:

* The `out-list` must contain at least one aggregation function,
  appropriately applied.

* If primary keys are not specified (i.e., `pk-list` omitted) then all
  non-aggregated columns in `out-list` are considered to be keys. [Is
  this a good idea? Are there instances where we need to be explicit
  about the grouping columns?...]

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

* [Note about having to use brackets when there's ambiguity in the
  parse, because there are no delimiters... Should there be
  delimiters?...]

## Example

Let's say your input looks like this:

    [Timestamp]  [IP Address]  [Some message]

Then the following:

    stag 'into $2 max $1 as "Latest" when not $2 = "127.0.0.1"'

Would show the latest hit timestamp, by IP address, for any non-local
connection. Or, say, if you wanted to see the total hit count bucketed
by hour:

    stag 'into hour $1 as "Hour" sum $2 as "Hits"'

Note that the primary key list has been omitted as it can be derived
from the output list. [See note above, re this being a good idea!]

Alternatively, if you have some text file named `foo.txt`, the following
will have the same result as `wc -l`:

    stag 'from "foo.txt" into count $0'

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
