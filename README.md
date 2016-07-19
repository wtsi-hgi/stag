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

## `stag` Language

    statement     = [ pk_list ]
                    [ from_clause ]
                    [ split_clause ]
                    "into" out_list
                    [ when_clause ]

    pk_list       = 1*col_id

    from_clause   = "from" ( filepath / fd )

    split_clause  = "split by" regex

    out_list      = 1*( aggregate_col [ alias ] )
                    *( col_id [ alias ] )
    
    when_clause   = "when" condition

    condition     = logic_block / "(" logic_block ")"

    logic_block   = predicate *( junction condition )

    predicate     = [ "not" ] col_id comparitor ( col_id / LITERAL )

    junction      = "and" / "or"

    comparitor    = "=" / "<" / ">" / "<=" / ">=" / "!=" / "~="

    aggregate_col = AGGREGATOR "(" col_id ")"

    col_id        = "$" 1*DIGIT
                  ; 1-indexed, $0 matches the whole record

    alias         = "as" STRING

    regex         = "/" REGEX "/"

    filepath      = STRING

    fd            = "&" 1*DIGIT

    AGGREGATOR    = "sum" / "count" / "mean" / "stdev" / "max" / "min"
                  ; others?...

    ; The following are not yet well-defined...

    REGEX         = <PCRE definition>

    STRING        = <Keyword or quoted string>

    LITERAL       = <Duck-typed literal>

Note that the `out_list` must contain at least one aggregated column,
however the order doesn't matter (contrary to the above definition).

If primary keys are not specified (i.e., `pk_list` omitted) then all
non-aggregated columns in `out_list` are considered to be keys.

If the `from_clause` is omitted, then it defaults to `from &0` (i.e.,
read from stdin).

If the `split_clause` is omitted, then it defaults to
`split by /\t|\s{2,}/` (i.e., split on tabs or two-or-more whitespaces).

The `~=` operator is for regular expression matches.

## Example

Let's say your input looks like this:

    [Timestamp]  [IP Address]  [Some message]

Then the following:

    stag '$2 into $2 max($1) as "Latest" when not $2 = "127.0.0.1"'

Would show the latest hit, by IP address, for any non-local connection.

Alternatively, if you have some text file named `foo.txt`, the following
will have the same result as `wc -l`:

    stag 'from foo.txt into count($0)'

[Think of better examples!...]

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
