# Stage 1: Build
FROM mcr.microsoft.com/dotnet/sdk:9.0 AS build
WORKDIR /src

# Copy solution and project folders
COPY ServiceExample.sln .
COPY ServiceExample/ ServiceExample/
COPY UnitTests/ UnitTests/

# Restore dependencies and publish
RUN dotnet restore
RUN dotnet publish ServiceExample/ServiceExample.csproj -c Release -o /app/out

# Stage 2: Runtime
FROM mcr.microsoft.com/dotnet/aspnet:9.0
WORKDIR /app
COPY --from=build /app/out .

# Expose port
EXPOSE 9080

# Environment variables
ENV Aspire__MongoDB__Driver__ConnectionString=mongodb://mongo:27017
ENV Aspire__StackExchange__Redis__ConnectionString=redis:6379
ENV Aspire__NATS__Net__ConnectionString=nats://nats:4222

# Run the app
ENTRYPOINT ["dotnet", "ServiceExample.dll"]

