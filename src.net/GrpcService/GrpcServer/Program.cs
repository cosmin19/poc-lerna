using Microsoft.AspNetCore.Hosting;
using Microsoft.AspNetCore.Server.Kestrel.Core;
using Microsoft.Extensions.Hosting;

namespace GrpcServer
{
    public static class Program
    {
        public static readonly int GRPC_PORT = 5000;
        public static readonly int CONTROLLERS_PORT = 5001;

        public static void Main(string[] args)
        {
            CreateHostBuilder(args).Build().Run();
        }

        public static IHostBuilder CreateHostBuilder(string[] args) =>
            Host.CreateDefaultBuilder(args)
                .ConfigureWebHostDefaults(webBuilder =>
                {
                    webBuilder
                        .ConfigureKestrel(options =>
                        {
                            //grpc port for http2 connections
                            options.ListenAnyIP(GRPC_PORT, listenOptions => listenOptions.Protocols = HttpProtocols.Http2);
                            //http port for controllers
                            options.ListenAnyIP(CONTROLLERS_PORT, listenOptions => listenOptions.Protocols = HttpProtocols.Http1);
                        })
                        .UseStartup<Startup>();
                });
    }
}
