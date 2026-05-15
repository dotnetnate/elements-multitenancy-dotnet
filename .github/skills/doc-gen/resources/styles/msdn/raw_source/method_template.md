---
layout: Reference
monikers:
- netframework-1.1
- netstandard-2.0
- netframework-2.0
- netcore-2.0
- netcore-2.1
- netstandard-2.1
- netcore-2.2
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
title: String.Clone Method (System) | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/dotnet/api/system.string.clone?view=net-10.0
uid: System.String.Clone*
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
- System.String.Clone
api_location:
- mscorlib.dll
- netstandard.dll
- System.Runtime.dll
topic_type:
- apiref
api_type:
- Assembly
locale: en-us
document_id: 5af90878-9ccb-f443-9899-0a2fe0eb4277
document_version_independent_id: a63accd0-94f6-42ec-989a-438efd826b57
updated_at: 2026-04-25T11:16:00.0000000Z
original_content_git_url: https://github.com/dotnet/dotnet-api-docs/blob/live/xml/System/String.xml
gitcommit: https://github.com/dotnet/dotnet-api-docs/blob/f31dadfd36cdfbfb416987813c0307422152a067/xml/System/String.xml
git_commit_id: f31dadfd36cdfbfb416987813c0307422152a067
default_moniker: net-10.0
site_name: Docs
depot_name: VS.dotnet-api-docs
page_type: dotnet
page_kind: method
ms.assetid: System.String.Clone*
description: 'Returns a reference to this instance of String. '
toc_rel: _splitted/system/toc.json
search.mshattr.devlang: csharp vb fsharp cpp
asset_id: api/system.string.clone
moniker_range_name: 77b1bc796a07d58802137f268bbba061
monikers:
- netframework-1.1
- netstandard-2.0
- netframework-2.0
- netcore-2.0
- netcore-2.1
- netstandard-2.1
- netcore-2.2
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
source_path: xml/System/String.xml
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/7696cda6-0510-47f6-8302-71bb5d2e28cf
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/69c76c32-967e-4c65-b89a-74cc527db725
platformId: 10b89a9e-6f99-47a7-6c28-2463aa17c846
---

# String.Clone Method

## Definition

- Namespace:
    - [System](system)

- Assemblies:
    - netstandard.dll, System.Runtime.dll

- Assembly:
    - System.Runtime.dll

- Assembly:
    - mscorlib.dll

- Assembly:
    - netstandard.dll

- Source:
    - [String.cs](https://github.com/dotnet/dotnet/blob/b0f34d51fccc69fd334253924abd8d6853fad7aa/src/runtime/src/libraries/System.Private.CoreLib/src/System/String.cs#L392C13-L392C25)

- Source:
    - [String.cs](https://github.com/dotnet/dotnet/blob/a8b33e7593686eaee701cd124daaabff2311634f/src/runtime/src/libraries/System.Private.CoreLib/src/System/String.cs#L403C13-L403C25)

- Source:
    - [String.cs](https://github.com/dotnet/runtime/blob/d099f075e45d2aa6007a22b71b45a08758559f80/src/libraries/System.Private.CoreLib/src/System/String.cs#L371C13-L371C25)

- Source:
    - [String.cs](https://github.com/dotnet/runtime/blob/5535e31a712343a63f5d7d796cd874e563e5ac14/src/libraries/System.Private.CoreLib/src/System/String.cs#L388C13-L388C25)

- Source:
    - [String.cs](https://github.com/dotnet/runtime/blob/1d1bf92fcf43aa6981804dc53c5174445069c9e4/src/libraries/System.Private.CoreLib/src/System/String.cs#L388C13-L388C25)

::: moniker range=" net-10.0 net-11.0 net-5.0 net-6.0 net-7.0 net-8.0 net-9.0 netcore-2.0 netcore-2.1 netcore-2.2 netcore-3.0 netcore-3.1 netframework-1.1 netframework-2.0 netframework-3.0 netframework-3.5 netframework-4.0 netframework-4.5 netframework-4.5.1 netframework-4.5.2 netframework-4.6 netframework-4.6.1 netframework-4.6.2 netframework-4.7 netframework-4.7.1 netframework-4.7.2 netframework-4.8 netframework-4.8.1 netstandard-2.0 netstandard-2.1 "

Returns a reference to this instance of [String](system.string).

```cpp
public:
 virtual System::Object ^ Clone();
```

```csharp
public object Clone();
```

```fsharp
abstract member Clone : unit -> obj
override this.Clone : unit -> obj
```

```vb
Public Function Clone () As Object
```

#### Returns

[Object](system.object)

This instance of [String](system.string).

#### Implements

[Clone()](system.icloneable.clone#system-icloneable-clone)

## Remarks

The return value is not an independent copy of this instance; it is simply another view of the same data. Use the [Copy](system.string.copy) or [CopyTo](system.string.copyto) method to create a separate [String](system.string) object with the same value as this instance.

Because the [Clone](system.string.clone) method simply returns the existing string instance, there is little reason to call it directly.

## Applies to

## See also

- [Copy(String)](system.string.copy#system-string-copy%28system-string%29)
- [CopyTo(Int32, Char\[\], Int32, Int32)](system.string.copyto#system-string-copyto%28system-int32-system-char%28%29-system-int32-system-int32%29)

::: moniker-end