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

    statement := [pk_list]
                 [from_clause]
                 [split_clause]
                 "into" out_list
                 [when_clause]

    pk_list := col_id+

    from_clause := "from" <filename>

    split_clause := "split by" /<regular expression>/

    out_list := (col_id ["as" <alias>])+

    when_clause := <conditions...>

(n.b., `out_list` must contain at least one aggregate function)

## Examples

[Examples here]

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
