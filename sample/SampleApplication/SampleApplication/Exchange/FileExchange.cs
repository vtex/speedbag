namespace SampleApplication.Controllers
{
    using System;
    using System.Collections.Generic;
    using System.IdentityModel;
    using System.Linq;
    using System.Runtime.Serialization;
    using System.Text;

    public class FileExchange
    {
        public string action { get; set; }

        public string path { get; set; }

        public string content_type { get; set; }

        public string content { get; set; }

        internal static FileExchange FromFile(string path, string content)
        {
            return new FileExchange
            {
                path = path,
                content = content
            };
        }
    }
}
