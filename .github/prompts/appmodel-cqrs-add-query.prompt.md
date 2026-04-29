---
agent: agent
---

You are an expert .NET developer specializing in the CQRS (Command Query Responsibility Segregation) pattern. Your task is to add a new Query to an existing CQRS application following best practices. To do this, you will make use of the classes in the ELements.ApplicationModel.CQRS.Queries namespace.

Your tasks are as follows:
- Identify the appropriate location for the new Query, Query Handler, and any related classes based on the existing project structure. If the user is currently in a project that ends in '.Application', this is likely the correct project for the Query and Query Handler. If they are not and you are unsure, ask for clarification.
- If the user has provided a name for the query, use that to name the types you will create. If not, ask for the desired name of the Query.
- In the project identified for the Query and Query Handler, create a new class for the Query in the Queries folder (or create the folder if it does not exist). The Query class should implement the IQuery interface and include any necessary properties for the query parameters.
- Create a corresponding Query Handler class in the Queries folder (or create the folder if it does not exist). The Query Handler should implement the IQueryHandler<TQuery, TResult> interface, where TQuery is the Query class you created and TResult is the expected return type of the query. If the return type cannot be inferred, ask the user for clarification.
- When creating the Query Handler, follow the following conventions:
    - Implement the Handle method to process the query and return the appropriate result.
    - Use dependency injection to access any required services or repositories.
    - If there is an obvious repository implementation in the project structure that corresponds to the Query's purpose, utilize it within the Query Handler and inject it in the constructor. For example, if the Query is related to "User" data, look for a IUserRepository in the related Domain project. The domain project should be named the same as the application project but without the '.Application' suffix and use the '.Domain' suffix instead.
    - Name the Query Handler class by appending "Handler" to the Query class name (e.g., if the Query is named GetUserByIdQuery, the handler should be named GetUserByIdQueryHandler).
    - All members of the Query Handler class are documented with XML comments describing its purpose and parameters.
    - The Query Handler and Query classes are in their own files, named after the class (e.g., GetUserByIdQuery.cs and GetUserByIdQueryHandler.cs).
- When creating the Query class, follow these conventions:
    - Name the Query class with a descriptive name that indicates its purpose (e.g., GetUserByIdQuery).
    - Include properties for any parameters needed to execute the query. If the user has not specified parameters, ask for clarification.
    - All members of the Query class are documented with XML comments describing its purpose and parameters.
    - The Query Handler and Query classes are in their own files, named after the class (e.g., GetUserByIdQuery.cs and GetUserByIdQueryHandler.cs).



