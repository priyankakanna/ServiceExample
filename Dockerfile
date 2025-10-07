# Stage 1: Build
FROM mcr.microsoft.com/dotnet/sdk:9.0 AS build
WORKDIR /src

# 1️⃣ Copy solution and project files separately for caching
COPY ServiceExample.sln .
COPY ServiceExample/*.csproj ./ServiceExample/
COPY UnitTests/*.csproj ./UnitTests/

# 2️⃣ Restore dependencies (layer will cache unless csproj changes)
RUN dotnet restore

# 3️⃣ Copy source code for each project separately
COPY ServiceExample/. ./ServiceExample/
COPY UnitTests/. ./UnitTests/

# 4️⃣ Build projects individually to leverage cache
RUN dotnet build ServiceExample/ServiceExample.csproj -c Release --no-restore
RUN dotnet build UnitTests/UnitTests.csproj -c Release --no-restore

# 5️⃣ Run unit tests
RUN dotnet test UnitTests/UnitTests.csproj --configuration Release --no-build --verbosity normal

# 6️⃣ Publish main application
RUN dotnet publish ServiceExample/ServiceExample.csproj -c Release -o /app/out --no-build

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
