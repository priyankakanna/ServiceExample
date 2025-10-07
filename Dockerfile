# Stage 1: Build
FROM mcr.microsoft.com/dotnet/sdk:9.0 AS build
WORKDIR /src

# 1️⃣ Copy solution and project files separately for better caching
COPY ServiceExample.sln .
COPY ServiceExample/*.csproj ./ServiceExample/
COPY UnitTests/*.csproj ./UnitTests/

# 2️⃣ Restore dependencies (cached layer)
RUN dotnet restore --verbosity minimal

# 3️⃣ Copy remaining source code
COPY ServiceExample/. ./ServiceExample/
COPY UnitTests/. ./UnitTests/

# 4️⃣ Build and test in single layer to reduce image size
RUN dotnet build ServiceExample/ServiceExample.csproj -c Release --no-restore && \
    dotnet test UnitTests/UnitTests.csproj -c Release --no-build --verbosity minimal && \
    dotnet publish ServiceExample/ServiceExample.csproj -c Release -o /app/publish --no-build

# Stage 2: Runtime
FROM mcr.microsoft.com/dotnet/aspnet:9.0 AS final
WORKDIR /app

# Create a non-root user for security
RUN adduser --disabled-password --home /app --gecos '' appuser && \
    chown -R appuser:appuser /app
USER appuser

COPY --from=build /app/publish .

# Expose port
EXPOSE 9080

# Environment variables (consider using appsettings.json instead)
ENV ASPNETCORE_URLS=http://+:9080

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:9080/health || exit 1

# Run the app
ENTRYPOINT ["dotnet", "ServiceExample.dll"]
