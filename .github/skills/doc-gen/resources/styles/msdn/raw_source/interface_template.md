---
layout: Reference
monikers:
- netstandard-2.0-pp
- netstandard-2.1
- netcore-3.0
- netframework-4.6.2-pp
- netframework-4.7-pp
- netframework-4.7.1-pp
- netframework-4.7.2-pp
- netframework-4.8-pp
- netframework-4.8.1-pp
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
title: IAsyncDisposable Interface (System) | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/dotnet/api/system.iasyncdisposable?view=net-10.0
uid: System.IAsyncDisposable
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
- System.IAsyncDisposable
api_location:
- System.Runtime.dll
- netstandard.dll
- Microsoft.Bcl.AsyncInterfaces.dll
topic_type:
- apiref
api_type:
- Assembly
locale: en-us
document_id: 28a2565e-7e6e-981d-b37b-ee7e4b467bac
document_version_independent_id: 7b92c390-2a0a-bde4-71b4-497f68ea1ccf
updated_at: 2026-04-01T10:31:00.0000000Z
original_content_git_url: https://github.com/dotnet/dotnet-api-docs/blob/live/xml/System/IAsyncDisposable.xml
gitcommit: https://github.com/dotnet/dotnet-api-docs/blob/7af46a1787976e60158e84afefec9aaa78d7f536/xml/System/IAsyncDisposable.xml
git_commit_id: 7af46a1787976e60158e84afefec9aaa78d7f536
default_moniker: net-10.0
site_name: Docs
depot_name: VS.dotnet-api-docs
page_type: dotnet
page_kind: interface
ms.assetid: System.IAsyncDisposable
description: 'Provides a mechanism for releasing unmanaged resources asynchronously. '
toc_rel: _splitted/system/toc.json
search.mshattr.devlang: csharp vb fsharp cpp
asset_id: api/system.iasyncdisposable
moniker_range_name: b496d59c6f65605f5d4a75b884a0b136
monikers:
- netstandard-2.0-pp
- netstandard-2.1
- netcore-3.0
- netframework-4.6.2-pp
- netframework-4.7-pp
- netframework-4.7.1-pp
- netframework-4.7.2-pp
- netframework-4.8-pp
- netframework-4.8.1-pp
- netcore-3.1
- net-5.0
- net-6.0
- net-7.0
- net-8.0
- net-9.0
- net-10.0
- net-11.0
item_type: Content
source_path: xml/System/IAsyncDisposable.xml
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/7696cda6-0510-47f6-8302-71bb5d2e28cf
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/69c76c32-967e-4c65-b89a-74cc527db725
platformId: eb46ce94-d4ee-59e8-5613-6d28a9479c8a
---

# IAsyncDisposable Interface

## Definition

- Namespace:
    - [System](system)

- Assemblies:
    - netstandard.dll, System.Runtime.dll

- Assembly:
    - System.Runtime.dll

- Assembly:
    - Microsoft.Bcl.AsyncInterfaces.dll

- Assembly:
    - netstandard.dll

- Package:
    - Microsoft.Bcl.AsyncInterfaces v11.0.0-preview.3.26207.106

- Source:
    - [IAsyncDisposable.cs](https://github.com/dotnet/dotnet/blob/b0f34d51fccc69fd334253924abd8d6853fad7aa/src/runtime/src/libraries/System.Private.CoreLib/src/System/IAsyncDisposable.cs)

- Source:
    - [IAsyncDisposable.cs](https://github.com/dotnet/dotnet/blob/a8b33e7593686eaee701cd124daaabff2311634f/src/runtime/src/libraries/System.Private.CoreLib/src/System/IAsyncDisposable.cs)

Provides a mechanism for releasing unmanaged resources asynchronously.

```cpp
public interface class IAsyncDisposable
```

```csharp
public interface IAsyncDisposable
```

```fsharp
type IAsyncDisposable = interface
```

```vb
Public Interface IAsyncDisposable
```

- Derived
    - [Microsoft.Extensions.AI.Evaluation.Reporting.ScenarioRun](microsoft.extensions.ai.evaluation.reporting.scenariorun)

[Microsoft.Extensions.AI.IRealtimeClientSession](microsoft.extensions.ai.irealtimeclientsession)

[Microsoft.Extensions.AI.OpenAIRealtimeClientSession](microsoft.extensions.ai.openairealtimeclientsession)

[Microsoft.Extensions.DependencyInjection.AsyncServiceScope](microsoft.extensions.dependencyinjection.asyncservicescope)

[Microsoft.Extensions.DependencyInjection.ServiceProvider](microsoft.extensions.dependencyinjection.serviceprovider)

[System.Collections.Generic.IAsyncEnumerator&lt;T&gt;](system.collections.generic.iasyncenumerator-1)

[System.Data.Common.DbBatch](system.data.common.dbbatch)

[System.Data.Common.DbCommand](system.data.common.dbcommand)

[System.Data.Common.DbConnection](system.data.common.dbconnection)

[System.Data.Common.DbDataReader](system.data.common.dbdatareader)

[System.Data.Common.DbDataSource](system.data.common.dbdatasource)

[System.Data.Common.DbTransaction](system.data.common.dbtransaction)

[System.Formats.Tar.TarReader](system.formats.tar.tarreader)

[System.Formats.Tar.TarWriter](system.formats.tar.tarwriter)

[System.IO.BinaryWriter](system.io.binarywriter)

[System.IO.Compression.ZipArchive](system.io.compression.ziparchive)

[System.IO.Stream](system.io.stream)

[System.IO.TextWriter](system.io.textwriter)

[System.Net.Quic.QuicConnection](system.net.quic.quicconnection)

[System.Net.Quic.QuicListener](system.net.quic.quiclistener)

[System.ServiceModel.ChannelFactory](system.servicemodel.channelfactory)

[System.ServiceModel.ClientBase&lt;TChannel&gt;](system.servicemodel.clientbase-1)

[System.Text.Json.Utf8JsonWriter](system.text.json.utf8jsonwriter)

[System.Threading.CancellationTokenRegistration](system.threading.cancellationtokenregistration)

[System.Threading.ITimer](system.threading.itimer)

[System.Threading.Timer](system.threading.timer)

[System.Xml.XmlWriter](system.xml.xmlwriter)

More…

## Remarks

For more information about this API, see [Supplemental API remarks for IAsyncDisposable](/en-us/dotnet/fundamentals/runtime-libraries/system-iasyncdisposable).

## Methods

| Name | Description |
| --- | --- |
| [DisposeAsync()](system.iasyncdisposable.disposeasync#system-iasyncdisposable-disposeasync) | Performs application-defined tasks associated with freeing, releasing, or resetting unmanaged resources asynchronously. |

## Extension Methods

| Name | Description |
| --- | --- |
| [ConfigureAwait(IAsyncDisposable, Boolean)](system.threading.tasks.taskasyncenumerableextensions.configureawait#system-threading-tasks-taskasyncenumerableextensions-configureawait%28system-iasyncdisposable-system-boolean%29) | Configures how awaits on the tasks returned from an async disposable will be performed. |

## Applies to