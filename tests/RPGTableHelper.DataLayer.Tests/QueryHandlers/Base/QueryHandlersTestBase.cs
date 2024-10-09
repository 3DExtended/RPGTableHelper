using AutoMapper;
using FluentAssertions;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.DependencyInjection;
using NSubstitute;
using RPGTableHelper.DataLayer.EfCore;
using RPGTableHelper.Shared.Services;

namespace RPGTableHelper.DataLayer.Tests.QueryHandlers.Base
{
    public abstract class QueryHandlersTestBase : IDisposable
    {
        private bool _isDisposed;
        private string _runIdentifier;

        protected RpgDbContext Context { get; }

        protected IDbContextFactory<RpgDbContext> ContextFactory { get; }

        protected IMapper Mapper { get; }
        protected ISystemClock SystemClock { get; }

        protected IServiceProvider ServiceProvider { get; }

        protected readonly DateTime SystemClockNow = new DateTime(2024, 01, 01, 10, 4, 15);

        protected QueryHandlersTestBase()
        {
            _runIdentifier = Guid.NewGuid().ToString();

            ServiceProvider = new ServiceCollection()
                .AddDbContextFactory<RpgDbContext>(o =>
                    o.UseSqlite($"DataSource=file:memdb{_runIdentifier}?mode=memory&cache=shared")
                )
                .AddAutoMapper(typeof(DataLayerEntitiesMapperProfile))
                .BuildServiceProvider();

            // initialize test database
            ContextFactory = ServiceProvider.GetRequiredService<IDbContextFactory<RpgDbContext>>();
            Context = ContextFactory.CreateDbContext();
            Context.Database.OpenConnection();
            Context.Database.EnsureCreated();

            SystemClock = Substitute.For<ISystemClock>();

            SystemClock.Now.Returns(SystemClockNow);

            Mapper = ServiceProvider.GetRequiredService<IMapper>();
        }

        protected void AssertCorrectTime(
            DateTimeOffset foundTime,
            TimeSpan? differenceFromSystemClock = null
        )
        {
            foundTime.Should().Be(SystemClockNow.Add(differenceFromSystemClock ?? TimeSpan.Zero));
        }

        public void Dispose()
        {
            Dispose(true);
            GC.SuppressFinalize(this);
        }

        protected virtual void Dispose(bool disposing)
        {
            if (_isDisposed)
            {
                return;
            }

            if (disposing)
            {
                // free managed resources
                Context.Database.CloseConnection();
                Context.Dispose();
            }

            _isDisposed = true;
        }
    }
}
