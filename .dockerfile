# Use the official ASP.NET Core runtime image as the base image
FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS base
WORKDIR /app
EXPOSE 80
EXPOSE 443

# Use the .NET SDK image for building the application
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src
COPY ["blazorwebapp/blazorwebapp.csproj", "BlazorApp/"]
RUN dotnet restore "blazorwebapp/blazorwebapp.csproj"
COPY . .
WORKDIR "/src/blazorwebapp/"
RUN dotnet build "blazorwebapp.csproj" -c Release -o /app/build

# Publish the application to the /app/publish directory
FROM build AS publish
RUN dotnet publish "blazorwebapp.csproj" -c Release -o /app/publish

# Use the runtime image to create the final container
FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "blazorwebapp.dll"]
