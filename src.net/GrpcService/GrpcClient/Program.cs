using Grpc.Core;
using System;
using System.Threading.Tasks;
using GrpcProtos.Services;
using GrpcProtos.Common;
//using GrpcProtos.Common;

namespace GrpcClient
{
    public static class Program
    {
        public static async Task Main()
        {
            Console.WriteLine("Press any key to start...");
            Console.ReadKey();

            Channel channel = new Channel("127.0.0.1:5000", ChannelCredentials.Insecure);

            var client = new MegaHelloWorld.MegaHelloWorldClient(channel);
            var request = new MessageRequest
            {
                Name = "King Julien"
            };
            var reply = await client.GetMessageAsync(request);
            Console.WriteLine(reply.Message);

            channel.ShutdownAsync().Wait();
            Console.WriteLine("Press any key to exit...");
            Console.ReadKey();
        }
    }
}
