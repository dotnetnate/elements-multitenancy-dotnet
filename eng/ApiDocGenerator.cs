using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Reflection;
using System.Text;
using System.Xml.Linq;

class ApiDocGenerator
{
    static void Main(string[] args)
    {
        var sourceRoot = @"L:\repos\elements-dotnet\src\applicationmodel";
        var docsRoot = @"L:\repos\elements-dotnet\docs\applicationmodel";
        var binRoot = @"L:\repos\elements-dotnet\artifacts\bin";
        
        var projects = new[]
        {
            "Elements.ApplicationModel.Abstractions",
            "Elements.ApplicationModel.DomainDriven",
            "Elements.ApplicationModel.EventSourcing.Abstractions",
            "Elements.ApplicationModel.CQRS",
            "Elements.ApplicationModel.EventSourcing.Daemon",
            "Elements.ApplicationModel.EventSourcing.Extensions.Kafka",
            "Elements.ApplicationModel.EventSourcing.Extensions.MongoDB",
            "Elements.ApplicationModel.EventSourcing.Hosting",
            "Elements.ApplicationModel.Extensions.AspNet",
            "Elements.ApplicationModel.Extensions.Console",
            "Elements.ApplicationModel.Extensions.GraphQL",
            "Elements.ApplicationModel.Extensions.Grpc",
            "Elements.ApplicationModel.Extensions.Mcp",
            "Elements.ApplicationModel.Templates"
        };
        
        Directory.CreateDirectory(docsRoot);
        
        int totalTypes = 0;
        int totalMembers = 0;
        var filesCreated = new List<string>();
        
        foreach (var project in projects)
        {
            Console.WriteLine($"Processing {project}...");
            
            // Look for built assembly
            var assemblyPath = Directory.GetFiles(binRoot, $"{project}.dll", SearchOption.AllDirectories)
                .Where(f => f.Contains("Release") && !f.Contains("Tests"))
                .OrderByDescending(f => new FileInfo(f).LastWriteTime)
                .FirstOrDefault();
            
            if (assemblyPath == null || !File.Exists(assemblyPath))
            {
                Console.WriteLine($"  Warning: Assembly not found for {project}");
                continue;
            }
            
            var asm = Assembly.LoadFrom(assemblyPath);
            var xmlPath = Path.ChangeExtension(assemblyPath, ".xml");
            XDocument xmlDocs = File.Exists(xmlPath) ? XDocument.Load(xmlPath) : null;
            
            var publicTypes = asm.GetExportedTypes()
                .Where(t => t.IsPublic && !t.Name.Contains("<") && !t.Name.Contains("__"));
            
            var typesList = publicTypes.ToList();
            Console.WriteLine($"  Found {typesList.Count} public types");
            
            // Generate project overview
            GenerateProjectOverview(docsRoot, project, typesList, xmlDocs);
            filesCreated.Add(Path.Combine(docsRoot, $"{project}.md"));
            
            foreach (var type in typesList)
            {
                // Type page
                GenerateTypePage(docsRoot, project, type, xmlDocs);
                filesCreated.Add(Path.Combine(docsRoot, $"{project}.{type.Name}.md"));
                totalTypes++;
                
                // Member pages
                var members = type.GetMembers(BindingFlags.Public | BindingFlags.Instance | BindingFlags.Static | BindingFlags.DeclaredOnly);
                foreach (var member in members)
                {
                    GenerateMemberPage(docsRoot, project, type, member, xmlDocs);
                    filesCreated.Add(Path.Combine(docsRoot, $"{project}.{type.Name}.{member.Name}.md"));
                    totalMembers++;
                }
            }
        }
        
        Console.WriteLine($"\n=== Complete ===");
        Console.WriteLine($"Types: {totalTypes}");
        Console.WriteLine($"Members: {totalMembers}");
        Console.WriteLine($"Files: {filesCreated.Count}");
    }
    
    static void GenerateProjectOverview(string docsRoot, string project, List<Type> types, XDocument xmlDocs)
    {
        var sb = new StringBuilder();
        sb.AppendLine($"# {project}");
        sb.AppendLine();
        sb.AppendLine($"**Assembly:** {project}.dll");
        sb.AppendLine();
        sb.AppendLine("## Overview");
        sb.AppendLine();
        sb.AppendLine($"This assembly provides functionality for the Elements .NET framework application model.");
        sb.AppendLine();
        sb.AppendLine("## Types");
        sb.AppendLine();
        sb.AppendLine("| Type | Description |");
        sb.AppendLine("| --- | --- |");
        
        foreach (var type in types.OrderBy(t => t.Name))
        {
            var summary = GetXmlSummary(type, xmlDocs) ?? $"Represents the {type.Name} type.";
            sb.AppendLine($"| [{type.Name}]({project}.{type.Name}.md) | {summary} |");
        }
        
        File.WriteAllText(Path.Combine(docsRoot, $"{project}.md"), sb.ToString());
    }
    
