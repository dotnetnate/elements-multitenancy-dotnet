using System.Collections.Immutable;
using System.Text.Encodings.Web;
using System.Text.Json;
using System.Text.Json.Serialization;
using Microsoft.CodeAnalysis;
using Microsoft.CodeAnalysis.CSharp;
using Microsoft.CodeAnalysis.CSharp.Syntax;

// docsurface --project <path-to-project-dir-or-csproj> --assembly-name <name> --output <surface.json>
// Pure Roslyn syntax scan. No reflection. No assembly loading.
// Emits the public/protected API surface of the project so the doc generator
// can render property/field/return types and filter non-public symbols.

string? projectArg = null;
string? assemblyName = null;
string? output = null;

for (int i = 0; i < args.Length; i++)
{
    switch (args[i])
    {
        case "--project": projectArg = args[++i]; break;
        case "--assembly-name": assemblyName = args[++i]; break;
        case "--output": output = args[++i]; break;
        default: Console.Error.WriteLine($"unknown argument: {args[i]}"); return 2;
    }
}

if (string.IsNullOrWhiteSpace(projectArg) || string.IsNullOrWhiteSpace(output))
{
    Console.Error.WriteLine("usage: docsurface --project <dir-or-csproj> --output <file> [--assembly-name <name>]");
    return 2;
}

string projectDir;
if (Directory.Exists(projectArg))
{
    projectDir = Path.GetFullPath(projectArg);
}
else if (File.Exists(projectArg) && projectArg.EndsWith(".csproj", StringComparison.OrdinalIgnoreCase))
{
    projectDir = Path.GetDirectoryName(Path.GetFullPath(projectArg))!;
    assemblyName ??= Path.GetFileNameWithoutExtension(projectArg);
}
else
{
    Console.Error.WriteLine($"project path not found: {projectArg}");
    return 2;
}

assemblyName ??= new DirectoryInfo(projectDir).Name;

var sourceFiles = EnumerateSourceFiles(projectDir).ToArray();
var collector = new SurfaceCollector();
foreach (var file in sourceFiles)
{
    string text;
    try { text = File.ReadAllText(file); }
    catch { continue; }
    var tree = CSharpSyntaxTree.ParseText(text, path: file);
    var root = tree.GetCompilationUnitRoot();
    collector.Visit(root, defaultNamespace: null, containingType: null);
}

var surface = new SurfaceDocument
{
    AssemblyName = assemblyName,
    DefaultNamespace = collector.MostCommonNamespace(),
    Types = collector.Types
        .OrderBy(t => t.DocId, StringComparer.Ordinal)
        .ToList(),
};

var json = JsonSerializer.Serialize(surface, SurfaceJsonContext.Default.SurfaceDocument);
Directory.CreateDirectory(Path.GetDirectoryName(Path.GetFullPath(output))!);
File.WriteAllText(output, json);
Console.WriteLine($"surface written: {output} (types={surface.Types.Count}, files={sourceFiles.Length})");
return 0;

static IEnumerable<string> EnumerateSourceFiles(string dir)
{
    foreach (var f in Directory.EnumerateFiles(dir, "*.cs", SearchOption.AllDirectories))
    {
        var rel = Path.GetRelativePath(dir, f).Replace('\\', '/');
        if (rel.StartsWith("bin/", StringComparison.OrdinalIgnoreCase)) continue;
        if (rel.StartsWith("obj/", StringComparison.OrdinalIgnoreCase)) continue;
        if (rel.Contains("/bin/", StringComparison.OrdinalIgnoreCase)) continue;
        if (rel.Contains("/obj/", StringComparison.OrdinalIgnoreCase)) continue;
        if (rel.EndsWith(".g.cs", StringComparison.OrdinalIgnoreCase)) continue;
        if (rel.EndsWith(".Designer.cs", StringComparison.OrdinalIgnoreCase)) continue;
        yield return f;
    }
}

sealed class SurfaceCollector
{
    public List<TypeSurface> Types { get; } = new();
    private readonly Dictionary<string, int> _nsCounts = new(StringComparer.Ordinal);

