---
layout: Reference
monikers:
- dotnet-uwp-10.0
- netstandard-1.0
- netcore-1.0
- netcore-1.1
- netstandard-1.1
- netstandard-1.2
- netstandard-1.3
- netstandard-1.4
- netstandard-1.5
- netstandard-1.6
- netcore-2.0
- netstandard-2.0
- netcore-2.1
- netstandard-2.1
- netcore-2.2
- netcore-3.0
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
title: Action Delegate (System) | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/dotnet/api/system.action?view=net-10.0
uid: System.Action
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
- System.Action
- System.Action..ctor
- System.Action.Invoke
- System.Action.BeginInvoke
- System.Action.EndInvoke
api_location:
- System.Runtime.dll
- mscorlib.dll
- netstandard.dll
- System.Core.dll
topic_type:
- apiref
api_type:
- Assembly
locale: en-us
document_id: 6679a3f4-7df5-1aba-535b-c72cb9131370
document_version_independent_id: 90f2da7c-aaf1-13f6-db60-920ab1ef56e1
updated_at: 2026-04-25T11:16:00.0000000Z
original_content_git_url: https://github.com/dotnet/dotnet-api-docs/blob/live/xml/System/Action.xml
gitcommit: https://github.com/dotnet/dotnet-api-docs/blob/3766956447773510eb2b10a8f9d2b491b903db9e/xml/System/Action.xml
git_commit_id: 3766956447773510eb2b10a8f9d2b491b903db9e
default_moniker: net-10.0
site_name: Docs
depot_name: VS.dotnet-api-docs
page_type: dotnet
page_kind: delegate
ms.assetid: System.Action
description: 'Encapsulates a method that has no parameters and does not return a value. '
toc_rel: _splitted/system/toc.json
search.mshattr.devlang: csharp vb fsharp cpp
asset_id: api/system.action
moniker_range_name: d5b19da92a0fce32317f09cbf57ad587
monikers:
- dotnet-uwp-10.0
- netstandard-1.0
- netcore-1.0
- netcore-1.1
- netstandard-1.1
- netstandard-1.2
- netstandard-1.3
- netstandard-1.4
- netstandard-1.5
- netstandard-1.6
- netcore-2.0
- netstandard-2.0
- netcore-2.1
- netstandard-2.1
- netcore-2.2
- netcore-3.0
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
source_path: xml/System/Action.xml
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/7696cda6-0510-47f6-8302-71bb5d2e28cf
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/69c76c32-967e-4c65-b89a-74cc527db725
platformId: 8bddb6f4-8e3e-ae06-6753-665c6f85aec5
---

# Action Delegate

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
    - System.Core.dll

- Assembly:
    - mscorlib.dll

- Assembly:
    - netstandard.dll

