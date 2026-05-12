using Microsoft.VisualStudio.TestTools.UnitTesting;
using MyOrg.Elements.MultiTenancy;

namespace Elements.MultiTenancy.Abstractions.Tests.Unit;

[TestClass]
public class GuidTenantIdParserTests {
    private GuidTenantIdParser _parser = null!;

    [TestInitialize]
    public void Setup() {
        _parser = new GuidTenantIdParser();
    }

    [TestMethod]
    public void Parse_WithValidGuid_ReturnsNormalizedGuid() {
        // Arrange
        var guid = Guid.NewGuid();
        var input = guid.ToString().ToUpper();

        // Act
        var result = _parser.Parse(input);

        // Assert
        Assert.AreEqual(guid.ToString("D"), result);
    }

    [TestMethod]
    public void Parse_WithGuidInDifferentFormat_ReturnsStandardFormat() {
        // Arrange
        var guid = Guid.NewGuid();
        var input = guid.ToString("N"); // Without hyphens

        // Act
        var result = _parser.Parse(input);

        // Assert
        Assert.AreEqual(guid.ToString("D"), result);
    }

    [TestMethod]
    public void Parse_WithInvalidGuid_ReturnsNull() {
        // Arrange
        var input = "not-a-guid";

        // Act
        var result = _parser.Parse(input);

        // Assert
        Assert.IsNull(result);
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
}