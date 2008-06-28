#!/usr/bin/perl -w

use strict;
use warnings;
use Test::More tests => 1;

use lib 't/lib';
use TestParser qw(:all);

parse_and_diff( <<'EOP', <<'EOE' );
$x = 1;
EOP
root:
    class: Language::P::ParseTree::BinOp
    op: =
    left:
        class: Language::P::ParseTree::Symbol
        name: x
        sigil: $
    right:
        class: Language::P::ParseTree::Constant
        value: 1
        type: number
EOE