    static void GenerateTypePage(string docsRoot, string project, Type type, XDocument xmlDocs)
    {
        var sb = new StringBuilder();
        var kind = type.IsInterface ? "Interface" : type.IsEnum ? "Enum" : type.IsValueType ? "Struct" : "Class";
        
       sb.AppendLine($"# {type.Name} {kind}");
        sb.AppendLine();
        sb.AppendLine($"**Namespace:** {type.Namespace}");
        sb.AppendLine();
        sb.AppendLine($"**Assembly:** {project}.dll");
        sb.AppendLine();
        
        var summary = GetXmlSummary(type, xmlDocs) ?? $"Represents the {type.Name} {kind.ToLower()}.";
        sb.AppendLine(summary);
        sb.AppendLine();
        
        sb.AppendLine("```csharp");
        sb.AppendLine($"public {kind.ToLower()} {type.Name}");
        sb.AppendLine("```");
        sb.AppendLine();
        
        // Members
        var constructors = type.GetConstructors(BindingFlags.Public | BindingFlags.Instance);
        if (constructors.Any())
        {
            sb.AppendLine("## Constructors");
            sb.AppendLine();
            sb.AppendLine("| Name | Description |");
            sb.AppendLine("| --- | --- |");
            foreach (var ctor in constructors)
            {
                var ctorSummary = GetXmlSummary(ctor, xmlDocs) ?? "Initializes a new instance.";
                sb.AppendLine($"| [{type.Name}()]({project}.{type.Name}.{type.Name}.md) | {ctorSummary} |");
            }
            sb.AppendLine();
        }
        
        var properties = type.GetProperties(BindingFlags.Public | BindingFlags.Instance | BindingFlags.Static | BindingFlags.DeclaredOnly);
        if (properties.Any())
        {
            sb.AppendLine("## Properties");
            sb.AppendLine();
            sb.AppendLine("| Name | Type | Description |");
            sb.AppendLine("| --- | --- | --- |");
            foreach (var prop in properties.OrderBy(p => p.Name))
            {
                var propSummary = GetXmlSummary(prop, xmlDocs) ?? $"Gets or sets the {prop.Name}.";
                sb.AppendLine($"| [{prop.Name}]({project}.{type.Name}.{prop.Name}.md) | `{prop.PropertyType.Name}` | {propSummary} |");
            }
            sb.AppendLine();
        }
        
        var methods = type.GetMethods(BindingFlags.Public | BindingFlags.Instance | BindingFlags.Static | BindingFlags.DeclaredOnly)
            .Where(m => !m.IsSpecialName);
        if (methods.Any())
        {
            sb.AppendLine("## Methods");
            sb.AppendLine();
            sb.AppendLine("| Name | Description |");
            sb.AppendLine("| --- | --- |");
            foreach (var method in methods.OrderBy(m => m.Name))
            {
                var methodSummary = GetXmlSummary(method, xmlDocs) ?? $"Executes the {method.Name} operation.";
                sb.AppendLine($"| [{method.Name}()]({project}.{type.Name}.{method.Name}.md) | {methodSummary} |");
            }
            sb.AppendLine();
        }
        
        sb.AppendLine("## See Also");
        sb.AppendLine();
        sb.AppendLine($"- [{project}]({project}.md)");
        
        File.WriteAllText(Path.Combine(docsRoot, $"{project}.{type.Name}.md"), sb.ToString());
    }
    
    static void GenerateMemberPage(string docsRoot, string project, Type type, MemberInfo member, XDocument xmlDocs)
    {
        var sb = new StringBuilder();
        var kind = member.MemberType.ToString();
        
        sb.AppendLine($"# {type.Name}.{member.Name} {kind}");
        sb.AppendLine();
        sb.AppendLine($"**Namespace:** {type.Namespace}");
        sb.AppendLine();
        sb.AppendLine($"**Assembly:** {project}.dll");
        sb.AppendLine();
        
        var summary = GetXmlSummary(member, xmlDocs) ?? $"Represents the {member.Name} {kind.ToLower()}.";
        sb.AppendLine(summary);
        sb.AppendLine();
        
        sb.AppendLine("```csharp");
        sb.AppendLine($"public {member.Name}");
        sb.AppendLine("```");
        sb.AppendLine();
        
        sb.AppendLine("## See Also");
        sb.AppendLine();
        sb.AppendLine($"- [{type.Name}]({project}.{type.Name}.md)");
        sb.AppendLine($"- [{project}]({project}.md)");
        
        File.WriteAllText(Path.Combine(docsRoot, $"{project}.{type.Name}.{member.Name}.md"), sb.ToString());
    }
    
    static string GetXmlSummary(MemberInfo member, XDocument xmlDocs)
    {
        if (xmlDocs == null) return null;
        
        var memberName = member is Type t ? $"T:{t.FullName}" : 
            member is MethodInfo m ? $"M:{m.DeclaringType.FullName}.{m.Name}" :
            member is PropertyInfo p ? $"P:{p.DeclaringType.FullName}.{p.Name}" :
            $"M:{member.DeclaringType.FullName}.{member.Name}";
        
        var elem = xmlDocs.Descendants("member")
            .FirstOrDefault(e => e.Attribute("name")?.Value == memberName);
        
        return elem?.Element("summary")?.Value?.Trim();
    }
}
