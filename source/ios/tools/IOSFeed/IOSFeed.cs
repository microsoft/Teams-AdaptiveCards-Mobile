// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.
using System;
using System.IO;
using System.Security.Cryptography;
using System.Text;
using System.Threading.Tasks;
using Microsoft.Azure.Storage;
using Microsoft.Azure.Storage.Blob;

namespace AdaptiveCards.Tools.IOSFeed
{
    public static class Constants
    {
        public static readonly string ConnectionStringPath =
            Environment.GetEnvironmentVariable("IOSFEED_CONNECTION_STRING_PATH") ??
            "source/ios/tools/IOSFeed/ConnectString.txt";
        public const string ContainerId = "adaptivecardsiosblobs";
        public const string FrameworkPath = "source/ios/AdaptiveCards/AdaptiveCards";
        public const string FrameworkName = "AdaptiveCards.framework.zip";
        public const string PodspecPath = "./source/ios/tools/";
        public const string TargetPodspecPath = "./source/ios/";
        public const string PodspecName = "AdaptiveCards.podspec";
    }

    /// <summary>
    /// IOSFeed picks up ios artifact, sends to the Azure storage 
    /// and updates podspec for pod publication
    /// </summary>
    class IOSFeed
    {
        public static void Main()
        {
            try
            {
                // Run the examples asynchronously, wait for the results before proceeding
                ProcessAsync().GetAwaiter().GetResult();
            }
            catch (Exception ex)
            {
                Console.Error.WriteLine("Uploading task failed with exception type {0}", ex.GetType().Name);
                Environment.ExitCode = 1;
            }
        }

        private static async Task ProcessAsync()
        {
            string storageConnectionString;

            FileInfo fi = new FileInfo(Constants.ConnectionStringPath);
            if (!fi.Exists)
            {
                throw new InvalidOperationException(Path.GetFileName(Constants.ConnectionStringPath) + " does not exist");
            }

            using (StreamReader sr = File.OpenText(Constants.ConnectionStringPath))
            {
                storageConnectionString = sr.ReadToEnd();
            }

            // Check whether the connection string can be parsed.
            if (!CloudStorageAccount.TryParse(storageConnectionString, out CloudStorageAccount storageAccount))
            {
                throw new InvalidOperationException(Path.GetFileName(Constants.ConnectionStringPath) + " does not have valid connection string");
            }
            else
            {
                // If the connection string is valid, proceed with operations against Blob
                // storage here.
                // Create the CloudBlobClient that represents the 
                // Blob storage endpoint for the storage account.
                CloudBlobClient cloudBlobClient = storageAccount.CreateCloudBlobClient();

                CloudBlobContainer cloudBlobContainer =
                    cloudBlobClient.GetContainerReference(Constants.ContainerId);
                await cloudBlobContainer.CreateIfNotExistsAsync();

                // Set the permissions so the blobs are public.
                BlobContainerPermissions permissions = new BlobContainerPermissions
                {
                    PublicAccess = BlobContainerPublicAccessType.Blob
                };

                await cloudBlobContainer.SetPermissionsAsync(permissions);

                var sourceFile = Path.Combine(Constants.FrameworkPath, Constants.FrameworkName);
                var sourceFileSha256 = GetSha256(sourceFile);
                var blobGuid = Guid.NewGuid().ToString();
                var cloudFileName = blobGuid + Constants.FrameworkName;

                CloudBlockBlob cloudBlockBlob = cloudBlobContainer.GetBlockBlobReference(cloudFileName);
                try
                {
                    await cloudBlockBlob.UploadFromFileAsync(sourceFile);
                    UpdatePodSpec(cloudBlockBlob.Uri.ToString(), sourceFileSha256);
                }
                catch (Exception)
                {
                    // when exception happens, nothing is permanent except blob, so we delete it here, and allow the rest of the exception
                    // to follow the chain
                    cloudBlockBlob.DeleteIfExists();
                    throw;
                }
            }
        }

        private static string GetSha256(string filePath)
        {
            using (var stream = File.OpenRead(filePath))
            using (var sha256 = SHA256.Create())
            {
                return BitConverter.ToString(sha256.ComputeHash(stream)).Replace("-", "").ToLowerInvariant();
            }
        }

        private static void UpdatePodSpec(string uri, string sha256)
        {
            var sourceFile = Path.Combine(Constants.PodspecPath, Constants.PodspecName);
            var targetFile = Path.Combine(Constants.TargetPodspecPath, Constants.PodspecName);

            FileInfo fi = new FileInfo(sourceFile);
            if (!fi.Exists)
            {
                throw new FileNotFoundException("missing file: " + Constants.PodspecName);
            }

            // Open the stream and read it back.
            using (StreamReader sr = File.OpenText(sourceFile))
            {
                string s;
                StringBuilder output = new StringBuilder();
                while ((s = sr.ReadLine()) != null)
                {
                    if (s.Length != 0)
                    {
                        var splits = s.Split('=');
                        StringBuilder stringBuilderForEditedString = new StringBuilder();
                        if (splits.Length > 0)
                        {
                            if (splits[0].Contains("spec.source", StringComparison.OrdinalIgnoreCase))
                            {
                                stringBuilderForEditedString
                                    .Append(splits[0])
                                    .Append("= { :http => '")
                                    .Append(uri)
                                    .Append("', :sha256 => '")
                                    .Append(sha256)
                                    .Append("' }");
                            }
                            else
                            {
                                stringBuilderForEditedString.Append(s);
                            }
                        }

                        output.Append(stringBuilderForEditedString + "\n");
                    } else
                    {
                        output.Append("\n");
                    }
                }

                File.WriteAllText(targetFile, output.ToString());
            }
        }
    }
}
