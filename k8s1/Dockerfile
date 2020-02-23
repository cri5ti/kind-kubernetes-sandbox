FROM mcr.microsoft.com/dotnet/core/aspnet:3.1 AS base
WORKDIR /app
EXPOSE 80

FROM mcr.microsoft.com/dotnet/core/sdk:3.1 AS build
WORKDIR /src
COPY ["k8s1.csproj", "k8s1/"]

RUN dotnet restore "k8s1/k8s1.csproj"
COPY . k8s1/
WORKDIR "/src/k8s1"
RUN dotnet build "k8s1.csproj" -c Release -o /app/build

FROM build AS publish
RUN dotnet publish "k8s1.csproj" -c Release -o /app/publish

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "k8s1.dll"]
