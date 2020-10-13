using Grpc.Core;
using GrpcProtos.Services;
using GrpcProtos.Common;
using Microsoft.Extensions.Logging;
using System;
using System.Threading.Tasks;

namespace GrpcServices.Services
{
    public class HelloWorldService : HelloWorld.HelloWorldBase
    {
        // Fields
        public ILogger<HelloWorldService> _logger { get; }

        // Ctor
        public HelloWorldService(ILogger<HelloWorldService> logger)
        {
            _logger = logger ?? throw new ArgumentNullException(nameof(logger));
        }

        // Mehods
        public override async Task<MessageResponse> GetMessage(MessageRequest body, ServerCallContext context)
        {
            return new MessageResponse
            {
                Message = string.IsNullOrWhiteSpace(body?.Name) ? "Hello, no-name!" : $"Hello, {body.Name}"
            };
        }
    }
}
