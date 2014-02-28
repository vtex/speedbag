namespace SampleApplication.Controllers
{
    using Amazon;
    using SampleApplication.Resources;
    using System;
    using System.Net;
    using System.Net.Http;
    using System.Threading.Tasks;
    using System.Web;
    using System.Web.Http;
    using Vtex.Practices.Aws.S3;

    public class PersistenceController : ApiController
    {
        private readonly S3FileFactory resourceFactory;

        public PersistenceController()
        {
            var s3Adapter = S3ConnectionFactory.GetS3Adapter;
            this.resourceFactory = new S3FileFactory(s3Adapter);
        }

        [HttpPut]
        public async Task<HttpResponseMessage> Update(HttpRequestMessage request)
        {
            var content = request.Content;
            var jsonContent = content.ReadAsAsync<FileExchange[]>().Result;

            var name = 0;
            foreach (var element in jsonContent)
            {
                if (element.action.Equals("removed"))
                {
                    name++;
                    await DeleteFile(element.path);
                }

                if (element.action.Equals("created"))
                {
                    name++;
                    await ChangeFile(element.path, Base64Decode(element.content)).ConfigureAwait(false);
                }

                if (element.action.Equals("changed"))
                {
                    name++;
                    await ChangeFile(element.path, Base64Decode(element.content)).ConfigureAwait(false);
                }
            }
            return this.Request.CreateResponse(HttpStatusCode.OK, name);             
        }

        private async Task ChangeFile(string filePath, string content)
        {
            var fileStorage = this.resourceFactory.CreateFileStorage();
            await fileStorage.SaveAsync(filePath, content);
        }

        public async Task DeleteFile(string filePath)
        {
            var fileStorage = this.resourceFactory.CreateFileStorage();

            var files = await fileStorage.GetAllPathsAsync(filePath);
            foreach (string path in files)
            {
               await fileStorage.DeleteAsync(path);  
            }

            await fileStorage.DeleteAsync(filePath);
        }

        [HttpGet]
        public string GetFile(int path)
        {
            return "get path funcionou";
        }

        public static string Base64Decode(string base64EncodedData)
        {
            var base64EncodedBytes = System.Convert.FromBase64String(base64EncodedData);
            return System.Text.Encoding.UTF8.GetString(base64EncodedBytes);
        }
    }
}