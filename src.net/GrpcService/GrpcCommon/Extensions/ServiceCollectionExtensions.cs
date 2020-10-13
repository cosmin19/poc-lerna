using Microsoft.Extensions.DependencyInjection;
using System;

namespace GrpcCommon.Extensions
{
    public static class ServiceCollectionExtensions
    {
        public static IServiceCollection AddGrpcServices(this IServiceCollection services, Action setup)
        {
            services.AddGrpc();
            AppContext.SetSwitch("System.Net.Http.SocketsHttpHandler.Http2UnencryptedSupport", true);

            setup.Invoke();

            return services;
        }
    }
}
