using Runtime = org.mbarbon.p.runtime.Runtime;

namespace org.mbarbon.p.values
{    
    public class Typeglob
    {
        public Typeglob(Runtime runtime)
        {
            body = new TypeglobBody(runtime);
        }

        public Scalar Scalar
        {
            get { return body.Scalar; }
            set { body.Scalar = value; }
        }

        public Array Array
        {
            get { return body.Array; }
            set { body.Array = value; }
        }

        public Hash Hash
        {
            get { return body.Hash; }
            set { body.Hash = value; }
        }

        public Handle Handle
        {
            get { return body.Handle; }
            set { body.Handle = value; }
        }

        public Code Code
        {
            get { return body.Code; }
            set { body.Code = value; }
        }

        private TypeglobBody body;
    }

    public class TypeglobBody
    {
        public TypeglobBody(Runtime runtime)
        {
        }

        public Scalar Scalar
        {
            get { return scalar; }
            set { scalar = value; }
        }

        public Array Array
        {
            get { return array; }
            set { array = value; }
        }

        public Hash Hash
        {
            get { return hash; }
            set { hash = value; }
        }

        public Handle Handle
        {
            get { return handle; }
            set { handle = value; }
        }
        
        public Code Code
        {
            get { return code; }
            set { code = value; }
        }

        private Scalar scalar;
        private Array array;
        private Hash hash;
        private Handle handle;
        private Code code;
    }
}
