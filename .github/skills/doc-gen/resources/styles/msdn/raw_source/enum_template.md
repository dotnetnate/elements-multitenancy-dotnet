---
layout: Reference
monikers:
- dotnet-uwp-10.0
- netstandard-1.0
- netcore-1.0
- netcore-1.1
- netstandard-1.1
- netframework-1.1
- netstandard-1.2
- netstandard-1.3
- netstandard-1.4
- netstandard-1.5
- netstandard-1.6
- netcore-2.0
- netstandard-2.0
- netframework-2.0
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
title: AttributeTargets Enum (System) | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/dotnet/api/system.attributetargets?view=net-10.0
uid: System.AttributeTargets
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
- System.AttributeTargets
- System.AttributeTargets.All
- System.AttributeTargets.Assembly
- System.AttributeTargets.Class
- System.AttributeTargets.Constructor
- System.AttributeTargets.Delegate
- System.AttributeTargets.Enum
- System.AttributeTargets.Event
- System.AttributeTargets.Field
- System.AttributeTargets.GenericParameter
- System.AttributeTargets.Interface
- System.AttributeTargets.Method
- System.AttributeTargets.Module
- System.AttributeTargets.Parameter
- System.AttributeTargets.Property
- System.AttributeTargets.ReturnValue
- System.AttributeTargets.Struct
api_location:
- System.Runtime.dll
- mscorlib.dll
- netstandard.dll
topic_type:
- apiref
api_type:
- Assembly
locale: en-us
document_id: 61359e83-0fb1-a5e9-4c98-461af866c482
document_version_independent_id: dccce69b-e64f-db55-99fa-fc1aeba3e012
updated_at: 2026-02-11T22:52:00.0000000Z
original_content_git_url: https://github.com/dotnet/dotnet-api-docs/blob/live/xml/System/AttributeTargets.xml
gitcommit: https://github.com/dotnet/dotnet-api-docs/blob/e50d1863acf6da5affec9b315ba2ed88d12274e3/xml/System/AttributeTargets.xml
git_commit_id: e50d1863acf6da5affec9b315ba2ed88d12274e3
default_moniker: net-10.0
site_name: Docs
depot_name: VS.dotnet-api-docs
page_type: dotnet
page_kind: enum
ms.assetid: System.AttributeTargets
description: 'Specifies the application elements on which it is valid to apply an attribute. '
toc_rel: _splitted/system/toc.json
search.mshattr.devlang: csharp vb fsharp cpp
asset_id: api/system.attributetargets
moniker_range_name: f9012738b8c424b4dd2d6afed8279361
monikers:
- dotnet-uwp-10.0
- netstandard-1.0
- netcore-1.0
- netcore-1.1
- netstandard-1.1
- netframework-1.1
- netstandard-1.2
- netstandard-1.3
- netstandard-1.4
- netstandard-1.5
- netstandard-1.6
- netcore-2.0
- netstandard-2.0
- netframework-2.0
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
source_path: xml/System/AttributeTargets.xml
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/7696cda6-0510-47f6-8302-71bb5d2e28cf
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/69c76c32-967e-4c65-b89a-74cc527db725
platformId: 0810d652-fb39-7d9e-bedb-6e215bed6c88
---

# AttributeTargets Enum

## Definition

- Namespace:
    - [System](system)

- Assemblies:
    - mscorlib.dll, System.Runtime.dll

- Assemblies:
    - netstandard.dll, System.Runtime.dll

- Assembly:
    - System.Runtime.dll

- Assembly:
    - mscorlib.dll

- Assembly:
    - netstandard.dll

