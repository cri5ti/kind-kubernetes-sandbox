A sandbox project for experimenting with kubernetes.

### `./deploy.sh`


```
./deploy.sh --rebuild
Linux version 4.4.0-18362-Microsoft (Microsoft@Microsoft.com) (gcc version 5.4.0 (GCC) ) #476-Microsoft Fri Nov 01 16:53:00 PST 2019
 ✔ kind
 ✔ kubectl
 ✔ helm
 ✔ registry running on 172.17.0.3:5000
 ▶ dropping cluster c1...
Deleting cluster "c1" ...
No kind clusters found.
 ▶ deploying cluster c1 with 1 worker nodes...
Creating cluster "c1" ...
 ✓ Ensuring node image (kindest/node:v1.17.0) 🖼
 ✓ Preparing nodes 📦 📦
 ✓ Writing configuration 📜
 ✓ Starting control-plane 🕹️
 ✓ Installing CNI 🔌
 ✓ Installing StorageClass 💾
 ✓ Joining worker nodes 🚜
Set kubectl context to "kind-c1"
You can now use your cluster with:

kubectl cluster-info --context kind-c1

Thanks for using kind! 😊
 ✔ cluster c1 ready
namespace/kubernetes-dashboard created
serviceaccount/kubernetes-dashboard created
service/kubernetes-dashboard created
secret/kubernetes-dashboard-certs created
secret/kubernetes-dashboard-csrf created
secret/kubernetes-dashboard-key-holder created
configmap/kubernetes-dashboard-settings created
role.rbac.authorization.k8s.io/kubernetes-dashboard created
clusterrole.rbac.authorization.k8s.io/kubernetes-dashboard created
rolebinding.rbac.authorization.k8s.io/kubernetes-dashboard created
clusterrolebinding.rbac.authorization.k8s.io/kubernetes-dashboard created
deployment.apps/kubernetes-dashboard created
service/dashboard-metrics-scraper created
deployment.apps/dashboard-metrics-scraper created
service/kubernetes-dashboard-nodeport created
serviceaccount/admin-user created
clusterrolebinding.rbac.authorization.k8s.io/admin-user created
Enter Export Password:
Verifying - Enter Export Password:
 ✔ kubernetes dashboard: https://localhost:7070
 🔑 eyJhbGciOiJSUzI1NiIsImtpZCI6IlRsaEJESkRiTk4zbzY3TlpBVFFlN1F6Nnk3QjM2aE5iRGFQMDdHaWNTRncifQ.eyJpc3MiOiJrdWJlcm5ldGVzL3NlcnZpY2VhY2NvdW50Iiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9uYW1lc3BhY2UiOiJrdWJlcm5ldGVzLWRhc2hib2FyZCIsImt1YmVybmV0ZXMuaW8vc2VydmljZWFjY291bnQvc2VjcmV0Lm5hbWUiOiJhZG1pbi11c2VyLXRva2VuLXN4aHZwIiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9zZXJ2aWNlLWFjY291bnQubmFtZSI6ImFkbWluLXVzZXIiLCJrdWJlcm5ldGVzLmlvL3NlcnZpY2VhY2NvdW50L3NlcnZpY2UtYWNjb3VudC51aWQiOiI4OTBhZjJlYS0wNTk4LTRmNGQtYmZiOS03ZmVlYWViNTBkMmYiLCJzdWIiOiJzeXN0ZW06c2VydmljZWFjY291bnQ6a3ViZXJuZXRlcy1kYXNoYm9hcmQ6YWRtaW4tdXNlciJ9.a7u5QvumVWAcEvEDEL1MmwmuUtT_-Tl7tEaqrtFMCYvA1oKOwM_fcRTXknnS8VxwmuUce5NbVsYqaAtmTmiwb8ZSlUsSZ39HBx9PNT2KjlPl9kVcR_G-gpFwLavqBzkilJrjH_1B1pcOCXFAH7TmttawS-e8ZJRETK9-CQN77u--eYpaTbzJY46pY07684GlhX1bh3xzauqKAoTriafDNYESXLoAuaQT7A8fLoYqHgM65B7AFiJ5o46pBY7cTTnLBtf665ZDt6rvftkSJtT0vp7WedDuSMuqNpZCXJaDSz0wWBat5xDXdpEj939fHNp_Z10ebVllCcfh4helVmiLaw
 ▶ ingress-nginx
namespace/ingress-nginx created
configmap/nginx-configuration created
configmap/tcp-services created
configmap/udp-services created
serviceaccount/nginx-ingress-serviceaccount created
clusterrole.rbac.authorization.k8s.io/nginx-ingress-clusterrole created
role.rbac.authorization.k8s.io/nginx-ingress-role created
rolebinding.rbac.authorization.k8s.io/nginx-ingress-role-nisa-binding created
clusterrolebinding.rbac.authorization.k8s.io/nginx-ingress-clusterrole-nisa-binding created
deployment.apps/nginx-ingress-controller created
limitrange/ingress-nginx created
service/ingress-nginx created
deployment.apps/nginx-ingress-controller patched
 ⚒ building images
 ▶ building localhost:5000/k8s1 image...
docker build -f ../../k8s1/Dockerfile ../../k8s1 -t localhost:5000/k8s1 > /dev/null
Sending build context to Docker daemon  20.48kB
Step 1/16 : FROM mcr.microsoft.com/dotnet/core/aspnet:3.1 AS base
 ---> 47da1e9634dc
Step 2/16 : WORKDIR /app
 ---> Using cache
 ---> 06314e6ff684
Step 3/16 : EXPOSE 80
 ---> Using cache
 ---> 71348ff28740
Step 4/16 : FROM mcr.microsoft.com/dotnet/core/sdk:3.1 AS build
 ---> 4a651b73be3d
Step 5/16 : WORKDIR /src
 ---> Using cache
 ---> 3c3d3a546dac
Step 6/16 : COPY ["k8s1.csproj", "k8s1/"]
 ---> Using cache
 ---> 47466a15ffa0
Step 7/16 : RUN dotnet restore "k8s1/k8s1.csproj"
 ---> Using cache
 ---> 9d5c9ba00603
Step 8/16 : COPY . k8s1/
 ---> Using cache
 ---> 98c71851b5d9
Step 9/16 : WORKDIR "/src/k8s1"
 ---> Using cache
 ---> df1ec9522a43
Step 10/16 : RUN dotnet build "k8s1.csproj" -c Release -o /app/build
 ---> Using cache
 ---> b00c5bc7b99c
Step 11/16 : FROM build AS publish
 ---> b00c5bc7b99c
Step 12/16 : RUN dotnet publish "k8s1.csproj" -c Release -o /app/publish
 ---> Using cache
 ---> 475a912a01be
Step 13/16 : FROM base AS final
 ---> 71348ff28740
Step 14/16 : WORKDIR /app
 ---> Using cache
 ---> f0f0131ba668
Step 15/16 : COPY --from=publish /app/publish .
 ---> Using cache
 ---> cc1e0a34008c
Step 16/16 : ENTRYPOINT ["dotnet", "k8s1.dll"]
 ---> Using cache
 ---> b3bfd17a02a5
Successfully built b3bfd17a02a5
Successfully tagged localhost:5000/k8s1:latest
   ✔ localhost:5000/k8s1 image built.
The push refers to repository [localhost:5000/k8s1]
d1b8ff00f850: Layer already exists
4ca62c9a896b: Layer already exists
2688285497ef: Layer already exists
383100ee58c3: Layer already exists
6e98de2e6b3f: Layer already exists
a9e56403c599: Layer already exists
488dfecc21b1: Layer already exists
latest: digest: sha256:7b1f56b848b44c9115fb9624df3f5f15fd543f017a3e53dff515fb0454b92ceb size: 1790
   ▶ deploying k8s1
Release "k8s1" does not exist. Installing it now.
NAME: k8s1
LAST DEPLOYED: Sun Feb 23 21:47:10 2020
NAMESPACE: default
STATUS: deployed
REVISION: 1
TEST SUITE: None
NOTES:
1. Get the application URL by running these commands:
  http://local.cri5ti.com/api/
deployment.apps/k8s1 image updated
 ▶ building localhost:5000/webapp1 image...
docker build -f ../../webapp1/Dockerfile ../../webapp1 -t localhost:5000/webapp1 > /dev/null
Sending build context to Docker daemon  25.09kB
Step 1/3 : FROM nginx
 ---> 2073e0bcb60e
Step 2/3 : EXPOSE 80
 ---> Using cache
 ---> 7666324640d8
Step 3/3 : COPY static/ /usr/share/nginx/html
 ---> Using cache
 ---> 3e3fd50d7249
Successfully built 3e3fd50d7249
Successfully tagged localhost:5000/webapp1:latest
   ✔ localhost:5000/webapp1 image built.
The push refers to repository [localhost:5000/webapp1]
5a5b7a9bb438: Layer already exists
22439467ad99: Layer already exists
b4a29beac87c: Layer already exists
488dfecc21b1: Layer already exists
latest: digest: sha256:491df74b5a1064fc637c2e08c64dc37e634afe0c6bd59162fc7b14df983f253a size: 1155
   ▶ deploying webapp1
Release "webapp1" does not exist. Installing it now.
NAME: webapp1
LAST DEPLOYED: Sun Feb 23 21:47:12 2020
NAMESPACE: default
STATUS: deployed
REVISION: 1
NOTES:
1. Get the application URL by running these commands:
  http://local.cri5ti.com/
deployment.apps/webapp1 image updated
```