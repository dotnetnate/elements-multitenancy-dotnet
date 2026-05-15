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
title: String Class (System) | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/dotnet/api/system.string?view=net-10.0
uid: System.String
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
- System.String
api_location:
- System.Runtime.dll
- mscorlib.dll
- netstandard.dll
topic_type:
- apiref
api_type:
- Assembly
locale: en-us
document_id: 7eb81599-a548-5d41-4013-812d9148b09d
document_version_independent_id: de28387f-e401-9ecd-1fc0-a9e37d55d6ea
updated_at: 2026-04-25T11:16:00.0000000Z
original_content_git_url: https://github.com/dotnet/dotnet-api-docs/blob/live/xml/System/String.xml
gitcommit: https://github.com/dotnet/dotnet-api-docs/blob/f31dadfd36cdfbfb416987813c0307422152a067/xml/System/String.xml
git_commit_id: f31dadfd36cdfbfb416987813c0307422152a067
default_moniker: net-10.0
site_name: Docs
depot_name: VS.dotnet-api-docs
page_type: dotnet
page_kind: class
ms.assetid: System.String
description: 'Represents text as a sequence of UTF-16 code units. '
toc_rel: _splitted/system/toc.json
search.mshattr.devlang: csharp vb fsharp cpp
asset_id: api/system.string
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
source_path: xml/System/String.xml
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/7696cda6-0510-47f6-8302-71bb5d2e28cf
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/69c76c32-967e-4c65-b89a-74cc527db725
platformId: ea5ee17b-a431-9cf9-8b95-ec61e38a8fd3
---

