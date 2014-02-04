namespace SampleApplication.Controllers
{
    using System;
    using System.Collections.Generic;
    using System.IdentityModel;
    using System.Linq;
    using System.Runtime.Serialization;
    using System.Text;

    [DataContract]
    public class FileExchange
    {
        [DataMember(Name = "Content")]
        public string Content { get; set; }

        [DataMember(Name = "FilePath")]
        public string FilePath { get; set; }

        internal static FileExchange FromFile(string path, string content)
        {
            return new FileExchange
            {
                FilePath = path,
                Content = content
            };
        }

        internal void IsValid()
        {
            if (string.IsNullOrWhiteSpace(this.FilePath))
                throw new BadRequestException("O caminho do arquivo não foi informado");

            if (this.Content == null)
                throw new BadRequestException("O conteúdo do arquivo não pode ser nulo");
        }
    }
}
