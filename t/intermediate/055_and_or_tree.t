#!/usr/bin/perl -w

use strict;
use warnings;
use Test::More tests => 4;

use lib qw(t/lib);
use TestIntermediate qw(:all);

generate_tree_and_diff( <<'EOP', <<'EOI' );
$x = $a && $b;
EOP
# main
L1:
  set index=1 (global name="a", slot=1)
  jump_if_true to=L2 (get index=1)
  jump to=L4
L2:
  set index=2 (global name="b", slot=1)
  set index=3 (get index=2)
  jump to=L3
L3:
  assign (global name="x", slot=1), (get index=3)
  end
L4:
  set index=3 (get index=1)
  jump to=L3
EOI

generate_tree_and_diff( <<'EOP', <<'EOI' );
$x = $a || $b;
EOP
# main
L1:
  set index=1 (global name="a", slot=1)
  jump_if_true to=L4 (get index=1)
  jump to=L2
L2:
  set index=2 (global name="b", slot=1)
  set index=3 (get index=2)
  jump to=L3
L3:
  assign (global name="x", slot=1), (get index=3)
  end
L4:
  set index=3 (get index=1)
  jump to=L3
EOI

generate_tree_and_diff( <<'EOP', <<'EOI' );
$x = $a && $b && $c;
EOP
# main
L1:
  set index=1 (global name="a", slot=1)
  jump_if_true to=L2 (get index=1)
  jump to=L6
L2:
  set index=2 (global name="b", slot=1)
  set index=3 (get index=2)
  jump to=L3
L3:
  jump_if_true to=L4 (get index=3)
  jump to=L7
L4:
  set index=4 (global name="c", slot=1)
  set index=5 (get index=4)
  jump to=L5
L5:
  assign (global name="x", slot=1), (get index=5)
  end
L6:
  set index=3 (get index=1)
  jump to=L3
L7:
  set index=5 (get index=3)
  jump to=L5
EOI

generate_tree_and_diff( <<'EOP', <<'EOI' );
$x = $a || $b || $c;
EOP
# main
L1:
  set index=1 (global name="a", slot=1)
  jump_if_true to=L6 (get index=1)
  jump to=L2
L2:
  set index=2 (global name="b", slot=1)
  set index=3 (get index=2)
  jump to=L3
L3:
  jump_if_true to=L7 (get index=3)
  jump to=L4
L4:
  set index=4 (global name="c", slot=1)
  set index=5 (get index=4)
  jump to=L5
L5:
  assign (global name="x", slot=1), (get index=5)
  end
L6:
  set index=3 (get index=1)
  jump to=L3
L7:
  set index=5 (get index=3)
  jump to=L5
EOI
