using Prodot.Patterns.Cqrs;
using RPGTableHelper.DataLayer.Contracts.Models.Auth;

namespace RPGTableHelper.DataLayer.Contracts.Queries.Apple;

public class AppleAuthKeysQuery : IQuery<AppleKeysResponse, AppleAuthKeysQuery> { }
