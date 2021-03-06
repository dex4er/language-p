#!/usr/bin/perl -w

use strict;
use warnings;
use Test::More tests => 3;

use lib qw(t/lib);
use TestIntermediate qw(:all);

generate_tree_and_diff( <<'EOP', <<'EOI' );
$x = $a + 2;
print !$a
EOP
# main
L1:
  assign context=2 (global name="x", slot=1), (add context=4 (global name="a", slot=1), (constant_integer value=2))
  print context=2 (global name="STDOUT", slot=7), (make_array (not context=8 (global name="a", slot=1)))
  jump to=L2
L2:
  end
EOI

generate_tree_and_diff( <<'EOP', <<'EOI' );
$x = abs $t;
EOP
# main
L1:
  assign context=2 (global name="x", slot=1), (abs context=4 (global name="t", slot=1))
  jump to=L2
L2:
  end
EOI

generate_tree_and_diff( <<'EOP', <<'EOI' );
$x = "$a\n";
EOP
# main
L1:
  assign context=2 (global name="x", slot=1), (concat_assign context=4 (concat_assign context=4 (fresh_string value=""), (global name="a", slot=1)), (constant_string value="\x0a"))
  jump to=L2
L2:
  end
EOI
