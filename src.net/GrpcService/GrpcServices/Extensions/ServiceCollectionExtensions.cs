using GrpcServices.Services;
using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Routing;
using Microsoft.Extensions.DependencyInjection;
using System;

namespace GrpcServices.Extensions
{
    public static class ServiceCollectionExtensions
    {
        public static IServiceCollection AddConfigGrpcServices(this IServiceCollection services)
        {
            services.AddGrpc();
            AppContext.SetSwitch("System.Net.Http.SocketsHttpHandler.Http2UnencryptedSupport", true);

            return services;
        }

        public static IEndpointRouteBuilder MapConfigGrpcServices(this IEndpointRouteBuilder endpoints)
        {
            endpoints.MapGrpcService<HelloWorldService>();

            return endpoints;
        }
    }
}
