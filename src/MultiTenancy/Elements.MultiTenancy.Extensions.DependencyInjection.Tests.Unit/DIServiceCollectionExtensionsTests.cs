using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.VisualStudio.TestTools.UnitTesting;
using MyOrg.Elements.Configuration;
using MyOrg.Elements.MultiTenancy;
using MyOrg.Elements.MultiTenancy.DependencyInjection;

namespace Elements.MultiTenancy.Extensions.DependencyInjection.Tests.Unit;

[TestClass]
public class DIServiceCollectionExtensionsTests {
    private interface IMessagingService {
        string GetInfo();
    }

    private class KafkaService(KafkaOptions options) : IMessagingService {
        public string GetInfo() => $"kafka:{options.BootstrapServers}";
    }

    private class RabbitMqService(RabbitMqOptions options) : IMessagingService {
        public string GetInfo() => $"rabbit:{options.Host}";
    }

    private class KafkaOptions {
        public string BootstrapServers { get; set; } = "";
    }

    private class RabbitMqOptions {
        public string Host { get; set; } = "";
    }

    private class TestOptions {
        public string Value { get; set; } = "";
    }

    private class TestTenantConfig {
        public string Name { get; set; } = "";
    }

    // === AddKeyedTenantServiceResolver ===

    [TestMethod]
    public void AddKeyedTenantServiceResolver_RegistersResolver() {
        var services = new ServiceCollection();
        services.AddSingleton<ITenantContextAccessor, TenantContextAccessor>();
        services.AddKeyedSingleton<IMessagingService>("tenant1",
            (_, _) => new KafkaService(new KafkaOptions { BootstrapServers = "kafka:9092" }));

        services.AddKeyedTenantServiceResolver<IMessagingService>();
        using var provider = services.BuildServiceProvider();

        var resolver = provider.GetService<ITenantServiceResolver<IMessagingService>>();
        Assert.IsNotNull(resolver);
        Assert.IsInstanceOfType<KeyedTenantServiceResolver<IMessagingService>>(resolver);
    }

    // === AddFactoryTenantServiceResolver ===

    [TestMethod]
    public void AddFactoryTenantServiceResolver_RegistersResolver() {
        var services = new ServiceCollection();
        services.AddSingleton<ITenantContextAccessor, TenantContextAccessor>();

        services.AddFactoryTenantServiceResolver<IMessagingService>(builder => {
            builder.ForTenant("tenant1",
                sp => new KafkaService(new KafkaOptions { BootstrapServers = "kafka:9092" }));
        });
        using var provider = services.BuildServiceProvider();

        var resolver = provider.GetService<ITenantServiceResolver<IMessagingService>>();
        Assert.IsNotNull(resolver);
        Assert.IsInstanceOfType<FactoryTenantServiceResolver<IMessagingService>>(resolver);
    }

    // === AddConfigurationTenantStore ===

    [TestMethod]
    public void AddConfigurationTenantStore_RegistersStore() {
        var config = new ConfigurationBuilder()
            .AddInMemoryCollection(new Dictionary<string, string?> {
                ["Tenants:tenant1:Name"] = "Tenant One",
            })
            .Build();

        var services = new ServiceCollection();
        services.AddSingleton<IConfiguration>(config);
        services.AddConfigurationTenantStore<TestTenantConfig>();
        using var provider = services.BuildServiceProvider();

        var store = provider.GetService<ITenantStore<TestTenantConfig>>();
        Assert.IsNotNull(store);
    }

    [TestMethod]
    public void AddConfigurationTenantStore_GetAllTenantIds_ReturnsConfiguredTenants() {
        var config = new ConfigurationBuilder()
            .AddInMemoryCollection(new Dictionary<string, string?> {
                ["Tenants:t1:Name"] = "A",
                ["Tenants:t2:Name"] = "B",
            })
            .Build();

        var services = new ServiceCollection();
        services.AddSingleton<IConfiguration>(config);
        services.AddConfigurationTenantStore<TestTenantConfig>();
        using var provider = services.BuildServiceProvider();

        var store = provider.GetRequiredService<ITenantStore<TestTenantConfig>>();
        var ids = store.GetAllTenantIds().ToList();

        Assert.AreEqual(2, ids.Count);
        Assert.IsTrue(ids.Contains("t1"));
        Assert.IsTrue(ids.Contains("t2"));
    }

    // === AddTenantOptions ===

    [TestMethod]
    public void AddTenantOptions_BindsPerTenantOptions() {
        var config = new ConfigurationBuilder()
            .AddInMemoryCollection(new Dictionary<string, string?> {
                ["Tenants:tenant1:Settings:Value"] = "one",
                ["Tenants:tenant2:Settings:Value"] = "two",
            })
            .Build();

        var accessor = new TenantContextAccessor();
        accessor.TenantContext = new TenantContext("tenant1");

        var services = new ServiceCollection();
        services.AddSingleton<ITenantContextAccessor>(accessor);
        services.AddTenantOptions<TestOptions>(config, "Settings");
        using var provider = services.BuildServiceProvider();

        var tenantOptions = provider.GetRequiredService<TenantOptions<TestOptions>>();
        Assert.AreEqual("one", tenantOptions.Value.Value);

        // Switch tenant
        accessor.TenantContext = new TenantContext("tenant2");
        Assert.AreEqual("two", tenantOptions.Value.Value);
    }