    public string? MostCommonNamespace()
        => _nsCounts.Count == 0 ? null : _nsCounts.OrderByDescending(kv => kv.Value).ThenBy(kv => kv.Key, StringComparer.Ordinal).First().Key;

    public void Visit(SyntaxNode node, string? defaultNamespace, TypeSurface? containingType)
    {
        foreach (var child in node.ChildNodes())
        {
            switch (child)
            {
                case BaseNamespaceDeclarationSyntax nsDecl:
                    Visit(nsDecl, nsDecl.Name.ToString(), containingType);
                    break;
                case BaseTypeDeclarationSyntax tDecl:
                    VisitType(tDecl, defaultNamespace, containingType);
                    break;
                case DelegateDeclarationSyntax dDecl:
                    VisitDelegate(dDecl, defaultNamespace, containingType);
                    break;
            }
        }
    }

    private void VisitType(BaseTypeDeclarationSyntax tDecl, string? ns, TypeSurface? containingType)
    {
        string vis = Visibility(tDecl.Modifiers, containingType);
        if (!IsExternallyVisible(vis, containingType)) return;

        string kind = tDecl switch
        {
            ClassDeclarationSyntax c when c.Modifiers.Any(m => m.IsKind(SyntaxKind.RecordKeyword)) => "record",
            ClassDeclarationSyntax => "class",
            StructDeclarationSyntax s when s.Modifiers.Any(m => m.IsKind(SyntaxKind.RecordKeyword)) => "record struct",
            StructDeclarationSyntax => "struct",
            InterfaceDeclarationSyntax => "interface",
            EnumDeclarationSyntax => "enum",
            RecordDeclarationSyntax r when r.ClassOrStructKeyword.IsKind(SyntaxKind.StructKeyword) => "record struct",
            RecordDeclarationSyntax => "record",
            _ => "type",
        };

        var typeParams = GetTypeParameters(tDecl);
        int arity = typeParams.Count;
        string nameOnly = tDecl.Identifier.ValueText;
        string fullName;
        if (containingType != null)
        {
            // nested: append with '+' convention in metadata but we use '.' for doc ids
            fullName = containingType.FullNameArityStripped + "." + nameOnly;
        }
        else
        {
            fullName = string.IsNullOrEmpty(ns) ? nameOnly : ns + "." + nameOnly;
        }

        string docId = "T:" + fullName + (arity > 0 ? "`" + arity : "");

        if (!string.IsNullOrEmpty(ns))
        {
            _nsCounts[ns!] = _nsCounts.TryGetValue(ns!, out var c) ? c + 1 : 1;
        }

        var mods = tDecl.Modifiers.Select(m => m.ValueText).ToHashSet(StringComparer.Ordinal);

        var type = new TypeSurface
        {
            DocId = docId,
            Namespace = ns ?? string.Empty,
            Name = nameOnly,
            FullNameArityStripped = fullName,
            Arity = arity,
            Kind = kind,
            Visibility = vis,
            IsStatic = mods.Contains("static"),
            IsAbstract = mods.Contains("abstract"),
            IsSealed = mods.Contains("sealed"),
            IsPartial = mods.Contains("partial"),
            IsReadOnly = mods.Contains("readonly"),
            TypeParameters = typeParams,
            BaseTypes = GetBaseTypes(tDecl),
        };

        // dedupe by docId (partial classes)
        var existing = Types.FirstOrDefault(t => t.DocId == docId);
        if (existing == null)
        {
            Types.Add(type);
            existing = type;
        }

        // Visit members
        if (tDecl is TypeDeclarationSyntax typeDecl)
        {
            foreach (var mem in typeDecl.Members)
            {
                VisitMember(mem, existing, ns);
            }
        }
        else if (tDecl is EnumDeclarationSyntax enumDecl)
        {
            foreach (var mem in enumDecl.Members)
            {
                var memberDocId = "F:" + existing.FullNameArityStripped + "." + mem.Identifier.ValueText;
                existing.Members.Add(new MemberSurface
                {
                    DocId = memberDocId,
                    Name = mem.Identifier.ValueText,
                    Kind = "field",
                    Visibility = "public",
                    ReturnType = existing.Name,
                    IsStatic = true,
                });
            }
        }

        // record positional parameters become public init-only properties
        if (tDecl is RecordDeclarationSyntax rec && rec.ParameterList != null)
        {
            foreach (var p in rec.ParameterList.Parameters)
            {
                existing.Members.Add(new MemberSurface
                {
                    DocId = "P:" + existing.FullNameArityStripped + "." + p.Identifier.ValueText,
                    Name = p.Identifier.ValueText,
                    Kind = "property",
                    Visibility = "public",
                    ReturnType = p.Type?.ToString() ?? "",
                });
            }
        }
    }

