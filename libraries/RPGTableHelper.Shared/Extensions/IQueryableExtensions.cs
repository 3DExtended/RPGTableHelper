using System.Linq.Expressions;

namespace RPGTableHelper.Shared.Extensions
{
    public static class IQueryableExtensions
    {
        public static int CountDistinct<T, TKey>(
            this IQueryable<T> source,
            Expression<Func<T, TKey>> keySelector
        ) => source.Select(keySelector).Distinct().Count();

        public static int CountDistinct<T, TKey>(
            this IEnumerable<T> source,
            Func<T, TKey> keySelector
        ) => source.Select(keySelector).Distinct().Count();
    }
}
