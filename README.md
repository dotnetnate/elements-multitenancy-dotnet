
# elements-dotnet

![CI](https://github.com/dotnetnate/elements-dotnet/actions/workflows/dotnet.yml/badge.svg)
[![Quality Report](https://img.shields.io/badge/Quality_Report-latest-blue)](https://dotnetnate.github.io/elements-dotnet/)

This repository contains a .NET solution in `/src` with several libraries grouped by core capability, along with adapters to well-known products.

## Products

### Core 
- **Elements.Core**: Provides foundation types and extensions that are used within the Elements ecosystem. This project does not take dependencies on any external libraries other than the .NET BCL/FCL. 


### Validation

**Elements.Validation.Abstractions**: Provides a uniform interface for performing validation within applications.


#### Adapter Projects
| Project | Product Name | Product Documentation / Repo |
|-----------------|-------------|------------------------------|
| [Elements.Validation.FluentValidation](src/Elements.Validation.FluentValidation) | FluentValidation | [NuGet](https://www.nuget.org/packages/FluentValidation) / [GitHub](https://github.com/FluentValidation/FluentValidation) / [Docs](https://fluentvalidation.net/) |
| [Elements.Validation.DataAnnotations](src/Elements.Validation.DataAnnotations) | Microsoft DataAnnotations | [Microsoft Docs](https://learn.microsoft.com/en-us/dotnet/api/system.componentmodel.dataannotations) |

### Security & Identity
**Elements.Security.Identity.Abstractions**: Provides abstractions for obtaining identities from the application execution context as well as transmitting or persisting a refrence to an identity.  

## Build and Usage
- All source code is located in `/src`.
- Run `dotnet build src/src.sln` to build all projects.

## Additional Information
- For build, packaging, or deployment scripts and assets, see the [eng](/eng) folder.
- For documentation, see the [docs](/docs) folder.