    private void VisitDelegate(DelegateDeclarationSyntax dDecl, string? ns, TypeSurface? containingType)
    {
        string vis = Visibility(dDecl.Modifiers, containingType);
        if (!IsExternallyVisible(vis, containingType)) return;

        int arity = dDecl.TypeParameterList?.Parameters.Count ?? 0;
        string nameOnly = dDecl.Identifier.ValueText;
        string fullName = containingType != null
            ? containingType.FullNameArityStripped + "." + nameOnly
            : (string.IsNullOrEmpty(ns) ? nameOnly : ns + "." + nameOnly);

        var type = new TypeSurface
        {
            DocId = "T:" + fullName + (arity > 0 ? "`" + arity : ""),
            Namespace = ns ?? string.Empty,
            Name = nameOnly,
            FullNameArityStripped = fullName,
            Arity = arity,
            Kind = "delegate",
            Visibility = vis,
            TypeParameters = dDecl.TypeParameterList?.Parameters.Select(p => p.Identifier.ValueText).ToList() ?? new List<string>(),
            ReturnType = dDecl.ReturnType.ToString(),
            Parameters = dDecl.ParameterList.Parameters.Select(p => new ParameterSurface
            {
                Name = p.Identifier.ValueText,
                Type = p.Type?.ToString() ?? "",
                Modifier = ParamModifier(p.Modifiers),
            }).ToList(),
        };

        if (!string.IsNullOrEmpty(ns))
        {
            _nsCounts[ns!] = _nsCounts.TryGetValue(ns!, out var c) ? c + 1 : 1;
        }

        Types.Add(type);
    }

