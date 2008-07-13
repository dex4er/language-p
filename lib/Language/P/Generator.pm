package Language::P::Generator;

use strict;
use warnings;
use base qw(Class::Accessor::Fast);

__PACKAGE__->mk_ro_accessors( qw(runtime) );

use Language::P::Opcodes qw(o);
use Language::P::Value::StringNumber;
use Language::P::Value::Handle;
use Language::P::Value::ScratchPad;

# HACK
our @bytecode;
our %labels;
our %patch;
our $label_count = 0;

sub _new_label {
    ++$label_count;
    $labels{$label_count} = undef;

    return $label_count;
}

sub _set_label {
    my( $label, $to ) = @_;

    die if $labels{$label};
    $labels{$label} = $to;

    $_->{to} = $to foreach @{$patch{$label} || []};
    delete $patch{$label};
}

sub _to_label {
    my( $label, $op ) = @_;

    $op->{to} = $labels{$label} if $labels{$label};
    push @{$patch{$label} ||= []}, $op;
}

my @codes;

sub push_code {
    my( $self, $code ) = @_;

    push @codes, $code;

    # TODO do not use global
    *bytecode = $code->bytecode;
}

sub pop_code {
    my( $self, $code ) = @_;

    pop @codes;

    # TODO do not use global
    *bytecode = @codes ? $codes[-1]->bytecode : [];
}

sub process {
    my( $self, $tree ) = @_;

#     use Data::Dumper;
#     print Dumper( $tree );
    $self->dispatch( $tree );

    return;
}

sub finished {
    my( $self ) = @_;

    $self->_allocate_lexicals;

    if( $codes[-1]->isa( 'Language::P::Value::Subroutine' ) ) {
        push @bytecode, o( 'return' );
    } else {
        push @bytecode, o( 'end' );
    }
}

my %dispatch =
  ( FunctionCall           => '_function_call',
    Builtin                => '_function_call',
    Overridable            => '_function_call',
    BinOp                  => '_binary_op',
    Constant               => '_constant',
    Symbol                 => '_symbol',
    LexicalDeclaration     => '_lexical_declaration',
    LexicalSymbol          => '_lexical_declaration',
    List                   => '_list',
    Conditional            => '_cond',
    ConditionalLoop        => '_cond_loop',
    Ternary                => '_ternary',
    Block                  => '_block',
    Subroutine             => '_subroutine',
    QuotedString           => '_quoted_string',
    );

my %dispatch_cond =
  ( BinOp          => '_binary_op_cond',
    );

sub dispatch {
    my( $self, $tree ) = @_;
    ( my $pack = ref $tree ) =~ s/^.*:://;
    my $meth = $dispatch{$pack};

#     use Data::Dumper;
#     print Dumper( $tree );
    Carp::confess( $pack ) unless $meth;

    $self->$meth( $tree );
}

sub dispatch_cond {
    my( $self, $tree, $true, $false ) = @_;
    ( my $pack = ref $tree ) =~ s/^.*:://;
    my $meth = $dispatch_cond{$pack} || '_anything_cond';

#     use Data::Dumper;
#     print Dumper( $tree );
    die $pack unless $meth;

    $self->$meth( $tree, $true, $false );
}

my %reverse_conditionals =
  ( '<'      => '>=',
    '>'      => '<=',
    '<='     => '>',
    '>='     => '<',
    '=='     => '!=',
    '!='     => '==',
    );

my %conditionals =
  ( '<'      => 'compare_i_lt_int',
    'lt'     => 'compare_s_lt_int',
    '>'      => 'compare_i_gt_int',
    'gt'     => 'compare_s_gt_int',
    '<='     => 'compare_i_le_int',
    'le'     => 'compare_s_le_int',
    '>='     => 'compare_i_ge_int',
    'ge'     => 'compare_s_ge_int',
    '=='     => 'compare_i_eq_int',
    'eq'     => 'compare_s_eq_int',
    '!='     => 'compare_i_ne_int',
    'ne'     => 'compare_s_ne_int',
    );

my %short_circuit =
  ( '&&'     => 'jump_if_false',
    '||'     => 'jump_if_true',
    );

