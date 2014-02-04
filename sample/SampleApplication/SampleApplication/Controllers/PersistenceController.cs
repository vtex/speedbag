namespace SampleApplication.Controllers
{
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
            var s3Adapter = new LocalFilesystemS3Adapter(HttpContext.Current.Server.MapPath("~/s3tests"));
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

            return await fileStorage.DeleteAsync(request.FilePath)
                ? this.Request.CreateResponse(HttpStatusCode.NoContent)
                : this.Request.CreateResponse(HttpStatusCode.NotFound);
        }

        [HttpGet]
        public string GetFile(string path)
        {
            throw new NotImplementedException();
        }
    }
}