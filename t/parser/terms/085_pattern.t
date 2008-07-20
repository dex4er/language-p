#!/usr/bin/perl -w

use strict;
use warnings;
use Test::More tests => 7;

use lib 't/lib';
use TestParser qw(:all);

parse_and_diff( <<'EOP', <<'EOE' );
/^test/;
EOP
root:
    class: Language::P::ParseTree::Pattern
    op: m
    components:
            class: Language::P::ParseTree::RXAssertion
            type: START
            class: Language::P::ParseTree::Constant
            value: test
            type: string
    flags: undef
EOE

parse_and_diff( <<'EOP', <<'EOE' );
m/^\ntest\w/;
EOP
root:
    class: Language::P::ParseTree::Pattern
    op: m
    components:
            class: Language::P::ParseTree::RXAssertion
            type: START
            class: Language::P::ParseTree::Constant
            value: 
test
            type: string
            class: Language::P::ParseTree::RXClass
            elements: WORDS
    flags: undef
EOE

parse_and_diff( <<'EOP', <<'EOE' );
$a =~ /^test/;
EOP
root:
    class: Language::P::ParseTree::BinOp
    op: =~
    left:
        class: Language::P::ParseTree::Symbol
        name: a
        sigil: $
    right:
        class: Language::P::ParseTree::Pattern
        op: m
        components:
                class: Language::P::ParseTree::RXAssertion
                type: START
                class: Language::P::ParseTree::Constant
                value: test
                type: string
        flags: undef
EOE

parse_and_diff( <<'EOP', <<'EOE' );
//ms;
EOP
root:
    class: Language::P::ParseTree::Pattern
    op: m
    components:
    flags:
        m
        s
EOE

parse_and_diff( <<'EOP', <<'EOE' );
/a*b+c?d*?b+?c??/;
EOP
root:
    class: Language::P::ParseTree::Pattern
    op: m
    components:
            class: Language::P::ParseTree::RXQuantifier
            node:
                class: Language::P::ParseTree::Constant
                value: a
                type: string
            min: 0
            max: -1
            greedy: 1
            class: Language::P::ParseTree::RXQuantifier
            node:
                class: Language::P::ParseTree::Constant
                value: b
                type: string
            min: 1
            max: -1
            greedy: 1
            class: Language::P::ParseTree::RXQuantifier
            node:
                class: Language::P::ParseTree::Constant
                value: c
                type: string
            min: 0
            max: 1
            greedy: 1
            class: Language::P::ParseTree::RXQuantifier
            node:
                class: Language::P::ParseTree::Constant
                value: d
                type: string
            min: 0
            max: -1
            greedy: 0
            class: Language::P::ParseTree::RXQuantifier
            node:
                class: Language::P::ParseTree::Constant
                value: b
                type: string
            min: 1
            max: -1
            greedy: 0
            class: Language::P::ParseTree::RXQuantifier
            node:
                class: Language::P::ParseTree::Constant
                value: c
                type: string
            min: 0
            max: 1
            greedy: 0
    flags: undef
EOE

parse_and_diff( <<'EOP', <<'EOE' );
/(a(cbc)??w)*/;
EOP
root:
    class: Language::P::ParseTree::Pattern
    op: m
    components:
            class: Language::P::ParseTree::RXQuantifier
            node:
                class: Language::P::ParseTree::RXGroup
                components:
                        class: Language::P::ParseTree::Constant
                        value: a
                        type: string
                        class: Language::P::ParseTree::RXQuantifier
                        node:
                            class: Language::P::ParseTree::RXGroup
                            components:
                                    class: Language::P::ParseTree::Constant
                                    value: cbc
                                    type: string
                        min: 0
                        max: 1
                        greedy: 0
                        class: Language::P::ParseTree::Constant
                        value: w
                        type: string
            min: 0
            max: -1
            greedy: 1
    flags: undef
EOE

parse_and_diff( <<'EOP', <<'EOE' );
qr/^test/;
EOP
root:
    class: Language::P::ParseTree::Pattern
    op: qr
    components:
            class: Language::P::ParseTree::RXAssertion
            type: START
            class: Language::P::ParseTree::Constant
            value: test
            type: string
    flags: undef
EOE
