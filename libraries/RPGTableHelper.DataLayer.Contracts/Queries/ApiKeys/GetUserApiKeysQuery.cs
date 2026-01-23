using System;
using System.Collections.Generic;
using Prodot.Patterns.Cqrs;
using RPGTableHelper.DataLayer.Contracts.Models.ApiKeys;
using RPGTableHelper.DataLayer.Contracts.Models.Auth;

namespace RPGTableHelper.DataLayer.Contracts.Queries.ApiKeys
{
    public class GetUserApiKeysQuery : IQuery<IEnumerable<ApiKeyDto>, GetUserApiKeysQuery>
    {
        public User.UserIdentifier UserId { get; set; } = default!;
    }
}
