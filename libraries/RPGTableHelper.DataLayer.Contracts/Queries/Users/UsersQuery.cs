using Prodot.Patterns.Cqrs.EfCore;
using RPGTableHelper.DataLayer.Contracts.Models.Auth;

namespace RPGTableHelper.DataLayer.Contracts.Queries.Users
{
    /// <summary>
    /// Represents a query for retrieving a list of User models.
    /// </summary>
    /// <remarks>
    /// This query is designed to work with the CQRS pattern and EF Core.
    /// It uses User.UserIdentifier as the identifier type and Guid as the key type.
    /// </remarks>
    public class UsersQuery : ListOfModelQuery<User, User.UserIdentifier, Guid, UsersQuery> { }
}
