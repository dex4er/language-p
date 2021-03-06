#!/usr/bin/perl -w

print "1..46\n";

$text = 'abbcccddddeeeeeffffff';

# match
print $text =~ /^a/ ? "ok\n" : "not ok\n";
print $text =~ /bc/ ? "ok\n" : "not ok\n";
print $text =~ /de+f/ ? "ok\n" : "not ok\n";

# not match
print $text !~ /bac/ ? "ok\n" : "not ok\n";

# empty quantifier
print "" =~ /a*/ ? "ok\n" : "not ok\n";

# quantifiers
print $text =~ /eg*f/ ? "ok\n" : "not ok\n";
print $text =~ /eg?f/ ? "ok\n" : "not ok\n";
print $text !~ /g+f/ ? "ok\n" : "not ok\n";

# quantified group
print $text =~ /(a|b)*/ ? "ok\n" : "not ok\n";

# alternation
print $text =~ /(a|b|c)d/ ? "ok\n" : "not ok\n";

# character classes
print $text =~ /^([ab]+)/ ? "ok\n" : "not ok\n";
print $1 eq 'abb' ? "ok\n" : "not ok - $1\n";

# dot
print "aaa" =~ /a.a/ ? "ok\n" : "not ok\n";
print "a\na" =~ /a.a/ ? "not ok\n" : "ok\n";
print "a\na" =~ /a.a/s ? "ok\n" : "not ok\n";

# special classes
print "a" =~ /\w/ ? "ok\n" : "not ok\n";
print "!" =~ /\w/ ? "not ok\n" : "ok\n";
print "!" =~ /[\w!]/ ? "ok\n" : "not ok\n";
print "a" =~ /[\w!]/ ? "ok\n" : "not ok\n";
print "?" =~ /[\w!]/ ? "not ok\n" : "ok\n";
print "?" =~ /\W/ ? "ok\n" : "not ok\n";
print "1" =~ /\d/ ? "ok\n" : "not ok\n";
print "1" =~ /\D/ ? "not ok\n" : "ok\n";
print " " =~ /\s/ ? "ok\n" : "not ok\n";
print " " =~ /\S/ ? "not ok\n" : "ok\n";

# captures
print $text =~ /(a|b|c)d/ ? "ok\n" : "not ok\n";
print $1 eq 'c' ? "ok\n" : "not ok\n";

{
    $text =~ /(not match)/;

    print $1 eq 'c' ? "ok\n" : "not ok\n";

    print $text =~ /(d+)(e+)/ ? "ok\n" : "not ok\n";
    print $1 eq 'dddd' ? "ok\n" : "not ok\n";
    print $2 eq 'eeeee' ? "ok\n" : "not ok\n";
}

print $1 eq 'c' ? "ok\n" : "not ok - $1\n";

# captures in list context
@x = $text =~ /((b|c)+)/;

print "$x[0] $x[1]" eq "bbccc c" ? "ok\n" : "not ok - $x[0] $x[1]\n";

# global match in list context
@x = $text =~ /b+|d+|f+/g;

print "$x[0] $x[1] $x[2]" eq "bb dddd ffffff" ? "ok\n" : "not ok - $x[0] $x[1] $x[2]\n";
print defined pos $text ? "not ok\n" : "ok\n";

# global match in scalar context
pos $text = undef; # in case the test above fails
print $text =~ /b+|d+|f+/g ? "ok\n" : "not ok\n";
print pos $text == 3 ? "ok\n" : "not ok\n";

print $text =~ /b+|d+|f+/g ? "ok\n" : "not ok\n";
print pos $text == 10 ? "ok\n" : "not ok\n";

print $text =~ /b+|d+|f+/g ? "ok\n" : "not ok\n";
print pos $text == 21 ? "ok\n" : "not ok\n";

print $text =~ /b+|d+|f+/gc ? "not ok\n" : "ok\n";
print pos $text == 21 ? "ok\n" : "not ok\n";

print $text =~ /b+|d+|f+/g ? "not ok\n" : "ok\n";
print defined pos $text ? "not ok\n" : "ok\n";

# global match the empty string
++$x, "\n" while $text =~ /z*/g;
print $x == 22 ? "ok\n" : "not ok - $x\n";
