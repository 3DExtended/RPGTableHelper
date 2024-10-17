using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using FluentAssertions;
using Prodot.Patterns.Cqrs;
using RPGTableHelper.DataLayer.Contracts.Queries.Users;
using RPGTableHelper.DataLayer.Entities;
using RPGTableHelper.DataLayer.QueryHandlers.Users;
using RPGTableHelper.DataLayer.Tests.QueryHandlers.Base;

namespace RPGTableHelper.DataLayer.Tests.QueryHandlers.Users
{
    public class UserSearchByUsernameQueryHandlerTests : QueryHandlersTestBase
    {
        [Fact]
        public async Task RunQueryAsync_RetrievesEntityCorrectly()
        {
            // Arrange
            var entity1 = new UserEntity
            {
                Id = Guid.Empty,
                Username = "asdf",
                SignInProviderId = "bhzujkmn1",
            };
            var entity2 = new UserEntity
            {
                Id = Guid.Empty,
                Username = "asdfBla2",
                SignInProviderId = "bhzujkmn2",
            };
            var entity3 = new UserEntity
            {
                Id = Guid.Empty,
                Username = "asdfblaasdf3",
                SignInProviderId = "bhzujkmn3",
            };

            Context.Users.Add(entity1);
            Context.Users.Add(entity2);
            Context.Users.Add(entity3);
            Context.SaveChanges();

            var query = new UserSearchByUsernameQuery { UsernamePart = "BLA" };
            var subjectUnderTest = new UserSearchByUsernameQueryHandler(ContextFactory, Mapper);

            // Act
            var result = await subjectUnderTest.RunQueryAsync(query, default);

            // Assert
            result.IsSome.Should().BeTrue("because the retrieval should be successful");
            result.Get().Count.Should().Be(2);
        }

        [Fact]
        public async Task RunQueryAsync_RetrievesEntityCorrectlyWhenNoMatchesFound()
        {
            // Arrange
            var entity1 = new UserEntity
            {
                Id = Guid.Empty,
                Username = "asdf",
                SignInProviderId = "bhzujkmn1",
            };
            var entity2 = new UserEntity
            {
                Id = Guid.Empty,
                Username = "asdfBla2",
                SignInProviderId = "bhzujkmn2",
            };
            var entity3 = new UserEntity
            {
                Id = Guid.Empty,
                Username = "asdfblaasdf3",
                SignInProviderId = "bhzujkmn3",
            };

            Context.Users.Add(entity1);
            Context.Users.Add(entity2);
            Context.Users.Add(entity3);
            Context.SaveChanges();

            var query = new UserSearchByUsernameQuery { UsernamePart = "asdfasdfasdfasdfasdf" };
            var subjectUnderTest = new UserSearchByUsernameQueryHandler(ContextFactory, Mapper);

            // Act
            var result = await subjectUnderTest.RunQueryAsync(query, default);

            // Assert
            result.IsSome.Should().BeTrue("because the retrieval should be successful but empty");
            result.Get().Count.Should().Be(0);
        }
    }
}