    private void VisitMember(MemberDeclarationSyntax mem, TypeSurface declaringType, string? ns)
    {
        switch (mem)
        {
            case BaseTypeDeclarationSyntax nested:
                VisitType(nested, ns, declaringType);
                break;
            case DelegateDeclarationSyntax nestedDel:
                VisitDelegate(nestedDel, ns, declaringType);
                break;
            case ConstructorDeclarationSyntax ctor:
                AddMethodLike(declaringType, "constructor", "#ctor", ctor.Modifiers, ctor.ParameterList, null, null, ctor);
                break;
            case MethodDeclarationSyntax method:
                {
                    var typeArgs = method.TypeParameterList?.Parameters.Select(p => p.Identifier.ValueText).ToList();
                    AddMethodLike(declaringType, "method", method.Identifier.ValueText, method.Modifiers, method.ParameterList,
                        method.ReturnType.ToString(), typeArgs, method);
                }
                break;
            case OperatorDeclarationSyntax op:
                AddMethodLike(declaringType, "operator", "op_" + op.OperatorToken.ValueText, op.Modifiers, op.ParameterList,
                    op.ReturnType.ToString(), null, op);
                break;
            case ConversionOperatorDeclarationSyntax conv:
                {
                    string name = conv.ImplicitOrExplicitKeyword.IsKind(SyntaxKind.ImplicitKeyword) ? "op_Implicit" : "op_Explicit";
                    AddMethodLike(declaringType, "operator", name, conv.Modifiers, conv.ParameterList, conv.Type.ToString(), null, conv);
                }
                break;
            case PropertyDeclarationSyntax prop:
                {
                    string vis = Visibility(prop.Modifiers, declaringType);
                    if (!IsExternallyVisible(vis, declaringType)) return;
                    declaringType.Members.Add(new MemberSurface
                    {
                        DocId = "P:" + declaringType.FullNameArityStripped + "." + prop.Identifier.ValueText,
                        Name = prop.Identifier.ValueText,
                        Kind = "property",
                        Visibility = vis,
                        ReturnType = prop.Type.ToString(),
                        IsStatic = prop.Modifiers.Any(m => m.IsKind(SyntaxKind.StaticKeyword)),
                        HasGetter = prop.AccessorList?.Accessors.Any(a => a.IsKind(SyntaxKind.GetAccessorDeclaration)) ?? (prop.ExpressionBody != null),
                        HasSetter = prop.AccessorList?.Accessors.Any(a => a.IsKind(SyntaxKind.SetAccessorDeclaration) || a.IsKind(SyntaxKind.InitAccessorDeclaration)) ?? false,
                        IsInitOnly = prop.AccessorList?.Accessors.Any(a => a.IsKind(SyntaxKind.InitAccessorDeclaration)) ?? false,
                    });
                }
                break;
            case IndexerDeclarationSyntax idx:
                {
                    string vis = Visibility(idx.Modifiers, declaringType);
                    if (!IsExternallyVisible(vis, declaringType)) return;
                    declaringType.Members.Add(new MemberSurface
                    {
                        DocId = "P:" + declaringType.FullNameArityStripped + ".Item(" + string.Join(",", idx.ParameterList.Parameters.Select(p => p.Type?.ToString() ?? "")) + ")",
                        Name = "this[]",
                        Kind = "property",
                        Visibility = vis,
                        ReturnType = idx.Type.ToString(),
                        Parameters = idx.ParameterList.Parameters.Select(p => new ParameterSurface
                        {
                            Name = p.Identifier.ValueText,
                            Type = p.Type?.ToString() ?? "",
                            Modifier = ParamModifier(p.Modifiers),
                        }).ToList(),
                    });
                }
                break;
            case FieldDeclarationSyntax field:
                {
                    string vis = Visibility(field.Modifiers, declaringType);
                    if (!IsExternallyVisible(vis, declaringType)) return;
                    bool isStatic = field.Modifiers.Any(m => m.IsKind(SyntaxKind.StaticKeyword));
                    bool isReadonly = field.Modifiers.Any(m => m.IsKind(SyntaxKind.ReadOnlyKeyword));
                    bool isConst = field.Modifiers.Any(m => m.IsKind(SyntaxKind.ConstKeyword));
                    string fieldType = field.Declaration.Type.ToString();
                    foreach (var v in field.Declaration.Variables)
                    {
                        declaringType.Members.Add(new MemberSurface
                        {
                            DocId = "F:" + declaringType.FullNameArityStripped + "." + v.Identifier.ValueText,
                            Name = v.Identifier.ValueText,
                            Kind = "field",
                            Visibility = vis,
                            ReturnType = fieldType,
                            IsStatic = isStatic,
                            IsReadOnly = isReadonly,
                            IsConst = isConst,
                        });
                    }
                }
                break;
            case EventDeclarationSyntax evt:
                {
                    string vis = Visibility(evt.Modifiers, declaringType);
                    if (!IsExternallyVisible(vis, declaringType)) return;
                    declaringType.Members.Add(new MemberSurface
                    {
                        DocId = "E:" + declaringType.FullNameArityStripped + "." + evt.Identifier.ValueText,
                        Name = evt.Identifier.ValueText,
                        Kind = "event",
                        Visibility = vis,
                        ReturnType = evt.Type.ToString(),
                        IsStatic = evt.Modifiers.Any(m => m.IsKind(SyntaxKind.StaticKeyword)),
                    });
                }
                break;
            case EventFieldDeclarationSyntax evtField:
                {
                    string vis = Visibility(evtField.Modifiers, declaringType);
                    if (!IsExternallyVisible(vis, declaringType)) return;
                    string evtType = evtField.Declaration.Type.ToString();
                    bool isStatic = evtField.Modifiers.Any(m => m.IsKind(SyntaxKind.StaticKeyword));
                    foreach (var v in evtField.Declaration.Variables)
                    {
                        declaringType.Members.Add(new MemberSurface
                        {
                            DocId = "E:" + declaringType.FullNameArityStripped + "." + v.Identifier.ValueText,
                            Name = v.Identifier.ValueText,
                            Kind = "event",
                            Visibility = vis,
                            ReturnType = evtType,
                            IsStatic = isStatic,
                        });
                    }
                }
                break;
        }
    }

