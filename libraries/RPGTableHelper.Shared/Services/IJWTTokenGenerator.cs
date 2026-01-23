namespace RPGTableHelper.Shared.Services;

public interface IJWTTokenGenerator
{
    string GetJWTToken(string username, string userIdentityProviderId);
}
