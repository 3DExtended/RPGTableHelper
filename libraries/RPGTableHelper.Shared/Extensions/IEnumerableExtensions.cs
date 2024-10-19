using System.Security.Cryptography;

namespace RPGTableHelper.Shared.Extensions
{
    public static class IEnumerableExtensions
    {
        public static IEnumerable<TItem> RandomSample<TItem>(
            this IReadOnlyList<TItem> items,
            int count
        )
        {
            if (count < 1 || count > items.Count)
            {
                throw new ArgumentOutOfRangeException(nameof(count));
            }
            List<int> indexes = Enumerable.Range(0, items.Count).ToList();
            int yieldedCount = 0;

            while (yieldedCount < count)
            {
                int i = RandomNumberGenerator.GetInt32(indexes.Count);
                int randomIndex = indexes[i];
                yield return items[randomIndex];

                indexes[i] = indexes[indexes.Count - 1]; // Replace yielded index with the last one
                indexes.RemoveAt(indexes.Count - 1);
                yieldedCount++;
            }
        }
    }
}