# String Class

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
    - [String.cs](https://github.com/dotnet/dotnet/blob/b0f34d51fccc69fd334253924abd8d6853fad7aa/src/runtime/src/libraries/System.Private.CoreLib/src/System/String.cs)

- Source:
    - [String.cs](https://github.com/dotnet/dotnet/blob/a8b33e7593686eaee701cd124daaabff2311634f/src/runtime/src/libraries/System.Private.CoreLib/src/System/String.cs)

- Source:
    - [String.cs](https://github.com/dotnet/runtime/blob/d099f075e45d2aa6007a22b71b45a08758559f80/src/libraries/System.Private.CoreLib/src/System/String.cs)

- Source:
    - [String.cs](https://github.com/dotnet/runtime/blob/5535e31a712343a63f5d7d796cd874e563e5ac14/src/libraries/System.Private.CoreLib/src/System/String.cs)

- Source:
    - [String.cs](https://github.com/dotnet/runtime/blob/1d1bf92fcf43aa6981804dc53c5174445069c9e4/src/libraries/System.Private.CoreLib/src/System/String.cs)

Represents text as a sequence of UTF-16 code units.

```cpp
public ref class System::String sealed : IComparable, IComparable<System::String ^>, IConvertible, IEquatable<System::String ^>, System::Collections::Generic::IEnumerable<char>
```

```cpp
public ref class System::String sealed : ICloneable, IComparable, IComparable<System::String ^>, IConvertible, IEquatable<System::String ^>, IParsable<System::String ^>, ISpanParsable<System::String ^>, System::Collections::Generic::IEnumerable<char>
```

```cpp
public ref class System::String sealed : ICloneable, IComparable, IComparable<System::String ^>, IConvertible, IEquatable<System::String ^>, System::Collections::Generic::IEnumerable<char>
```

```cpp
public ref class System::String sealed : ICloneable, IComparable, IConvertible, System::Collections::IEnumerable
```

```cpp
public ref class System::String sealed : IComparable, IComparable<System::String ^>, IEquatable<System::String ^>, System::Collections::IEnumerable
```

```cpp
public ref class System::String sealed : IComparable, IComparable<System::String ^>, IEquatable<System::String ^>, System::Collections::Generic::IEnumerable<char>
```

```csharp
public sealed class String : IComparable, IComparable<string>, IConvertible, IEquatable<string>, System.Collections.Generic.IEnumerable<char>
```

```csharp
public sealed class String : ICloneable, IComparable, IComparable<string>, IConvertible, IEquatable<string>, IParsable<string>, ISpanParsable<string>, System.Collections.Generic.IEnumerable<char>
```

```csharp
public sealed class String : ICloneable, IComparable, IComparable<string>, IConvertible, IEquatable<string>, System.Collections.Generic.IEnumerable<char>
```

```csharp
[System.Serializable]
public sealed class String : ICloneable, IComparable, IConvertible, System.Collections.IEnumerable
```

```csharp
[System.Serializable]
[System.Runtime.InteropServices.ComVisible(true)]
public sealed class String : ICloneable, IComparable, IComparable<string>, IConvertible, IEquatable<string>, System.Collections.Generic.IEnumerable<char>
```

```csharp
public sealed class String : IComparable, IComparable<string>, IEquatable<string>, System.Collections.IEnumerable
```

```csharp
public sealed class String : IComparable, IComparable<string>, IEquatable<string>, System.Collections.Generic.IEnumerable<char>
```

```fsharp
type string = class
    interface seq<char>
    interface IEnumerable
    interface IComparable
    interface IComparable<string>
    interface IConvertible
    interface IEquatable<string>
```

```fsharp
type string = class
    interface seq<char>
    interface IEnumerable
    interface ICloneable
    interface IComparable
    interface IComparable<string>
    interface IConvertible
    interface IEquatable<string>
    interface IParsable<string>
    interface ISpanParsable<string>
```

```fsharp
type string = class
    interface seq<char>
    interface IEnumerable
    interface ICloneable
    interface IComparable
    interface IComparable<string>
    interface IConvertible
    interface IEquatable<string>
```

```fsharp
type string = class
    interface seq<char>
    interface IEnumerable
    interface IComparable
    interface IComparable<string>
    interface IConvertible
    interface IEquatable<string>
    interface ICloneable
```

```fsharp
[<System.Serializable>]
type string = class
    interface IComparable
    interface ICloneable
    interface IConvertible
    interface IEnumerable
```

```fsharp
[<System.Serializable>]
[<System.Runtime.InteropServices.ComVisible(true)>]
type string = class
    interface IComparable
    interface ICloneable
    interface IConvertible
    interface IComparable<string>
    interface seq<char>
    interface IEnumerable
    interface IEquatable<string>
```

```fsharp
[<System.Serializable>]
[<System.Runtime.InteropServices.ComVisible(true)>]
type string = class
    interface IComparable
    interface ICloneable
    interface IConvertible
    interface IEnumerable
    interface IComparable<string>
    interface seq<char>
    interface IEquatable<string>
```

```fsharp
type string = class
    interface IEnumerable
    interface IComparable
    interface IComparable<string>
    interface IEquatable<string>
```

```fsharp
type string = class
    interface IComparable
    interface IComparable<string>
    interface IEquatable<string>
    interface seq<char>
    interface IEnumerable
```

```vb
Public NotInheritable Class String
Implements IComparable, IComparable(Of String), IConvertible, IEnumerable(Of Char), IEquatable(Of String)
```

```vb
Public NotInheritable Class String
Implements ICloneable, IComparable, IComparable(Of String), IConvertible, IEnumerable(Of Char), IEquatable(Of String), IParsable(Of String), ISpanParsable(Of String)
```

```vb
Public NotInheritable Class String
Implements ICloneable, IComparable, IComparable(Of String), IConvertible, IEnumerable(Of Char), IEquatable(Of String)
```

```vb
Public NotInheritable Class String
Implements ICloneable, IComparable, IConvertible, IEnumerable
```

```vb
Public NotInheritable Class String
Implements IComparable, IComparable(Of String), IEnumerable, IEquatable(Of String)
```

```vb
Public NotInheritable Class String
Implements IComparable, IComparable(Of String), IEnumerable(Of Char), IEquatable(Of String)
```

- Inheritance
    - [Object](system.object)
String

- Attributes
    - [SerializableAttribute](system.serializableattribute)[ComVisibleAttribute](system.runtime.interopservices.comvisibleattribute)

- Implements
    - [IEnumerable](system.collections.generic.ienumerable-1)&lt;[Char](system.char)&gt;[IEnumerable](system.collections.ienumerable)[IComparable](system.icomparable)[IComparable](system.icomparable-1)&lt;[String](system.string)&gt;[IConvertible](system.iconvertible)[IEquatable](system.iequatable-1)&lt;[String](system.string)&gt;[ICloneable](system.icloneable)[IParsable](system.iparsable-1)&lt;[String](system.string)&gt;[IParsable&lt;TSelf&gt;](system.iparsable-1)[ISpanParsable](system.ispanparsable-1)&lt;[String](system.string)&gt;

## Remarks

For more information about this API, see [Supplemental API remarks for String](/en-us/dotnet/fundamentals/runtime-libraries/system-string).

## Constructors

| Name | Description |
| --- | --- |
| [String(Char, Int32)](system.string.-ctor#system-string-ctor%28system-char-system-int32%29) | Initializes a new instance of the [String](system.string) class to the value indicated by a specified Unicode character repeated a specified number of times. |
| [String(Char\[\], Int32, Int32)](system.string.-ctor#system-string-ctor%28system-char%28%29-system-int32-system-int32%29) | Initializes a new instance of the [String](system.string) class to the value indicated by an array of Unicode characters, a starting character position within that array, and a length. |
| [String(Char\[\])](system.string.-ctor#system-string-ctor%28system-char%28%29%29) | Initializes a new instance of the [String](system.string) class to the Unicode characters indicated in the specified character array. |
| [String(Char*, Int32, Int32)](system.string.-ctor#system-string-ctor%28system-char*-system-int32-system-int32%29) | Initializes a new instance of the [String](system.string) class to the value indicated by a specified pointer to an array of Unicode characters, a starting character position within that array, and a length. |
| [String(Char*)](system.string.-ctor#system-string-ctor%28system-char*%29) | Initializes a new instance of the [String](system.string) class to the value indicated by a specified pointer to an array of Unicode characters. |
| [String(ReadOnlySpan&lt;Char&gt;)](system.string.-ctor#system-string-ctor%28system-readonlyspan%28%28system-char%29%29%29) | Initializes a new instance of the [String](system.string) class to the Unicode characters indicated in the specified read-only span. |
| [String(SByte*, Int32, Int32, Encoding)](system.string.-ctor#system-string-ctor%28system-sbyte*-system-int32-system-int32-system-text-encoding%29) | Initializes a new instance of the [String](system.string) class to the value indicated by a specified pointer to an array of 8-bit signed integers, a starting position within that array, a length, and an [Encoding](system.text.encoding) object. |
| [String(SByte*, Int32, Int32)](system.string.-ctor#system-string-ctor%28system-sbyte*-system-int32-system-int32%29) | Initializes a new instance of the [String](system.string) class to the value indicated by a specified pointer to an array of 8-bit signed integers, a starting position within that array, and a length. |
| [String(SByte*)](system.string.-ctor#system-string-ctor%28system-sbyte*%29) | Initializes a new instance of the [String](system.string) class to the value indicated by a pointer to an array of 8-bit signed integers. |

## Fields

| Name | Description |
| --- | --- |
| [Empty](system.string.empty#system-string-empty) | Represents the empty string. This field is read-only. |

## Properties

| Name | Description |
| --- | --- |
| [Chars\[Int32\]](system.string.chars#system-string-chars%28system-int32%29) | Gets the [Char](system.char) object at a specified position in the current [String](system.string) object. |
| [Length](system.string.length#system-string-length) | Gets the number of characters in the current [String](system.string) object. |

## Methods

| Name | Description |
| --- | --- |
| [Clone()](system.string.clone#system-string-clone) | Returns a reference to this instance of [String](system.string). |
| [Compare(String, Int32, String, Int32, Int32, Boolean, CultureInfo)](system.string.compare#system-string-compare%28system-string-system-int32-system-string-system-int32-system-int32-system-boolean-system-globalization-cultureinfo%29) | Compares substrings of two specified [String](system.string) objects, ignoring or honoring their case and using culture-specific information to influence the comparison, and returns an integer that indicates their relative position in the sort order. |
| [Compare(String, Int32, String, Int32, Int32, Boolean)](system.string.compare#system-string-compare%28system-string-system-int32-system-string-system-int32-system-int32-system-boolean%29) | Compares substrings of two specified [String](system.string) objects, ignoring or honoring their case, and returns an integer that indicates their relative position in the sort order. |
| [Compare(String, Int32, String, Int32, Int32, CultureInfo, CompareOptions)](system.string.compare#system-string-compare%28system-string-system-int32-system-string-system-int32-system-int32-system-globalization-cultureinfo-system-globalization-compareoptions%29) | Compares substrings of two specified [String](system.string) objects using the specified comparison options and culture-specific information to influence the comparison, and returns an integer that indicates the relationship of the two substrings to each other in the sort order. |
| [Compare(String, Int32, String, Int32, Int32, StringComparison)](system.string.compare#system-string-compare%28system-string-system-int32-system-string-system-int32-system-int32-system-stringcomparison%29) | Compares substrings of two specified [String](system.string) objects using the specified rules, and returns an integer that indicates their relative position in the sort order. |
| [Compare(String, Int32, String, Int32, Int32)](system.string.compare#system-string-compare%28system-string-system-int32-system-string-system-int32-system-int32%29) | Compares substrings of two specified [String](system.string) objects and returns an integer that indicates their relative position in the sort order. |
| [Compare(String, String, Boolean, CultureInfo)](system.string.compare#system-string-compare%28system-string-system-string-system-boolean-system-globalization-cultureinfo%29) | Compares two specified [String](system.string) objects, ignoring or honoring their case, and using culture-specific information to influence the comparison, and returns an integer that indicates their relative position in the sort order. |
| [Compare(String, String, Boolean)](system.string.compare#system-string-compare%28system-string-system-string-system-boolean%29) | Compares two specified [String](system.string) objects, ignoring or honoring their case, and returns an integer that indicates their relative position in the sort order. |
| [Compare(String, String, CultureInfo, CompareOptions)](system.string.compare#system-string-compare%28system-string-system-string-system-globalization-cultureinfo-system-globalization-compareoptions%29) | Compares two specified [String](system.string) objects using the specified comparison options and culture-specific information to influence the comparison, and returns an integer that indicates the relationship of the two strings to each other in the sort order. |
| [Compare(String, String, StringComparison)](system.string.compare#system-string-compare%28system-string-system-string-system-stringcomparison%29) | Compares two specified [String](system.string) objects using the specified rules, and returns an integer that indicates their relative position in the sort order. |
| [Compare(String, String)](system.string.compare#system-string-compare%28system-string-system-string%29) | Compares two specified [String](system.string) objects and returns an integer that indicates their relative position in the sort order. |
| [CompareOrdinal(String, Int32, String, Int32, Int32)](system.string.compareordinal#system-string-compareordinal%28system-string-system-int32-system-string-system-int32-system-int32%29) | Compares substrings of two specified [String](system.string) objects by evaluating the numeric values of the corresponding [Char](system.char) objects in each substring. |
| [CompareOrdinal(String, String)](system.string.compareordinal#system-string-compareordinal%28system-string-system-string%29) | Compares two specified [String](system.string) objects by evaluating the numeric values of the corresponding [Char](system.char) objects in each string. |
| [CompareTo(Object)](system.string.compareto#system-string-compareto%28system-object%29) | Compares this instance with a specified [Object](system.object) and indicates whether this instance precedes, follows, or appears in the same position in the sort order as the specified [Object](system.object). |
| [CompareTo(String)](system.string.compareto#system-string-compareto%28system-string%29) | Compares this instance with a specified [String](system.string) object and indicates whether this instance precedes, follows, or appears in the same position in the sort order as the specified string. |
| [Concat(IEnumerable&lt;String&gt;)](system.string.concat#system-string-concat%28system-collections-generic-ienumerable%28%28system-string%29%29%29) | Concatenates the members of a constructed [IEnumerable&lt;T&gt;](system.collections.generic.ienumerable-1) collection of type [String](system.string). |
| [Concat(Object, Object, Object, Object)](system.string.concat#system-string-concat%28system-object-system-object-system-object-system-object%29) | Concatenates the string representations of four specified objects and any objects specified in an optional variable length parameter list. |
| [Concat(Object, Object, Object)](system.string.concat#system-string-concat%28system-object-system-object-system-object%29) | Concatenates the string representations of three specified objects. |
| [Concat(Object, Object)](system.string.concat#system-string-concat%28system-object-system-object%29) | Concatenates the string representations of two specified objects. |
| [Concat(Object)](system.string.concat#system-string-concat%28system-object%29) | Creates the string representation of a specified object. |
| [Concat(Object\[\])](system.string.concat#system-string-concat%28system-object%28%29%29) | Concatenates the string representations of the elements in a specified [Object](system.object) array. |
| [Concat(ReadOnlySpan&lt;Char&gt;, ReadOnlySpan&lt;Char&gt;, ReadOnlySpan&lt;Char&gt;, ReadOnlySpan&lt;Char&gt;)](system.string.concat#system-string-concat%28system-readonlyspan%28%28system-char%29%29-system-readonlyspan%28%28system-char%29%29-system-readonlyspan%28%28system-char%29%29-system-readonlyspan%28%28system-char%29%29%29) | Concatenates the string representations of four specified read-only character spans. |
| [Concat(ReadOnlySpan&lt;Char&gt;, ReadOnlySpan&lt;Char&gt;, ReadOnlySpan&lt;Char&gt;)](system.string.concat#system-string-concat%28system-readonlyspan%28%28system-char%29%29-system-readonlyspan%28%28system-char%29%29-system-readonlyspan%28%28system-char%29%29%29) | Concatenates the string representations of three specified read-only character spans. |
| [Concat(ReadOnlySpan&lt;Char&gt;, ReadOnlySpan&lt;Char&gt;)](system.string.concat#system-string-concat%28system-readonlyspan%28%28system-char%29%29-system-readonlyspan%28%28system-char%29%29%29) | Concatenates the string representations of two specified read-only character spans. |
| [Concat(ReadOnlySpan&lt;Object&gt;)](system.string.concat#system-string-concat%28system-readonlyspan%28%28system-object%29%29%29) | Concatenates the string representations of the elements in a specified span of objects. |
| [Concat(ReadOnlySpan&lt;String&gt;)](system.string.concat#system-string-concat%28system-readonlyspan%28%28system-string%29%29%29) | Concatenates the elements of a specified span of [String](system.string). |
| [Concat(String, String, String, String)](system.string.concat#system-string-concat%28system-string-system-string-system-string-system-string%29) | Concatenates four specified instances of [String](system.string). |
| [Concat(String, String, String)](system.string.concat#system-string-concat%28system-string-system-string-system-string%29) | Concatenates three specified instances of [String](system.string). |
| [Concat(String, String)](system.string.concat#system-string-concat%28system-string-system-string%29) | Concatenates two specified instances of [String](system.string). |
| [Concat(String\[\])](system.string.concat#system-string-concat%28system-string%28%29%29) | Concatenates the elements of a specified [String](system.string) array. |
| [Concat&lt;T&gt;(IEnumerable&lt;T&gt;)](system.string.concat#system-string-concat-1%28system-collections-generic-ienumerable%28%28-0%29%29%29) | Concatenates the members of an [IEnumerable&lt;T&gt;](system.collections.generic.ienumerable-1) implementation. |
| [Contains(Char, StringComparison)](system.string.contains#system-string-contains%28system-char-system-stringcomparison%29) | Returns a value indicating whether a specified character occurs within this string, using the specified comparison rules. |
| [Contains(Char)](system.string.contains#system-string-contains%28system-char%29) | Returns a value indicating whether a specified character occurs within this string. |
| [Contains(Rune, StringComparison)](system.string.contains#system-string-contains%28system-text-rune-system-stringcomparison%29) |
| [Contains(Rune)](system.string.contains#system-string-contains%28system-text-rune%29) |
| [Contains(String, StringComparison)](system.string.contains#system-string-contains%28system-string-system-stringcomparison%29) | Returns a value indicating whether a specified string occurs within this string, using the specified comparison rules. |
| [Contains(String)](system.string.contains#system-string-contains%28system-string%29) | Returns a value indicating whether a specified substring occurs within this string. |
| [Copy(String)](system.string.copy#system-string-copy%28system-string%29) | ::: moniker range=" net-10.0 net-11.0 net-5.0 net-6.0 net-7.0 net-8.0 net-9.0 netcore-3.0 netcore-3.1 "<br>**Obsolete.**<br><br>::: moniker-end<br><br>Creates a new instance of [String](system.string) with the same value as a specified [String](system.string). |
| [CopyTo(Int32, Char\[\], Int32, Int32)](system.string.copyto#system-string-copyto%28system-int32-system-char%28%29-system-int32-system-int32%29) | Copies a specified number of characters from a specified position in this instance to a specified position in an array of Unicode characters. |
| [CopyTo(Span&lt;Char&gt;)](system.string.copyto#system-string-copyto%28system-span%28%28system-char%29%29%29) | Copies the contents of this string into the destination span. |
| [Create(IFormatProvider, DefaultInterpolatedStringHandler)](system.string.create#system-string-create%28system-iformatprovider-system-runtime-compilerservices-defaultinterpolatedstringhandler@%29) | Creates a new string by using the specified provider to control the formatting of the specified interpolated string. |
| [Create(IFormatProvider, Span&lt;Char&gt;, DefaultInterpolatedStringHandler)](system.string.create#system-string-create%28system-iformatprovider-system-span%28%28system-char%29%29-system-runtime-compilerservices-defaultinterpolatedstringhandler@%29) | Creates a new string by using the specified provider to control the formatting of the specified interpolated string. |
| [Create&lt;TState&gt;(Int32, TState, SpanAction&lt;Char,TState&gt;)](system.string.create#system-string-create-1%28system-int32-0-system-buffers-spanaction%28%28system-char-0%29%29%29) | Creates a new string with a specific length and initializes it after creation by using the specified callback. |
| [EndsWith(Char, StringComparison)](system.string.endswith#system-string-endswith%28system-char-system-stringcomparison%29) |
| [EndsWith(Char)](system.string.endswith#system-string-endswith%28system-char%29) | Determines whether the end of this string instance matches the specified character. |
| [EndsWith(Rune, StringComparison)](system.string.endswith#system-string-endswith%28system-text-rune-system-stringcomparison%29) |
| [EndsWith(Rune)](system.string.endswith#system-string-endswith%28system-text-rune%29) |
| [EndsWith(String, Boolean, CultureInfo)](system.string.endswith#system-string-endswith%28system-string-system-boolean-system-globalization-cultureinfo%29) | Determines whether the end of this string instance matches the specified string when compared using the specified culture. |
| [EndsWith(String, StringComparison)](system.string.endswith#system-string-endswith%28system-string-system-stringcomparison%29) | Determines whether the end of this string instance matches the specified string when compared using the specified comparison option. |
| [EndsWith(String)](system.string.endswith#system-string-endswith%28system-string%29) | Determines whether the end of this string instance matches the specified string. |
| [EnumerateRunes()](system.string.enumeraterunes#system-string-enumeraterunes) | Returns an enumeration of [Rune](system.text.rune) from this string. |
| [Equals(Object)](system.string.equals#system-string-equals%28system-object%29) | Determines whether this instance and a specified object, which must also be a [String](system.string) object, have the same value. |
| [Equals(String, String, StringComparison)](system.string.equals#system-string-equals%28system-string-system-string-system-stringcomparison%29) | Determines whether two specified [String](system.string) objects have the same value. A parameter specifies the culture, case, and sort rules used in the comparison. |
| [Equals(String, String)](system.string.equals#system-string-equals%28system-string-system-string%29) | Determines whether two specified [String](system.string) objects have the same value. |
| [Equals(String, StringComparison)](system.string.equals#system-string-equals%28system-string-system-stringcomparison%29) | Determines whether this string and a specified [String](system.string) object have the same value. A parameter specifies the culture, case, and sort rules used in the comparison. |
| [Equals(String)](system.string.equals#system-string-equals%28system-string%29) | Determines whether this instance and another specified [String](system.string) object have the same value. |
| [Format(IFormatProvider, CompositeFormat, Object\[\])](system.string.format#system-string-format%28system-iformatprovider-system-text-compositeformat-system-object%28%29%29) | Replaces the format item or items in a [CompositeFormat](system.text.compositeformat) with the string representation of the corresponding objects in the specified format. |
| [Format(IFormatProvider, CompositeFormat, ReadOnlySpan&lt;Object&gt;)](system.string.format#system-string-format%28system-iformatprovider-system-text-compositeformat-system-readonlyspan%28%28system-object%29%29%29) | Replaces the format item or items in a [CompositeFormat](system.text.compositeformat) with the string representation of the corresponding objects in the specified format. |
| [Format(IFormatProvider, String, Object, Object, Object)](system.string.format#system-string-format%28system-iformatprovider-system-string-system-object-system-object-system-object%29) | Replaces the format items in a string with the string representation of three specified objects. A parameter supplies culture-specific formatting information. |
| [Format(IFormatProvider, String, Object, Object)](system.string.format#system-string-format%28system-iformatprovider-system-string-system-object-system-object%29) | Replaces the format items in a string with the string representation of two specified objects. A parameter supplies culture-specific formatting information. |
| [Format(IFormatProvider, String, Object)](system.string.format#system-string-format%28system-iformatprovider-system-string-system-object%29) | Replaces the format item or items in a specified string with the string representation of the corresponding object. A parameter supplies culture-specific formatting information. |
| [Format(IFormatProvider, String, Object\[\])](system.string.format#system-string-format%28system-iformatprovider-system-string-system-object%28%29%29) | Replaces the format items in a string with the string representations of corresponding objects in a specified array. A parameter supplies culture-specific formatting information. |
| [Format(IFormatProvider, String, ReadOnlySpan&lt;Object&gt;)](system.string.format#system-string-format%28system-iformatprovider-system-string-system-readonlyspan%28%28system-object%29%29%29) | Replaces the format items in a string with the string representations of corresponding objects in a specified span. A parameter supplies culture-specific formatting information. |
| [Format(String, Object, Object, Object)](system.string.format#system-string-format%28system-string-system-object-system-object-system-object%29) | Replaces the format items in a string with the string representation of three specified objects. |
| [Format(String, Object, Object)](system.string.format#system-string-format%28system-string-system-object-system-object%29) | Replaces the format items in a string with the string representation of two specified objects. |
| [Format(String, Object)](system.string.format#system-string-format%28system-string-system-object%29) | Replaces one or more format items in a string with the string representation of a specified object. |
| [Format(String, Object\[\])](system.string.format#system-string-format%28system-string-system-object%28%29%29) | Replaces the format item in a specified string with the string representation of a corresponding object in a specified array. |
| [Format(String, ReadOnlySpan&lt;Object&gt;)](system.string.format#system-string-format%28system-string-system-readonlyspan%28%28system-object%29%29%29) | Replaces the format item in a specified string with the string representation of a corresponding object in a specified span. |
| [Format&lt;TArg0,TArg1,TArg2&gt;(IFormatProvider, CompositeFormat, TArg0, TArg1, TArg2)](system.string.format#system-string-format-3%28system-iformatprovider-system-text-compositeformat-0-1-2%29) | Replaces the format item or items in a [CompositeFormat](system.text.compositeformat) with the string representation of the corresponding objects in the specified format. |
| [Format&lt;TArg0,TArg1&gt;(IFormatProvider, CompositeFormat, TArg0, TArg1)](system.string.format#system-string-format-2%28system-iformatprovider-system-text-compositeformat-0-1%29) | Replaces the format item or items in a [CompositeFormat](system.text.compositeformat) with the string representation of the corresponding objects in the specified format. |
| [Format&lt;TArg0&gt;(IFormatProvider, CompositeFormat, TArg0)](system.string.format#system-string-format-1%28system-iformatprovider-system-text-compositeformat-0%29) | Replaces the format item or items in a [CompositeFormat](system.text.compositeformat) with the string representation of the corresponding objects in the specified format. |
| [GetEnumerator()](system.string.getenumerator#system-string-getenumerator) | Retrieves an object that can iterate through the individual characters in this string. |
| [GetHashCode()](system.string.gethashcode#system-string-gethashcode) | Returns the hash code for this string. |
| [GetHashCode(ReadOnlySpan&lt;Char&gt;, StringComparison)](system.string.gethashcode#system-string-gethashcode%28system-readonlyspan%28%28system-char%29%29-system-stringcomparison%29) | Returns the hash code for the provided read-only character span using the specified rules. |
| [GetHashCode(ReadOnlySpan&lt;Char&gt;)](system.string.gethashcode#system-string-gethashcode%28system-readonlyspan%28%28system-char%29%29%29) | Returns the hash code for the provided read-only character span. |
| [GetHashCode(StringComparison)](system.string.gethashcode#system-string-gethashcode%28system-stringcomparison%29) | Returns the hash code for this string using the specified rules. |
| [GetPinnableReference()](system.string.getpinnablereference#system-string-getpinnablereference) | Returns a reference to the element of the string at index zero.<br><br>This method is intended to support .NET compilers and is not intended to be called by user code. |
| [GetType()](system.object.gettype#system-object-gettype) | Gets the [Type](system.type) of the current instance.<br> (Inherited from [Object](system.object)) |
| [GetTypeCode()](system.string.gettypecode#system-string-gettypecode) | Returns the [TypeCode](system.typecode) for the [String](system.string) class. |
| [IndexOf(Char, Int32, Int32, StringComparison)](system.string.indexof#system-string-indexof%28system-char-system-int32-system-int32-system-stringcomparison%29) |
| [IndexOf(Char, Int32, Int32)](system.string.indexof#system-string-indexof%28system-char-system-int32-system-int32%29) | Reports the zero-based index of the first occurrence of the specified character in this instance. The search starts at a specified character position and examines a specified number of character positions. |
| [IndexOf(Char, Int32, StringComparison)](system.string.indexof#system-string-indexof%28system-char-system-int32-system-stringcomparison%29) |
| [IndexOf(Char, Int32)](system.string.indexof#system-string-indexof%28system-char-system-int32%29) | Reports the zero-based index of the first occurrence of the specified Unicode character in this string. The search starts at a specified character position. |
| [IndexOf(Char, StringComparison)](system.string.indexof#system-string-indexof%28system-char-system-stringcomparison%29) | Reports the zero-based index of the first occurrence of the specified Unicode character in this string. A parameter specifies the type of search to use for the specified character. |
| [IndexOf(Char)](system.string.indexof#system-string-indexof%28system-char%29) | Reports the zero-based index of the first occurrence of the specified Unicode character in this string. |
| [IndexOf(Rune, Int32, Int32, StringComparison)](system.string.indexof#system-string-indexof%28system-text-rune-system-int32-system-int32-system-stringcomparison%29) |
| [IndexOf(Rune, Int32, Int32)](system.string.indexof#system-string-indexof%28system-text-rune-system-int32-system-int32%29) |
| [IndexOf(Rune, Int32, StringComparison)](system.string.indexof#system-string-indexof%28system-text-rune-system-int32-system-stringcomparison%29) |
| [IndexOf(Rune, Int32)](system.string.indexof#system-string-indexof%28system-text-rune-system-int32%29) |
| [IndexOf(Rune, StringComparison)](system.string.indexof#system-string-indexof%28system-text-rune-system-stringcomparison%29) |
| [IndexOf(Rune)](system.string.indexof#system-string-indexof%28system-text-rune%29) |
| [IndexOf(String, Int32, Int32, StringComparison)](system.string.indexof#system-string-indexof%28system-string-system-int32-system-int32-system-stringcomparison%29) | Reports the zero-based index of the first occurrence of the specified string in the current [String](system.string) object. Parameters specify the starting search position in the current string, the number of characters in the current string to search, and the type of search to use for the specified string. |
| [IndexOf(String, Int32, Int32)](system.string.indexof#system-string-indexof%28system-string-system-int32-system-int32%29) | Reports the zero-based index of the first occurrence of the specified string in this instance. The search starts at a specified character position and examines a specified number of character positions. |
| [IndexOf(String, Int32, StringComparison)](system.string.indexof#system-string-indexof%28system-string-system-int32-system-stringcomparison%29) | Reports the zero-based index of the first occurrence of the specified string in the current [String](system.string) object. Parameters specify the starting search position in the current string and the type of search to use for the specified string. |
| [IndexOf(String, Int32)](system.string.indexof#system-string-indexof%28system-string-system-int32%29) | Reports the zero-based index of the first occurrence of the specified string in this instance. The search starts at a specified character position. |
| [IndexOf(String, StringComparison)](system.string.indexof#system-string-indexof%28system-string-system-stringcomparison%29) | Reports the zero-based index of the first occurrence of the specified string in the current [String](system.string) object. A parameter specifies the type of search to use for the specified string. |
| [IndexOf(String)](system.string.indexof#system-string-indexof%28system-string%29) | Reports the zero-based index of the first occurrence of the specified string in this instance. |
| [IndexOfAny(Char\[\], Int32, Int32)](system.string.indexofany#system-string-indexofany%28system-char%28%29-system-int32-system-int32%29) | Reports the zero-based index of the first occurrence in this instance of any character in a specified array of Unicode characters. The search starts at a specified character position and examines a specified number of character positions. |
| [IndexOfAny(Char\[\], Int32)](system.string.indexofany#system-string-indexofany%28system-char%28%29-system-int32%29) | Reports the zero-based index of the first occurrence in this instance of any character in a specified array of Unicode characters. The search starts at a specified character position. |
| [IndexOfAny(Char\[\])](system.string.indexofany#system-string-indexofany%28system-char%28%29%29) | Reports the zero-based index of the first occurrence in this instance of any character in a specified array of Unicode characters. |
| [Insert(Int32, String)](system.string.insert#system-string-insert%28system-int32-system-string%29) | Returns a new string in which a specified string is inserted at a specified index position in this instance. |
| [Intern(String)](system.string.intern#system-string-intern%28system-string%29) | Retrieves the system's reference to the specified [String](system.string). |
| [IsInterned(String)](system.string.isinterned#system-string-isinterned%28system-string%29) | Retrieves a reference to a specified [String](system.string). |
| [IsNormalized()](system.string.isnormalized#system-string-isnormalized) | Indicates whether this string is in Unicode normalization form C. |
| [IsNormalized(NormalizationForm)](system.string.isnormalized#system-string-isnormalized%28system-text-normalizationform%29) | Indicates whether this string is in the specified Unicode normalization form. |
| [IsNullOrEmpty(String)](system.string.isnullorempty#system-string-isnullorempty%28system-string%29) | Indicates whether the specified string is `null` or an empty string (""). |
| [IsNullOrWhiteSpace(String)](system.string.isnullorwhitespace#system-string-isnullorwhitespace%28system-string%29) | Indicates whether a specified string is `null`, empty, or consists only of white-space characters. |
| [Join(Char, Object\[\])](system.string.join#system-string-join%28system-char-system-object%28%29%29) | Concatenates the string representations of an array of objects, using the specified separator between each member. |
| [Join(Char, ReadOnlySpan&lt;Object&gt;)](system.string.join#system-string-join%28system-char-system-readonlyspan%28%28system-object%29%29%29) | Concatenates the string representations of a span of objects, using the specified separator between each member. |
| [Join(Char, ReadOnlySpan&lt;String&gt;)](system.string.join#system-string-join%28system-char-system-readonlyspan%28%28system-string%29%29%29) | Concatenates a span of strings, using the specified separator between each member. |
| [Join(Char, String\[\], Int32, Int32)](system.string.join#system-string-join%28system-char-system-string%28%29-system-int32-system-int32%29) | Concatenates an array of strings, using the specified separator between each member, starting with the element in `value` located at the `startIndex` position, and concatenating up to `count` elements. |
| [Join(Char, String\[\])](system.string.join#system-string-join%28system-char-system-string%28%29%29) | Concatenates an array of strings, using the specified separator between each member. |
| [Join(String, IEnumerable&lt;String&gt;)](system.string.join#system-string-join%28system-string-system-collections-generic-ienumerable%28%28system-string%29%29%29) | Concatenates the members of a constructed [IEnumerable&lt;T&gt;](system.collections.generic.ienumerable-1) collection of type [String](system.string), using the specified separator between each member. |
| [Join(String, Object\[\])](system.string.join#system-string-join%28system-string-system-object%28%29%29) | Concatenates the elements of an object array, using the specified separator between each element. |
| [Join(String, ReadOnlySpan&lt;Object&gt;)](system.string.join#system-string-join%28system-string-system-readonlyspan%28%28system-object%29%29%29) | Concatenates the string representations of a span of objects, using the specified separator between each member. |
| [Join(String, ReadOnlySpan&lt;String&gt;)](system.string.join#system-string-join%28system-string-system-readonlyspan%28%28system-string%29%29%29) | Concatenates a span of strings, using the specified separator between each member. |
| [Join(String, String\[\], Int32, Int32)](system.string.join#system-string-join%28system-string-system-string%28%29-system-int32-system-int32%29) | Concatenates the specified elements of a string array, using the specified separator between each element. |
| [Join(String, String\[\])](system.string.join#system-string-join%28system-string-system-string%28%29%29) | Concatenates all the elements of a string array, using the specified separator between each element. |
| [Join&lt;T&gt;(Char, IEnumerable&lt;T&gt;)](system.string.join#system-string-join-1%28system-char-system-collections-generic-ienumerable%28%28-0%29%29%29) | Concatenates the members of a collection, using the specified separator between each member. |
| [Join&lt;T&gt;(String, IEnumerable&lt;T&gt;)](system.string.join#system-string-join-1%28system-string-system-collections-generic-ienumerable%28%28-0%29%29%29) | Concatenates the members of a collection, using the specified separator between each member. |
| [LastIndexOf(Char, Int32, Int32, StringComparison)](system.string.lastindexof#system-string-lastindexof%28system-char-system-int32-system-int32-system-stringcomparison%29) |
| [LastIndexOf(Char, Int32, Int32)](system.string.lastindexof#system-string-lastindexof%28system-char-system-int32-system-int32%29) | Reports the zero-based index position of the last occurrence of the specified Unicode character in a substring within this instance. The search starts at a specified character position and proceeds backward toward the beginning of the string for a specified number of character positions. |
| [LastIndexOf(Char, Int32, StringComparison)](system.string.lastindexof#system-string-lastindexof%28system-char-system-int32-system-stringcomparison%29) |
| [LastIndexOf(Char, Int32)](system.string.lastindexof#system-string-lastindexof%28system-char-system-int32%29) | Reports the zero-based index position of the last occurrence of a specified Unicode character within this instance. The search starts at a specified character position and proceeds backward toward the beginning of the string. |
| [LastIndexOf(Char, StringComparison)](system.string.lastindexof#system-string-lastindexof%28system-char-system-stringcomparison%29) |
| [LastIndexOf(Char)](system.string.lastindexof#system-string-lastindexof%28system-char%29) | Reports the zero-based index position of the last occurrence of a specified Unicode character within this instance. |
| [LastIndexOf(Rune, Int32, Int32, StringComparison)](system.string.lastindexof#system-string-lastindexof%28system-text-rune-system-int32-system-int32-system-stringcomparison%29) |
| [LastIndexOf(Rune, Int32, Int32)](system.string.lastindexof#system-string-lastindexof%28system-text-rune-system-int32-system-int32%29) |
| [LastIndexOf(Rune, Int32, StringComparison)](system.string.lastindexof#system-string-lastindexof%28system-text-rune-system-int32-system-stringcomparison%29) |
| [LastIndexOf(Rune, Int32)](system.string.lastindexof#system-string-lastindexof%28system-text-rune-system-int32%29) |
| [LastIndexOf(Rune, StringComparison)](system.string.lastindexof#system-string-lastindexof%28system-text-rune-system-stringcomparison%29) |
| [LastIndexOf(Rune)](system.string.lastindexof#system-string-lastindexof%28system-text-rune%29) |
| [LastIndexOf(String, Int32, Int32, StringComparison)](system.string.lastindexof#system-string-lastindexof%28system-string-system-int32-system-int32-system-stringcomparison%29) | Reports the zero-based index position of the last occurrence of a specified string within this instance. The search starts at a specified character position and proceeds backward toward the beginning of the string for the specified number of character positions. A parameter specifies the type of comparison to perform when searching for the specified string. |
| [LastIndexOf(String, Int32, Int32)](system.string.lastindexof#system-string-lastindexof%28system-string-system-int32-system-int32%29) | Reports the zero-based index position of the last occurrence of a specified string within this instance. The search starts at a specified character position and proceeds backward toward the beginning of the string for a specified number of character positions. |
| [LastIndexOf(String, Int32, StringComparison)](system.string.lastindexof#system-string-lastindexof%28system-string-system-int32-system-stringcomparison%29) | Reports the zero-based index of the last occurrence of a specified string within the current [String](system.string) object. The search starts at a specified character position and proceeds backward toward the beginning of the string. A parameter specifies the type of comparison to perform when searching for the specified string. |
| [LastIndexOf(String, Int32)](system.string.lastindexof#system-string-lastindexof%28system-string-system-int32%29) | Reports the zero-based index position of the last occurrence of a specified string within this instance. The search starts at a specified character position and proceeds backward toward the beginning of the string. |
| [LastIndexOf(String, StringComparison)](system.string.lastindexof#system-string-lastindexof%28system-string-system-stringcomparison%29) | Reports the zero-based index of the last occurrence of a specified string within the current [String](system.string) object. A parameter specifies the type of search to use for the specified string. |
| [LastIndexOf(String)](system.string.lastindexof#system-string-lastindexof%28system-string%29) | Reports the zero-based index position of the last occurrence of a specified string within this instance. |
| [LastIndexOfAny(Char\[\], Int32, Int32)](system.string.lastindexofany#system-string-lastindexofany%28system-char%28%29-system-int32-system-int32%29) | Reports the zero-based index position of the last occurrence in this instance of one or more characters specified in a Unicode array. The search starts at a specified character position and proceeds backward toward the beginning of the string for a specified number of character positions. |
| [LastIndexOfAny(Char\[\], Int32)](system.string.lastindexofany#system-string-lastindexofany%28system-char%28%29-system-int32%29) | Reports the zero-based index position of the last occurrence in this instance of one or more characters specified in a Unicode array. The search starts at a specified character position and proceeds backward toward the beginning of the string. |
| [LastIndexOfAny(Char\[\])](system.string.lastindexofany#system-string-lastindexofany%28system-char%28%29%29) | Reports the zero-based index position of the last occurrence in this instance of one or more characters specified in a Unicode array. |
| [MemberwiseClone()](system.object.memberwiseclone#system-object-memberwiseclone) | Creates a shallow copy of the current [Object](system.object).<br> (Inherited from [Object](system.object)) |
| [Normalize()](system.string.normalize#system-string-normalize) | Returns a new string whose textual value is the same as this string, but whose binary representation is in Unicode normalization form C. |
| [Normalize(NormalizationForm)](system.string.normalize#system-string-normalize%28system-text-normalizationform%29) | Returns a new string whose textual value is the same as this string, but whose binary representation is in the specified Unicode normalization form. |
| [PadLeft(Int32, Char)](system.string.padleft#system-string-padleft%28system-int32-system-char%29) | Returns a new string that right-aligns the characters in this instance by padding them on the left with a specified Unicode character, for a specified total length. |
| [PadLeft(Int32)](system.string.padleft#system-string-padleft%28system-int32%29) | Returns a new string that right-aligns the characters in this instance by padding them with spaces on the left, for a specified total length. |
| [PadRight(Int32, Char)](system.string.padright#system-string-padright%28system-int32-system-char%29) | Returns a new string that left-aligns the characters in this string by padding them on the right with a specified Unicode character, for a specified total length. |
| [PadRight(Int32)](system.string.padright#system-string-padright%28system-int32%29) | Returns a new string that left-aligns the characters in this string by padding them with spaces on the right, for a specified total length. |
| [Remove(Int32, Int32)](system.string.remove#system-string-remove%28system-int32-system-int32%29) | Returns a new string in which a specified number of characters in the current instance beginning at a specified position have been deleted. |
| [Remove(Int32)](system.string.remove#system-string-remove%28system-int32%29) | Returns a new string in which all the characters in the current instance, beginning at a specified position and continuing through the last position, have been deleted. |
| [Replace(Char, Char)](system.string.replace#system-string-replace%28system-char-system-char%29) | Returns a new string in which all occurrences of a specified Unicode character in this instance are replaced with another specified Unicode character. |
| [Replace(Rune, Rune)](system.string.replace#system-string-replace%28system-text-rune-system-text-rune%29) |
| [Replace(String, String, Boolean, CultureInfo)](system.string.replace#system-string-replace%28system-string-system-string-system-boolean-system-globalization-cultureinfo%29) | Returns a new string in which all occurrences of a specified string in the current instance are replaced with another specified string, using the provided culture and case sensitivity. |
| [Replace(String, String, StringComparison)](system.string.replace#system-string-replace%28system-string-system-string-system-stringcomparison%29) | Returns a new string in which all occurrences of a specified string in the current instance are replaced with another specified string, using the provided comparison type. |
| [Replace(String, String)](system.string.replace#system-string-replace%28system-string-system-string%29) | Returns a new string in which all occurrences of a specified string in the current instance are replaced with another specified string. |
| [ReplaceLineEndings()](system.string.replacelineendings#system-string-replacelineendings) | Replaces all newline sequences in the current string with [NewLine](system.environment.newline#system-environment-newline). |
| [ReplaceLineEndings(String)](system.string.replacelineendings#system-string-replacelineendings%28system-string%29) | Replaces all newline sequences in the current string with `replacementText`. |
| [Split(Char, Int32, StringSplitOptions)](system.string.split#system-string-split%28system-char-system-int32-system-stringsplitoptions%29) | Splits a string into a maximum number of substrings based on the provided character separator, optionally omitting empty substrings from the result. |
| [Split(Char, StringSplitOptions)](system.string.split#system-string-split%28system-char-system-stringsplitoptions%29) | Splits a string into substrings based on a specified delimiting character and, optionally, options. |
| [Split(Char\[\], Int32, StringSplitOptions)](system.string.split#system-string-split%28system-char%28%29-system-int32-system-stringsplitoptions%29) | Splits a string into a maximum number of substrings based on specified delimiting characters and, optionally, options. |
| [Split(Char\[\], Int32)](system.string.split#system-string-split%28system-char%28%29-system-int32%29) | Splits a string into a maximum number of substrings based on specified delimiting characters. |
| [Split(Char\[\], StringSplitOptions)](system.string.split#system-string-split%28system-char%28%29-system-stringsplitoptions%29) | Splits a string into substrings based on specified delimiting characters and options. |
| [Split(Char\[\])](system.string.split#system-string-split%28system-char%28%29%29) | Splits a string into substrings based on specified delimiting characters. |
| [Split(ReadOnlySpan&lt;Char&gt;)](system.string.split#system-string-split%28system-readonlyspan%28%28system-char%29%29%29) | Splits a string into substrings based on specified delimiting characters. |
| [Split(Rune, Int32, StringSplitOptions)](system.string.split#system-string-split%28system-text-rune-system-int32-system-stringsplitoptions%29) |
| [Split(Rune, StringSplitOptions)](system.string.split#system-string-split%28system-text-rune-system-stringsplitoptions%29) |
| [Split(String, Int32, StringSplitOptions)](system.string.split#system-string-split%28system-string-system-int32-system-stringsplitoptions%29) | Splits a string into a maximum number of substrings based on a specified delimiting string and, optionally, options. |
| [Split(String, StringSplitOptions)](system.string.split#system-string-split%28system-string-system-stringsplitoptions%29) | Splits a string into substrings that are based on the provided string separator. |
| [Split(String\[\], Int32, StringSplitOptions)](system.string.split#system-string-split%28system-string%28%29-system-int32-system-stringsplitoptions%29) | Splits a string into a maximum number of substrings based on specified delimiting strings and, optionally, options. |
| [Split(String\[\], StringSplitOptions)](system.string.split#system-string-split%28system-string%28%29-system-stringsplitoptions%29) | Splits a string into substrings based on a specified delimiting string and, optionally, options. |
| [StartsWith(Char, StringComparison)](system.string.startswith#system-string-startswith%28system-char-system-stringcomparison%29) |
| [StartsWith(Char)](system.string.startswith#system-string-startswith%28system-char%29) | Determines whether this string instance starts with the specified character. |
| [StartsWith(Rune, StringComparison)](system.string.startswith#system-string-startswith%28system-text-rune-system-stringcomparison%29) |
| [StartsWith(Rune)](system.string.startswith#system-string-startswith%28system-text-rune%29) |
| [StartsWith(String, Boolean, CultureInfo)](system.string.startswith#system-string-startswith%28system-string-system-boolean-system-globalization-cultureinfo%29) | Determines whether the beginning of this string instance matches the specified string when compared using the specified culture. |
| [StartsWith(String, StringComparison)](system.string.startswith#system-string-startswith%28system-string-system-stringcomparison%29) | Determines whether the beginning of this string instance matches the specified string when compared using the specified comparison option. |
| [StartsWith(String)](system.string.startswith#system-string-startswith%28system-string%29) | Determines whether the beginning of this string instance matches the specified string. |
| [Substring(Int32, Int32)](system.string.substring#system-string-substring%28system-int32-system-int32%29) | Retrieves a substring from this instance. The substring starts at a specified character position and has a specified length. |
| [Substring(Int32)](system.string.substring#system-string-substring%28system-int32%29) | Retrieves a substring from this instance. The substring starts at a specified character position and continues to the end of the string. |
| [ToCharArray()](system.string.tochararray#system-string-tochararray) | Copies the characters in this instance to a Unicode character array. |
| [ToCharArray(Int32, Int32)](system.string.tochararray#system-string-tochararray%28system-int32-system-int32%29) | Copies the characters in a specified substring in this instance to a Unicode character array. |
| [ToLower()](system.string.tolower#system-string-tolower) | Returns a copy of this string converted to lowercase. |
| [ToLower(CultureInfo)](system.string.tolower#system-string-tolower%28system-globalization-cultureinfo%29) | Returns a copy of this string converted to lowercase, using the casing rules of the specified culture. |
| [ToLowerInvariant()](system.string.tolowerinvariant#system-string-tolowerinvariant) | Returns a copy of this [String](system.string) object converted to lowercase using the casing rules of the invariant culture. |
| [ToString()](system.string.tostring#system-string-tostring) | Returns this instance of [String](system.string); no actual conversion is performed. |
| [ToString(IFormatProvider)](system.string.tostring#system-string-tostring%28system-iformatprovider%29) | Returns this instance of [String](system.string); no actual conversion is performed. |
| [ToUpper()](system.string.toupper#system-string-toupper) | Returns a copy of this string converted to uppercase. |
| [ToUpper(CultureInfo)](system.string.toupper#system-string-toupper%28system-globalization-cultureinfo%29) | Returns a copy of this string converted to uppercase, using the casing rules of the specified culture. |
| [ToUpperInvariant()](system.string.toupperinvariant#system-string-toupperinvariant) | Returns a copy of this [String](system.string) object converted to uppercase using the casing rules of the invariant culture. |
| [Trim()](system.string.trim#system-string-trim) | Removes all leading and trailing white-space characters from the current string. |
| [Trim(Char)](system.string.trim#system-string-trim%28system-char%29) | Removes all leading and trailing instances of a character from the current string. |
| [Trim(Char\[\])](system.string.trim#system-string-trim%28system-char%28%29%29) | Removes all leading and trailing occurrences of a set of characters specified in an array from the current string. |
| [Trim(Rune)](system.string.trim#system-string-trim%28system-text-rune%29) |
| [TrimEnd()](system.string.trimend#system-string-trimend) | Removes all the trailing white-space characters from the current string. |
| [TrimEnd(Char)](system.string.trimend#system-string-trimend%28system-char%29) | Removes all the trailing occurrences of a character from the current string. |
| [TrimEnd(Char\[\])](system.string.trimend#system-string-trimend%28system-char%28%29%29) | Removes all the trailing occurrences of a set of characters specified in an array from the current string. |
| [TrimEnd(Rune)](system.string.trimend#system-string-trimend%28system-text-rune%29) |
| [TrimStart()](system.string.trimstart#system-string-trimstart) | Removes all the leading white-space characters from the current string. |
| [TrimStart(Char)](system.string.trimstart#system-string-trimstart%28system-char%29) | Removes all the leading occurrences of a specified character from the current string. |
| [TrimStart(Char\[\])](system.string.trimstart#system-string-trimstart%28system-char%28%29%29) | Removes all the leading occurrences of a set of characters specified in an array from the current string. |
| [TrimStart(Rune)](system.string.trimstart#system-string-trimstart%28system-text-rune%29) |
| [TryCopyTo(Span&lt;Char&gt;)](system.string.trycopyto#system-string-trycopyto%28system-span%28%28system-char%29%29%29) | Copies the contents of this string into the destination span. |

## Operators

| Name | Description |
| --- | --- |
| [Equality(String, String)](system.string.op_equality#system-string-op-equality%28system-string-system-string%29) | Determines whether two specified strings have the same value. |
| [Implicit(String to ReadOnlySpan&lt;Char&gt;)](system.string.op_implicit#system-string-op-implicit%28system-string%29-system-readonlyspan%28%28system-char%29%29) | Defines an implicit conversion of a given string to a read-only span of characters. |
| [Inequality(String, String)](system.string.op_inequality#system-string-op-inequality%28system-string-system-string%29) | Determines whether two specified strings have different values. |

## Explicit Interface Implementations

| Name | Description |
| --- | --- |
| [IComparable.CompareTo(Object)](system.string.system-icomparable-compareto#system-string-system-icomparable-compareto%28system-object%29) | Compares this instance with a specified [Object](system.object) and indicates whether this instance precedes, follows, or appears in the same position in the sort order as the specified [Object](system.object). |
| [IConvertible.GetTypeCode()](system.string.system-iconvertible-gettypecode#system-string-system-iconvertible-gettypecode) | Returns the [TypeCode](system.typecode) for the [String](system.string) class. |
| [IConvertible.ToBoolean(IFormatProvider)](system.string.system-iconvertible-toboolean#system-string-system-iconvertible-toboolean%28system-iformatprovider%29) | For a description of this member, see [ToBoolean(IFormatProvider)](system.iconvertible.toboolean#system-iconvertible-toboolean%28system-iformatprovider%29). |
| [IConvertible.ToByte(IFormatProvider)](system.string.system-iconvertible-tobyte#system-string-system-iconvertible-tobyte%28system-iformatprovider%29) | For a description of this member, see [ToByte(IFormatProvider)](system.iconvertible.tobyte#system-iconvertible-tobyte%28system-iformatprovider%29). |
| [IConvertible.ToChar(IFormatProvider)](system.string.system-iconvertible-tochar#system-string-system-iconvertible-tochar%28system-iformatprovider%29) | For a description of this member, see [ToChar(IFormatProvider)](system.iconvertible.tochar#system-iconvertible-tochar%28system-iformatprovider%29). |
| [IConvertible.ToDateTime(IFormatProvider)](system.string.system-iconvertible-todatetime#system-string-system-iconvertible-todatetime%28system-iformatprovider%29) | For a description of this member, see [ToDateTime(IFormatProvider)](system.iconvertible.todatetime#system-iconvertible-todatetime%28system-iformatprovider%29). |
| [IConvertible.ToDecimal(IFormatProvider)](system.string.system-iconvertible-todecimal#system-string-system-iconvertible-todecimal%28system-iformatprovider%29) | For a description of this member, see [ToDecimal(IFormatProvider)](system.iconvertible.todecimal#system-iconvertible-todecimal%28system-iformatprovider%29). |
| [IConvertible.ToDouble(IFormatProvider)](system.string.system-iconvertible-todouble#system-string-system-iconvertible-todouble%28system-iformatprovider%29) | For a description of this member, see [ToDouble(IFormatProvider)](system.iconvertible.todouble#system-iconvertible-todouble%28system-iformatprovider%29). |
| [IConvertible.ToInt16(IFormatProvider)](system.string.system-iconvertible-toint16#system-string-system-iconvertible-toint16%28system-iformatprovider%29) | For a description of this member, see [ToInt16(IFormatProvider)](system.iconvertible.toint16#system-iconvertible-toint16%28system-iformatprovider%29). |
| [IConvertible.ToInt32(IFormatProvider)](system.string.system-iconvertible-toint32#system-string-system-iconvertible-toint32%28system-iformatprovider%29) | For a description of this member, see [ToInt32(IFormatProvider)](system.iconvertible.toint32#system-iconvertible-toint32%28system-iformatprovider%29). |
| [IConvertible.ToInt64(IFormatProvider)](system.string.system-iconvertible-toint64#system-string-system-iconvertible-toint64%28system-iformatprovider%29) | For a description of this member, see [ToInt64(IFormatProvider)](system.iconvertible.toint64#system-iconvertible-toint64%28system-iformatprovider%29). |
| [IConvertible.ToSByte(IFormatProvider)](system.string.system-iconvertible-tosbyte#system-string-system-iconvertible-tosbyte%28system-iformatprovider%29) | For a description of this member, see [ToSByte(IFormatProvider)](system.iconvertible.tosbyte#system-iconvertible-tosbyte%28system-iformatprovider%29). |
| [IConvertible.ToSingle(IFormatProvider)](system.string.system-iconvertible-tosingle#system-string-system-iconvertible-tosingle%28system-iformatprovider%29) | For a description of this member, see [ToSingle(IFormatProvider)](system.iconvertible.tosingle#system-iconvertible-tosingle%28system-iformatprovider%29). |
| [IConvertible.ToString(IFormatProvider)](system.string.system-iconvertible-tostring#system-string-system-iconvertible-tostring%28system-iformatprovider%29) | For a description of this member, see [ToString(IFormatProvider)](system.iconvertible.tostring#system-iconvertible-tostring%28system-iformatprovider%29). |
| [IConvertible.ToType(Type, IFormatProvider)](system.string.system-iconvertible-totype#system-string-system-iconvertible-totype%28system-type-system-iformatprovider%29) | For a description of this member, see [ToType(Type, IFormatProvider)](system.iconvertible.totype#system-iconvertible-totype%28system-type-system-iformatprovider%29). |
| [IConvertible.ToUInt16(IFormatProvider)](system.string.system-iconvertible-touint16#system-string-system-iconvertible-touint16%28system-iformatprovider%29) | For a description of this member, see [ToUInt16(IFormatProvider)](system.iconvertible.touint16#system-iconvertible-touint16%28system-iformatprovider%29). |
| [IConvertible.ToUInt32(IFormatProvider)](system.string.system-iconvertible-touint32#system-string-system-iconvertible-touint32%28system-iformatprovider%29) | For a description of this member, see [ToUInt32(IFormatProvider)](system.iconvertible.touint32#system-iconvertible-touint32%28system-iformatprovider%29). |
| [IConvertible.ToUInt64(IFormatProvider)](system.string.system-iconvertible-touint64#system-string-system-iconvertible-touint64%28system-iformatprovider%29) | For a description of this member, see [ToUInt64(IFormatProvider)](system.iconvertible.touint64#system-iconvertible-touint64%28system-iformatprovider%29). |
| [IEnumerable.GetEnumerator()](system.string.system-collections-ienumerable-getenumerator#system-string-system-collections-ienumerable-getenumerator) | Returns an enumerator that iterates through the current [String](system.string) object. |
| [IEnumerable&lt;Char&gt;.GetEnumerator()](system.string.system-collections-generic-ienumerable-system-char--getenumerator#system-string-system-collections-generic-ienumerable%28%28system-char%29%29-getenumerator) | Returns an enumerator that iterates through the current [String](system.string) object. |
| [IParsable&lt;String&gt;.Parse(String, IFormatProvider)](system.string.system-iparsable-system-string--parse#system-string-system-iparsable%28%28system-string%29%29-parse%28system-string-system-iformatprovider%29) | Parses a string into a value. |
| [IParsable&lt;String&gt;.TryParse(String, IFormatProvider, String)](system.string.system-iparsable-system-string--tryparse#system-string-system-iparsable%28%28system-string%29%29-tryparse%28system-string-system-iformatprovider-system-string@%29) |
| [ISpanParsable&lt;String&gt;.Parse(ReadOnlySpan&lt;Char&gt;, IFormatProvider)](system.string.system-ispanparsable-system-string--parse#system-string-system-ispanparsable%28%28system-string%29%29-parse%28system-readonlyspan%28%28system-char%29%29-system-iformatprovider%29) | Parses a span of characters into a value. |
| [ISpanParsable&lt;String&gt;.TryParse(ReadOnlySpan&lt;Char&gt;, IFormatProvider, String)](system.string.system-ispanparsable-system-string--tryparse#system-string-system-ispanparsable%28%28system-string%29%29-tryparse%28system-readonlyspan%28%28system-char%29%29-system-iformatprovider-system-string@%29) |

## Extension Methods

| Name | Description |
| --- | --- |
| [Aggregate&lt;TSource,TAccumulate,TResult&gt;(IEnumerable&lt;TSource&gt;, TAccumulate, Func&lt;TAccumulate,TSource,TAccumulate&gt;, Func&lt;TAccumulate,TResult&gt;)](system.linq.enumerable.aggregate#system-linq-enumerable-aggregate-3%28system-collections-generic-ienumerable%28%28-0%29%29-1-system-func%28%28-1-0-1%29%29-system-func%28%28-1-2%29%29%29) | Applies an accumulator function over a sequence. The specified seed value is used as the initial accumulator value, and the specified function is used to select the result value. |
| [Aggregate&lt;TSource,TAccumulate&gt;(IEnumerable&lt;TSource&gt;, TAccumulate, Func&lt;TAccumulate,TSource,TAccumulate&gt;)](system.linq.enumerable.aggregate#system-linq-enumerable-aggregate-2%28system-collections-generic-ienumerable%28%28-0%29%29-1-system-func%28%28-1-0-1%29%29%29) | Applies an accumulator function over a sequence. The specified seed value is used as the initial accumulator value. |
| [Aggregate&lt;TSource&gt;(IEnumerable&lt;TSource&gt;, Func&lt;TSource,TSource,TSource&gt;)](system.linq.enumerable.aggregate#system-linq-enumerable-aggregate-1%28system-collections-generic-ienumerable%28%28-0%29%29-system-func%28%28-0-0-0%29%29%29) | Applies an accumulator function over a sequence. |
| [AggregateBy&lt;TSource,TKey,TAccumulate&gt;(IEnumerable&lt;TSource&gt;, Func&lt;TSource, TKey&gt;, Func&lt;TKey,TAccumulate&gt;, Func&lt;TAccumulate,TSource,TAccumulate&gt;, IEqualityComparer&lt;TKey&gt;)](system.linq.enumerable.aggregateby#system-linq-enumerable-aggregateby-3%28system-collections-generic-ienumerable%28%28-0%29%29-system-func%28%28-0-1%29%29-system-func%28%28-1-2%29%29-system-func%28%28-2-0-2%29%29-system-collections-generic-iequalitycomparer%28%28-1%29%29%29) | Applies an accumulator function over a sequence, grouping results by key. |
| [AggregateBy&lt;TSource,TKey,TAccumulate&gt;(IEnumerable&lt;TSource&gt;, Func&lt;TSource, TKey&gt;, TAccumulate, Func&lt;TAccumulate,TSource,TAccumulate&gt;, IEqualityComparer&lt;TKey&gt;)](system.linq.enumerable.aggregateby#system-linq-enumerable-aggregateby-3%28system-collections-generic-ienumerable%28%28-0%29%29-system-func%28%28-0-1%29%29-2-system-func%28%28-2-0-2%29%29-system-collections-generic-iequalitycomparer%28%28-1%29%29%29) | Applies an accumulator function over a sequence, grouping results by key. |
| [All&lt;TSource&gt;(IEnumerable&lt;TSource&gt;, Func&lt;TSource,Boolean&gt;)](system.linq.enumerable.all#system-linq-enumerable-all-1%28system-collections-generic-ienumerable%28%28-0%29%29-system-func%28%28-0-system-boolean%29%29%29) | Determines whether all elements of a sequence satisfy a condition. |
| [Ancestors&lt;T&gt;(IEnumerable&lt;T&gt;, XName)](system.xml.linq.extensions.ancestors#system-xml-linq-extensions-ancestors-1%28system-collections-generic-ienumerable%28%28-0%29%29-system-xml-linq-xname%29) | Returns a filtered collection of elements that contains the ancestors of every node in the source collection. Only elements that have a matching [XName](system.xml.linq.xname) are included in the collection. |
| [Ancestors&lt;T&gt;(IEnumerable&lt;T&gt;)](system.xml.linq.extensions.ancestors#system-xml-linq-extensions-ancestors-1%28system-collections-generic-ienumerable%28%28-0%29%29%29) | Returns a collection of elements that contains the ancestors of every node in the source collection. |
| [Any&lt;TSource&gt;(IEnumerable&lt;TSource&gt;, Func&lt;TSource,Boolean&gt;)](system.linq.enumerable.any#system-linq-enumerable-any-1%28system-collections-generic-ienumerable%28%28-0%29%29-system-func%28%28-0-system-boolean%29%29%29) | Determines whether any element of a sequence satisfies a condition. |
| [Any&lt;TSource&gt;(IEnumerable&lt;TSource&gt;)](system.linq.enumerable.any#system-linq-enumerable-any-1%28system-collections-generic-ienumerable%28%28-0%29%29%29) | Determines whether a sequence contains any elements. |
| [Append&lt;TSource&gt;(IEnumerable&lt;TSource&gt;, TSource)](system.linq.enumerable.append#system-linq-enumerable-append-1%28system-collections-generic-ienumerable%28%28-0%29%29-0%29) | Appends a value to the end of the sequence. |
| [AsEnumerable&lt;TSource&gt;(IEnumerable&lt;TSource&gt;)](system.linq.enumerable.asenumerable#system-linq-enumerable-asenumerable-1%28system-collections-generic-ienumerable%28%28-0%29%29%29) | Returns the input typed as [IEnumerable&lt;T&gt;](system.collections.generic.ienumerable-1). |
| [AsMemory(String, Index)](system.memoryextensions.asmemory#system-memoryextensions-asmemory%28system-string-system-index%29) | Creates a new `ReadOnlyMemory<Char>` over a portion of the target string starting at a specified index. |
| [AsMemory(String, Int32, Int32)](system.memoryextensions.asmemory#system-memoryextensions-asmemory%28system-string-system-int32-system-int32%29) | Creates a new `ReadOnlyMemory<Char>` over a portion of the target string beginning at a specified position with a length. |
| [AsMemory(String, Int32)](system.memoryextensions.asmemory#system-memoryextensions-asmemory%28system-string-system-int32%29) | Creates a new `ReadOnlyMemory<Char>` over a portion of the target string starting at a specified character position. |
| [AsMemory(String, Range)](system.memoryextensions.asmemory#system-memoryextensions-asmemory%28system-string-system-range%29) | Creates a new `ReadOnlyMemory<Char>` over a specified range of the target string. |
| [AsMemory(String)](system.memoryextensions.asmemory#system-memoryextensions-asmemory%28system-string%29) | Creates a new `ReadOnlyMemory<Char>` over the portion of the target string. |
| [AsParallel(IEnumerable)](system.linq.parallelenumerable.asparallel#system-linq-parallelenumerable-asparallel%28system-collections-ienumerable%29) | Enables parallelization of a query. |
| [AsParallel&lt;TSource&gt;(IEnumerable&lt;TSource&gt;)](system.linq.parallelenumerable.asparallel#system-linq-parallelenumerable-asparallel-1%28system-collections-generic-ienumerable%28%28-0%29%29%29) | Enables parallelization of a query. |
| [AsQueryable(IEnumerable)](system.linq.queryable.asqueryable#system-linq-queryable-asqueryable%28system-collections-ienumerable%29) | Converts an [IEnumerable](system.collections.ienumerable) to an [IQueryable](system.linq.iqueryable). |
| [AsQueryable&lt;TElement&gt;(IEnumerable&lt;TElement&gt;)](system.linq.queryable.asqueryable#system-linq-queryable-asqueryable-1%28system-collections-generic-ienumerable%28%28-0%29%29%29) | Converts a generic [IEnumerable&lt;T&gt;](system.collections.generic.ienumerable-1) to a generic [IQueryable&lt;T&gt;](system.linq.iqueryable-1). |
| [AsSpan(String, Index)](system.memoryextensions.asspan#system-memoryextensions-asspan%28system-string-system-index%29) | Creates a new [ReadOnlySpan&lt;T&gt;](system.readonlyspan-1) over a portion of the target string from a specified position to the end of the string. |
| [AsSpan(String, Int32, Int32)](system.memoryextensions.asspan#system-memoryextensions-asspan%28system-string-system-int32-system-int32%29) | Creates a new read-only span over a portion of the target string from a specified position for a specified number of characters. |
| [AsSpan(String, Int32)](system.memoryextensions.asspan#system-memoryextensions-asspan%28system-string-system-int32%29) | Creates a new read-only span over a portion of the target string from a specified position to the end of the string. |
| [AsSpan(String, Range)](system.memoryextensions.asspan#system-memoryextensions-asspan%28system-string-system-range%29) | Creates a new [ReadOnlySpan&lt;T&gt;](system.readonlyspan-1) over a portion of a target string using the range start and end indexes. |
| [AsSpan(String)](system.memoryextensions.asspan#system-memoryextensions-asspan%28system-string%29) | Creates a new read-only span over a string. |
| [Average&lt;TSource&gt;(IEnumerable&lt;TSource&gt;, Func&lt;TSource,Decimal&gt;)](system.linq.enumerable.average#system-linq-enumerable-average-1%28system-collections-generic-ienumerable%28%28-0%29%29-system-func%28%28-0-system-decimal%29%29%29) | Computes the average of a sequence of [Decimal](system.decimal) values that are obtained by invoking a transform function on each element of the input sequence. |
| [Average&lt;TSource&gt;(IEnumerable&lt;TSource&gt;, Func&lt;TSource,Double&gt;)](system.linq.enumerable.average#system-linq-enumerable-average-1%28system-collections-generic-ienumerable%28%28-0%29%29-system-func%28%28-0-system-double%29%29%29) | Computes the average of a sequence of [Double](system.double) values that are obtained by invoking a transform function on each element of the input sequence. |
| [Average&lt;TSource&gt;(IEnumerable&lt;TSource&gt;, Func&lt;TSource,Int32&gt;)](system.linq.enumerable.average#system-linq-enumerable-average-1%28system-collections-generic-ienumerable%28%28-0%29%29-system-func%28%28-0-system-int32%29%29%29) | Computes the average of a sequence of [Int32](system.int32) values that are obtained by invoking a transform function on each element of the input sequence. |
| [Average&lt;TSource&gt;(IEnumerable&lt;TSource&gt;, Func&lt;TSource,Int64&gt;)](system.linq.enumerable.average#system-linq-enumerable-average-1%28system-collections-generic-ienumerable%28%28-0%29%29-system-func%28%28-0-system-int64%29%29%29) | Computes the average of a sequence of [Int64](system.int64) values that are obtained by invoking a transform function on each element of the input sequence. |
| [Average&lt;TSource&gt;(IEnumerable&lt;TSource&gt;, Func&lt;TSource,Nullable&lt;Decimal&gt;&gt;)](system.linq.enumerable.average#system-linq-enumerable-average-1%28system-collections-generic-ienumerable%28%28-0%29%29-system-func%28%28-0-system-nullable%28%28system-decimal%29%29%29%29%29) | Computes the average of a sequence of nullable [Decimal](system.decimal) values that are obtained by invoking a transform function on each element of the input sequence. |
| [Average&lt;TSource&gt;(IEnumerable&lt;TSource&gt;, Func&lt;TSource,Nullable&lt;Double&gt;&gt;)](system.linq.enumerable.average#system-linq-enumerable-average-1%28system-collections-generic-ienumerable%28%28-0%29%29-system-func%28%28-0-system-nullable%28%28system-double%29%29%29%29%29) | Computes the average of a sequence of nullable [Double](system.double) values that are obtained by invoking a transform function on each element of the input sequence. |
| [Average&lt;TSource&gt;(IEnumerable&lt;TSource&gt;, Func&lt;TSource,Nullable&lt;Int32&gt;&gt;)](system.linq.enumerable.average#system-linq-enumerable-average-1%28system-collections-generic-ienumerable%28%28-0%29%29-system-func%28%28-0-system-nullable%28%28system-int32%29%29%29%29%29) | Computes the average of a sequence of nullable [Int32](system.int32) values that are obtained by invoking a transform function on each element of the input sequence. |
| [Average&lt;TSource&gt;(IEnumerable&lt;TSource&gt;, Func&lt;TSource,Nullable&lt;Int64&gt;&gt;)](system.linq.enumerable.average#system-linq-enumerable-average-1%28system-collections-generic-ienumerable%28%28-0%29%29-system-func%28%28-0-system-nullable%28%28system-int64%29%29%29%29%29) | Computes the average of a sequence of nullable [Int64](system.int64) values that are obtained by invoking a transform function on each element of the input sequence. |
| [Average&lt;TSource&gt;(IEnumerable&lt;TSource&gt;, Func&lt;TSource,Nullable&lt;Single&gt;&gt;)](system.linq.enumerable.average#system-linq-enumerable-average-1%28system-collections-generic-ienumerable%28%28-0%29%29-system-func%28%28-0-system-nullable%28%28system-single%29%29%29%29%29) | Computes the average of a sequence of nullable [Single](system.single) values that are obtained by invoking a transform function on each element of the input sequence. |
| [Average&lt;TSource&gt;(IEnumerable&lt;TSource&gt;, Func&lt;TSource,Single&gt;)](system.linq.enumerable.average#system-linq-enumerable-average-1%28system-collections-generic-ienumerable%28%28-0%29%29-system-func%28%28-0-system-single%29%29%29) | Computes the average of a sequence of [Single](system.single) values that are obtained by invoking a transform function on each element of the input sequence. |
| [Cast&lt;TResult&gt;(IEnumerable)](system.linq.enumerable.cast#system-linq-enumerable-cast-1%28system-collections-ienumerable%29) | Casts the elements of an [IEnumerable](system.collections.ienumerable) to the specified type. |
| [Chunk&lt;TSource&gt;(IEnumerable&lt;TSource&gt;, Int32)](system.linq.enumerable.chunk#system-linq-enumerable-chunk-1%28system-collections-generic-ienumerable%28%28-0%29%29-system-int32%29) | Splits the elements of a sequence into chunks of size at most `size`. |
| [Concat&lt;TSource&gt;(IEnumerable&lt;TSource&gt;, IEnumerable&lt;TSource&gt;)](system.linq.enumerable.concat#system-linq-enumerable-concat-1%28system-collections-generic-ienumerable%28%28-0%29%29-system-collections-generic-ienumerable%28%28-0%29%29%29) | Concatenates two sequences. |
| [Contains&lt;TSource&gt;(IEnumerable&lt;TSource&gt;, TSource, IEqualityComparer&lt;TSource&gt;)](system.linq.enumerable.contains#system-linq-enumerable-contains-1%28system-collections-generic-ienumerable%28%28-0%29%29-0-system-collections-generic-iequalitycomparer%28%28-0%29%29%29) | Determines whether a sequence contains a specified element by using a specified [IEqualityComparer&lt;T&gt;](system.collections.generic.iequalitycomparer-1). |
| [Contains&lt;TSource&gt;(IEnumerable&lt;TSource&gt;, TSource)](system.linq.enumerable.contains#system-linq-enumerable-contains-1%28system-collections-generic-ienumerable%28%28-0%29%29-0%29) | Determines whether a sequence contains a specified element by using the default equality comparer. |
| [CopyToDataTable&lt;T&gt;(IEnumerable&lt;T&gt;, DataTable, LoadOption, FillErrorEventHandler)](system.data.datatableextensions.copytodatatable#system-data-datatableextensions-copytodatatable-1%28system-collections-generic-ienumerable%28%28-0%29%29-system-data-datatable-system-data-loadoption-system-data-fillerroreventhandler%29) | Copies [DataRow](system.data.datarow) objects to the specified [DataTable](system.data.datatable), given an input [IEnumerable&lt;T&gt;](system.collections.generic.ienumerable-1) object where the generic parameter `T` is [DataRow](system.data.datarow). |
| [CopyToDataTable&lt;T&gt;(IEnumerable&lt;T&gt;, DataTable, LoadOption)](system.data.datatableextensions.copytodatatable#system-data-datatableextensions-copytodatatable-1%28system-collections-generic-ienumerable%28%28-0%29%29-system-data-datatable-system-data-loadoption%29) | Copies [DataRow](system.data.datarow) objects to the specified [DataTable](system.data.datatable), given an input [IEnumerable&lt;T&gt;](system.collections.generic.ienumerable-1) object where the generic parameter `T` is [DataRow](system.data.datarow). |
| [CopyToDataTable&lt;T&gt;(IEnumerable&lt;T&gt;)](system.data.datatableextensions.copytodatatable#system-data-datatableextensions-copytodatatable-1%28system-collections-generic-ienumerable%28%28-0%29%29%29) | Returns a [DataTable](system.data.datatable) that contains copies of the [DataRow](system.data.datarow) objects, given an input [IEnumerable&lt;T&gt;](system.collections.generic.ienumerable-1) object where the generic parameter `T` is [DataRow](system.data.datarow). |
| [Count&lt;TSource&gt;(IEnumerable&lt;TSource&gt;, Func&lt;TSource,Boolean&gt;)](system.linq.enumerable.count#system-linq-enumerable-count-1%28system-collections-generic-ienumerable%28%28-0%29%29-system-func%28%28-0-system-boolean%29%29%29) | Returns a number that represents how many elements in the specified sequence satisfy a condition. |
| [Count&lt;TSource&gt;(IEnumerable&lt;TSource&gt;)](system.linq.enumerable.count#system-linq-enumerable-count-1%28system-collections-generic-ienumerable%28%28-0%29%29%29) | Returns the number of elements in a sequence. |
| [CountBy&lt;TSource,TKey&gt;(IEnumerable&lt;TSource&gt;, Func&lt;TSource,TKey&gt;, IEqualityComparer&lt;TKey&gt;)](system.linq.enumerable.countby#system-linq-enumerable-countby-2%28system-collections-generic-ienumerable%28%28-0%29%29-system-func%28%28-0-1%29%29-system-collections-generic-iequalitycomparer%28%28-1%29%29%29) | Returns the count of elements in the source sequence grouped by key. |
| [DefaultIfEmpty&lt;TSource&gt;(IEnumerable&lt;TSource&gt;, TSource)](system.linq.enumerable.defaultifempty#system-linq-enumerable-defaultifempty-1%28system-collections-generic-ienumerable%28%28-0%29%29-0%29) | Returns the elements of the specified sequence or the specified value in a singleton collection if the sequence is empty. |
| [DefaultIfEmpty&lt;TSource&gt;(IEnumerable&lt;TSource&gt;)](system.linq.enumerable.defaultifempty#system-linq-enumerable-defaultifempty-1%28system-collections-generic-ienumerable%28%28-0%29%29%29) | Returns the elements of the specified sequence or the type parameter's default value in a singleton collection if the sequence is empty. |
| [DescendantNodes&lt;T&gt;(IEnumerable&lt;T&gt;)](system.xml.linq.extensions.descendantnodes#system-xml-linq-extensions-descendantnodes-1%28system-collections-generic-ienumerable%28%28-0%29%29%29) | Returns a collection of the descendant nodes of every document and element in the source collection. |
| [Descendants&lt;T&gt;(IEnumerable&lt;T&gt;, XName)](system.xml.linq.extensions.descendants#system-xml-linq-extensions-descendants-1%28system-collections-generic-ienumerable%28%28-0%29%29-system-xml-linq-xname%29) | Returns a filtered collection of elements that contains the descendant elements of every element and document in the source collection. Only elements that have a matching [XName](system.xml.linq.xname) are included in the collection. |
| [Descendants&lt;T&gt;(IEnumerable&lt;T&gt;)](system.xml.linq.extensions.descendants#system-xml-linq-extensions-descendants-1%28system-collections-generic-ienumerable%28%28-0%29%29%29) | Returns a collection of elements that contains the descendant elements of every element and document in the source collection. |
| [Distinct&lt;TSource&gt;(IEnumerable&lt;TSource&gt;, IEqualityComparer&lt;TSource&gt;)](system.linq.enumerable.distinct#system-linq-enumerable-distinct-1%28system-collections-generic-ienumerable%28%28-0%29%29-system-collections-generic-iequalitycomparer%28%28-0%29%29%29) | Returns distinct elements from a sequence by using a specified [IEqualityComparer&lt;T&gt;](system.collections.generic.iequalitycomparer-1) to compare values. |
| [Distinct&lt;TSource&gt;(IEnumerable&lt;TSource&gt;)](system.linq.enumerable.distinct#system-linq-enumerable-distinct-1%28system-collections-generic-ienumerable%28%28-0%29%29%29) | Returns distinct elements from a sequence by using the default equality comparer to compare values. |
| [DistinctBy&lt;TSource,TKey&gt;(IEnumerable&lt;TSource&gt;, Func&lt;TSource,TKey&gt;, IEqualityComparer&lt;TKey&gt;)](system.linq.enumerable.distinctby#system-linq-enumerable-distinctby-2%28system-collections-generic-ienumerable%28%28-0%29%29-system-func%28%28-0-1%29%29-system-collections-generic-iequalitycomparer%28%28-1%29%29%29) | Returns distinct elements from a sequence according to a specified key selector function and using a specified comparer to compare keys. |
| [DistinctBy&lt;TSource,TKey&gt;(IEnumerable&lt;TSource&gt;, Func&lt;TSource,TKey&gt;)](system.linq.enumerable.distinctby#system-linq-enumerable-distinctby-2%28system-collections-generic-ienumerable%28%28-0%29%29-system-func%28%28-0-1%29%29%29) | Returns distinct elements from a sequence according to a specified key selector function. |
| [ElementAt&lt;TSource&gt;(IEnumerable&lt;TSource&gt;, Index)](system.linq.enumerable.elementat#system-linq-enumerable-elementat-1%28system-collections-generic-ienumerable%28%28-0%29%29-system-index%29) | Returns the element at a specified index in a sequence. |
| [ElementAt&lt;TSource&gt;(IEnumerable&lt;TSource&gt;, Int32)](system.linq.enumerable.elementat#system-linq-enumerable-elementat-1%28system-collections-generic-ienumerable%28%28-0%29%29-system-int32%29) | Returns the element at a specified index in a sequence. |
| [ElementAtOrDefault&lt;TSource&gt;(IEnumerable&lt;TSource&gt;, Index)](system.linq.enumerable.elementatordefault#system-linq-enumerable-elementatordefault-1%28system-collections-generic-ienumerable%28%28-0%29%29-system-index%29) | Returns the element at a specified index in a sequence or a default value if the index is out of range. |
| [ElementAtOrDefault&lt;TSource&gt;(IEnumerable&lt;TSource&gt;, Int32)](system.linq.enumerable.elementatordefault#system-linq-enumerable-elementatordefault-1%28system-collections-generic-ienumerable%28%28-0%29%29-system-int32%29) | Returns the element at a specified index in a sequence or a default value if the index is out of range. |
| [Elements&lt;T&gt;(IEnumerable&lt;T&gt;, XName)](system.xml.linq.extensions.elements#system-xml-linq-extensions-elements-1%28system-collections-generic-ienumerable%28%28-0%29%29-system-xml-linq-xname%29) | Returns a filtered collection of the child elements of every element and document in the source collection. Only elements that have a matching [XName](system.xml.linq.xname) are included in the collection. |
| [Elements&lt;T&gt;(IEnumerable&lt;T&gt;)](system.xml.linq.extensions.elements#system-xml-linq-extensions-elements-1%28system-collections-generic-ienumerable%28%28-0%29%29%29) | Returns a collection of the child elements of every element and document in the source collection. |
| [Except&lt;TSource&gt;(IEnumerable&lt;TSource&gt;, IEnumerable&lt;TSource&gt;, IEqualityComparer&lt;TSource&gt;)](system.linq.enumerable.except#system-linq-enumerable-except-1%28system-collections-generic-ienumerable%28%28-0%29%29-system-collections-generic-ienumerable%28%28-0%29%29-system-collections-generic-iequalitycomparer%28%28-0%29%29%29) | Produces the set difference of two sequences by using the specified [IEqualityComparer&lt;T&gt;](system.collections.generic.iequalitycomparer-1) to compare values. |
| [Except&lt;TSource&gt;(IEnumerable&lt;TSource&gt;, IEnumerable&lt;TSource&gt;)](system.linq.enumerable.except#system-linq-enumerable-except-1%28system-collections-generic-ienumerable%28%28-0%29%29-system-collections-generic-ienumerable%28%28-0%29%29%29) | Produces the set difference of two sequences by using the default equality comparer to compare values. |
| [ExceptBy&lt;TSource,TKey&gt;(IEnumerable&lt;TSource&gt;, IEnumerable&lt;TKey&gt;, Func&lt;TSource,TKey&gt;, IEqualityComparer&lt;TKey&gt;)](system.linq.enumerable.exceptby#system-linq-enumerable-exceptby-2%28system-collections-generic-ienumerable%28%28-0%29%29-system-collections-generic-ienumerable%28%28-1%29%29-system-func%28%28-0-1%29%29-system-collections-generic-iequalitycomparer%28%28-1%29%29%29) | Produces the set difference of two sequences according to a specified key selector function. |
| [ExceptBy&lt;TSource,TKey&gt;(IEnumerable&lt;TSource&gt;, IEnumerable&lt;TKey&gt;, Func&lt;TSource,TKey&gt;)](system.linq.enumerable.exceptby#system-linq-enumerable-exceptby-2%28system-collections-generic-ienumerable%28%28-0%29%29-system-collections-generic-ienumerable%28%28-1%29%29-system-func%28%28-0-1%29%29%29) | Produces the set difference of two sequences according to a specified key selector function. |
| [First&lt;TSource&gt;(IEnumerable&lt;TSource&gt;, Func&lt;TSource,Boolean&gt;)](system.linq.enumerable.first#system-linq-enumerable-first-1%28system-collections-generic-ienumerable%28%28-0%29%29-system-func%28%28-0-system-boolean%29%29%29) | Returns the first element in a sequence that satisfies a specified condition. |
| [First&lt;TSource&gt;(IEnumerable&lt;TSource&gt;)](system.linq.enumerable.first#system-linq-enumerable-first-1%28system-collections-generic-ienumerable%28%28-0%29%29%29) | Returns the first element of a sequence. |
| [FirstOrDefault&lt;TSource&gt;(IEnumerable&lt;TSource&gt;, Func&lt;TSource,Boolean&gt;, TSource)](system.linq.enumerable.firstordefault#system-linq-enumerable-firstordefault-1%28system-collections-generic-ienumerable%28%28-0%29%29-system-func%28%28-0-system-boolean%29%29-0%29) | Returns the first element of the sequence that satisfies a condition, or a specified default value if no such element is found. |
| [FirstOrDefault&lt;TSource&gt;(IEnumerable&lt;TSource&gt;, Func&lt;TSource,Boolean&gt;)](system.linq.enumerable.firstordefault#system-linq-enumerable-firstordefault-1%28system-collections-generic-ienumerable%28%28-0%29%29-system-func%28%28-0-system-boolean%29%29%29) | Returns the first element of the sequence that satisfies a condition or a default value if no such element is found. |
| [FirstOrDefault&lt;TSource&gt;(IEnumerable&lt;TSource&gt;, TSource)](system.linq.enumerable.firstordefault#system-linq-enumerable-firstordefault-1%28system-collections-generic-ienumerable%28%28-0%29%29-0%29) | Returns the first element of a sequence, or a specified default value if the sequence contains no elements. |
| [FirstOrDefault&lt;TSource&gt;(IEnumerable&lt;TSource&gt;)](system.linq.enumerable.firstordefault#system-linq-enumerable-firstordefault-1%28system-collections-generic-ienumerable%28%28-0%29%29%29) | Returns the first element of a sequence, or a default value if the sequence contains no elements. |
| [GroupBy&lt;TSource,TKey,TElement,TResult&gt;(IEnumerable&lt;TSource&gt;, Func&lt;TSource, TKey&gt;, Func&lt;TSource,TElement&gt;, Func&lt;TKey,IEnumerable&lt;TElement&gt;, TResult&gt;, IEqualityComparer&lt;TKey&gt;)](system.linq.enumerable.groupby#system-linq-enumerable-groupby-4%28system-collections-generic-ienumerable%28%28-0%29%29-system-func%28%28-0-1%29%29-system-func%28%28-0-2%29%29-system-func%28%28-1-system-collections-generic-ienumerable%28%28-2%29%29-3%29%29-system-collections-generic-iequalitycomparer%28%28-1%29%29%29) | Groups the elements of a sequence according to a specified key selector function and creates a result value from each group and its key. Key values are compared by using a specified comparer, and the elements of each group are projected by using a specified function. |
| [GroupBy&lt;TSource,TKey,TElement,TResult&gt;(IEnumerable&lt;TSource&gt;, Func&lt;TSource,TKey&gt;, Func&lt;TSource,TElement&gt;, Func&lt;TKey,IEnumerable&lt;TElement&gt;,TResult&gt;)](system.linq.enumerable.groupby#system-linq-enumerable-groupby-4%28system-collections-generic-ienumerable%28%28-0%29%29-system-func%28%28-0-1%29%29-system-func%28%28-0-2%29%29-system-func%28%28-1-system-collections-generic-ienumerable%28%28-2%29%29-3%29%29%29) | Groups the elements of a sequence according to a specified key selector function and creates a result value from each group and its key. The elements of each group are projected by using a specified function. |
| [GroupBy&lt;TSource,TKey,TElement&gt;(IEnumerable&lt;TSource&gt;, Func&lt;TSource,TKey&gt;, Func&lt;TSource,TElement&gt;, IEqualityComparer&lt;TKey&gt;)](system.linq.enumerable.groupby#system-linq-enumerable-groupby-3%28system-collections-generic-ienumerable%28%28-0%29%29-system-func%28%28-0-1%29%29-system-func%28%28-0-2%29%29-system-collections-generic-iequalitycomparer%28%28-1%29%29%29) | Groups the elements of a sequence according to a key selector function. The keys are compared by using a comparer and each group's elements are projected by using a specified function. |
| [GroupBy&lt;TSource,TKey,TElement&gt;(IEnumerable&lt;TSource&gt;, Func&lt;TSource,TKey&gt;, Func&lt;TSource,TElement&gt;)](system.linq.enumerable.groupby#system-linq-enumerable-groupby-3%28system-collections-generic-ienumerable%28%28-0%29%29-system-func%28%28-0-1%29%29-system-func%28%28-0-2%29%29%29) | Groups the elements of a sequence according to a specified key selector function and projects the elements for each group by using a specified function. |
| [GroupBy&lt;TSource,TKey,TResult&gt;(IEnumerable&lt;TSource&gt;, Func&lt;TSource,TKey&gt;, Func&lt;TKey,IEnumerable&lt;TSource&gt;,TResult&gt;, IEqualityComparer&lt;TKey&gt;)](system.linq.enumerable.groupby#system-linq-enumerable-groupby-3%28system-collections-generic-ienumerable%28%28-0%29%29-system-func%28%28-0-1%29%29-system-func%28%28-1-system-collections-generic-ienumerable%28%28-0%29%29-2%29%29-system-collections-generic-iequalitycomparer%28%28-1%29%29%29) | Groups the elements of a sequence according to a specified key selector function and creates a result value from each group and its key. The keys are compared by using a specified comparer. |
| [GroupBy&lt;TSource,TKey,TResult&gt;(IEnumerable&lt;TSource&gt;, Func&lt;TSource,TKey&gt;, Func&lt;TKey,IEnumerable&lt;TSource&gt;,TResult&gt;)](system.linq.enumerable.groupby#system-linq-enumerable-groupby-3%28system-collections-generic-ienumerable%28%28-0%29%29-system-func%28%28-0-1%29%29-system-func%28%28-1-system-collections-generic-ienumerable%28%28-0%29%29-2%29%29%29) | Groups the elements of a sequence according to a specified key selector function and creates a result value from each group and its key. |
| [GroupBy&lt;TSource,TKey&gt;(IEnumerable&lt;TSource&gt;, Func&lt;TSource,TKey&gt;, IEqualityComparer&lt;TKey&gt;)](system.linq.enumerable.groupby#system-linq-enumerable-groupby-2%28system-collections-generic-ienumerable%28%28-0%29%29-system-func%28%28-0-1%29%29-system-collections-generic-iequalitycomparer%28%28-1%29%29%29) | Groups the elements of a sequence according to a specified key selector function and compares the keys by using a specified comparer. |
| [GroupBy&lt;TSource,TKey&gt;(IEnumerable&lt;TSource&gt;, Func&lt;TSource,TKey&gt;)](system.linq.enumerable.groupby#system-linq-enumerable-groupby-2%28system-collections-generic-ienumerable%28%28-0%29%29-system-func%28%28-0-1%29%29%29) | Groups the elements of a sequence according to a specified key selector function. |
| [GroupJoin&lt;TOuter,TInner,TKey,TResult&gt;(IEnumerable&lt;TOuter&gt;, IEnumerable&lt;TInner&gt;, Func&lt;TOuter,TKey&gt;, Func&lt;TInner,TKey&gt;, Func&lt;TOuter,IEnumerable&lt;TInner&gt;, TResult&gt;, IEqualityComparer&lt;TKey&gt;)](system.linq.enumerable.groupjoin#system-linq-enumerable-groupjoin-4%28system-collections-generic-ienumerable%28%28-0%29%29-system-collections-generic-ienumerable%28%28-1%29%29-system-func%28%28-0-2%29%29-system-func%28%28-1-2%29%29-system-func%28%28-0-system-collections-generic-ienumerable%28%28-1%29%29-3%29%29-system-collections-generic-iequalitycomparer%28%28-2%29%29%29) | Correlates the elements of two sequences based on key equality and groups the results. A specified [IEqualityComparer&lt;T&gt;](system.collections.generic.iequalitycomparer-1) is used to compare keys. |
| [GroupJoin&lt;TOuter,TInner,TKey,TResult&gt;(IEnumerable&lt;TOuter&gt;, IEnumerable&lt;TInner&gt;, Func&lt;TOuter,TKey&gt;, Func&lt;TInner,TKey&gt;, Func&lt;TOuter,IEnumerable&lt;TInner&gt;, TResult&gt;)](system.linq.enumerable.groupjoin#system-linq-enumerable-groupjoin-4%28system-collections-generic-ienumerable%28%28-0%29%29-system-collections-generic-ienumerable%28%28-1%29%29-system-func%28%28-0-2%29%29-system-func%28%28-1-2%29%29-system-func%28%28-0-system-collections-generic-ienumerable%28%28-1%29%29-3%29%29%29) | Correlates the elements of two sequences based on equality of keys and groups the results. The default equality comparer is used to compare keys. |
| [Index&lt;TSource&gt;(IEnumerable&lt;TSource&gt;)](system.linq.enumerable.index#system-linq-enumerable-index-1%28system-collections-generic-ienumerable%28%28-0%29%29%29) | Returns an enumerable that incorporates the element's index into a tuple. |
| [InDocumentOrder&lt;T&gt;(IEnumerable&lt;T&gt;)](system.xml.linq.extensions.indocumentorder#system-xml-linq-extensions-indocumentorder-1%28system-collections-generic-ienumerable%28%28-0%29%29%29) | Returns a collection of nodes that contains all nodes in the source collection, sorted in document order. |
| [Intersect&lt;TSource&gt;(IEnumerable&lt;TSource&gt;, IEnumerable&lt;TSource&gt;, IEqualityComparer&lt;TSource&gt;)](system.linq.enumerable.intersect#system-linq-enumerable-intersect-1%28system-collections-generic-ienumerable%28%28-0%29%29-system-collections-generic-ienumerable%28%28-0%29%29-system-collections-generic-iequalitycomparer%28%28-0%29%29%29) | Produces the set intersection of two sequences by using the specified [IEqualityComparer&lt;T&gt;](system.collections.generic.iequalitycomparer-1) to compare values. |
| [Intersect&lt;TSource&gt;(IEnumerable&lt;TSource&gt;, IEnumerable&lt;TSource&gt;)](system.linq.enumerable.intersect#system-linq-enumerable-intersect-1%28system-collections-generic-ienumerable%28%28-0%29%29-system-collections-generic-ienumerable%28%28-0%29%29%29) | Produces the set intersection of two sequences by using the default equality comparer to compare values. |
| [IntersectBy&lt;TSource,TKey&gt;(IEnumerable&lt;TSource&gt;, IEnumerable&lt;TKey&gt;, Func&lt;TSource,TKey&gt;, IEqualityComparer&lt;TKey&gt;)](system.linq.enumerable.intersectby#system-linq-enumerable-intersectby-2%28system-collections-generic-ienumerable%28%28-0%29%29-system-collections-generic-ienumerable%28%28-1%29%29-system-func%28%28-0-1%29%29-system-collections-generic-iequalitycomparer%28%28-1%29%29%29) | Produces the set intersection of two sequences according to a specified key selector function. |
| [IntersectBy&lt;TSource,TKey&gt;(IEnumerable&lt;TSource&gt;, IEnumerable&lt;TKey&gt;, Func&lt;TSource,TKey&gt;)](system.linq.enumerable.intersectby#system-linq-enumerable-intersectby-2%28system-collections-generic-ienumerable%28%28-0%29%29-system-collections-generic-ienumerable%28%28-1%29%29-system-func%28%28-0-1%29%29%29) | Produces the set intersection of two sequences according to a specified key selector function. |
| [IsNormalized(String, NormalizationForm)](system.stringnormalizationextensions.isnormalized#system-stringnormalizationextensions-isnormalized%28system-string-system-text-normalizationform%29) | Indicates whether a string is in a specified Unicode normalization form. |
| [IsNormalized(String)](system.stringnormalizationextensions.isnormalized#system-stringnormalizationextensions-isnormalized%28system-string%29) | Indicates whether the specified string is in Unicode normalization form C. |
| [Join&lt;TOuter,TInner,TKey,TResult&gt;(IEnumerable&lt;TOuter&gt;, IEnumerable&lt;TInner&gt;, Func&lt;TOuter,TKey&gt;, Func&lt;TInner,TKey&gt;, Func&lt;TOuter,TInner,TResult&gt;, IEqualityComparer&lt;TKey&gt;)](system.linq.enumerable.join#system-linq-enumerable-join-4%28system-collections-generic-ienumerable%28%28-0%29%29-system-collections-generic-ienumerable%28%28-1%29%29-system-func%28%28-0-2%29%29-system-func%28%28-1-2%29%29-system-func%28%28-0-1-3%29%29-system-collections-generic-iequalitycomparer%28%28-2%29%29%29) | Correlates the elements of two sequences based on matching keys. A specified [IEqualityComparer&lt;T&gt;](system.collections.generic.iequalitycomparer-1) is used to compare keys. |
| [Join&lt;TOuter,TInner,TKey,TResult&gt;(IEnumerable&lt;TOuter&gt;, IEnumerable&lt;TInner&gt;, Func&lt;TOuter,TKey&gt;, Func&lt;TInner,TKey&gt;, Func&lt;TOuter,TInner,TResult&gt;)](system.linq.enumerable.join#system-linq-enumerable-join-4%28system-collections-generic-ienumerable%28%28-0%29%29-system-collections-generic-ienumerable%28%28-1%29%29-system-func%28%28-0-2%29%29-system-func%28%28-1-2%29%29-system-func%28%28-0-1-3%29%29%29) | Correlates the elements of two sequences based on matching keys. The default equality comparer is used to compare keys. |
| [Last&lt;TSource&gt;(IEnumerable&lt;TSource&gt;, Func&lt;TSource,Boolean&gt;)](system.linq.enumerable.last#system-linq-enumerable-last-1%28system-collections-generic-ienumerable%28%28-0%29%29-system-func%28%28-0-system-boolean%29%29%29) | Returns the last element of a sequence that satisfies a specified condition. |
| [Last&lt;TSource&gt;(IEnumerable&lt;TSource&gt;)](system.linq.enumerable.last#system-linq-enumerable-last-1%28system-collections-generic-ienumerable%28%28-0%29%29%29) | Returns the last element of a sequence. |
| [LastOrDefault&lt;TSource&gt;(IEnumerable&lt;TSource&gt;, Func&lt;TSource,Boolean&gt;, TSource)](system.linq.enumerable.lastordefault#system-linq-enumerable-lastordefault-1%28system-collections-generic-ienumerable%28%28-0%29%29-system-func%28%28-0-system-boolean%29%29-0%29) | Returns the last element of a sequence that satisfies a condition, or a specified default value if no such element is found. |
| [LastOrDefault&lt;TSource&gt;(IEnumerable&lt;TSource&gt;, Func&lt;TSource,Boolean&gt;)](system.linq.enumerable.lastordefault#system-linq-enumerable-lastordefault-1%28system-collections-generic-ienumerable%28%28-0%29%29-system-func%28%28-0-system-boolean%29%29%29) | Returns the last element of a sequence that satisfies a condition or a default value if no such element is found. |
| [LastOrDefault&lt;TSource&gt;(IEnumerable&lt;TSource&gt;, TSource)](system.linq.enumerable.lastordefault#system-linq-enumerable-lastordefault-1%28system-collections-generic-ienumerable%28%28-0%29%29-0%29) | Returns the last element of a sequence, or a specified default value if the sequence contains no elements. |
| [LastOrDefault&lt;TSource&gt;(IEnumerable&lt;TSource&gt;)](system.linq.enumerable.lastordefault#system-linq-enumerable-lastordefault-1%28system-collections-generic-ienumerable%28%28-0%29%29%29) | Returns the last element of a sequence, or a default value if the sequence contains no elements. |
| [LeftJoin&lt;TOuter,TInner,TKey,TResult&gt;(IEnumerable&lt;TOuter&gt;, IEnumerable&lt;TInner&gt;, Func&lt;TOuter,TKey&gt;, Func&lt;TInner,TKey&gt;, Func&lt;TOuter,TInner,TResult&gt;, IEqualityComparer&lt;TKey&gt;)](system.linq.enumerable.leftjoin#system-linq-enumerable-leftjoin-4%28system-collections-generic-ienumerable%28%28-0%29%29-system-collections-generic-ienumerable%28%28-1%29%29-system-func%28%28-0-2%29%29-system-func%28%28-1-2%29%29-system-func%28%28-0-1-3%29%29-system-collections-generic-iequalitycomparer%28%28-2%29%29%29) | Correlates the elements of two sequences based on matching keys. A specified [IEqualityComparer&lt;T&gt;](system.collections.generic.iequalitycomparer-1) is used to compare keys. |
| [LeftJoin&lt;TOuter,TInner,TKey,TResult&gt;(IEnumerable&lt;TOuter&gt;, IEnumerable&lt;TInner&gt;, Func&lt;TOuter,TKey&gt;, Func&lt;TInner,TKey&gt;, Func&lt;TOuter,TInner,TResult&gt;)](system.linq.enumerable.leftjoin#system-linq-enumerable-leftjoin-4%28system-collections-generic-ienumerable%28%28-0%29%29-system-collections-generic-ienumerable%28%28-1%29%29-system-func%28%28-0-2%29%29-system-func%28%28-1-2%29%29-system-func%28%28-0-1-3%29%29%29) | Correlates the elements of two sequences based on matching keys. The default equality comparer is used to compare keys. |
| [LongCount&lt;TSource&gt;(IEnumerable&lt;TSource&gt;, Func&lt;TSource,Boolean&gt;)](system.linq.enumerable.longcount#system-linq-enumerable-longcount-1%28system-collections-generic-ienumerable%28%28-0%29%29-system-func%28%28-0-system-boolean%29%29%29) | Returns an [Int64](system.int64) that represents how many elements in a sequence satisfy a condition. |
| [LongCount&lt;TSource&gt;(IEnumerable&lt;TSource&gt;)](system.linq.enumerable.longcount#system-linq-enumerable-longcount-1%28system-collections-generic-ienumerable%28%28-0%29%29%29) | Returns an [Int64](system.int64) that represents the total number of elements in a sequence. |
| [Max&lt;TSource,TResult&gt;(IEnumerable&lt;TSource&gt;, Func&lt;TSource,TResult&gt;)](system.linq.enumerable.max#system-linq-enumerable-max-2%28system-collections-generic-ienumerable%28%28-0%29%29-system-func%28%28-0-1%29%29%29) | Invokes a transform function on each element of a generic sequence and returns the maximum resulting value. |
| [Max&lt;TSource&gt;(IEnumerable&lt;TSource&gt;, Func&lt;TSource,Decimal&gt;)](system.linq.enumerable.max#system-linq-enumerable-max-1%28system-collections-generic-ienumerable%28%28-0%29%29-system-func%28%28-0-system-decimal%29%29%29) | Invokes a transform function on each element of a sequence and returns the maximum [Decimal](system.decimal) value. |
| [Max&lt;TSource&gt;(IEnumerable&lt;TSource&gt;, Func&lt;TSource,Double&gt;)](system.linq.enumerable.max#system-linq-enumerable-max-1%28system-collections-generic-ienumerable%28%28-0%29%29-system-func%28%28-0-system-double%29%29%29) | Invokes a transform function on each element of a sequence and returns the maximum [Double](system.double) value. |
| [Max&lt;TSource&gt;(IEnumerable&lt;TSource&gt;, Func&lt;TSource,Int32&gt;)](system.linq.enumerable.max#system-linq-enumerable-max-1%28system-collections-generic-ienumerable%28%28-0%29%29-system-func%28%28-0-system-int32%29%29%29) | Invokes a transform function on each element of a sequence and returns the maximum [Int32](system.int32) value. |
| [Max&lt;TSource&gt;(IEnumerable&lt;TSource&gt;, Func&lt;TSource,Int64&gt;)](system.linq.enumerable.max#system-linq-enumerable-max-1%28system-collections-generic-ienumerable%28%28-0%29%29-system-func%28%28-0-system-int64%29%29%29) | Invokes a transform function on each element of a sequence and returns the maximum [Int64](system.int64) value. |
| [Max&lt;TSource&gt;(IEnumerable&lt;TSource&gt;, Func&lt;TSource,Nullable&lt;Decimal&gt;&gt;)](system.linq.enumerable.max#system-linq-enumerable-max-1%28system-collections-generic-ienumerable%28%28-0%29%29-system-func%28%28-0-system-nullable%28%28system-decimal%29%29%29%29%29) | Invokes a transform function on each element of a sequence and returns the maximum nullable [Decimal](system.decimal) value. |
| [Max&lt;TSource&gt;(IEnumerable&lt;TSource&gt;, Func&lt;TSource,Nullable&lt;Double&gt;&gt;)](system.linq.enumerable.max#system-linq-enumerable-max-1%28system-collections-generic-ienumerable%28%28-0%29%29-system-func%28%28-0-system-nullable%28%28system-double%29%29%29%29%29) | Invokes a transform function on each element of a sequence and returns the maximum nullable [Double](system.double) value. |
| [Max&lt;TSource&gt;(IEnumerable&lt;TSource&gt;, Func&lt;TSource,Nullable&lt;Int32&gt;&gt;)](system.linq.enumerable.max#system-linq-enumerable-max-1%28system-collections-generic-ienumerable%28%28-0%29%29-system-func%28%28-0-system-nullable%28%28system-int32%29%29%29%29%29) | Invokes a transform function on each element of a sequence and returns the maximum nullable [Int32](system.int32) value. |
| [Max&lt;TSource&gt;(IEnumerable&lt;TSource&gt;, Func&lt;TSource,Nullable&lt;Int64&gt;&gt;)](system.linq.enumerable.max#system-linq-enumerable-max-1%28system-collections-generic-ienumerable%28%28-0%29%29-system-func%28%28-0-system-nullable%28%28system-int64%29%29%29%29%29) | Invokes a transform function on each element of a sequence and returns the maximum nullable [Int64](system.int64) value. |
| [Max&lt;TSource&gt;(IEnumerable&lt;TSource&gt;, Func&lt;TSource,Nullable&lt;Single&gt;&gt;)](system.linq.enumerable.max#system-linq-enumerable-max-1%28system-collections-generic-ienumerable%28%28-0%29%29-system-func%28%28-0-system-nullable%28%28system-single%29%29%29%29%29) | Invokes a transform function on each element of a sequence and returns the maximum nullable [Single](system.single) value. |
| [Max&lt;TSource&gt;(IEnumerable&lt;TSource&gt;, Func&lt;TSource,Single&gt;)](system.linq.enumerable.max#system-linq-enumerable-max-1%28system-collections-generic-ienumerable%28%28-0%29%29-system-func%28%28-0-system-single%29%29%29) | Invokes a transform function on each element of a sequence and returns the maximum [Single](system.single) value. |
| [Max&lt;TSource&gt;(IEnumerable&lt;TSource&gt;, IComparer&lt;TSource&gt;)](system.linq.enumerable.max#system-linq-enumerable-max-1%28system-collections-generic-ienumerable%28%28-0%29%29-system-collections-generic-icomparer%28%28-0%29%29%29) | Returns the maximum value in a generic sequence. |
| [Max&lt;TSource&gt;(IEnumerable&lt;TSource&gt;)](system.linq.enumerable.max#system-linq-enumerable-max-1%28system-collections-generic-ienumerable%28%28-0%29%29%29) | Returns the maximum value in a generic sequence. |
| [MaxBy&lt;TSource,TKey&gt;(IEnumerable&lt;TSource&gt;, Func&lt;TSource,TKey&gt;, IComparer&lt;TKey&gt;)](system.linq.enumerable.maxby#system-linq-enumerable-maxby-2%28system-collections-generic-ienumerable%28%28-0%29%29-system-func%28%28-0-1%29%29-system-collections-generic-icomparer%28%28-1%29%29%29) | Returns the maximum value in a generic sequence according to a specified key selector function and key comparer. |
| [MaxBy&lt;TSource,TKey&gt;(IEnumerable&lt;TSource&gt;, Func&lt;TSource,TKey&gt;)](system.linq.enumerable.maxby#system-linq-enumerable-maxby-2%28system-collections-generic-ienumerable%28%28-0%29%29-system-func%28%28-0-1%29%29%29) | Returns the maximum value in a generic sequence according to a specified key selector function. |
| [Min&lt;TSource,TResult&gt;(IEnumerable&lt;TSource&gt;, Func&lt;TSource,TResult&gt;)](system.linq.enumerable.min#system-linq-enumerable-min-2%28system-collections-generic-ienumerable%28%28-0%29%29-system-func%28%28-0-1%29%29%29) | Invokes a transform function on each element of a generic sequence and returns the minimum resulting value. |
| [Min&lt;TSource&gt;(IEnumerable&lt;TSource&gt;, Func&lt;TSource,Decimal&gt;)](system.linq.enumerable.min#system-linq-enumerable-min-1%28system-collections-generic-ienumerable%28%28-0%29%29-system-func%28%28-0-system-decimal%29%29%29) | Invokes a transform function on each element of a sequence and returns the minimum [Decimal](system.decimal) value. |
| [Min&lt;TSource&gt;(IEnumerable&lt;TSource&gt;, Func&lt;TSource,Double&gt;)](system.linq.enumerable.min#system-linq-enumerable-min-1%28system-collections-generic-ienumerable%28%28-0%29%29-system-func%28%28-0-system-double%29%29%29) | Invokes a transform function on each element of a sequence and returns the minimum [Double](system.double) value. |
| [Min&lt;TSource&gt;(IEnumerable&lt;TSource&gt;, Func&lt;TSource,Int32&gt;)](system.linq.enumerable.min#system-linq-enumerable-min-1%28system-collections-generic-ienumerable%28%28-0%29%29-system-func%28%28-0-system-int32%29%29%29) | Invokes a transform function on each element of a sequence and returns the minimum [Int32](system.int32) value. |
| [Min&lt;TSource&gt;(IEnumerable&lt;TSource&gt;, Func&lt;TSource,Int64&gt;)](system.linq.enumerable.min#system-linq-enumerable-min-1%28system-collections-generic-ienumerable%28%28-0%29%29-system-func%28%28-0-system-int64%29%29%29) | Invokes a transform function on each element of a sequence and returns the minimum [Int64](system.int64) value. |
| [Min&lt;TSource&gt;(IEnumerable&lt;TSource&gt;, Func&lt;TSource,Nullable&lt;Decimal&gt;&gt;)](system.linq.enumerable.min#system-linq-enumerable-min-1%28system-collections-generic-ienumerable%28%28-0%29%29-system-func%28%28-0-system-nullable%28%28system-decimal%29%29%29%29%29) | Invokes a transform function on each element of a sequence and returns the minimum nullable [Decimal](system.decimal) value. |
| [Min&lt;TSource&gt;(IEnumerable&lt;TSource&gt;, Func&lt;TSource,Nullable&lt;Double&gt;&gt;)](system.linq.enumerable.min#system-linq-enumerable-min-1%28system-collections-generic-ienumerable%28%28-0%29%29-system-func%28%28-0-system-nullable%28%28system-double%29%29%29%29%29) | Invokes a transform function on each element of a sequence and returns the minimum nullable [Double](system.double) value. |
| [Min&lt;TSource&gt;(IEnumerable&lt;TSource&gt;, Func&lt;TSource,Nullable&lt;Int32&gt;&gt;)](system.linq.enumerable.min#system-linq-enumerable-min-1%28system-collections-generic-ienumerable%28%28-0%29%29-system-func%28%28-0-system-nullable%28%28system-int32%29%29%29%29%29) | Invokes a transform function on each element of a sequence and returns the minimum nullable [Int32](system.int32) value. |
| [Min&lt;TSource&gt;(IEnumerable&lt;TSource&gt;, Func&lt;TSource,Nullable&lt;Int64&gt;&gt;)](system.linq.enumerable.min#system-linq-enumerable-min-1%28system-collections-generic-ienumerable%28%28-0%29%29-system-func%28%28-0-system-nullable%28%28system-int64%29%29%29%29%29) | Invokes a transform function on each element of a sequence and returns the minimum nullable [Int64](system.int64) value. |
| [Min&lt;TSource&gt;(IEnumerable&lt;TSource&gt;, Func&lt;TSource,Nullable&lt;Single&gt;&gt;)](system.linq.enumerable.min#system-linq-enumerable-min-1%28system-collections-generic-ienumerable%28%28-0%29%29-system-func%28%28-0-system-nullable%28%28system-single%29%29%29%29%29) | Invokes a transform function on each element of a sequence and returns the minimum nullable [Single](system.single) value. |
| [Min&lt;TSource&gt;(IEnumerable&lt;TSource&gt;, Func&lt;TSource,Single&gt;)](system.linq.enumerable.min#system-linq-enumerable-min-1%28system-collections-generic-ienumerable%28%28-0%29%29-system-func%28%28-0-system-single%29%29%29) | Invokes a transform function on each element of a sequence and returns the minimum [Single](system.single) value. |
| [Min&lt;TSource&gt;(IEnumerable&lt;TSource&gt;, IComparer&lt;TSource&gt;)](system.linq.enumerable.min#system-linq-enumerable-min-1%28system-collections-generic-ienumerable%28%28-0%29%29-system-collections-generic-icomparer%28%28-0%29%29%29) | Returns the minimum value in a generic sequence. |
| [Min&lt;TSource&gt;(IEnumerable&lt;TSource&gt;)](system.linq.enumerable.min#system-linq-enumerable-min-1%28system-collections-generic-ienumerable%28%28-0%29%29%29) | Returns the minimum value in a generic sequence. |
| [MinBy&lt;TSource,TKey&gt;(IEnumerable&lt;TSource&gt;, Func&lt;TSource,TKey&gt;, IComparer&lt;TKey&gt;)](system.linq.enumerable.minby#system-linq-enumerable-minby-2%28system-collections-generic-ienumerable%28%28-0%29%29-system-func%28%28-0-1%29%29-system-collections-generic-icomparer%28%28-1%29%29%29) | Returns the minimum value in a generic sequence according to a specified key selector function and key comparer. |
| [MinBy&lt;TSource,TKey&gt;(IEnumerable&lt;TSource&gt;, Func&lt;TSource,TKey&gt;)](system.linq.enumerable.minby#system-linq-enumerable-minby-2%28system-collections-generic-ienumerable%28%28-0%29%29-system-func%28%28-0-1%29%29%29) | Returns the minimum value in a generic sequence according to a specified key selector function. |
| [Nodes&lt;T&gt;(IEnumerable&lt;T&gt;)](system.xml.linq.extensions.nodes#system-xml-linq-extensions-nodes-1%28system-collections-generic-ienumerable%28%28-0%29%29%29) | Returns a collection of the child nodes of every document and element in the source collection. |
| [Normalize(String, NormalizationForm)](system.stringnormalizationextensions.normalize#system-stringnormalizationextensions-normalize%28system-string-system-text-normalizationform%29) | Normalizes a string to the specified Unicode normalization form. |
| [Normalize(String)](system.stringnormalizationextensions.normalize#system-stringnormalizationextensions-normalize%28system-string%29) | Normalizes a string to a Unicode normalization form C. |
| [OfType&lt;TResult&gt;(IEnumerable)](system.linq.enumerable.oftype#system-linq-enumerable-oftype-1%28system-collections-ienumerable%29) | Filters the elements of an [IEnumerable](system.collections.ienumerable) based on a specified type. |
| [Order&lt;T&gt;(IEnumerable&lt;T&gt;, IComparer&lt;T&gt;)](system.linq.enumerable.order#system-linq-enumerable-order-1%28system-collections-generic-ienumerable%28%28-0%29%29-system-collections-generic-icomparer%28%28-0%29%29%29) | Sorts the elements of a sequence in ascending order. |
| [Order&lt;T&gt;(IEnumerable&lt;T&gt;)](system.linq.enumerable.order#system-linq-enumerable-order-1%28system-collections-generic-ienumerable%28%28-0%29%29%29) | Sorts the elements of a sequence in ascending order. |
| [OrderBy&lt;TSource,TKey&gt;(IEnumerable&lt;TSource&gt;, Func&lt;TSource,TKey&gt;, IComparer&lt;TKey&gt;)](system.linq.enumerable.orderby#system-linq-enumerable-orderby-2%28system-collections-generic-ienumerable%28%28-0%29%29-system-func%28%28-0-1%29%29-system-collections-generic-icomparer%28%28-1%29%29%29) | Sorts the elements of a sequence in ascending order by using a specified comparer. |
| [OrderBy&lt;TSource,TKey&gt;(IEnumerable&lt;TSource&gt;, Func&lt;TSource,TKey&gt;)](system.linq.enumerable.orderby#system-linq-enumerable-orderby-2%28system-collections-generic-ienumerable%28%28-0%29%29-system-func%28%28-0-1%29%29%29) | Sorts the elements of a sequence in ascending order according to a key. |
| [OrderByDescending&lt;TSource,TKey&gt;(IEnumerable&lt;TSource&gt;, Func&lt;TSource,TKey&gt;, IComparer&lt;TKey&gt;)](system.linq.enumerable.orderbydescending#system-linq-enumerable-orderbydescending-2%28system-collections-generic-ienumerable%28%28-0%29%29-system-func%28%28-0-1%29%29-system-collections-generic-icomparer%28%28-1%29%29%29) | Sorts the elements of a sequence in descending order by using a specified comparer. |
| [OrderByDescending&lt;TSource,TKey&gt;(IEnumerable&lt;TSource&gt;, Func&lt;TSource,TKey&gt;)](system.linq.enumerable.orderbydescending#system-linq-enumerable-orderbydescending-2%28system-collections-generic-ienumerable%28%28-0%29%29-system-func%28%28-0-1%29%29%29) | Sorts the elements of a sequence in descending order according to a key. |
| [OrderDescending&lt;T&gt;(IEnumerable&lt;T&gt;, IComparer&lt;T&gt;)](system.linq.enumerable.orderdescending#system-linq-enumerable-orderdescending-1%28system-collections-generic-ienumerable%28%28-0%29%29-system-collections-generic-icomparer%28%28-0%29%29%29) | Sorts the elements of a sequence in descending order. |
| [OrderDescending&lt;T&gt;(IEnumerable&lt;T&gt;)](system.linq.enumerable.orderdescending#system-linq-enumerable-orderdescending-1%28system-collections-generic-ienumerable%28%28-0%29%29%29) | Sorts the elements of a sequence in descending order. |
| [Prepend&lt;TSource&gt;(IEnumerable&lt;TSource&gt;, TSource)](system.linq.enumerable.prepend#system-linq-enumerable-prepend-1%28system-collections-generic-ienumerable%28%28-0%29%29-0%29) | Adds a value to the beginning of the sequence. |
| [Remove&lt;T&gt;(IEnumerable&lt;T&gt;)](system.xml.linq.extensions.remove#system-xml-linq-extensions-remove-1%28system-collections-generic-ienumerable%28%28-0%29%29%29) | Removes every node in the source collection from its parent node. |
| [Reverse&lt;TSource&gt;(IEnumerable&lt;TSource&gt;)](system.linq.enumerable.reverse#system-linq-enumerable-reverse-1%28system-collections-generic-ienumerable%28%28-0%29%29%29) | Inverts the order of the elements in a sequence. |
| [RightJoin&lt;TOuter,TInner,TKey,TResult&gt;(IEnumerable&lt;TOuter&gt;, IEnumerable&lt;TInner&gt;, Func&lt;TOuter,TKey&gt;, Func&lt;TInner,TKey&gt;, Func&lt;TOuter,TInner,TResult&gt;, IEqualityComparer&lt;TKey&gt;)](system.linq.enumerable.rightjoin#system-linq-enumerable-rightjoin-4%28system-collections-generic-ienumerable%28%28-0%29%29-system-collections-generic-ienumerable%28%28-1%29%29-system-func%28%28-0-2%29%29-system-func%28%28-1-2%29%29-system-func%28%28-0-1-3%29%29-system-collections-generic-iequalitycomparer%28%28-2%29%29%29) | Correlates the elements of two sequences based on matching keys. A specified [IEqualityComparer&lt;T&gt;](system.collections.generic.iequalitycomparer-1) is used to compare keys. |
| [RightJoin&lt;TOuter,TInner,TKey,TResult&gt;(IEnumerable&lt;TOuter&gt;, IEnumerable&lt;TInner&gt;, Func&lt;TOuter,TKey&gt;, Func&lt;TInner,TKey&gt;, Func&lt;TOuter,TInner,TResult&gt;)](system.linq.enumerable.rightjoin#system-linq-enumerable-rightjoin-4%28system-collections-generic-ienumerable%28%28-0%29%29-system-collections-generic-ienumerable%28%28-1%29%29-system-func%28%28-0-2%29%29-system-func%28%28-1-2%29%29-system-func%28%28-0-1-3%29%29%29) | Correlates the elements of two sequences based on matching keys. The default equality comparer is used to compare keys. |
| [Select&lt;TSource,TResult&gt;(IEnumerable&lt;TSource&gt;, Func&lt;TSource,Int32,TResult&gt;)](system.linq.enumerable.select#system-linq-enumerable-select-2%28system-collections-generic-ienumerable%28%28-0%29%29-system-func%28%28-0-system-int32-1%29%29%29) | Projects each element of a sequence into a new form by incorporating the element's index. |
| [Select&lt;TSource,TResult&gt;(IEnumerable&lt;TSource&gt;, Func&lt;TSource,TResult&gt;)](system.linq.enumerable.select#system-linq-enumerable-select-2%28system-collections-generic-ienumerable%28%28-0%29%29-system-func%28%28-0-1%29%29%29) | Projects each element of a sequence into a new form. |
| [SelectMany&lt;TSource,TCollection,TResult&gt;(IEnumerable&lt;TSource&gt;, Func&lt;TSource,IEnumerable&lt;TCollection&gt;&gt;, Func&lt;TSource,TCollection,TResult&gt;)](system.linq.enumerable.selectmany#system-linq-enumerable-selectmany-3%28system-collections-generic-ienumerable%28%28-0%29%29-system-func%28%28-0-system-collections-generic-ienumerable%28%28-1%29%29%29%29-system-func%28%28-0-1-2%29%29%29) | Projects each element of a sequence to an [IEnumerable&lt;T&gt;](system.collections.generic.ienumerable-1), flattens the resulting sequences into one sequence, and invokes a result selector function on each element therein. |
| [SelectMany&lt;TSource,TCollection,TResult&gt;(IEnumerable&lt;TSource&gt;, Func&lt;TSource,Int32,IEnumerable&lt;TCollection&gt;&gt;, Func&lt;TSource,TCollection,TResult&gt;)](system.linq.enumerable.selectmany#system-linq-enumerable-selectmany-3%28system-collections-generic-ienumerable%28%28-0%29%29-system-func%28%28-0-system-int32-system-collections-generic-ienumerable%28%28-1%29%29%29%29-system-func%28%28-0-1-2%29%29%29) | Projects each element of a sequence to an [IEnumerable&lt;T&gt;](system.collections.generic.ienumerable-1), flattens the resulting sequences into one sequence, and invokes a result selector function on each element therein. The index of each source element is used in the intermediate projected form of that element. |
| [SelectMany&lt;TSource,TResult&gt;(IEnumerable&lt;TSource&gt;, Func&lt;TSource,IEnumerable&lt;TResult&gt;&gt;)](system.linq.enumerable.selectmany#system-linq-enumerable-selectmany-2%28system-collections-generic-ienumerable%28%28-0%29%29-system-func%28%28-0-system-collections-generic-ienumerable%28%28-1%29%29%29%29%29) | Projects each element of a sequence to an [IEnumerable&lt;T&gt;](system.collections.generic.ienumerable-1) and flattens the resulting sequences into one sequence. |
| [SelectMany&lt;TSource,TResult&gt;(IEnumerable&lt;TSource&gt;, Func&lt;TSource,Int32,IEnumerable&lt;TResult&gt;&gt;)](system.linq.enumerable.selectmany#system-linq-enumerable-selectmany-2%28system-collections-generic-ienumerable%28%28-0%29%29-system-func%28%28-0-system-int32-system-collections-generic-ienumerable%28%28-1%29%29%29%29%29) | Projects each element of a sequence to an [IEnumerable&lt;T&gt;](system.collections.generic.ienumerable-1), and flattens the resulting sequences into one sequence. The index of each source element is used in the projected form of that element. |
| [SequenceEqual&lt;TSource&gt;(IEnumerable&lt;TSource&gt;, IEnumerable&lt;TSource&gt;, IEqualityComparer&lt;TSource&gt;)](system.linq.enumerable.sequenceequal#system-linq-enumerable-sequenceequal-1%28system-collections-generic-ienumerable%28%28-0%29%29-system-collections-generic-ienumerable%28%28-0%29%29-system-collections-generic-iequalitycomparer%28%28-0%29%29%29) | Determines whether two sequences are equal by comparing their elements by using a specified [IEqualityComparer&lt;T&gt;](system.collections.generic.iequalitycomparer-1). |
| [SequenceEqual&lt;TSource&gt;(IEnumerable&lt;TSource&gt;, IEnumerable&lt;TSource&gt;)](system.linq.enumerable.sequenceequal#system-linq-enumerable-sequenceequal-1%28system-collections-generic-ienumerable%28%28-0%29%29-system-collections-generic-ienumerable%28%28-0%29%29%29) | Determines whether two sequences are equal by comparing the elements by using the default equality comparer for their type. |
| [Shuffle&lt;TSource&gt;(IEnumerable&lt;TSource&gt;)](system.linq.enumerable.shuffle#system-linq-enumerable-shuffle-1%28system-collections-generic-ienumerable%28%28-0%29%29%29) | Shuffles the order of the elements of a sequence. |
| [Single&lt;TSource&gt;(IEnumerable&lt;TSource&gt;, Func&lt;TSource,Boolean&gt;)](system.linq.enumerable.single#system-linq-enumerable-single-1%28system-collections-generic-ienumerable%28%28-0%29%29-system-func%28%28-0-system-boolean%29%29%29) | Returns the only element of a sequence that satisfies a specified condition, and throws an exception if more than one such element exists. |
| [Single&lt;TSource&gt;(IEnumerable&lt;TSource&gt;)](system.linq.enumerable.single#system-linq-enumerable-single-1%28system-collections-generic-ienumerable%28%28-0%29%29%29) | Returns the only element of a sequence, and throws an exception if there is not exactly one element in the sequence. |
| [SingleOrDefault&lt;TSource&gt;(IEnumerable&lt;TSource&gt;, Func&lt;TSource,Boolean&gt;, TSource)](system.linq.enumerable.singleordefault#system-linq-enumerable-singleordefault-1%28system-collections-generic-ienumerable%28%28-0%29%29-system-func%28%28-0-system-boolean%29%29-0%29) | Returns the only element of a sequence that satisfies a specified condition, or a specified default value if no such element exists; this method throws an exception if more than one element satisfies the condition. |
| [SingleOrDefault&lt;TSource&gt;(IEnumerable&lt;TSource&gt;, Func&lt;TSource,Boolean&gt;)](system.linq.enumerable.singleordefault#system-linq-enumerable-singleordefault-1%28system-collections-generic-ienumerable%28%28-0%29%29-system-func%28%28-0-system-boolean%29%29%29) | Returns the only element of a sequence that satisfies a specified condition or a default value if no such element exists; this method throws an exception if more than one element satisfies the condition. |
| [SingleOrDefault&lt;TSource&gt;(IEnumerable&lt;TSource&gt;, TSource)](system.linq.enumerable.singleordefault#system-linq-enumerable-singleordefault-1%28system-collections-generic-ienumerable%28%28-0%29%29-0%29) | Returns the only element of a sequence, or a specified default value if the sequence is empty; this method throws an exception if there is more than one element in the sequence. |
| [SingleOrDefault&lt;TSource&gt;(IEnumerable&lt;TSource&gt;)](system.linq.enumerable.singleordefault#system-linq-enumerable-singleordefault-1%28system-collections-generic-ienumerable%28%28-0%29%29%29) | Returns the only element of a sequence, or a default value if the sequence is empty; this method throws an exception if there is more than one element in the sequence. |
| [Skip&lt;TSource&gt;(IEnumerable&lt;TSource&gt;, Int32)](system.linq.enumerable.skip#system-linq-enumerable-skip-1%28system-collections-generic-ienumerable%28%28-0%29%29-system-int32%29) | Bypasses a specified number of elements in a sequence and then returns the remaining elements. |
| [SkipLast&lt;TSource&gt;(IEnumerable&lt;TSource&gt;, Int32)](system.linq.enumerable.skiplast#system-linq-enumerable-skiplast-1%28system-collections-generic-ienumerable%28%28-0%29%29-system-int32%29) | Returns a new enumerable collection that contains the elements from `source` with the last `count` elements of the source collection omitted. |
| [SkipWhile&lt;TSource&gt;(IEnumerable&lt;TSource&gt;, Func&lt;TSource,Boolean&gt;)](system.linq.enumerable.skipwhile#system-linq-enumerable-skipwhile-1%28system-collections-generic-ienumerable%28%28-0%29%29-system-func%28%28-0-system-boolean%29%29%29) | Bypasses elements in a sequence as long as a specified condition is true and then returns the remaining elements. |
| [SkipWhile&lt;TSource&gt;(IEnumerable&lt;TSource&gt;, Func&lt;TSource,Int32,Boolean&gt;)](system.linq.enumerable.skipwhile#system-linq-enumerable-skipwhile-1%28system-collections-generic-ienumerable%28%28-0%29%29-system-func%28%28-0-system-int32-system-boolean%29%29%29) | Bypasses elements in a sequence as long as a specified condition is true and then returns the remaining elements. The element's index is used in the logic of the predicate function. |
| [Sum&lt;TSource&gt;(IEnumerable&lt;TSource&gt;, Func&lt;TSource,Decimal&gt;)](system.linq.enumerable.sum#system-linq-enumerable-sum-1%28system-collections-generic-ienumerable%28%28-0%29%29-system-func%28%28-0-system-decimal%29%29%29) | Computes the sum of the sequence of [Decimal](system.decimal) values that are obtained by invoking a transform function on each element of the input sequence. |
| [Sum&lt;TSource&gt;(IEnumerable&lt;TSource&gt;, Func&lt;TSource,Double&gt;)](system.linq.enumerable.sum#system-linq-enumerable-sum-1%28system-collections-generic-ienumerable%28%28-0%29%29-system-func%28%28-0-system-double%29%29%29) | Computes the sum of the sequence of [Double](system.double) values that are obtained by invoking a transform function on each element of the input sequence. |
| [Sum&lt;TSource&gt;(IEnumerable&lt;TSource&gt;, Func&lt;TSource,Int32&gt;)](system.linq.enumerable.sum#system-linq-enumerable-sum-1%28system-collections-generic-ienumerable%28%28-0%29%29-system-func%28%28-0-system-int32%29%29%29) | Computes the sum of the sequence of [Int32](system.int32) values that are obtained by invoking a transform function on each element of the input sequence. |
| [Sum&lt;TSource&gt;(IEnumerable&lt;TSource&gt;, Func&lt;TSource,Int64&gt;)](system.linq.enumerable.sum#system-linq-enumerable-sum-1%28system-collections-generic-ienumerable%28%28-0%29%29-system-func%28%28-0-system-int64%29%29%29) | Computes the sum of the sequence of [Int64](system.int64) values that are obtained by invoking a transform function on each element of the input sequence. |
| [Sum&lt;TSource&gt;(IEnumerable&lt;TSource&gt;, Func&lt;TSource,Nullable&lt;Decimal&gt;&gt;)](system.linq.enumerable.sum#system-linq-enumerable-sum-1%28system-collections-generic-ienumerable%28%28-0%29%29-system-func%28%28-0-system-nullable%28%28system-decimal%29%29%29%29%29) | Computes the sum of the sequence of nullable [Decimal](system.decimal) values that are obtained by invoking a transform function on each element of the input sequence. |
| [Sum&lt;TSource&gt;(IEnumerable&lt;TSource&gt;, Func&lt;TSource,Nullable&lt;Double&gt;&gt;)](system.linq.enumerable.sum#system-linq-enumerable-sum-1%28system-collections-generic-ienumerable%28%28-0%29%29-system-func%28%28-0-system-nullable%28%28system-double%29%29%29%29%29) | Computes the sum of the sequence of nullable [Double](system.double) values that are obtained by invoking a transform function on each element of the input sequence. |
| [Sum&lt;TSource&gt;(IEnumerable&lt;TSource&gt;, Func&lt;TSource,Nullable&lt;Int32&gt;&gt;)](system.linq.enumerable.sum#system-linq-enumerable-sum-1%28system-collections-generic-ienumerable%28%28-0%29%29-system-func%28%28-0-system-nullable%28%28system-int32%29%29%29%29%29) | Computes the sum of the sequence of nullable [Int32](system.int32) values that are obtained by invoking a transform function on each element of the input sequence. |
| [Sum&lt;TSource&gt;(IEnumerable&lt;TSource&gt;, Func&lt;TSource,Nullable&lt;Int64&gt;&gt;)](system.linq.enumerable.sum#system-linq-enumerable-sum-1%28system-collections-generic-ienumerable%28%28-0%29%29-system-func%28%28-0-system-nullable%28%28system-int64%29%29%29%29%29) | Computes the sum of the sequence of nullable [Int64](system.int64) values that are obtained by invoking a transform function on each element of the input sequence. |
| [Sum&lt;TSource&gt;(IEnumerable&lt;TSource&gt;, Func&lt;TSource,Nullable&lt;Single&gt;&gt;)](system.linq.enumerable.sum#system-linq-enumerable-sum-1%28system-collections-generic-ienumerable%28%28-0%29%29-system-func%28%28-0-system-nullable%28%28system-single%29%29%29%29%29) | Computes the sum of the sequence of nullable [Single](system.single) values that are obtained by invoking a transform function on each element of the input sequence. |
| [Sum&lt;TSource&gt;(IEnumerable&lt;TSource&gt;, Func&lt;TSource,Single&gt;)](system.linq.enumerable.sum#system-linq-enumerable-sum-1%28system-collections-generic-ienumerable%28%28-0%29%29-system-func%28%28-0-system-single%29%29%29) | Computes the sum of the sequence of [Single](system.single) values that are obtained by invoking a transform function on each element of the input sequence. |
| [Take&lt;TSource&gt;(IEnumerable&lt;TSource&gt;, Int32)](system.linq.enumerable.take#system-linq-enumerable-take-1%28system-collections-generic-ienumerable%28%28-0%29%29-system-int32%29) | Returns a specified number of contiguous elements from the start of a sequence. |
| [Take&lt;TSource&gt;(IEnumerable&lt;TSource&gt;, Range)](system.linq.enumerable.take#system-linq-enumerable-take-1%28system-collections-generic-ienumerable%28%28-0%29%29-system-range%29) | Returns a specified range of contiguous elements from a sequence. |
| [TakeLast&lt;TSource&gt;(IEnumerable&lt;TSource&gt;, Int32)](system.linq.enumerable.takelast#system-linq-enumerable-takelast-1%28system-collections-generic-ienumerable%28%28-0%29%29-system-int32%29) | Returns a new enumerable collection that contains the last `count` elements from `source`. |
| [TakeWhile&lt;TSource&gt;(IEnumerable&lt;TSource&gt;, Func&lt;TSource,Boolean&gt;)](system.linq.enumerable.takewhile#system-linq-enumerable-takewhile-1%28system-collections-generic-ienumerable%28%28-0%29%29-system-func%28%28-0-system-boolean%29%29%29) | Returns elements from a sequence as long as a specified condition is true. |
| [TakeWhile&lt;TSource&gt;(IEnumerable&lt;TSource&gt;, Func&lt;TSource,Int32,Boolean&gt;)](system.linq.enumerable.takewhile#system-linq-enumerable-takewhile-1%28system-collections-generic-ienumerable%28%28-0%29%29-system-func%28%28-0-system-int32-system-boolean%29%29%29) | Returns elements from a sequence as long as a specified condition is true. The element's index is used in the logic of the predicate function. |
| [ToArray&lt;TSource&gt;(IEnumerable&lt;TSource&gt;)](system.linq.enumerable.toarray#system-linq-enumerable-toarray-1%28system-collections-generic-ienumerable%28%28-0%29%29%29) | Creates an array from a [IEnumerable&lt;T&gt;](system.collections.generic.ienumerable-1). |
| [ToAsyncEnumerable&lt;TSource&gt;(IEnumerable&lt;TSource&gt;)](system.linq.asyncenumerable.toasyncenumerable#system-linq-asyncenumerable-toasyncenumerable-1%28system-collections-generic-ienumerable%28%28-0%29%29%29) | Creates a new [IAsyncEnumerable&lt;T&gt;](system.collections.generic.iasyncenumerable-1) that iterates through `source`. |
| [ToDictionary&lt;TSource,TKey,TElement&gt;(IEnumerable&lt;TSource&gt;, Func&lt;TSource,TKey&gt;, Func&lt;TSource,TElement&gt;, IEqualityComparer&lt;TKey&gt;)](system.linq.enumerable.todictionary#system-linq-enumerable-todictionary-3%28system-collections-generic-ienumerable%28%28-0%29%29-system-func%28%28-0-1%29%29-system-func%28%28-0-2%29%29-system-collections-generic-iequalitycomparer%28%28-1%29%29%29) | Creates a [Dictionary&lt;TKey,TValue&gt;](system.collections.generic.dictionary-2) from an [IEnumerable&lt;T&gt;](system.collections.generic.ienumerable-1) according to a specified key selector function, a comparer, and an element selector function. |
| [ToDictionary&lt;TSource,TKey,TElement&gt;(IEnumerable&lt;TSource&gt;, Func&lt;TSource,TKey&gt;, Func&lt;TSource,TElement&gt;)](system.linq.enumerable.todictionary#system-linq-enumerable-todictionary-3%28system-collections-generic-ienumerable%28%28-0%29%29-system-func%28%28-0-1%29%29-system-func%28%28-0-2%29%29%29) | Creates a [Dictionary&lt;TKey,TValue&gt;](system.collections.generic.dictionary-2) from an [IEnumerable&lt;T&gt;](system.collections.generic.ienumerable-1) according to specified key selector and element selector functions. |
| [ToDictionary&lt;TSource,TKey&gt;(IEnumerable&lt;TSource&gt;, Func&lt;TSource,TKey&gt;, IEqualityComparer&lt;TKey&gt;)](system.linq.enumerable.todictionary#system-linq-enumerable-todictionary-2%28system-collections-generic-ienumerable%28%28-0%29%29-system-func%28%28-0-1%29%29-system-collections-generic-iequalitycomparer%28%28-1%29%29%29) | Creates a [Dictionary&lt;TKey,TValue&gt;](system.collections.generic.dictionary-2) from an [IEnumerable&lt;T&gt;](system.collections.generic.ienumerable-1) according to a specified key selector function and key comparer. |
| [ToDictionary&lt;TSource,TKey&gt;(IEnumerable&lt;TSource&gt;, Func&lt;TSource,TKey&gt;)](system.linq.enumerable.todictionary#system-linq-enumerable-todictionary-2%28system-collections-generic-ienumerable%28%28-0%29%29-system-func%28%28-0-1%29%29%29) | Creates a [Dictionary&lt;TKey,TValue&gt;](system.collections.generic.dictionary-2) from an [IEnumerable&lt;T&gt;](system.collections.generic.ienumerable-1) according to a specified key selector function. |
| [ToFrozenDictionary&lt;TSource,TKey,TElement&gt;(IEnumerable&lt;TSource&gt;, Func&lt;TSource,TKey&gt;, Func&lt;TSource,TElement&gt;, IEqualityComparer&lt;TKey&gt;)](system.collections.frozen.frozendictionary.tofrozendictionary#system-collections-frozen-frozendictionary-tofrozendictionary-3%28system-collections-generic-ienumerable%28%28-0%29%29-system-func%28%28-0-1%29%29-system-func%28%28-0-2%29%29-system-collections-generic-iequalitycomparer%28%28-1%29%29%29) | Creates a [FrozenDictionary&lt;TKey,TValue&gt;](system.collections.frozen.frozendictionary-2) from an [IEnumerable&lt;T&gt;](system.collections.generic.ienumerable-1) according to specified key selector and element selector functions. |
| [ToFrozenDictionary&lt;TSource,TKey&gt;(IEnumerable&lt;TSource&gt;, Func&lt;TSource,TKey&gt;, IEqualityComparer&lt;TKey&gt;)](system.collections.frozen.frozendictionary.tofrozendictionary#system-collections-frozen-frozendictionary-tofrozendictionary-2%28system-collections-generic-ienumerable%28%28-0%29%29-system-func%28%28-0-1%29%29-system-collections-generic-iequalitycomparer%28%28-1%29%29%29) | Creates a [FrozenDictionary&lt;TKey,TValue&gt;](system.collections.frozen.frozendictionary-2) from an [IEnumerable&lt;T&gt;](system.collections.generic.ienumerable-1) according to specified key selector function. |
| [ToFrozenSet&lt;T&gt;(IEnumerable&lt;T&gt;, IEqualityComparer&lt;T&gt;)](system.collections.frozen.frozenset.tofrozenset#system-collections-frozen-frozenset-tofrozenset-1%28system-collections-generic-ienumerable%28%28-0%29%29-system-collections-generic-iequalitycomparer%28%28-0%29%29%29) | Creates a [FrozenSet&lt;T&gt;](system.collections.frozen.frozenset-1) with the specified values. |
| [ToHashSet&lt;TSource&gt;(IEnumerable&lt;TSource&gt;, IEqualityComparer&lt;TSource&gt;)](system.linq.enumerable.tohashset#system-linq-enumerable-tohashset-1%28system-collections-generic-ienumerable%28%28-0%29%29-system-collections-generic-iequalitycomparer%28%28-0%29%29%29) | Creates a [HashSet&lt;T&gt;](system.collections.generic.hashset-1) from an [IEnumerable&lt;T&gt;](system.collections.generic.ienumerable-1) using the `comparer` to compare keys. |
| [ToHashSet&lt;TSource&gt;(IEnumerable&lt;TSource&gt;)](system.linq.enumerable.tohashset#system-linq-enumerable-tohashset-1%28system-collections-generic-ienumerable%28%28-0%29%29%29) | Creates a [HashSet&lt;T&gt;](system.collections.generic.hashset-1) from an [IEnumerable&lt;T&gt;](system.collections.generic.ienumerable-1). |
| [ToImmutableArray&lt;TSource&gt;(IEnumerable&lt;TSource&gt;)](system.collections.immutable.immutablearray.toimmutablearray#system-collections-immutable-immutablearray-toimmutablearray-1%28system-collections-generic-ienumerable%28%28-0%29%29%29) | Creates an immutable array from the specified collection. |
| [ToImmutableDictionary&lt;TSource,TKey,TValue&gt;(IEnumerable&lt;TSource&gt;, Func&lt;TSource,TKey&gt;, Func&lt;TSource,TValue&gt;, IEqualityComparer&lt;TKey&gt;, IEqualityComparer&lt;TValue&gt;)](system.collections.immutable.immutabledictionary.toimmutabledictionary#system-collections-immutable-immutabledictionary-toimmutabledictionary-3%28system-collections-generic-ienumerable%28%28-0%29%29-system-func%28%28-0-1%29%29-system-func%28%28-0-2%29%29-system-collections-generic-iequalitycomparer%28%28-1%29%29-system-collections-generic-iequalitycomparer%28%28-2%29%29%29) | Enumerates and transforms a sequence, and produces an immutable dictionary of its contents by using the specified key and value comparers. |
| [ToImmutableDictionary&lt;TSource,TKey,TValue&gt;(IEnumerable&lt;TSource&gt;, Func&lt;TSource,TKey&gt;, Func&lt;TSource,TValue&gt;, IEqualityComparer&lt;TKey&gt;)](system.collections.immutable.immutabledictionary.toimmutabledictionary#system-collections-immutable-immutabledictionary-toimmutabledictionary-3%28system-collections-generic-ienumerable%28%28-0%29%29-system-func%28%28-0-1%29%29-system-func%28%28-0-2%29%29-system-collections-generic-iequalitycomparer%28%28-1%29%29%29) | Enumerates and transforms a sequence, and produces an immutable dictionary of its contents by using the specified key comparer. |
| [ToImmutableDictionary&lt;TSource,TKey,TValue&gt;(IEnumerable&lt;TSource&gt;, Func&lt;TSource,TKey&gt;, Func&lt;TSource,TValue&gt;)](system.collections.immutable.immutabledictionary.toimmutabledictionary#system-collections-immutable-immutabledictionary-toimmutabledictionary-3%28system-collections-generic-ienumerable%28%28-0%29%29-system-func%28%28-0-1%29%29-system-func%28%28-0-2%29%29%29) | Enumerates and transforms a sequence, and produces an immutable dictionary of its contents. |
| [ToImmutableDictionary&lt;TSource,TKey&gt;(IEnumerable&lt;TSource&gt;, Func&lt;TSource,TKey&gt;, IEqualityComparer&lt;TKey&gt;)](system.collections.immutable.immutabledictionary.toimmutabledictionary#system-collections-immutable-immutabledictionary-toimmutabledictionary-2%28system-collections-generic-ienumerable%28%28-0%29%29-system-func%28%28-0-1%29%29-system-collections-generic-iequalitycomparer%28%28-1%29%29%29) | Constructs an immutable dictionary based on some transformation of a sequence. |
| [ToImmutableDictionary&lt;TSource,TKey&gt;(IEnumerable&lt;TSource&gt;, Func&lt;TSource,TKey&gt;)](system.collections.immutable.immutabledictionary.toimmutabledictionary#system-collections-immutable-immutabledictionary-toimmutabledictionary-2%28system-collections-generic-ienumerable%28%28-0%29%29-system-func%28%28-0-1%29%29%29) | Constructs an immutable dictionary from an existing collection of elements, applying a transformation function to the source keys. |
| [ToImmutableHashSet&lt;TSource&gt;(IEnumerable&lt;TSource&gt;, IEqualityComparer&lt;TSource&gt;)](system.collections.immutable.immutablehashset.toimmutablehashset#system-collections-immutable-immutablehashset-toimmutablehashset-1%28system-collections-generic-ienumerable%28%28-0%29%29-system-collections-generic-iequalitycomparer%28%28-0%29%29%29) | Enumerates a sequence, produces an immutable hash set of its contents, and uses the specified equality comparer for the set type. |
| [ToImmutableHashSet&lt;TSource&gt;(IEnumerable&lt;TSource&gt;)](system.collections.immutable.immutablehashset.toimmutablehashset#system-collections-immutable-immutablehashset-toimmutablehashset-1%28system-collections-generic-ienumerable%28%28-0%29%29%29) | Enumerates a sequence and produces an immutable hash set of its contents. |
| [ToImmutableList&lt;TSource&gt;(IEnumerable&lt;TSource&gt;)](system.collections.immutable.immutablelist.toimmutablelist#system-collections-immutable-immutablelist-toimmutablelist-1%28system-collections-generic-ienumerable%28%28-0%29%29%29) | Enumerates a sequence and produces an immutable list of its contents. |
| [ToImmutableSortedDictionary&lt;TSource,TKey,TValue&gt;(IEnumerable&lt;TSource&gt;, Func&lt;TSource,TKey&gt;, Func&lt;TSource,TValue&gt;, IComparer&lt;TKey&gt;, IEqualityComparer&lt;TValue&gt;)](system.collections.immutable.immutablesorteddictionary.toimmutablesorteddictionary#system-collections-immutable-immutablesorteddictionary-toimmutablesorteddictionary-3%28system-collections-generic-ienumerable%28%28-0%29%29-system-func%28%28-0-1%29%29-system-func%28%28-0-2%29%29-system-collections-generic-icomparer%28%28-1%29%29-system-collections-generic-iequalitycomparer%28%28-2%29%29%29) | Enumerates and transforms a sequence, and produces an immutable sorted dictionary of its contents by using the specified key and value comparers. |
| [ToImmutableSortedDictionary&lt;TSource,TKey,TValue&gt;(IEnumerable&lt;TSource&gt;, Func&lt;TSource,TKey&gt;, Func&lt;TSource,TValue&gt;, IComparer&lt;TKey&gt;)](system.collections.immutable.immutablesorteddictionary.toimmutablesorteddictionary#system-collections-immutable-immutablesorteddictionary-toimmutablesorteddictionary-3%28system-collections-generic-ienumerable%28%28-0%29%29-system-func%28%28-0-1%29%29-system-func%28%28-0-2%29%29-system-collections-generic-icomparer%28%28-1%29%29%29) | Enumerates and transforms a sequence, and produces an immutable sorted dictionary of its contents by using the specified key comparer. |
| [ToImmutableSortedDictionary&lt;TSource,TKey,TValue&gt;(IEnumerable&lt;TSource&gt;, Func&lt;TSource,TKey&gt;, Func&lt;TSource,TValue&gt;)](system.collections.immutable.immutablesorteddictionary.toimmutablesorteddictionary#system-collections-immutable-immutablesorteddictionary-toimmutablesorteddictionary-3%28system-collections-generic-ienumerable%28%28-0%29%29-system-func%28%28-0-1%29%29-system-func%28%28-0-2%29%29%29) | Enumerates and transforms a sequence, and produces an immutable sorted dictionary of its contents. |
| [ToImmutableSortedSet&lt;TSource&gt;(IEnumerable&lt;TSource&gt;, IComparer&lt;TSource&gt;)](system.collections.immutable.immutablesortedset.toimmutablesortedset#system-collections-immutable-immutablesortedset-toimmutablesortedset-1%28system-collections-generic-ienumerable%28%28-0%29%29-system-collections-generic-icomparer%28%28-0%29%29%29) | Enumerates a sequence, produces an immutable sorted set of its contents, and uses the specified comparer. |
| [ToImmutableSortedSet&lt;TSource&gt;(IEnumerable&lt;TSource&gt;)](system.collections.immutable.immutablesortedset.toimmutablesortedset#system-collections-immutable-immutablesortedset-toimmutablesortedset-1%28system-collections-generic-ienumerable%28%28-0%29%29%29) | Enumerates a sequence and produces an immutable sorted set of its contents. |
| [ToList&lt;TSource&gt;(IEnumerable&lt;TSource&gt;)](system.linq.enumerable.tolist#system-linq-enumerable-tolist-1%28system-collections-generic-ienumerable%28%28-0%29%29%29) | Creates a [List&lt;T&gt;](system.collections.generic.list-1) from an [IEnumerable&lt;T&gt;](system.collections.generic.ienumerable-1). |
| [ToLookup&lt;TSource,TKey,TElement&gt;(IEnumerable&lt;TSource&gt;, Func&lt;TSource,TKey&gt;, Func&lt;TSource,TElement&gt;, IEqualityComparer&lt;TKey&gt;)](system.linq.enumerable.tolookup#system-linq-enumerable-tolookup-3%28system-collections-generic-ienumerable%28%28-0%29%29-system-func%28%28-0-1%29%29-system-func%28%28-0-2%29%29-system-collections-generic-iequalitycomparer%28%28-1%29%29%29) | Creates a [Lookup&lt;TKey,TElement&gt;](system.linq.lookup-2) from an [IEnumerable&lt;T&gt;](system.collections.generic.ienumerable-1) according to a specified key selector function, a comparer and an element selector function. |
| [ToLookup&lt;TSource,TKey,TElement&gt;(IEnumerable&lt;TSource&gt;, Func&lt;TSource,TKey&gt;, Func&lt;TSource,TElement&gt;)](system.linq.enumerable.tolookup#system-linq-enumerable-tolookup-3%28system-collections-generic-ienumerable%28%28-0%29%29-system-func%28%28-0-1%29%29-system-func%28%28-0-2%29%29%29) | Creates a [Lookup&lt;TKey,TElement&gt;](system.linq.lookup-2) from an [IEnumerable&lt;T&gt;](system.collections.generic.ienumerable-1) according to specified key selector and element selector functions. |
| [ToLookup&lt;TSource,TKey&gt;(IEnumerable&lt;TSource&gt;, Func&lt;TSource,TKey&gt;, IEqualityComparer&lt;TKey&gt;)](system.linq.enumerable.tolookup#system-linq-enumerable-tolookup-2%28system-collections-generic-ienumerable%28%28-0%29%29-system-func%28%28-0-1%29%29-system-collections-generic-iequalitycomparer%28%28-1%29%29%29) | Creates a [Lookup&lt;TKey,TElement&gt;](system.linq.lookup-2) from an [IEnumerable&lt;T&gt;](system.collections.generic.ienumerable-1) according to a specified key selector function and key comparer. |
| [ToLookup&lt;TSource,TKey&gt;(IEnumerable&lt;TSource&gt;, Func&lt;TSource,TKey&gt;)](system.linq.enumerable.tolookup#system-linq-enumerable-tolookup-2%28system-collections-generic-ienumerable%28%28-0%29%29-system-func%28%28-0-1%29%29%29) | Creates a [Lookup&lt;TKey,TElement&gt;](system.linq.lookup-2) from an [IEnumerable&lt;T&gt;](system.collections.generic.ienumerable-1) according to a specified key selector function. |
| [TryGetNonEnumeratedCount&lt;TSource&gt;(IEnumerable&lt;TSource&gt;, Int32)](system.linq.enumerable.trygetnonenumeratedcount#system-linq-enumerable-trygetnonenumeratedcount-1%28system-collections-generic-ienumerable%28%28-0%29%29-system-int32@%29) | Attempts to determine the number of elements in a sequence without forcing an enumeration. |
| [Union&lt;TSource&gt;(IEnumerable&lt;TSource&gt;, IEnumerable&lt;TSource&gt;, IEqualityComparer&lt;TSource&gt;)](system.linq.enumerable.union#system-linq-enumerable-union-1%28system-collections-generic-ienumerable%28%28-0%29%29-system-collections-generic-ienumerable%28%28-0%29%29-system-collections-generic-iequalitycomparer%28%28-0%29%29%29) | Produces the set union of two sequences by using a specified [IEqualityComparer&lt;T&gt;](system.collections.generic.iequalitycomparer-1). |
| [Union&lt;TSource&gt;(IEnumerable&lt;TSource&gt;, IEnumerable&lt;TSource&gt;)](system.linq.enumerable.union#system-linq-enumerable-union-1%28system-collections-generic-ienumerable%28%28-0%29%29-system-collections-generic-ienumerable%28%28-0%29%29%29) | Produces the set union of two sequences by using the default equality comparer. |
| [UnionBy&lt;TSource,TKey&gt;(IEnumerable&lt;TSource&gt;, IEnumerable&lt;TSource&gt;, Func&lt;TSource,TKey&gt;, IEqualityComparer&lt;TKey&gt;)](system.linq.enumerable.unionby#system-linq-enumerable-unionby-2%28system-collections-generic-ienumerable%28%28-0%29%29-system-collections-generic-ienumerable%28%28-0%29%29-system-func%28%28-0-1%29%29-system-collections-generic-iequalitycomparer%28%28-1%29%29%29) | Produces the set union of two sequences according to a specified key selector function. |
| [UnionBy&lt;TSource,TKey&gt;(IEnumerable&lt;TSource&gt;, IEnumerable&lt;TSource&gt;, Func&lt;TSource,TKey&gt;)](system.linq.enumerable.unionby#system-linq-enumerable-unionby-2%28system-collections-generic-ienumerable%28%28-0%29%29-system-collections-generic-ienumerable%28%28-0%29%29-system-func%28%28-0-1%29%29%29) | Produces the set union of two sequences according to a specified key selector function. |
| [Where&lt;TSource&gt;(IEnumerable&lt;TSource&gt;, Func&lt;TSource,Boolean&gt;)](system.linq.enumerable.where#system-linq-enumerable-where-1%28system-collections-generic-ienumerable%28%28-0%29%29-system-func%28%28-0-system-boolean%29%29%29) | Filters a sequence of values based on a predicate. |
| [Where&lt;TSource&gt;(IEnumerable&lt;TSource&gt;, Func&lt;TSource,Int32,Boolean&gt;)](system.linq.enumerable.where#system-linq-enumerable-where-1%28system-collections-generic-ienumerable%28%28-0%29%29-system-func%28%28-0-system-int32-system-boolean%29%29%29) | Filters a sequence of values based on a predicate. Each element's index is used in the logic of the predicate function. |
| [Zip&lt;TFirst,TSecond,TResult&gt;(IEnumerable&lt;TFirst&gt;, IEnumerable&lt;TSecond&gt;, Func&lt;TFirst,TSecond,TResult&gt;)](system.linq.enumerable.zip#system-linq-enumerable-zip-3%28system-collections-generic-ienumerable%28%28-0%29%29-system-collections-generic-ienumerable%28%28-1%29%29-system-func%28%28-0-1-2%29%29%29) | Applies a specified function to the corresponding elements of two sequences, producing a sequence of the results. |
| [Zip&lt;TFirst,TSecond,TThird&gt;(IEnumerable&lt;TFirst&gt;, IEnumerable&lt;TSecond&gt;, IEnumerable&lt;TThird&gt;)](system.linq.enumerable.zip#system-linq-enumerable-zip-3%28system-collections-generic-ienumerable%28%28-0%29%29-system-collections-generic-ienumerable%28%28-1%29%29-system-collections-generic-ienumerable%28%28-2%29%29%29) | Produces a sequence of tuples with elements from the three specified sequences. |
| [Zip&lt;TFirst,TSecond&gt;(IEnumerable&lt;TFirst&gt;, IEnumerable&lt;TSecond&gt;)](system.linq.enumerable.zip#system-linq-enumerable-zip-2%28system-collections-generic-ienumerable%28%28-0%29%29-system-collections-generic-ienumerable%28%28-1%29%29%29) | Produces a sequence of tuples with elements from the two specified sequences. |

## Applies to

## Thread Safety

This type is thread safe.