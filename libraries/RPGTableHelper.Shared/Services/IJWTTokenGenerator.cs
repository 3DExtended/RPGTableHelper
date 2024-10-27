namespace RPGTableHelper.Shared.Services;

public interface IJWTTokenGenerator
{
    public abstract string GetJWTToken(string username, string userIdentityProviderId);
}
