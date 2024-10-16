using Microsoft.AspNetCore.Mvc.Testing;
using RPGTableHelper.Api.Tests.Base;
using RPGTableHelper.WebApi;

namespace RPGTableHelper.Shared.Tests.Controllers.Authorization;

public class RegisterControllerTests : ControllerTestBase
{
    public RegisterControllerTests(WebApplicationFactory<Program> factory)
        : base(factory) { }
}
