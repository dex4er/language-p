using System.IO;

namespace org.mbarbon.p.runtime
{
    public partial class Serializer
    {
        public static CompilationUnit ReadCompilationUnit(string file_name)
        {
            BinaryReader reader = new BinaryReader(File.Open(file_name, FileMode.Open));

            int count = reader.ReadInt32();
            var cu = new CompilationUnit(file_name, count);

            for (int i = 0; i < count; ++i)
            {
                cu.Subroutines[i] = ReadSubroutine(reader);
            }

            return cu;
        }

        public static Subroutine ReadSubroutine(BinaryReader reader)
        {
            var name = ReadString(reader);
            int type = reader.ReadByte();
            int outer_sub = reader.ReadInt32();
            int lex_count = reader.ReadInt32();
            int bb_count = reader.ReadInt32();

            var lexicals = new LexicalInfo[lex_count];
            for (int i = 0; i < lex_count; ++i)
            {
                lexicals[i] = ReadLexical(reader);
            }

            var sub = new Subroutine(bb_count);

            sub.Lexicals = lexicals;
            if (name.Length != 0)
                sub.Name = name;
            sub.Outer = outer_sub;
            sub.Type = type;
            for (int i = 0; i < bb_count; ++i)
            {
                sub.BasicBlocks[i] = ReadBasicBlock(reader, sub);
            }

            return sub;
        }

        public static LexicalInfo ReadLexical(BinaryReader reader)
        {
            var info = new LexicalInfo();

            info.Level = reader.ReadInt32();
            info.Index = reader.ReadInt32();
            info.OuterIndex = reader.ReadInt32();
            info.Name = ReadString(reader);
            info.Slot = (Opcode.Sigil)reader.ReadByte();
            info.InPad = reader.ReadByte() != 0;
            info.FromMain = reader.ReadByte() != 0;

            return info;
        }

        public static BasicBlock ReadBasicBlock(BinaryReader reader,
                                                Subroutine sub)
        {
            int count = reader.ReadInt32();
            var bb = new BasicBlock(count);

            for (int i = 0; i < count; ++i)
            {
                bb.Opcodes[i] = ReadOpcode(reader, sub);
            }

            return bb;
        }

        // ReadOpcode() is autogenerated; see inc/Opcodes.pm

        public static string ReadString(BinaryReader reader)
        {
            int size = reader.ReadInt32();
            if (size == 0)
                return "";

            byte[] bytes = reader.ReadBytes(size);

            return System.Text.Encoding.UTF8.GetString(bytes);
        }
    }

    // class Opcode is autogenerated; see inc/Opcodes.pm

    // TODO autogenerate all opcode subclasses
    public class Global : Opcode
    {
        public string Name;
        public Opcode.Sigil Slot;
    }

    public class GlobSlot : Opcode
    {
        public Opcode.Sigil Slot;
    }

    public class ConstantInt : Opcode
    {
        public int Value;
    }

    public class ConstantString : Opcode
    {
        public string Value;
    }

    public class ConstantSub : Opcode
    {
        public int Value;
    }

    public class GetSet : Opcode
    {
        public int Index;
    }

    public class Jump : Opcode
    {
        public int To;
    }

    public class ScopeInOut : Opcode
    {
        public int Scope;
    }

    public class Temporary : Opcode
    {
        public int Index;
    }

    public class Lexical : Opcode
    {
        public LexicalInfo LexicalInfo;

        public int Index
        {
            get { return LexicalInfo.Index; }
        }

        public Opcode.Sigil Slot
        {
            get { return LexicalInfo.Slot; }
        }
    }

    public class BasicBlock
    {
        public BasicBlock(int opCount)
        {
            Opcodes = new Opcode[opCount];
        }

        public int Index;
        public Opcode[] Opcodes;
    }

    public class Subroutine
    {
        public Subroutine(int blockCount)
        {
            BasicBlocks = new BasicBlock[blockCount];
        }

        public int Type;
        public int Outer;
        public string Name;
        public BasicBlock[] BasicBlocks;
        public LexicalInfo[] Lexicals;
    }

    public class CompilationUnit
    {
        public CompilationUnit(string file_name, int subCount)
        {
            Subroutines = new Subroutine[subCount];
            FileName = file_name;
        }

        public string FileName;
        public Subroutine[] Subroutines;
    }

    public class LexicalInfo
    {
        public LexicalInfo()
            : this(null, 0, -1, -1, -1, false, false)
        { }

        public LexicalInfo(string name, Opcode.Sigil slot,
                           int level, int index, int outer,
                           bool in_pad, bool from_main)
        {
            Level = level;
            Index = index;
            OuterIndex = outer;
            Slot = slot;
            InPad = in_pad;
            FromMain = from_main;
            Name = name;
        }

        public int Level, Index, OuterIndex;
        public Opcode.Sigil Slot;
        public bool InPad, FromMain;
        public string Name;
    }
}
