namespace SampleApplication.Controllers
{
    using Amazon.S3.Model;
    using SampleApplication.Resources;
    using System.Collections.Generic;
    using System.Net;
    using System.Net.Http;
    using System.Threading.Tasks;
    using System.Web.Http;

    public class WorkspaceController : ApiController
    {
        private readonly S3FileFactory resourceFactory;

        public WorkspaceController()
        {
            var s3Adapter = S3ConnectionFactory.GetS3Adapter;
            this.resourceFactory = new S3FileFactory(s3Adapter);
        }

        [HttpGet]
        public async Task<HttpResponseMessage> GetWorkspace()
        {
            var fileStorage = this.resourceFactory.CreateFileStorage();
            var workspace = await fileStorage.GetAllAsync("src/");
            return this.Request.CreateResponse(HttpStatusCode.OK, workspace);
        }
    }
}