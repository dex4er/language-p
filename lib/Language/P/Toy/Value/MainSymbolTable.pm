package Language::P::Toy::Value::MainSymbolTable;

use strict;
use warnings;
use base qw(Language::P::Toy::Value::SymbolTable);

use Language::P::Toy::Value::ActiveScalar;
use Language::P::Toy::Value::StringNumber;

sub is_main { 1 }

my %special_names =
  ( # H
    "\010"             => 1,
    # O
    "\017"             => 1,
    # W
    "\027ARNING_BITS"  => 1,
    );
our %sigils; *sigils = \%Language::P::Toy::Value::SymbolTable::sigils;

sub new {
    my( $class, $runtime, $args ) = @_;
    my $self = $class->SUPER::new( $runtime, $args );

    my $out = Language::P::Toy::Value::Handle->new( $runtime, { handle => \*STDOUT } );
    $self->set_symbol( $runtime, 'STDOUT', 'I', $out );

    my $interpreter = Language::P::Toy::Value::Scalar->new_string( $runtime, $^X );
    $self->set_symbol( $runtime, "\030", '$', $interpreter );

    my $inc = Language::P::Toy::Value::Array->new( $runtime );
    $inc->push_value( $runtime, Language::P::Toy::Value::Scalar->new_string( $runtime, '.' ) );
    $self->set_symbol( $runtime, 'INC', '@', $inc );

    return $self;
}

sub _tied_to_rt_variable {
    my( $runtime, $name ) = @_;

    my $get = sub {
        return Language::P::Toy::Value::StringNumber->new
                   ( $runtime,
                     { string => $runtime->{_variables}->{$name},
                       } );
    };

    return Language::P::Toy::Value::ActiveScalarCallbacks->new
               ( $runtime,
                 { get_callback => $get,
                   } )
}

sub _tied_to_rt_methods {
    my( $runtime, $get_m, $set_m ) = @_;

    my $get = sub {
        return $runtime->$get_m;
    };

    my $set = sub {
        $runtime->$set_m( $_[2] );
    };

    return Language::P::Toy::Value::ActiveScalarCallbacks->new
               ( $runtime,
                 { get_callback => $get,
                   set_callback => $set,
                   } )
}

sub get_symbol {
    my( $self, $runtime, $name, $sigil, $create ) = @_;
    my( $symbol, $created ) = $self->SUPER::_get_symbol( $runtime, $name, '*', $create );

    return $symbol unless $symbol;
    if( !$created ) {
        return $symbol if $sigil eq '*';
        return $create ? $symbol->get_or_create_slot( $runtime, $sigils{$sigil}[0] ) :
                         $symbol->get_slot( $runtime, $sigils{$sigil}[0] );
    }
    if( $special_names{$name} ) {
        if( $name eq "\017" ) {
            $symbol->set_slot( $runtime, 'scalar',
                               _tied_to_rt_variable( $runtime, 'osname' ) );
        } elsif( $name eq "\010" ) {
            $symbol->set_slot( $runtime, 'scalar',
                               _tied_to_rt_methods( $runtime, 'get_hints',
                                                    'set_hints' ) );
        } elsif( $name eq "\027ARNING_BITS" ) {
            $symbol->set_slot( $runtime, 'scalar',
                               _tied_to_rt_methods( $runtime, 'get_warnings',
                                                    'set_warnings' ) );
        }
    }

    return $symbol if $sigil eq '*';
    return $create ? $symbol->get_or_create_slot( $runtime, $sigils{$sigil}[0] ) :
                     $symbol->get_slot( $runtime, $sigils{$sigil}[0] );
}

1;