    private static void AddMethodLike(
        TypeSurface declaringType, string kind, string name,
        SyntaxTokenList modifiers, ParameterListSyntax paramList, string? returnType,
        List<string>? methodTypeParams, SyntaxNode node)
    {
        string vis = Visibility(modifiers, declaringType);
        if (!IsExternallyVisible(vis, declaringType)) return;

        var parms = paramList.Parameters.Select(p => new ParameterSurface
        {
            Name = p.Identifier.ValueText,
            Type = p.Type?.ToString() ?? "",
            Modifier = ParamModifier(p.Modifiers),
        }).ToList();

        int marity = methodTypeParams?.Count ?? 0;

        // Build cref-style parameter list for disambiguation.
        // in/out/ref parameters are encoded with a trailing '@' in XML doc-id format.
        var paramTypesForCref = paramList.Parameters.Select(p =>
        {
            var t = p.Type?.ToString() ?? "";
            bool isByRef = p.Modifiers.Any(m =>
                m.IsKind(SyntaxKind.InKeyword) ||
                m.IsKind(SyntaxKind.RefKeyword) ||
                m.IsKind(SyntaxKind.OutKeyword));
            return isByRef ? t + "@" : t;
        }).ToList();
        string paramCref = paramTypesForCref.Count == 0 ? "" : "(" + string.Join(",", paramTypesForCref) + ")";

        string memberName = name switch
        {
            "#ctor" => "#ctor",
            _ => marity > 0 ? name + "``" + marity : name,
        };

        string docId = "M:" + declaringType.FullNameArityStripped + "." + memberName + paramCref;

        declaringType.Members.Add(new MemberSurface
        {
            DocId = docId,
            Name = name == "#ctor" ? declaringType.Name : name,
            Kind = kind,
            Visibility = vis,
            ReturnType = returnType,
            TypeParameters = methodTypeParams,
            Parameters = parms,
            IsStatic = modifiers.Any(m => m.IsKind(SyntaxKind.StaticKeyword)),
            IsAbstract = modifiers.Any(m => m.IsKind(SyntaxKind.AbstractKeyword)),
            IsVirtual = modifiers.Any(m => m.IsKind(SyntaxKind.VirtualKeyword)),
            IsOverride = modifiers.Any(m => m.IsKind(SyntaxKind.OverrideKeyword)),
            IsSealed = modifiers.Any(m => m.IsKind(SyntaxKind.SealedKeyword)),
            IsAsync = modifiers.Any(m => m.IsKind(SyntaxKind.AsyncKeyword)),
        });
    }

    private static string? ParamModifier(SyntaxTokenList mods)
    {
        // Prioritise pass-by-ref modifiers over 'this' so that 'this in' parameters
        // correctly report 'in' rather than 'this'. The order here determines the
        // single modifier returned for display; the doc-id '@' encoding is handled
        // separately in AddMethodLike.
        if (mods.Any(m => m.IsKind(SyntaxKind.RefKeyword))) return "ref";
        if (mods.Any(m => m.IsKind(SyntaxKind.OutKeyword))) return "out";
        if (mods.Any(m => m.IsKind(SyntaxKind.InKeyword))) return "in";
        if (mods.Any(m => m.IsKind(SyntaxKind.ParamsKeyword))) return "params";
        if (mods.Any(m => m.IsKind(SyntaxKind.ThisKeyword))) return "this";
        return null;
    }

    private static List<string> GetTypeParameters(BaseTypeDeclarationSyntax t)
    {
        return t switch
        {
            TypeDeclarationSyntax td when td.TypeParameterList != null
                => td.TypeParameterList.Parameters.Select(p => p.Identifier.ValueText).ToList(),
            _ => new List<string>(),
        };
    }

    private static List<string> GetBaseTypes(BaseTypeDeclarationSyntax t)
    {
        if (t.BaseList == null) return new List<string>();
        return t.BaseList.Types.Select(bt => bt.Type.ToString()).ToList();
    }