my %builtins =
  ( print    => 'print',
    return   => 'return',
    unlink   => 'unlink',
    %short_circuit,
    '+'      => 'add',
    '*'      => 'multiply',
    '-'      => 'subtract',
    '='      => 'assign',
    '=='     => 'compare_i_eq_scalar',
    'eq'     => 'compare_s_eq_scalar',
    '!='     => 'compare_i_ne_scalar',
    'ne'     => 'compare_s_ne_scalar',
    );

sub _function_call {
    my( $self, $tree ) = @_;

    push @bytecode, o( 'start_call' );

    if( $tree->function eq 'print' ) {
        # FIXME HACK, must create a builtin node type
        my $out = Language::P::Value::Handle->new( { handle => \*STDOUT } );
        push @bytecode, o( 'constant', value => $out ),
                        o( 'push_scalar' );
    }

    foreach my $arg ( @{$tree->arguments} ) {
        $self->dispatch( $arg );
        # FIXME HACK
        push @bytecode, o( 'push_scalar' );
    }

    if( $builtins{$tree->function} ) {
        push @bytecode, o( $builtins{$tree->function} );
    } else {
        push @bytecode,
             o( 'glob',      name => $tree->function, create => 1 ),
             o( 'glob_slot', slot => 'subroutine' ),
             o( 'call' );
    }
}

sub _list {
    my( $self, $tree ) = @_;

    push @bytecode, o( 'start_list' );

    foreach my $arg ( @{$tree->expressions} ) {
        $self->dispatch( $arg );
        # HACK
        push @bytecode, o( 'push_scalar' );
    }
}

sub _binary_op {
    my( $self, $tree ) = @_;

    die $tree->op unless $builtins{$tree->op};

    if( $short_circuit{$tree->op} ) {
        $self->dispatch( $tree->left );

        my $end = _new_label;

        # jump to $end if evalutating right is not necessary
        push @bytecode,
             o( 'dup' ),
             o( $short_circuit{$tree->op} );
        _to_label( $end, $bytecode[-1] );

        # evalutates right only if this is the correct return value
        $self->dispatch( $tree->right );

        _set_label( $end, scalar @bytecode );
    } else {
        $self->dispatch( $tree->right );
        $self->dispatch( $tree->left );

        push @bytecode, o( $builtins{$tree->op} );
    }
}

sub _binary_op_cond {
    my( $self, $tree, $true, $false ) = @_;

    if( !$conditionals{$tree->op} ) {
        _anything_cond( $self, $tree, $true, $false );
    }

    $self->dispatch( $tree->right );
    $self->dispatch( $tree->left );

    push @bytecode, o( $conditionals{$tree->op} );
    # jump to $false if false, fall trough if true
    push @bytecode, o( 'jump_if_eq_immed', value => 0 );
    _to_label( $false, $bytecode[-1] );
}

sub _anything_cond {
    my( $self, $tree, $true, $false ) = @_;

    $self->dispatch( $tree );

    # jump to $false if false, fall trough if true
    push @bytecode, o( 'jump_if_false' );
    _to_label( $false, $bytecode[-1] );
}

sub _constant {
    my( $self, $tree ) = @_;
    my $type = $tree->type;
    my $v;

    if( $type eq 'number' ) {
        $v = Language::P::Value::StringNumber->new( { integer => $tree->value } );
    } elsif( $type eq 'string' ) {
        $v = Language::P::Value::StringNumber->new( { string => $tree->value } );
    } else {
        die $type;
    }

    push @bytecode, o( 'constant', value => $v );
}

my %sigils =
  ( '$' => 'scalar',
    '&' => 'subroutine',
    );

sub _symbol {
    my( $self, $tree ) = @_;

    my $slot = $sigils{$tree->sigil};
    die $tree->sigil unless $slot;

    push @bytecode,
         o( 'glob',             name => $tree->name, create => 1 ),
         o( 'glob_slot_create', slot => $slot );
}

sub _lexical_declaration {
    my( $self, $tree ) = @_;

    die unless defined $tree->{slot}->{level};
#     use Data::Dumper;
#     print Dumper $tree;
    my $in_pad = $tree->{slot}->{slot}->{in_pad};
    push @bytecode,
        o( $in_pad ? 'lexical_pad' : 'lexical',
           lexical  => $tree->{slot}->{slot},
           level    => $tree->{slot}->{level},
           );
}