    // === AddPolymorphicTenantService ===

    [TestMethod]
    public void AddPolymorphicTenantService_RegistersPerTenantImplementations() {
        var config = new ConfigurationBuilder()
            .AddInMemoryCollection(new Dictionary<string, string?> {
                ["Tenants:tenant-a:Messaging:Provider"] = "Kafka",
                ["Tenants:tenant-a:Messaging:Settings:BootstrapServers"] = "kafka:9092",
                ["Tenants:tenant-b:Messaging:Provider"] = "RabbitMQ",
                ["Tenants:tenant-b:Messaging:Settings:Host"] = "rabbit.local",
            })
            .Build();

        var accessor = new TenantContextAccessor();
        var services = new ServiceCollection();
        services.AddSingleton<ITenantContextAccessor>(accessor);
        services.AddPolymorphicTenantService<IMessagingService>(config, "Messaging", b =>
            b.AddProvider<KafkaService, KafkaOptions>("Kafka")
             .AddProvider<RabbitMqService, RabbitMqOptions>("RabbitMQ"));
        using var provider = services.BuildServiceProvider();

        // Resolve via ITenantServiceResolver
        var resolver = provider.GetRequiredService<ITenantServiceResolver<IMessagingService>>();

        var tenantAService = resolver.Resolve("tenant-a");
        Assert.IsInstanceOfType<KafkaService>(tenantAService);
        Assert.AreEqual("kafka:kafka:9092", tenantAService.GetInfo());

        var tenantBService = resolver.Resolve("tenant-b");
        Assert.IsInstanceOfType<RabbitMqService>(tenantBService);
        Assert.AreEqual("rabbit:rabbit.local", tenantBService.GetInfo());
    }

    [TestMethod]
    public void AddPolymorphicTenantService_ResolvesCurrentTenant() {
        var config = new ConfigurationBuilder()
            .AddInMemoryCollection(new Dictionary<string, string?> {
                ["Tenants:tenant-a:Messaging:Provider"] = "Kafka",
                ["Tenants:tenant-a:Messaging:Settings:BootstrapServers"] = "kafka:9092",
            })
            .Build();

        var accessor = new TenantContextAccessor();
        accessor.TenantContext = new TenantContext("tenant-a");

        var services = new ServiceCollection();
        services.AddSingleton<ITenantContextAccessor>(accessor);
        services.AddPolymorphicTenantService<IMessagingService>(config, "Messaging", b =>
            b.AddProvider<KafkaService, KafkaOptions>("Kafka"));
        using var provider = services.BuildServiceProvider();

        var resolver = provider.GetRequiredService<ITenantServiceResolver<IMessagingService>>();
        var service = resolver.ResolveCurrent();

        Assert.IsInstanceOfType<KafkaService>(service);
        Assert.AreEqual("kafka:kafka:9092", service.GetInfo());
    }

    [TestMethod]
    public void AddPolymorphicTenantService_MissingProvider_Throws() {
        var config = new ConfigurationBuilder()
            .AddInMemoryCollection(new Dictionary<string, string?> {
                ["Tenants:tenant-a:Messaging:Provider"] = "Unknown",
            })
            .Build();

        var services = new ServiceCollection();
        services.AddSingleton<ITenantContextAccessor, TenantContextAccessor>();

        Assert.ThrowsExactly<InvalidOperationException>(() =>
            services.AddPolymorphicTenantService<IMessagingService>(config, "Messaging", b =>
                b.AddProvider<KafkaService, KafkaOptions>("Kafka")));
    }

    [TestMethod]
    public void AddPolymorphicTenantService_SkipsTenantWithoutServiceSection() {
        var config = new ConfigurationBuilder()
            .AddInMemoryCollection(new Dictionary<string, string?> {
                ["Tenants:tenant-a:Messaging:Provider"] = "Kafka",
                ["Tenants:tenant-a:Messaging:Settings:BootstrapServers"] = "kafka:9092",
                ["Tenants:tenant-b:Name"] = "Tenant B",
            })
            .Build();

        var accessor = new TenantContextAccessor();
        var services = new ServiceCollection();
        services.AddSingleton<ITenantContextAccessor>(accessor);

        // Should not throw — tenant-b has no Messaging section and is skipped
        services.AddPolymorphicTenantService<IMessagingService>(config, "Messaging", b =>
            b.AddProvider<KafkaService, KafkaOptions>("Kafka"));
        using var provider = services.BuildServiceProvider();

        var resolver = provider.GetRequiredService<ITenantServiceResolver<IMessagingService>>();
        var service = resolver.Resolve("tenant-a");
        Assert.IsInstanceOfType<KafkaService>(service);
    }
}