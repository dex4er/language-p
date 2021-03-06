package Language::P::Constants;

use strict;
use warnings;
use Exporter 'import';

our @EXPORT_OK =
  ( qw(NUM_INTEGER NUM_FLOAT NUM_HEXADECIMAL NUM_OCTAL NUM_BINARY
       STRING_BARE CONST_STRING CONST_NUMBER

       CXT_CALLER CXT_VOID CXT_SCALAR CXT_LIST CXT_LVALUE
       CXT_VIVIFY CXT_CALL_MASK

       PROTO_DEFAULT PROTO_SCALAR PROTO_ARRAY PROTO_HASH PROTO_SUB
       PROTO_GLOB PROTO_REFERENCE PROTO_BLOCK PROTO_AMPER PROTO_ANY
       PROTO_INDIROBJ PROTO_FILEHANDLE PROTO_MAKE_GLOB PROTO_MAKE_ARRAY
       PROTO_MAKE_HASH PROTO_DEFAULT_ARG PROTO_PATTERN

       FLAG_IMPLICITARGUMENTS FLAG_ERASEFRAME
       FLAG_RX_MULTI_LINE FLAG_RX_SINGLE_LINE FLAG_RX_CASE_INSENSITIVE
       FLAG_RX_FREE_FORMAT FLAG_RX_ONCE FLAG_RX_GLOBAL FLAG_RX_KEEP
       FLAG_RX_EVAL FLAG_RX_COMPLEMENT FLAG_RX_DELETE FLAG_RX_SQUEEZE

       VALUE_SCALAR VALUE_ARRAY VALUE_HASH VALUE_SUB VALUE_GLOB VALUE_HANDLE
       VALUE_ARRAY_LENGTH VALUE_LIST VALUE_ITERATOR

       DECLARATION_MY DECLARATION_OUR DECLARATION_STATE
       DECLARATION_CLOSED_OVER

       CHANGED_HINTS CHANGED_WARNINGS CHANGED_PACKAGE CHANGED_ALL) );
our %EXPORT_TAGS =
  ( all => \@EXPORT_OK,
    );

use constant
  { # numeric/string constants
    CONST_STRING       => 1,
    CONST_NUMBER       => 2,

    STRING_BARE        => 4,

    NUM_INTEGER        => 8,
    NUM_FLOAT          => 16,
    NUM_HEXADECIMAL    => 32,
    NUM_OCTAL          => 64,
    NUM_BINARY         => 128,

    # context
    CXT_CALLER         => 1,
    CXT_VOID           => 2,
    CXT_SCALAR         => 4,
    CXT_LIST           => 8,
    CXT_LVALUE         => 16,
    CXT_VIVIFY         => 32,
    CXT_CALL_MASK      => 1|2|4|8,

    PROTO_SCALAR       => 1,
    PROTO_ARRAY        => 2,
    PROTO_HASH         => 4,
    PROTO_SUB          => 8,
    PROTO_GLOB         => 16,
    PROTO_ANY          => 1|2|4|8|16,
    PROTO_REFERENCE    => 32,      # \<something> prototype
    PROTO_BLOCK        => 64,      # eval {}
    PROTO_AMPER        => 128,     # defined &foo, exists &foo
    PROTO_INDIROBJ     => 256,     # map/grep
    PROTO_FILEHANDLE   => 512,     # print/printf
    PROTO_MAKE_ARRAY   => 1024|2,  # push a
    PROTO_MAKE_HASH    => 1024|4,  # keys a
    PROTO_MAKE_GLOB    => 1024|16, # pipe a, a
    PROTO_DEFAULT_ARG  => 2048,    # adds $_ if no arg specified
    PROTO_PATTERN      => 4096,    # split /foo/
    PROTO_DEFAULT      => [ -1, -1, 0, 2 ],

    # sigils, anonymous array/hash constructors, dereferences
    VALUE_SCALAR       => 1,
    VALUE_ARRAY        => 2,
    VALUE_HASH         => 3,
    VALUE_SUB          => 4,
    VALUE_GLOB         => 5,
    VALUE_ARRAY_LENGTH => 6,
    VALUE_HANDLE       => 7,
    VALUE_LIST         => 8, # for list slices only
    VALUE_ITERATOR     => 9, # used as a marker by the IR generator

    # function calls
    FLAG_IMPLICITARGUMENTS => 1,
    FLAG_ERASEFRAME        => 2,

    # regular expressions
    FLAG_RX_MULTI_LINE       => 1,
    FLAG_RX_SINGLE_LINE      => 2,
    FLAG_RX_CASE_INSENSITIVE => 4,
    FLAG_RX_FREE_FORMAT      => 8,
    FLAG_RX_ONCE             => 16,
    FLAG_RX_GLOBAL           => 32,
    FLAG_RX_KEEP             => 64,
    FLAG_RX_EVAL             => 128,
    FLAG_RX_COMPLEMENT       => 1,
    FLAG_RX_DELETE           => 2,
    FLAG_RX_SQUEEZE          => 4,

    # declarations
    DECLARATION_MY           => 1,
    DECLARATION_OUR          => 2,
    DECLARATION_STATE        => 4,
    DECLARATION_CLOSED_OVER  => 8,
    DECLARATION_TYPE_MASK    => 7,

    # lexical state
    CHANGED_HINTS      => 1,
    CHANGED_WARNINGS   => 2,
    CHANGED_PACKAGE    => 4,
    CHANGED_ALL        => 7,
    };

1;
