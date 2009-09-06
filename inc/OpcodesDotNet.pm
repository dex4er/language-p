package OpcodesDotNet;

use strict;
use warnings;
use Exporter 'import';

our @EXPORT = qw(write_dotnet_deserializer);

use Opcodes;

my %dotnet_classes =
  ( 'OP_FRESH_STRING'      => 'ConstantString',
    'OP_CONSTANT_STRING'   => 'ConstantString',
    'OP_CONSTANT_INTEGER'  => 'ConstantInt',
    'OP_CONSTANT_SUB'      => 'ConstantSub',
    'OP_GLOBAL'            => 'Global',
    'OP_GLOB_SLOT'         => 'GlobSlot',
    'OP_GLOB_SLOT_SET'     => 'GlobSlot',
    'OP_GET'               => 'GetSet',
    'OP_SET'               => 'GetSet',
    'OP_JUMP'              => 'Jump',
    'OP_JUMP_IF_FALSE'     => 'Jump',
    'OP_JUMP_IF_F_EQ'      => 'Jump',
    'OP_JUMP_IF_F_GE'      => 'Jump',
    'OP_JUMP_IF_F_GT'      => 'Jump',
    'OP_JUMP_IF_F_LE'      => 'Jump',
    'OP_JUMP_IF_F_LT'      => 'Jump',
    'OP_JUMP_IF_F_NE'      => 'Jump',
    'OP_JUMP_IF_NULL'      => 'Jump',
    'OP_JUMP_IF_S_EQ'      => 'Jump',
    'OP_JUMP_IF_S_GE'      => 'Jump',
    'OP_JUMP_IF_S_GT'      => 'Jump',
    'OP_JUMP_IF_S_LE'      => 'Jump',
    'OP_JUMP_IF_S_LT'      => 'Jump',
    'OP_JUMP_IF_S_NE'      => 'Jump',
    'OP_JUMP_IF_TRUE'      => 'Jump',
    'OP_LEXICAL_PAD'       => 'Lexical',
    'OP_LEXICAL'           => 'Lexical',
    'OP_LEXICAL_PAD_SET'   => 'Lexical',
    'OP_LEXICAL_SET'       => 'Lexical',
    'OP_LEXICAL_PAD_CLEAR' => 'Lexical',
    'OP_LEXICAL_CLEAR'     => 'Lexical',
    'OP_SCOPE_ENTER'       => 'ScopeInOut',
    'OP_SCOPE_LEAVE'       => 'ScopeInOut',
    'OP_TEMPORARY'         => 'Temporary',
    'OP_TEMPORARY_SET'     => 'Temporary',
    );

sub write_dotnet_deserializer {
    my( $file ) = @ARGV;

    my %op = %{parse_opdesc()};

    open my $out, '>', $file;

    print $out <<'EOT';
using System.IO;

namespace org.mbarbon.p.runtime
{
    public partial class Serializer
    {
        public static Opcode ReadOpcode(BinaryReader reader, Subroutine sub)
        {
            var num = (Opcode.OpNumber)reader.ReadInt16();
            Opcode op;

            switch (num)
            {
EOT

    while( my( $k, $v ) = each %op ) {
        my $class = $dotnet_classes{$k};
        my $attrs = $v->[3][0];

        next unless @$attrs;
        if( !$class ) {
            if( @$attrs > 2 || $attrs->[0] ne 'context' ) {
        print $out sprintf <<'EOT', $k, $class, $class;
            case Opcode.OpNumber.%s:
                throw new System.Exception(string.Format("Unhandled opcode {0:S} in deserialization", num.ToString()));
EOT
                next;
            }
            $class = 'Opcode';
        }

        print $out sprintf <<'EOT', $k;
            case Opcode.OpNumber.%s:
            {
EOT

        if( $class ) {
            print $out sprintf <<'EOT', $class, $class;
                %s opc = new %s();
                op = opc;
EOT
        }

        for( my $i = 0; $i < @$attrs; $i += 2 ) {
            my $type = $attrs->[$i + 1];
            my $name = $attrs->[$i];
            if( $type eq 's' ) {
                print $out sprintf <<'EOT', ucfirst $name;
                opc.%s = ReadString(reader);
EOT
            } elsif( $type eq 'i' || $type eq 'i4' ) {
                print $out sprintf <<'EOT', ucfirst $name;
                opc.%s = reader.ReadInt32();
EOT
            } elsif( $type eq 'i_sigil' ) {
                print $out sprintf <<'EOT', ucfirst $name;
                opc.%s = (Opcode.Sigil)reader.ReadByte();
EOT
            } elsif( $type eq 'i1' ) {
                print $out sprintf <<'EOT', ucfirst $name;
                opc.%s = reader.ReadByte();
EOT
            } elsif( $type eq 'b' ) {
                print $out sprintf <<'EOT', ucfirst $name;
                opc.%s = reader.ReadInt32();
EOT
            } elsif( $type eq 'c' ) {
                print $out sprintf <<'EOT', ucfirst $name;
                opc.%s = reader.ReadInt32();
EOT
            } elsif( $type eq 'ls' || $type eq 'lp' ) {
                print $out sprintf <<'EOT';
                opc.LexicalInfo = sub.Lexicals[reader.ReadInt32()];
EOT
            }
        }

        print $out <<'EOT';
                break;
            }
EOT
    }

    print $out <<'EOT';
            default:
            {
                op = new Opcode();
                break;
            }
            }

            op.Number = num;
            int count = reader.ReadInt32();
            op.Childs = new Opcode[count];

            for (int i = 0; i < count; ++i)
            {
                op.Childs[i] = ReadOpcode(reader, sub);
            }

            return op;
        }
    }

    public class Opcode
    {
        public enum OpNumber : short
        {
EOT

    my $index = 1;
    foreach my $k ( sort keys %op ) {
        print $out <<EOT;
            $k = $index,
EOT
        ++$index;
    }

    print $out <<'EOT';
        }

        public enum ContextValues
        {
            CALLER = 1,
            VOID   = 2,
            SCALAR = 4,
            LIST   = 8,
        }

        public enum Sigil
        {
            SCALAR    = 1,
            ARRAY     = 2,
            HASH      = 3,
            SUB       = 4,
            GLOB      = 5,
            HANDLE    = 7,
        }

        public OpNumber Number;
        public int Context;
        public Opcode[] Childs;
    }
}
EOT
}

1;
