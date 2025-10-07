# Stage 1: Build
FROM mcr.microsoft.com/dotnet/sdk:9.0 AS build
WORKDIR /src

# Copy only project files first for better caching
COPY ServiceExample.sln .
COPY ServiceExample/*.csproj ./ServiceExample/
COPY UnitTests/*.csproj ./UnitTests/

# Restore dependencies (this layer caches well)
RUN dotnet restore --verbosity quiet

# Copy remaining source
COPY ServiceExample/. ./ServiceExample/
COPY UnitTests/. ./UnitTests/

# Build and test in one layer
RUN dotnet build -c Release --no-restore && \
    dotnet test -c Release --no-build --verbosity quiet && \
    dotnet publish ServiceExample/ServiceExample.csproj -c Release -o /app/publish --no-build

# Stage 2: Runtime
FROM mcr.microsoft.com/dotnet/aspnet:9.0 AS final
WORKDIR /app
COPY --from=build /app/publish .
EXPOSE 9080
ENTRYPOINT ["dotnet", "ServiceExample.dll"]
