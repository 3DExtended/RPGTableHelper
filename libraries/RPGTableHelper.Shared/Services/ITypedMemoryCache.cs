using Microsoft.Extensions.Caching.Memory;

namespace RPGTableHelper.Shared.Services
{
    public interface ITypedMemoryCache<TType>
        where TType : class
    {
        public IMemoryCache Cache { get; }

        Task AddToCacheAsync<TItem>(TItem cacheItem, string cacheKey, long? size = null);

        void Remove(string key);
    }
}
