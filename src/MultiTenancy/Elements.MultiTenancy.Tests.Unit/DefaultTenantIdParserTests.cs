using Microsoft.VisualStudio.TestTools.UnitTesting;
using MyOrg.Elements.MultiTenancy;

namespace Elements.MultiTenancy.Abstractions.Tests.Unit;

[TestClass]
public class DefaultTenantIdParserTests {
    private DefaultTenantIdParser _parser = null!;

    [TestInitialize]
    public void Setup() {
        _parser = new DefaultTenantIdParser();
    }

    [TestMethod]
    public void Parse_WithValidTenantId_ReturnsTrimmedValue() {
        // Arrange
        var input = "  tenant123  ";

        // Act
        var result = _parser.Parse(input);

        // Assert
        Assert.AreEqual("tenant123", result);
    }

    [TestMethod]
    public void Parse_WithNullValue_ReturnsNull() {
        // Act
        var result = _parser.Parse(null);

        // Assert
        Assert.IsNull(result);
    }

    [TestMethod]
    public void Parse_WithWhitespace_ReturnsNull() {
        // Act
        var result = _parser.Parse("   ");

        // Assert
        Assert.IsNull(result);
    }

    [TestMethod]
    public void Parse_WithEmptyString_ReturnsNull() {
        // Act
        var result = _parser.Parse(string.Empty);

        // Assert
        Assert.IsNull(result);
    }
}