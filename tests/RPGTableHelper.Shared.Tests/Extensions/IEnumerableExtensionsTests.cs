using System;
using System.Collections.Generic;
using System.Linq;
using FluentAssertions;
using RPGTableHelper.Shared.Extensions;
using Xunit;

namespace RPGTableHelper.Shared.Tests.Extensions
{
    public class IEnumerableExtensionsTests
    {
        [Fact]
        public void RandomSample_ShouldReturnRequestedNumberOfElements()
        {
            // Arrange
            var items = new List<int> { 1, 2, 3, 4, 5 };
            int count = 3;

            // Act
            var result = items.RandomSample(count).ToList();

            // Assert
            result.Should().HaveCount(count);
        }

        [Fact]
        public void RandomSample_ShouldReturnAllElementsWhenCountEqualsListSize()
        {
            // Arrange
            var items = new List<int> { 1, 2, 3, 4, 5 };
            int count = items.Count;

            // Act
            var result = items.RandomSample(count).ToList();

            // Assert
            result.Should().HaveCount(items.Count);
            result.Should().BeEquivalentTo(items, options => options.WithoutStrictOrdering());
        }

        [Fact]
        public void RandomSample_ShouldThrowExceptionWhenCountIsZero()
        {
            // Arrange
            var items = new List<int> { 1, 2, 3, 4, 5 };
            int count = 0;

            // Act
            Action act = () => items.RandomSample(count).ToList();

            // Assert
            act.Should()
                .Throw<ArgumentOutOfRangeException>()
                .WithMessage(
                    "Specified argument was out of the range of valid values. (Parameter 'count')"
                );
        }

        [Fact]
        public void RandomSample_ShouldThrowExceptionWhenCountIsGreaterThanListSize()
        {
            // Arrange
            var items = new List<int> { 1, 2, 3, 4, 5 };
            int count = 10;

            // Act
            Action act = () => items.RandomSample(count).ToList();

            // Assert
            act.Should()
                .Throw<ArgumentOutOfRangeException>()
                .WithMessage(
                    "Specified argument was out of the range of valid values. (Parameter 'count')"
                );
        }

        [Fact]
        public void RandomSample_ShouldThrowExceptionWhenCountIsNegative()
        {
            // Arrange
            var items = new List<int> { 1, 2, 3, 4, 5 };
            int count = -1;

            // Act
            Action act = () => items.RandomSample(count).ToList();

            // Assert
            act.Should()
                .Throw<ArgumentOutOfRangeException>()
                .WithMessage(
                    "Specified argument was out of the range of valid values. (Parameter 'count')"
                );
        }

        [Fact]
        public void RandomSample_ShouldHandleEmptyList()
        {
            // Arrange
            var items = new List<int>();
            int count = 1;

            // Act
            Action act = () => items.RandomSample(count).ToList();

            // Assert
            act.Should()
                .Throw<ArgumentOutOfRangeException>()
                .WithMessage(
                    "Specified argument was out of the range of valid values. (Parameter 'count')"
                );
        }

        [Fact]
        public void RandomSample_ShouldNotReturnDuplicateItems()
        {
            // Arrange
            var items = new List<int> { 1, 2, 3, 4, 5 };
            int count = 3;

            // Act
            var result = items.RandomSample(count).ToList();

            // Assert
            result.Should().OnlyHaveUniqueItems();
        }

        [Fact]
        public void RandomSample_ShouldReturnItemsInRandomOrder()
        {
            // Arrange
            var items = new List<int> { 1, 2, 3, 4, 5 };
            int count = 3;

            // Act
            var firstSample = items.RandomSample(count).ToList();
            var secondSample = items.RandomSample(count).ToList();

            // Assert
            firstSample
                .Should()
                .NotEqual(
                    secondSample,
                    "random sampling should give different results in most cases"
                );
        }

        [Theory]
        [InlineData(1)]
        [InlineData(2)]
        [InlineData(5)]
        public void RandomSample_ShouldHandleVariousSampleSizes(int sampleSize)
        {
            // Arrange
            var items = new List<int> { 1, 2, 3, 4, 5 };

            // Act
            var result = items.RandomSample(sampleSize).ToList();

            // Assert
            result.Should().HaveCount(sampleSize);
        }
    }
}
