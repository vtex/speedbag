namespace SampleApplication.Controllers
{
    using Amazon;
    using SampleApplication.Resources;
    using System;
    using System.Collections;
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
            var s3Adapter = CreateS3Adapter();
            this.resourceFactory = new S3FileFactory(s3Adapter);
        }

        [HttpPut]
        public async Task<HttpResponseMessage> Update(FileExchange request)
        {
            request.IsValid();
            var fileStorage = this.resourceFactory.CreateFileStorage();
            await fileStorage.SaveAsync(request.FilePath, request.Content);

            return this.Request.CreateResponse(HttpStatusCode.OK, FileExchange.FromFile(request.FilePath, request.Content));
        }

        [HttpDelete]
        public async Task<HttpResponseMessage> DeleteFile(FileExchange request)
        {
            var fileStorage = this.resourceFactory.CreateFileStorage();

            var files = await fileStorage.GetAllAsync(request.FilePath);
            foreach (string path in files)
            {
                await fileStorage.DeleteAsync(path);
            }
            
            return await fileStorage.DeleteAsync(request.FilePath)
                ? this.Request.CreateResponse(HttpStatusCode.NoContent)
                : this.Request.CreateResponse(HttpStatusCode.NotFound);
        }

        [HttpGet]
        public string GetFile(string path)
        {
            throw new NotImplementedException();
        }

        private IAmazonS3Adapter CreateS3Adapter()
        {
        }

    }
}