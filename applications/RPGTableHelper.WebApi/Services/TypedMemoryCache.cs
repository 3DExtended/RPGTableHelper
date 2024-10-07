using System.Collections.Concurrent;
using System.Runtime.InteropServices;
using Microsoft.Extensions.Caching.Memory;
using Prodot.Patterns.Cqrs;
using RPGTableHelper.Shared.Services;

namespace RPGTableHelper.WebApi.Services
{
    public class TypedMemoryCache<TType> : ITypedMemoryCache<TType>
        where TType : class
    {
        private readonly ConcurrentDictionary<string, DateTime> _oldestElementView = new();
        private readonly SemaphoreSlim _semaphore = new(1);
        private readonly long memorySizeInBytes;

        public TypedMemoryCache(IMemoryCache cache, long memorySizeInBytes)
        {
            this.memorySizeInBytes = memorySizeInBytes;
            Cache = cache;
        }

        public IMemoryCache Cache { get; set; }

        public async Task AddToCacheAsync<TItem>(
            TItem cacheItem,
            string cacheKey,
            long? size = null
        )
        {
            long itemSizeBytes = size ?? GetObjectSize(cacheItem);
            var cacheEntryOptions = new MemoryCacheEntryOptions()
                .SetSize(itemSizeBytes)
                .RegisterPostEvictionCallback(
                    (key, value, reason, state) =>
                    {
                        if (_oldestElementView.TryGetValue((string)key, out DateTime dateTime))
                        {
                            _oldestElementView.Remove((string)key, out var asdf);
                        }
                    }
                )
                .SetSlidingExpiration(TimeSpan.FromHours(3));

            if (itemSizeBytes >= memorySizeInBytes)
            {
                // dont cache things too big...
                return;
            }

            if (Cache.GetCurrentStatistics() != null)
            {
                var lastSize = Cache.GetCurrentStatistics()!.CurrentEstimatedSize;

                while (
                    Cache.GetCurrentStatistics()!.CurrentEstimatedSize + itemSizeBytes
                    > memorySizeInBytes
                )
                {
                    // Retrieve the oldest cache item
                    var oldestElement = _oldestElementView.OrderBy(e => e.Value).FirstOptional();
                    if (oldestElement.IsSome)
                    {
                        Cache.Remove(oldestElement.Get().Key);
                    }
                    else
                    {
                        return;
                    }

                    if (lastSize == Cache.GetCurrentStatistics()!.CurrentEstimatedSize)
                    {
                        return;
                    }

                    lastSize = Cache.GetCurrentStatistics()!.CurrentEstimatedSize;
                }
            }

            Cache.Set(cacheKey, cacheItem, cacheEntryOptions);

            // dont clear if size of cache item is 0
            if (itemSizeBytes > 0)
            {
                _oldestElementView.TryAdd(cacheKey, DateTime.UtcNow);
            }
        }

        public void Remove(string key)
        {
            Cache.Remove(key);
            _oldestElementView.Remove(key, out var asdf);
        }

        private int GetObjectSize(object obj)
        {
            if (obj == null)
                return 0;

            Type type = obj.GetType();

            // Check if the object is a value type
            if (type.IsValueType)
            {
                return Marshal.SizeOf(obj);
            }
            else
            {
                // Estimate the size based on the fields and properties of the object
                int size = nint.Size; // Reference size

                foreach (var field in type.GetFields())
                {
                    size += GetObjectSize(field.GetValue(obj));
                }

                foreach (var prop in type.GetProperties())
                {
                    size += GetObjectSize(prop.GetValue(obj));
                }

                return size;
            }
        }
    }
}
