namespace RPGTableHelper.Shared.Tests;

using AutoMapper;
using FluentAssertions;
using Prodot.Patterns.Cqrs;
using RPGTableHelper.DataLayer;

public class SharedMapperProfileTests
{
    private readonly IMapper _mapper;

    public SharedMapperProfileTests()
    {
        var config = new MapperConfiguration(cfg =>
        {
            cfg.AddProfile<SharedMapperProfile>();
        });

        _mapper = config.CreateMapper();
    }

    [Theory]
    [InlineData(0.0f)]
    [InlineData(1.0f)]
    [InlineData(-1.0f)]
    [InlineData(-1000.0f)]
    [InlineData(1000.0f)]
    public void FloatToOptionFloat_ShouldMapSuccessfully(float valueToTest)
    {
        // Arrange
        var value = valueToTest;

        // Act
        var floatOption = _mapper.Map<Option<float>>(value);

        // Assert
        floatOption.Should().NotBeNull();
        floatOption.IsSome.Should().BeTrue();
        floatOption.Get().Should().Be(value);
    }

    [Fact]
    public void FloatToOptionFloat_ShouldMapSuccessfullyNull()
    {
        // Arrange
        float? value = null;

        // Act
        var floatOption = _mapper.Map<Option<float>>(value);

        // Assert
        floatOption.Should().NotBeNull();
        floatOption.IsNone.Should().BeTrue();
    }

    [Fact]
    public void FloatOptionToFloat_ShouldMapSuccessfully()
    {
        // Arrange
        var value = Option.From(1234.0f);

        // Act
        var floatOption = _mapper.Map<float?>(value);

        // Assert
        floatOption.Should().NotBeNull();
        floatOption.Should().Be(value.Get());
    }

    [Fact]
    public void FloatOptionToFloat_ShouldMapSuccessfullyNull()
    {
        // Arrange
        var value = Option<float>.None;

        // Act
        var floatOption = _mapper.Map<float?>(value);

        // Assert
        floatOption.Should().BeNull();
    }

    [Theory]
    [InlineData(0.0)]
    [InlineData(1.0)]
    [InlineData(-1.0)]
    [InlineData(-1000.0)]
    [InlineData(1000.0)]
    public void DoubleToOptionDouble_ShouldMapSuccessfully(double valueToTest)
    {
        // Arrange
        var value = valueToTest;

        // Act
        var doubleOption = _mapper.Map<Option<double>>(value);

        // Assert
        doubleOption.Should().NotBeNull();
        doubleOption.IsSome.Should().BeTrue();
        doubleOption.Get().Should().Be(value);
    }

    [Fact]
    public void DoubleToOptionDouble_ShouldMapSuccessfullyNull()
    {
        // Arrange
        double? value = null;

        // Act
        var doubleOption = _mapper.Map<Option<double>>(value);

        // Assert
        doubleOption.Should().NotBeNull();
        doubleOption.IsNone.Should().BeTrue();
    }

    [Fact]
    public void DoubleOptionToDouble_ShouldMapSuccessfully()
    {
        // Arrange
        var value = Option.From(1234.0);

        // Act
        var doubleOption = _mapper.Map<double?>(value);

        // Assert
        doubleOption.Should().NotBeNull();
        doubleOption.Should().Be(value.Get());
    }

    [Fact]
    public void DoubleOptionToDouble_ShouldMapSuccessfullyNull()
    {
        // Arrange
        var value = Option<double>.None;

        // Act
        var doubleOption = _mapper.Map<double?>(value);

        // Assert
        doubleOption.Should().BeNull();
    }

    [Theory]
    [InlineData(2024, 10, 10)]
    [InlineData(2024, 10, 12)]
    [InlineData(2000, 10, 12)]
    public void DateOnlyToOptionDateOnly_ShouldMapSuccessfully(
        int valueToTest1,
        int valueToTest2,
        int valueToTest3
    )
    {
        // Arrange
        var value = new DateOnly(valueToTest1, valueToTest2, valueToTest3);

        // Act
        var dateOnlyOption = _mapper.Map<Option<DateOnly>>(value);

        // Assert
        dateOnlyOption.Should().NotBeNull();
        dateOnlyOption.IsSome.Should().BeTrue();
        dateOnlyOption.Get().Should().Be(value);
    }

    [Fact]
    public void DateOnlyToOptionDateOnly_ShouldMapSuccessfullyNull()
    {
        // Arrange
        DateOnly? value = null;

        // Act
        var dateOnlyOption = _mapper.Map<Option<DateOnly>>(value);

        // Assert
        dateOnlyOption.Should().NotBeNull();
        dateOnlyOption.IsNone.Should().BeTrue();
    }

    [Fact]
    public void DateOnlyOptionToDateOnly_ShouldMapSuccessfully()
    {
        // Arrange
        var value = Option.From(new DateOnly(2024, 10, 10));

        // Act
        var dateOnlyOption = _mapper.Map<DateOnly?>(value);

        // Assert
        dateOnlyOption.Should().NotBeNull();
        dateOnlyOption.Should().Be(value.Get());
    }

    [Fact]
    public void DateOnlyOptionToDateOnly_ShouldMapSuccessfullyNull()
    {
        // Arrange
        var value = Option<DateOnly>.None;

        // Act
        var dateOnlyOption = _mapper.Map<DateOnly?>(value);

        // Assert
        dateOnlyOption.Should().BeNull();
    }

    [Theory]
    [InlineData(true)]
    [InlineData(false)]
    public void BoolToOptionBool_ShouldMapSuccessfully(bool valueToTest1)
    {
        // Arrange
        var value = valueToTest1;

        // Act
        var boolOption = _mapper.Map<Option<bool>>(value);

        // Assert
        boolOption.Should().NotBeNull();
        boolOption.IsSome.Should().BeTrue();
        boolOption.Get().Should().Be(value);
    }

    [Fact]
    public void BoolToOptionBool_ShouldMapSuccessfullyNull()
    {
        // Arrange
        bool? value = null;

        // Act
        var boolOption = _mapper.Map<Option<bool>>(value);

        // Assert
        boolOption.Should().NotBeNull();
        boolOption.IsNone.Should().BeTrue();
    }

    [Fact]
    public void BoolOptionToBool_ShouldMapSuccessfully()
    {
        // Arrange
        var value = Option.From(true);

        // Act
        var boolOption = _mapper.Map<bool?>(value);

        // Assert
        boolOption.Should().NotBeNull();
        boolOption.Should().Be(value.Get());
    }

    [Fact]
    public void BoolOptionToBool_ShouldMapSuccessfullyNull()
    {
        // Arrange
        var value = Option<bool>.None;

        // Act
        var boolOption = _mapper.Map<bool?>(value);

        // Assert
        boolOption.Should().BeNull();
    }
}