- Source:
    - [AttributeTargets.cs](https://github.com/dotnet/dotnet/blob/b0f34d51fccc69fd334253924abd8d6853fad7aa/src/runtime/src/libraries/System.Private.CoreLib/src/System/AttributeTargets.cs)

- Source:
    - [AttributeTargets.cs](https://github.com/dotnet/dotnet/blob/a8b33e7593686eaee701cd124daaabff2311634f/src/runtime/src/libraries/System.Private.CoreLib/src/System/AttributeTargets.cs)

Specifies the application elements on which it is valid to apply an attribute.

This enumeration supports a bitwise combination of its member values.

```cpp
public enum class AttributeTargets
```

```csharp
[System.Flags]
public enum AttributeTargets
```

```csharp
[System.Flags]
[System.Serializable]
public enum AttributeTargets
```

```csharp
[System.Flags]
[System.Serializable]
[System.Runtime.InteropServices.ComVisible(true)]
public enum AttributeTargets
```

```fsharp
[<System.Flags>]
type AttributeTargets = 
```

```fsharp
[<System.Flags>]
[<System.Serializable>]
type AttributeTargets = 
```

```fsharp
[<System.Flags>]
[<System.Serializable>]
[<System.Runtime.InteropServices.ComVisible(true)>]
type AttributeTargets = 
```

```vb
Public Enum AttributeTargets
```

- Inheritance
    - [Object](system.object)

[ValueType](system.valuetype)

[Enum](system.enum)
AttributeTargets

- Attributes
    - [FlagsAttribute](system.flagsattribute)[SerializableAttribute](system.serializableattribute)[ComVisibleAttribute](system.runtime.interopservices.comvisibleattribute)

## Fields

| Name | Value | Description |
| --- | --- | --- |
| Assembly | 1 | Attribute can be applied to an assembly. |
| Module | 2 | Attribute can be applied to a module. `Module` refers to a portable executable file (.dll or.exe) and not a Visual Basic standard module. |
| Class | 4 | Attribute can be applied to a class. |
| Struct | 8 | Attribute can be applied to a structure; that is, a value type. |
| Enum | 16 | Attribute can be applied to an enumeration. |
| Constructor | 32 | Attribute can be applied to a constructor. |
| Method | 64 | Attribute can be applied to a method. |
| Property | 128 | Attribute can be applied to a property. |
| Field | 256 | Attribute can be applied to a field. |
| Event | 512 | Attribute can be applied to an event. |
| Interface | 1024 | Attribute can be applied to an interface. |
| Parameter | 2048 | Attribute can be applied to a parameter. |
| Delegate | 4096 | Attribute can be applied to a delegate. |
| ReturnValue | 8192 | Attribute can be applied to a return value. |
| GenericParameter | 16384 | Attribute can be applied to a generic parameter. Currently, this attribute can be applied only in C#, Microsoft intermediate language (MSIL), and emitted code. |
| All | 32767 | Attribute can be applied to any application element. |

## Examples

The following example illustrates the application of attributes to various targets.

Note

Visual Basic syntax doesn't support the application of attributes to type parameters.

```csharp
using System;

namespace AttTargsCS {
    // This attribute is only valid on a class.
    [AttributeUsage(AttributeTargets.Class)]
    public class ClassTargetAttribute : Attribute {
    }

    // This attribute is only valid on a method.
    [AttributeUsage(AttributeTargets.Method)]
    public class MethodTargetAttribute : Attribute {
    }

    // This attribute is only valid on a constructor.
    [AttributeUsage(AttributeTargets.Constructor)]
    public class ConstructorTargetAttribute : Attribute {
    }

    // This attribute is only valid on a field.
    [AttributeUsage(AttributeTargets.Field)]
    public class FieldTargetAttribute : Attribute {
    }

    // This attribute is valid on a class or a method.
    [AttributeUsage(AttributeTargets.Class|AttributeTargets.Method)]
    public class ClassMethodTargetAttribute : Attribute {
    }

    // This attribute is valid on a generic type parameter.
    [AttributeUsage(AttributeTargets.GenericParameter)]
    public class GenericParameterTargetAttribute : Attribute {
    }

    // This attribute is valid on any target.
    [AttributeUsage(AttributeTargets.All)]
    public class AllTargetsAttribute : Attribute {
    }

    [ClassTarget]
    [ClassMethodTarget]
    [AllTargets]
    public class TestClassAttribute {
        [ConstructorTarget]
        [AllTargets]
        TestClassAttribute() {
        }

        [MethodTarget]
        [ClassMethodTarget]
        [AllTargets]
        public void Method1() {
        }

        [FieldTarget]
        [AllTargets]
        public int myInt;

        public void GenericMethod<
            [GenericParameterTarget, AllTargets] T>(T x) {
        }

        static void Main(string[] args) {
        }
    }
}
```

```fsharp
open System

// This attribute is only valid on a class.
[<AttributeUsage(AttributeTargets.Class)>]
type ClassTargetAttribute() =
    inherit Attribute()

// This attribute is only valid on a method.
[<AttributeUsage(AttributeTargets.Method)>]
type MethodTargetAttribute() =
    inherit Attribute()

// This attribute is only valid on a constructor.
[<AttributeUsage(AttributeTargets.Constructor)>]
type ConstructorTargetAttribute() =
    inherit Attribute()

// This attribute is only valid on a field.
[<AttributeUsage(AttributeTargets.Field)>]
type FieldTargetAttribute() =
    inherit Attribute()

// This attribute is valid on a class or a method.
[<AttributeUsage(AttributeTargets.Class ||| AttributeTargets.Method)>]
type ClassMethodTargetAttribute() =
    inherit Attribute()

// This attribute is valid on a generic type parameter.
[<AttributeUsage(AttributeTargets.GenericParameter)>]
type GenericParameterTargetAttribute() =
    inherit Attribute()

// This attribute is valid on any target.
[<AttributeUsage(AttributeTargets.All)>]
type AllTargetsAttribute() =
    inherit Attribute()

[<ClassTarget>]
[<ClassMethodTarget>]
[<AllTargets>]
type TestClassAttribute [<ConstructorTarget>] [<AllTargets>] () =
    [<FieldTarget>]
    [<AllTargets>]
    let myInt = 0

    [<MethodTarget>]
    [<ClassMethodTarget>]
    [<AllTargets>]
    member _.Method1() = ()

    member _.GenericMethod<[<GenericParameterTarget; AllTargets>] 'T>(x: 'T) = ()
```

```vb
Module DemoModule
    ' This attribute is only valid on a class.
    <AttributeUsage(AttributeTargets.Class)> _
    Public Class ClassTargetAttribute
        Inherits Attribute
    End Class

    ' This attribute is only valid on a method.
    <AttributeUsage(AttributeTargets.Method)> _
    Public Class MethodTargetAttribute
        Inherits Attribute
    End Class

    ' This attribute is only valid on a constructor.
    <AttributeUsage(AttributeTargets.Constructor)> _
    Public Class ConstructorTargetAttribute 
        Inherits Attribute
    End Class

    ' This attribute is only valid on a field.
    <AttributeUsage(AttributeTargets.Field)> _
    Public Class FieldTargetAttribute 
        Inherits Attribute
    End Class

    ' This attribute is valid on a class or a method.
    <AttributeUsage(AttributeTargets.Class Or AttributeTargets.Method)> _
    Public Class ClassMethodTargetAttribute 
        Inherits Attribute
    End Class

    ' This attribute is valid on any target.
    <AttributeUsage(AttributeTargets.All)> _
    Public Class AllTargetsAttribute 
        Inherits Attribute
    End Class

    <ClassTarget, _
    ClassMethodTarget, _
    AllTargets> _
    Public Class TestClassAttribute
        <ConstructorTarget, _
        AllTargets> _
        Public Sub New
        End Sub

        <MethodTarget, _
        ClassMethodTarget, _
        AllTargets> _
        Public Sub Method1()
        End Sub

        <FieldTarget, _
        AllTargets> _
        Public myInt as Integer
    End Class

    Sub Main()
    End Sub
End Module
```

## Remarks

The [AttributeUsageAttribute](system.attributeusageattribute) class uses this enumeration to specify the kind of element on which it's valid to apply an attribute.

[AttributeTargets](system.attributetargets) enumeration values can be combined with a bitwise OR operation to get the preferred combination.

## Applies to