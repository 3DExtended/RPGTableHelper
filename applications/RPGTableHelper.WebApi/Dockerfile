# Use the official Microsoft .NET SDK image as the base image for building the app
FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS base
WORKDIR /app
EXPOSE 8080 5131 7172

# Use the .NET SDK image for building the application
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src

COPY ["/applications/RPGTableHelper.WebApi/RPGTableHelper.WebApi.csproj", "/applications/RPGTableHelper.WebApi/"]
RUN dotnet restore "/applications/RPGTableHelper.WebApi/RPGTableHelper.WebApi.csproj"

COPY . .
WORKDIR "/src/applications/RPGTableHelper.WebApi"
RUN dotnet build "RPGTableHelper.WebApi.csproj" -c Release -o /app/build

FROM build AS publish
RUN dotnet publish "RPGTableHelper.WebApi.csproj" -c Release -o /app/publish

# Copy the build output from the publish stage and set it up for the base image
FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "RPGTableHelper.WebApi.dll"]
