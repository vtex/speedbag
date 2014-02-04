﻿namespace SampleApplication.Resources
{
    using System;
    using System.Collections.Generic;
    using System.Linq;
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
            await this.s3.PutTextAsync(path, content);
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
    }
}