- Source:
    - [Action.cs](https://github.com/dotnet/dotnet/blob/b0f34d51fccc69fd334253924abd8d6853fad7aa/src/runtime/src/libraries/System.Private.CoreLib/src/System/Action.cs)

- Source:
    - [Action.cs](https://github.com/dotnet/dotnet/blob/a8b33e7593686eaee701cd124daaabff2311634f/src/runtime/src/libraries/System.Private.CoreLib/src/System/Action.cs)

Encapsulates a method that has no parameters and does not return a value.

```cpp
public delegate void Action();
```

```csharp
public delegate void Action();
```

```fsharp
type Action = delegate of unit -> unit
```

```vb
Public Delegate Sub Action()
```

## Remarks

You can use this delegate to pass a method as a parameter without explicitly declaring a custom delegate. The encapsulated method must correspond to the method signature that is defined by this delegate. This means that the encapsulated method must have no parameters and no return value. (In C#, the method must return `void`. In F# the function or method must return `unit`. In Visual Basic, it must be defined by the `Sub`…`End Sub` construct. It can also be a method that returns a value that is ignored.) Typically, such a method is used to perform an operation.

Note

To reference a method that has no parameters and returns a value, use the generic [Func&lt;TResult&gt;](system.func-1) delegate instead.

When you use the [Action](system.action) delegate, you do not have to explicitly define a delegate that encapsulates a parameterless procedure. For example, the following code explicitly declares a delegate named `ShowValue` and assigns a reference to the `Name.DisplayToWindow` instance method to its delegate instance.

```csharp
using System;
using System.Windows.Forms;

public delegate void ShowValue();

public class Name
{
   private string instanceName;

   public Name(string name)
   {
      this.instanceName = name;
   }

   public void DisplayToConsole()
   {
      Console.WriteLine(this.instanceName);
   }

   public void DisplayToWindow()
   {
      MessageBox.Show(this.instanceName);
   }
}

public class testTestDelegate
{
   public static void Main()
   {
      Name testName = new Name("Koani");
      ShowValue showMethod = testName.DisplayToWindow;
      showMethod();
   }
}
```

```fsharp
open System.Windows.Forms

type ShowValue = delegate of unit -> unit

type Name(name) =
    member _.DisplayToConsole() = 
        printfn "%s" name

    member _.DisplayToWindow() = 
        MessageBox.Show name |> ignore

let testName = Name "Koani"

let showMethod = ShowValue testName.DisplayToWindow

showMethod.Invoke()
```

```vb
Public Delegate Sub ShowValue

Public Class Name
   Private instanceName As String
   
   Public Sub New(name As String)
      Me.instanceName = name
   End Sub
   
   Public Sub DisplayToConsole()
      Console.WriteLine(Me.instanceName)
   End Sub   
   
   Public Sub DisplayToWindow()
      MsgBox(Me.instanceName)
   End Sub   
End Class

Public Module testDelegate
   Public Sub Main()
      Dim testName As New Name("Koani")
      Dim showMethod As ShowValue = AddressOf testName.DisplayToWindow
      showMethod   
   End Sub
End Module
```

The following example simplifies this code by instantiating the [Action](system.action) delegate instead of explicitly defining a new delegate and assigning a named method to it.

```csharp
using System;
using System.Windows.Forms;

public class Name
{
   private string instanceName;

   public Name(string name)
   {
      this.instanceName = name;
   }

   public void DisplayToConsole()
   {
      Console.WriteLine(this.instanceName);
   }

   public void DisplayToWindow()
   {
      MessageBox.Show(this.instanceName);
   }
}

public class testTestDelegate
{
   public static void Main()
   {
      Name testName = new Name("Koani");
      Action showMethod = testName.DisplayToWindow;
      showMethod();
   }
}
```

```fsharp
open System
open System.Windows.Forms

type Name(name) =
    member _.DisplayToConsole() =
        printfn "%s" name

    member _.DisplayToWindow() =
        MessageBox.Show name |> ignore

let testName = Name "Koani"

// unit -> unit functions and methods can be cast to Action.
let showMethod = Action testName.DisplayToWindow

showMethod.Invoke()
```

```vb
Public Class Name
   Private instanceName As String
   
   Public Sub New(name As String)
      Me.instanceName = name
   End Sub
   
   Public Sub DisplayToConsole()
      Console.WriteLine(Me.instanceName)
   End Sub   
   
   Public Sub DisplayToWindow()
      MsgBox(Me.instanceName)
   End Sub   
End Class

Public Module testDelegate
   Public Sub Main()
      Dim testName As New Name("Koani")
      Dim showMethod As Action = AddressOf testName.DisplayToWindow
      showMethod   
   End Sub
End Module
```

You can also use the [Action](system.action) delegate with anonymous methods in C#, as the following example illustrates. (For an introduction to anonymous methods, see [Anonymous Methods](/en-us/dotnet/csharp/language-reference/operators/delegate-operator).)

```csharp
using System;
using System.Windows.Forms;

public class Name
{
   private string instanceName;

   public Name(string name)
   {
      this.instanceName = name;
   }

   public void DisplayToConsole()
   {
      Console.WriteLine(this.instanceName);
   }

   public void DisplayToWindow()
   {
      MessageBox.Show(this.instanceName);
   }
}

public class Anonymous
{
   public static void Main()
   {
      Name testName = new Name("Koani");
      Action showMethod = delegate() { testName.DisplayToWindow();} ;
      showMethod();
   }
}
```

You can also assign a lambda expression to an [Action](system.action) delegate instance, as the following example illustrates. (For an introduction to lambda expressions, see [Lambda Expressions (C#)](/en-us/dotnet/csharp/language-reference/operators/lambda-expressions) or [Lambda Expressions (F#)](/en-us/dotnet/fsharp/language-reference/functions/lambda-expressions-the-fun-keyword).)

```csharp
using System;
using System.Windows.Forms;

public class Name
{
   private string instanceName;

   public Name(string name)
   {
      this.instanceName = name;
   }

   public void DisplayToConsole()
   {
      Console.WriteLine(this.instanceName);
   }

   public void DisplayToWindow()
   {
      MessageBox.Show(this.instanceName);
   }
}

public class LambdaExpression
{
   public static void Main()
   {
      Name testName = new Name("Koani");
      Action showMethod = () => testName.DisplayToWindow();
      showMethod();
   }
}
```

```fsharp
open System
open System.Windows.Forms

type Name(name) =
    member _.DisplayToConsole() = 
        printfn "%s" name

    member _.DisplayToWindow() = 
        MessageBox.Show name |> ignore

let testName = Name "Koani"

let showMethod = Action(fun () -> testName.DisplayToWindow())

showMethod.Invoke()
```

```vb
Public Class Name
   Private instanceName As String
   
   Public Sub New(name As String)
      Me.instanceName = name
   End Sub
   
   Public Function DisplayToConsole() As Integer
      Console.WriteLine(Me.instanceName)
      Return 0
   End Function
   
   Public Function DisplayToWindow() As Integer
      Return MsgBox(Me.instanceName)
   End Function      
End Class

Module LambdaExpression
   Public Sub Main()
      Dim name1 As New Name("Koani")
      Dim methodCall As Action = Sub() name1.DisplayToWindow()
      methodCall()
   End Sub
End Module
```

## Extension Methods

| Name | Description |
| --- | --- |
| [GetMethodInfo(Delegate)](system.reflection.runtimereflectionextensions.getmethodinfo#system-reflection-runtimereflectionextensions-getmethodinfo%28system-delegate%29) | Gets an object that represents the method represented by the specified delegate. |

## Applies to