sub _cond_loop {
    my( $self, $tree ) = @_;

    die $tree->block_type unless $tree->block_type eq 'while';

    my( $start, $true, $false ) = ( _new_label, _new_label, _new_label );
    _set_label( $start, scalar @bytecode );

    $self->dispatch_cond( $tree->condition, $true, $false );
    _set_label( $true, scalar @bytecode );
    $self->dispatch( $tree->block );
    push @bytecode, o( 'jump' );
    _to_label( $start, $bytecode[-1] );
    _set_label( $false, scalar @bytecode );
}

sub _cond {
    my( $self, $tree ) = @_;

    die if $tree->iftrues->[0]->[0] ne 'if';

    my $end = _new_label;
    foreach my $elsif ( @{$tree->iftrues} ) {
        my( $true, $false ) = ( _new_label, _new_label );
        $self->dispatch_cond( $elsif->[1], $true, $false );
        _set_label( $true, scalar @bytecode );
        $self->dispatch( $elsif->[2] );
        push @bytecode, o( 'jump' );
        _to_label( $end, $bytecode[-1] );
        _set_label( $false, scalar @bytecode );
    }
    if( $tree->iffalse ) {
        $self->dispatch( $tree->iffalse->[2] );
    }
    _set_label( $end, scalar @bytecode );
}

sub _ternary {
    my( $self, $tree ) = @_;

    my( $end, $true, $false ) = ( _new_label, _new_label, _new_label );
    $self->dispatch_cond( $tree->condition, $true, $false );
    _set_label( $true, scalar @bytecode );
    $self->dispatch( $tree->iftrue );
    push @bytecode, o( 'jump' );
    _to_label( $end, $bytecode[-1] );
    _set_label( $false, scalar @bytecode );

    $self->dispatch( $tree->iffalse );

    _set_label( $end, scalar @bytecode );
}

sub _block {
    my( $self, $tree ) = @_;

    foreach my $line ( @{$tree->lines} ) {
        $self->dispatch( $line );
    }
}

sub _subroutine {
    my( $self, $tree ) = @_;

    my $sub = Language::P::Value::Subroutine->new
                  ( { bytecode => [],
                      name     => $tree->name,
                      } );
    $self->push_code( $sub );

    foreach my $line ( @{$tree->lines} ) {
        $self->dispatch( $line );
    }

    $self->finished;
    $self->pop_code;

    $self->runtime->symbol_table->set_symbol( $tree->name, '&', $sub );
}

sub _quoted_string {
    my( $self, $tree ) = @_;

    if( @{$tree->components} == 1 ) {
        $self->dispatch( $tree->components->[0] );

        push @bytecode, o( 'stringify' );

        return;
    }

    $self->dispatch( $tree->components->[-1] );
    for( my $i = @{$tree->components} - 2; $i >= 0; --$i ) {
        $self->dispatch( $tree->components->[$i] );

        push @bytecode, o( 'concat' );
    }
}

sub _allocate_lexicals {
    my( $self ) = @_;

    my $pad = Language::P::Value::ScratchPad->new;
    my $has_pad;
    foreach my $op ( @bytecode ) {
        next if !$op->{lexical};

#         use Data::Dumper;
#         print Dumper $op;

        # FIXME make the lexical slot an object with accessors
        if( $op->{level} == 0 && $op->{lexical}->{index} == -100 ) {
            if( $op->{lexical}->{in_pad} ) {
                if( !$has_pad ) {
                    $codes[-1]->{lexicals} = $pad;
                    $pad->{outer} = $codes[-1]->{outer};
                    $has_pad = 1;
                }
                $op->{lexical}->{index} = $pad->add_value;
            } else {
                $op->{lexical}->{index} = $codes[-1]->stack_size;
                ++$codes[-1]->{stack_size};
            }
        }

        $op->{in_pad} = $op->{lexical}->{in_pad};
        $op->{index} = $op->{lexical}->{index};
        delete $op->{lexical};
    }
}

1;
