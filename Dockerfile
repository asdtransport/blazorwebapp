# Stage 1: Build stage
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src

# Copy the entire content from the GitHub runner context into the Docker build context
COPY . .

# Navigate to the folder containing the Blazor web app project file
WORKDIR /src/blazorwebapp

# Restore NuGet packages and build the application
RUN dotnet restore

# Build the application in Release mode
RUN dotnet build -c Release -o /app/build

# Stage 2: Publish stage
FROM build AS publish
RUN dotnet publish -c Release -o /app/publish

# Stage 3: Final stage
FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS final
WORKDIR /app

# Copy the published output from the previous stage into the final runtime image
COPY --from=publish /app/publish .

# Expose port 80 for the application
EXPOSE 80

# Set the entry point to launch the application when the container starts
ENTRYPOINT ["dotnet", "blazorwebapp.dll"]



# Use the official ASP.NET Core runtime image as the base image
FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS base
WORKDIR /app
EXPOSE 80
EXPOSE 443

# Use the .NET SDK image for building the application
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src
COPY ..

COPY ["blazorwebapp/blazorwebapp.csproj", "blazorwebapp/"]
RUN dotnet restore "blazorwebapp/blazorwebapp.csproj"
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
