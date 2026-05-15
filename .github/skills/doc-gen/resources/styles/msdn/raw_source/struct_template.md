---
layout: Reference
monikers:
- netframework-1.1
- netframework-2.0
- netcore-3.0
- netframework-3.0
- netframework-3.5
- netframework-4.0
- netframework-4.5
- netframework-4.5.1
- netframework-4.5.2
- netframework-4.6
- netframework-4.6.1
- netframework-4.6.2
- netframework-4.7
- netframework-4.7.1
- netframework-4.7.2
- netframework-4.8
- netframework-4.8.1
- netcore-3.1
- net-5.0
- net-6.0
- net-7.0
- net-8.0
- net-9.0
- net-10.0
- net-11.0
defaultMoniker: net-10.0
versioningType: Ranged
title: ArgIterator Struct (System) | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/dotnet/api/system.argiterator?view=net-10.0
uid: System.ArgIterator
namespace: System
breadcrumb_path: /dotnet/breadcrumb/toc.json
recommendations: true
author: dotnet-bot
ms.author: dotnetcontent
ms.date: 2025-07-01T00:00:00.0000000Z
show_latex: true
uhfHeaderId: MSDocsHeader-DotNet
apiPlatform: dotnet
ms.topic: reference
ms.service: dotnet-api
products:
- https://authoring-docs-microsoft.poolparty.biz/devrel/7696cda6-0510-47f6-8302-71bb5d2e28cf
feedback_system: OpenSource
feedback_product_url: https://aka.ms/feedback/report?space=61
feedback_help_link_url: https://learn.microsoft.com/answers/tags/97/dotnet
feedback_help_link_type: get-help-at-qna
ms.subservice: system
api_name:
- System.ArgIterator
api_location:
- mscorlib.dll
- netstandard.dll
- System.Runtime.dll
topic_type:
- apiref
api_type:
- Assembly
locale: en-us
document_id: d2a617e8-2b8f-44c1-58f0-cdc3bb4d2292
document_version_independent_id: 4451ad33-2b8c-7b00-8740-b4ff8e2a5d92
updated_at: 2026-04-15T17:56:00.0000000Z
original_content_git_url: https://github.com/dotnet/dotnet-api-docs/blob/live/xml/System/ArgIterator.xml
gitcommit: https://github.com/dotnet/dotnet-api-docs/blob/2156aae1480ffbc11586a792891f5a43b2589c4a/xml/System/ArgIterator.xml
git_commit_id: 2156aae1480ffbc11586a792891f5a43b2589c4a
default_moniker: net-10.0
site_name: Docs
depot_name: VS.dotnet-api-docs
page_type: dotnet
page_kind: struct
ms.assetid: System.ArgIterator
description: 'Represents a variable-length argument list; that is, the parameters of a function that takes a variable number of arguments. '
toc_rel: _splitted/system/toc.json
search.mshattr.devlang: csharp vb fsharp cpp
asset_id: api/system.argiterator
moniker_range_name: 824d1bdc3519bcfc4433f5b45432817a
monikers:
- netframework-1.1
- netframework-2.0
- netcore-3.0
- netframework-3.0
- netframework-3.5
- netframework-4.0
- netframework-4.5
- netframework-4.5.1
- netframework-4.5.2
- netframework-4.6
- netframework-4.6.1
- netframework-4.6.2
- netframework-4.7
- netframework-4.7.1
- netframework-4.7.2
- netframework-4.8
- netframework-4.8.1
- netcore-3.1
- net-5.0
- net-6.0
- net-7.0
- net-8.0
- net-9.0
- net-10.0
- net-11.0
item_type: Content
source_path: xml/System/ArgIterator.xml
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/7696cda6-0510-47f6-8302-71bb5d2e28cf
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/69c76c32-967e-4c65-b89a-74cc527db725
platformId: a80d2187-ff17-1f2d-c1e9-89683d95ecf4
---

# ArgIterator Struct

## Definition

- Namespace:
    - [System](system)

- Assembly:
    - System.Runtime.dll

