# Stage 1: Build
FROM mcr.microsoft.com/dotnet/sdk:9.0 AS build
WORKDIR /src

# 1️⃣ Copy solution and project files first for caching
COPY ServiceExample.sln .
COPY ServiceExample/*.csproj ./ServiceExample/
COPY UnitTests/*.csproj ./UnitTests/

# 2️⃣ Restore dependencies (cached if csproj files don't change)
RUN dotnet restore

# 3️⃣ Copy the rest of the source code
COPY ServiceExample/. ./ServiceExample/
COPY UnitTests/. ./UnitTests/

# 4️⃣ Build the project
RUN dotnet build ServiceExample/ServiceExample.csproj -c Release --no-restore

# 5️⃣ Run unit tests (optional, ensures build quality)
RUN dotnet test UnitTests/UnitTests.csproj --configuration Release --no-build --verbosity normal

# 6️⃣ Publish the app
RUN dotnet publish ServiceExample/ServiceExample.csproj -c Release -o /app/out --no-build

# Stage 2: Runtime
FROM mcr.microsoft.com/dotnet/aspnet:9.0
WORKDIR /app

# Copy published output
COPY --from=build /app/out .

# Expose port
EXPOSE 9080

# Environment variables
ENV Aspire__MongoDB__Driver__ConnectionString=mongodb://mongo:27017
ENV Aspire__StackExchange__Redis__ConnectionString=redis:6379
ENV Aspire__NATS__Net__ConnectionString=nats://nats:4222

# Run the app
ENTRYPOINT ["dotnet", "ServiceExample.dll"]
