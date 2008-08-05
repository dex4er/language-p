#!/usr/bin/perl -w

use strict;
use warnings;
use Test::More tests => 4;

use lib 't/lib';
use TestParser qw(:all);

parse_and_diff_yaml( <<'EOP', <<'EOE' );
1 ? 2 : 3
EOP
--- !parsetree:Ternary
condition: !parsetree:Number
  flags: NUM_INTEGER
  type: number
  value: 1
context: CXT_VOID
iffalse: !parsetree:Number
  flags: NUM_INTEGER
  type: number
  value: 3
iftrue: !parsetree:Number
  flags: NUM_INTEGER
  type: number
  value: 2
EOE

parse_and_diff_yaml( <<'EOP', <<'EOE' );
$a = 1 ? 2 : 3
EOP
--- !parsetree:BinOp
context: CXT_VOID
left: !parsetree:Symbol
  context: CXT_SCALAR|CXT_LVALUE
  name: a
  sigil: $
op: =
right: !parsetree:Ternary
  condition: !parsetree:Number
    flags: NUM_INTEGER
    type: number
    value: 1
  context: CXT_SCALAR
  iffalse: !parsetree:Number
    flags: NUM_INTEGER
    type: number
    value: 3
  iftrue: !parsetree:Number
    flags: NUM_INTEGER
    type: number
    value: 2
EOE

parse_and_diff_yaml( <<'EOP', <<'EOE' );
$a = 1 < 2 ? 2 + 3 : 3 + 4
EOP
--- !parsetree:BinOp
context: CXT_VOID
left: !parsetree:Symbol
  context: CXT_SCALAR|CXT_LVALUE
  name: a
  sigil: $
op: =
right: !parsetree:Ternary
  condition: !parsetree:BinOp
    context: CXT_SCALAR
    left: !parsetree:Number
      flags: NUM_INTEGER
      type: number
      value: 1
    op: <
    right: !parsetree:Number
      flags: NUM_INTEGER
      type: number
      value: 2
  context: CXT_SCALAR
  iffalse: !parsetree:BinOp
    context: CXT_SCALAR
    left: !parsetree:Number
      flags: NUM_INTEGER
      type: number
      value: 3
    op: +
    right: !parsetree:Number
      flags: NUM_INTEGER
      type: number
      value: 4
  iftrue: !parsetree:BinOp
    context: CXT_SCALAR
    left: !parsetree:Number
      flags: NUM_INTEGER
      type: number
      value: 2
    op: +
    right: !parsetree:Number
      flags: NUM_INTEGER
      type: number
      value: 3
EOE

parse_and_diff_yaml( <<'EOP', <<'EOE' );
$x ? $a = 1 : $b = 2;
EOP
--- !parsetree:BinOp
context: CXT_VOID
left: !parsetree:Ternary
  condition: !parsetree:Symbol
    context: CXT_SCALAR
    name: x
    sigil: $
  context: CXT_SCALAR|CXT_LVALUE
  iffalse: !parsetree:Symbol
    context: CXT_SCALAR|CXT_LVALUE
    name: b
    sigil: $
  iftrue: !parsetree:BinOp
    context: CXT_SCALAR|CXT_LVALUE
    left: !parsetree:Symbol
      context: CXT_SCALAR|CXT_LVALUE
      name: a
      sigil: $
    op: =
    right: !parsetree:Number
      flags: NUM_INTEGER
      type: number
      value: 1
op: =
right: !parsetree:Number
  flags: NUM_INTEGER
  type: number
  value: 2
EOE