- Assembly:
    - mscorlib.dll

- Source:
    - [ArgIterator.cs](https://github.com/dotnet/dotnet/blob/b0f34d51fccc69fd334253924abd8d6853fad7aa/src/runtime/src/coreclr/System.Private.CoreLib/src/System/ArgIterator.cs)

- Source:
    - [ArgIterator.cs](https://github.com/dotnet/dotnet/blob/a8b33e7593686eaee701cd124daaabff2311634f/src/runtime/src/coreclr/System.Private.CoreLib/src/System/ArgIterator.cs)

- Source:
    - [ArgIterator.cs](https://github.com/dotnet/runtime/blob/d099f075e45d2aa6007a22b71b45a08758559f80/src/coreclr/System.Private.CoreLib/src/System/ArgIterator.cs)

- Source:
    - [ArgIterator.cs](https://github.com/dotnet/runtime/blob/5535e31a712343a63f5d7d796cd874e563e5ac14/src/coreclr/System.Private.CoreLib/src/System/ArgIterator.cs)

- Source:
    - [ArgIterator.cs](https://github.com/dotnet/runtime/blob/1d1bf92fcf43aa6981804dc53c5174445069c9e4/src/coreclr/System.Private.CoreLib/src/System/ArgIterator.cs)

Represents a variable-length argument list; that is, the parameters of a function that takes a variable number of arguments.

```cpp
public value class ArgIterator
```

```csharp
public ref struct ArgIterator
```

```csharp
public struct ArgIterator
```

```fsharp
type ArgIterator = struct
```

```vb
Public Structure ArgIterator
```

- Inheritance
    - [Object](system.object)

[ValueType](system.valuetype)
ArgIterator

## Remarks

Developers who write compilers use the [ArgIterator](system.argiterator) structure to enumerate the mandatory and optional arguments in an argument list. The [ArgIterator](system.argiterator) structure is not generally useful for applications other than compilers.

The functionality in the [ArgIterator](system.argiterator) structure is typically hidden in the syntax of a specific programming language. For example, in the C++ programming language you declare a variable-length argument list by specifying an ellipsis ("...") at the end of the argument list. The [ArgIterator](system.argiterator) structure is useful primarily when a development language does not provide direct support for accessing variable-length parameters.

## Constructors

| Name | Description |
| --- | --- |
| [ArgIterator(RuntimeArgumentHandle, Void*)](system.argiterator.-ctor#system-argiterator-ctor%28system-runtimeargumenthandle-system-void*%29) | Initializes a new instance of the [ArgIterator](system.argiterator) structure using the specified argument list and a pointer to an item in the list. |
| [ArgIterator(RuntimeArgumentHandle)](system.argiterator.-ctor#system-argiterator-ctor%28system-runtimeargumenthandle%29) | Initializes a new instance of the [ArgIterator](system.argiterator) structure using the specified argument list. |

## Methods

| Name | Description |
| --- | --- |
| [End()](system.argiterator.end#system-argiterator-end) | Concludes processing of the variable-length argument list represented by this instance. |
| [Equals(Object)](system.argiterator.equals#system-argiterator-equals%28system-object%29) | This method is not supported, and always throws [NotSupportedException](system.notsupportedexception). |
| [GetHashCode()](system.argiterator.gethashcode#system-argiterator-gethashcode) | Returns the hash code of this object. |
| [GetNextArg()](system.argiterator.getnextarg#system-argiterator-getnextarg) | Returns the next argument in a variable-length argument list. |
| [GetNextArg(RuntimeTypeHandle)](system.argiterator.getnextarg#system-argiterator-getnextarg%28system-runtimetypehandle%29) | Returns the next argument in a variable-length argument list that has a specified type. |
| [GetNextArgType()](system.argiterator.getnextargtype#system-argiterator-getnextargtype) | Returns the type of the next argument. |
| [GetRemainingCount()](system.argiterator.getremainingcount#system-argiterator-getremainingcount) | Returns the number of arguments remaining in the argument list. |

## Applies to