# Stage 1: Build
FROM mcr.microsoft.com/dotnet/sdk:9.0 AS build
WORKDIR /src

# Copy project files
COPY ServiceExample.sln .
COPY ServiceExample/*.csproj ./ServiceExample/
COPY UnitTests/*.csproj ./UnitTests/

# Restore dependencies
RUN dotnet restore

# Copy source code
COPY ServiceExample/. ./ServiceExample/
COPY UnitTests/. ./UnitTests/

# Build and test
RUN dotnet build -c Release --no-restore && \
    dotnet test -c Release --no-build --verbosity minimal

# Publish
RUN dotnet publish ServiceExample/ServiceExample.csproj -c Release -o /app/publish --no-build

# Stage 2: Runtime
FROM mcr.microsoft.com/dotnet/aspnet:9.0 AS final
WORKDIR /app

# Create non-root user
RUN adduser --disabled-password --home /app --gecos '' appuser && \
    chown -R appuser:appuser /app
USER appuser

COPY --from=build /app/publish .

# Environment variables (can be overridden at runtime)
ENV ASPNETCORE_ENVIRONMENT=Production
ENV ASPNETCORE_URLS=http://+:9080

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:9080/health || exit 1

EXPOSE 9080

ENTRYPOINT ["dotnet", "ServiceExample.dll"]
