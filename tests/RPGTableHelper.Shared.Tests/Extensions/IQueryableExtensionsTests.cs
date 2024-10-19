using System;
using System.Collections.Generic;
using System.Linq;
using FluentAssertions;
using RPGTableHelper.Shared.Extensions;
using Xunit;

namespace RPGTableHelper.Shared.Tests.Extensions
{
    public class IQueryableExtensionsTests
    {
        [Fact]
        public void CountDistinct_ShouldReturnCorrectCountForDistinctItems_IQueryable()
        {
            // Arrange
            var items = new List<int> { 1, 2, 2, 3, 3, 3 }.AsQueryable();

            // Act
            var result = items.CountDistinct(x => x);

            // Assert
            result.Should().Be(3); // Distinct values are 1, 2, 3
        }

        [Fact]
        public void CountDistinct_ShouldReturnZeroForEmptyQueryable()
        {
            // Arrange
            var items = new List<int>().AsQueryable();

            // Act
            var result = items.CountDistinct(x => x);

            // Assert
            result.Should().Be(0);
        }

        [Fact]
        public void CountDistinct_ShouldReturnCorrectCountForDistinctItemsWithCustomKey_IQueryable()
        {
            // Arrange
            var items = new List<(int id, string name)>
            {
                (1, "Alice"),
                (2, "Bob"),
                (3, "Alice"), // Same name as id 1
                (4, "Charlie"),
                (
                    5,
                    "Bob"
                ) // Same name as id 2
                ,
            }.AsQueryable();

            // Act
            var result = items.CountDistinct(x => x.name);

            // Assert
            result.Should().Be(3); // Distinct names are "Alice", "Bob", "Charlie"
        }

        [Fact]
        public void CountDistinct_ShouldReturnOneForQueryableWithAllIdenticalItems()
        {
            // Arrange
            var items = new List<int> { 1, 1, 1, 1, 1 }.AsQueryable();

            // Act
            var result = items.CountDistinct(x => x);

            // Assert
            result.Should().Be(1);
        }

        [Fact]
        public void CountDistinct_ShouldReturnCorrectCountForDistinctItems_IEnumerable()
        {
            // Arrange
            var items = new List<int> { 1, 2, 2, 3, 3, 3 };

            // Act
            var result = items.CountDistinct(x => x);

            // Assert
            result.Should().Be(3); // Distinct values are 1, 2, 3
        }

        [Fact]
        public void CountDistinct_ShouldReturnZeroForEmptyEnumerable()
        {
            // Arrange
            var items = new List<int>();

            // Act
            var result = items.CountDistinct(x => x);

            // Assert
            result.Should().Be(0);
        }

        [Fact]
        public void CountDistinct_ShouldReturnCorrectCountForDistinctItemsWithCustomKey_IEnumerable()
        {
            // Arrange
            var items = new List<(int id, string name)>
            {
                (1, "Alice"),
                (2, "Bob"),
                (3, "Alice"), // Same name as id 1
                (4, "Charlie"),
                (
                    5,
                    "Bob"
                ) // Same name as id 2
                ,
            };

            // Act
            var result = items.CountDistinct(x => x.name);

            // Assert
            result.Should().Be(3); // Distinct names are "Alice", "Bob", "Charlie"
        }

        [Fact]
        public void CountDistinct_ShouldReturnOneForEnumerableWithAllIdenticalItems()
        {
            // Arrange
            var items = new List<int> { 1, 1, 1, 1, 1 };

            // Act
            var result = items.CountDistinct(x => x);

            // Assert
            result.Should().Be(1);
        }
    }
}
