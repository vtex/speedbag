namespace SampleApplication.Resources
{
    using Amazon.S3.Model;
    using SampleApplication.Controllers;
    using System;
    using System.Collections.Generic;
    using System.IO;
    using System.Linq;
    using System.Net;
    using System.Net.Http;
    using System.Text;
    using System.Threading.Tasks;
    using Vtex.Practices.Aws.S3;

    public class S3FileStorage
    {
        private readonly IAmazonS3Adapter s3;

        public S3FileStorage(IAmazonS3Adapter s3)
        {
            this.s3 = s3;
        }

        public async Task SaveAsync(string path, string content)
        {
            try
            {
                await this.s3.PutTextAsync(path, content);
            }
            catch (Exception)
            {
                throw new Exception("Erro ao salvar arquivo no S3");
            }
        }

        public async Task<bool> DeleteAsync(string path)
        {
            try
            {   
                await this.s3.DeleteFileAsync(path);
                return true;
            }
            catch (ObjectNotFoundException)
            {
                // ok, está apagado
            }
            return false;
        }

        public async Task<IEnumerable<FileExchange>> GetAllAsync(string path)
        {
            List<FileExchange> workspaceFiles = new List<FileExchange>();

            var paths = await this.s3.ListFilesAsync(path);
            foreach(string filePath in paths)
            {
                var file = await this.GetFileAsync(filePath);
               
                StreamReader reader = new StreamReader(file);
                String content = reader.ReadToEnd();
                workspaceFiles.Add(FileExchange.FromFile(filePath, Base64Decode(content)));
            }
            return workspaceFiles;
        }

        internal async Task<IEnumerable<string>> GetAllPathsAsync(string path)
        {
            return await this.s3.ListFilesAsync(path);
        }

        internal async Task<Stream> GetFileAsync(string path)
        {
            return await this.s3.GetFileAsync(path);
        }

        private static string Base64Decode(string plainText)
        {
            var plainTextBytes = System.Text.Encoding.UTF8.GetBytes(plainText);
            return System.Convert.ToBase64String(plainTextBytes);
        }
    }
}