    private static string Visibility(SyntaxTokenList modifiers, TypeSurface? containingType)
    {
        bool pub = false, priv = false, prot = false, intl = false, fp = false;
        foreach (var m in modifiers)
        {
            if (m.IsKind(SyntaxKind.PublicKeyword)) pub = true;
            else if (m.IsKind(SyntaxKind.PrivateKeyword)) priv = true;
            else if (m.IsKind(SyntaxKind.ProtectedKeyword)) prot = true;
            else if (m.IsKind(SyntaxKind.InternalKeyword)) intl = true;
            else if (m.IsKind(SyntaxKind.FileKeyword)) fp = true;
        }
        if (fp) return "file";
        if (pub) return "public";
        if (priv && prot) return "private protected";
        if (prot && intl) return "protected internal";
        if (priv) return "private";
        if (prot) return "protected";
        if (intl) return "internal";
        // default: top-level types are internal; members depend on containing kind
        if (containingType == null) return "internal";
        return containingType.Kind == "interface" ? "public" : "private";
    }

    private static bool IsExternallyVisible(string vis, TypeSurface? containingType)
    {
        // A symbol is externally visible only if its own visibility is public/protected
        // AND every containing type (if any) is itself externally visible.
        bool selfVisible = vis switch
        {
            "public" => true,
            "protected" or "protected internal" =>
                containingType == null || !containingType.IsSealed,
            _ => false,
        };
        if (!selfVisible) return false;
        if (containingType == null) return true;
        // Container must itself be externally visible (recursive check via its own visibility).
        return IsExternallyVisible(containingType.Visibility, null /* walked at creation */)
               && (containingType.Visibility == "public"
                   || containingType.Visibility == "protected"
                   || containingType.Visibility == "protected internal");
    }
}

sealed class SurfaceDocument
{
    public string AssemblyName { get; set; } = "";
    public string? DefaultNamespace { get; set; }
    public List<TypeSurface> Types { get; set; } = new();
}

sealed class TypeSurface
{
    public string DocId { get; set; } = "";
    public string Namespace { get; set; } = "";
    public string Name { get; set; } = "";
    public string FullNameArityStripped { get; set; } = "";
    public int Arity { get; set; }
    public string Kind { get; set; } = "";
    public string Visibility { get; set; } = "";
    public bool IsStatic { get; set; }
    public bool IsAbstract { get; set; }
    public bool IsSealed { get; set; }
    public bool IsPartial { get; set; }
    public bool IsReadOnly { get; set; }
    public List<string> TypeParameters { get; set; } = new();
    public List<string> BaseTypes { get; set; } = new();
    public string? ReturnType { get; set; }
    public List<ParameterSurface> Parameters { get; set; } = new();
    public List<MemberSurface> Members { get; set; } = new();
}

sealed class MemberSurface
{
    public string DocId { get; set; } = "";
    public string Name { get; set; } = "";
    public string Kind { get; set; } = "";
    public string Visibility { get; set; } = "";
    public string? ReturnType { get; set; }
    public List<string>? TypeParameters { get; set; }
    public List<ParameterSurface>? Parameters { get; set; }
    public bool IsStatic { get; set; }
    public bool IsAbstract { get; set; }
    public bool IsVirtual { get; set; }
    public bool IsOverride { get; set; }
    public bool IsSealed { get; set; }
    public bool IsAsync { get; set; }
    public bool IsReadOnly { get; set; }
    public bool IsConst { get; set; }
    public bool IsInitOnly { get; set; }
    public bool HasGetter { get; set; }
    public bool HasSetter { get; set; }
}

sealed class ParameterSurface
{
    public string Name { get; set; } = "";
    public string Type { get; set; } = "";
    public string? Modifier { get; set; }
}

[JsonSourceGenerationOptions(
    WriteIndented = false,
    DefaultIgnoreCondition = JsonIgnoreCondition.WhenWritingNull,
    PropertyNamingPolicy = JsonKnownNamingPolicy.CamelCase)]
[JsonSerializable(typeof(SurfaceDocument))]
internal partial class SurfaceJsonContext : JsonSerializerContext { }
