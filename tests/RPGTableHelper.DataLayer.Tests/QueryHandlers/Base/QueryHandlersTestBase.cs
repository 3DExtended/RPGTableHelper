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
        protected static DateTime SystemClockNow => new(2024, 01, 01, 10, 4, 15, DateTimeKind.Utc);
        private readonly string _runIdentifier;

        private bool _isDisposed;

        protected RpgDbContext Context { get; }

        protected IDbContextFactory<RpgDbContext> ContextFactory { get; }

        protected IMapper Mapper { get; }
        protected ISystemClock SystemClock { get; }

        protected IServiceProvider ServiceProvider { get; }

        protected QueryHandlersTestBase()
        {
            _runIdentifier = Guid.NewGuid().ToString();

            ServiceProvider = new ServiceCollection()
                .AddDbContextFactory<RpgDbContext>(o =>
                    o.UseSqlite($"DataSource=file:memdb{_runIdentifier}?mode=memory&cache=shared")
                )
                .AddAutoMapper(typeof(DataLayerEntitiesMapperProfile), typeof(SharedMapperProfile))
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

        public void Dispose()
        {
            Dispose(true);
            GC.SuppressFinalize(this);
        }

        protected void AssertCorrectTime(DateTimeOffset foundTime, TimeSpan? differenceFromSystemClock = null)
        {
            foundTime.Should().Be(SystemClockNow.Add(differenceFromSystemClock ?? TimeSpan.Zero));
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
