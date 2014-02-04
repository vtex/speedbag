namespace SampleApplication.Resources
{
    using System;
    using System.Collections.Generic;
    using System.Linq;
    using System.Web;
    using Vtex.Practices.Aws.S3;

    public class S3FileFactory
    {
        private readonly IAmazonS3Adapter s3;

        public S3FileFactory(IAmazonS3Adapter s3)
        {
            this.s3 = s3;
        }

        internal S3FileStorage CreateFileStorage()
        {
            return new S3FileStorage(this.s3);
        }
    }
}