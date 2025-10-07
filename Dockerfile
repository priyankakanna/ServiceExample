# Use smaller base image
FROM mcr.microsoft.com/dotnet/aspnet:9.0 AS base
WORKDIR /app
EXPOSE 9080

# Build stage
FROM mcr.microsoft.com/dotnet/sdk:9.0 AS build
WORKDIR /src

# Copy ONLY what's needed for restore
COPY ServiceExample/ServiceExample.csproj ./ServiceExample/
RUN dotnet restore ServiceExample/ServiceExample.csproj --verbosity quiet

# Copy source and build
COPY ServiceExample/. ./ServiceExample/
RUN dotnet publish ServiceExample/ServiceExample.csproj -c Release -o /app/publish --no-restore

# Final stage
FROM base AS final
WORKDIR /app
COPY --from=build /app/publish .
ENTRYPOINT ["dotnet", "ServiceExample.dll"]
