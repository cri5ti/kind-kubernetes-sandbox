#!/usr/bin/env bash
set -o errexit

kind_cluster=c1
worker_nodes=1
registry_name='kind-registry'
registry_port='5000'
rebuild_cluster=
skip_dashboard=

repo_root=../../

# args
{
    for i in "$@"
    do
    case ${i} in
        --rebuild)
        rebuild_cluster=yes
        ;;
        --skip-dashboard)
        skip_dashboard=yes
        ;;
        *) echo "Unsupported options"; exit 1 ;;
    esac
    done
}

# formats
{
    bold=$(tput bold)
    norm=$(tput sgr0)
    smul=$(tput smul) # Enable underline mode
    rmul=$(tput rmul) # Disable underline mode
}


# pre checks
{      
    if cat /proc/version | grep Microsoft; then
        #WSL aliases
        alias open="powershell.exe /c start"
    fi
    
    # pre-checks
    if ! [[ -x "$(command -v docker)" ]]; then echo " ❌ docker is not installed." >&2; exit 1; fi
}    


# make folder .bin
[[ ! -d ./.bin ]] && mkdir .bin
# add to path 
[[ ":$PATH:" != *"$PWD/.bin"* ]] && PATH=$PATH:$PWD/.bin

# check/download: kind
if ! [[ -x "$(command -v kind)" ]]; then 
    curl -Lo .bin/kind https://github.com/kubernetes-sigs/kind/releases/download/v0.7.0/kind-$(uname)-amd64
    chmod +x .bin/kind
else echo " ✔ kind"; fi

# check/download: kubectl
if ! [[ -x "$(command -v kubectl)" ]]; then 
    curl -Lo .bin/kubectl https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl
    chmod +x .bin/kubectl
else echo " ✔ kubectl"; fi

# check/download: helm
if ! [[ -x "$(command -v helm)" ]]; then 
    curl -Lo .bin/helm.tar.gz https://get.helm.sh/helm-v3.1.1-linux-amd64.tar.gz
    tar -zxvf .bin/helm.tar.gz -C .bin
    mv .bin/linux-amd64/helm .bin/helm
    chmod +x .bin/helm
    rm -r .bin/linux-amd64
    rm .bin/helm.tar.gz
else echo " ✔ helm"; fi

if [[ -n "${registry_name}" ]]; then
    running="$(docker inspect -f '{{.State.Running}}' "${registry_name}" 2>/dev/null || true)"
    if [[ "${running}" != 'true' ]]; then
        echo " ▶ starting registry ... "
        docker run -d --restart=always -p "${registry_port}:5000" --name "${registry_name}" registry:2
    fi
    registry_ip="$(docker inspect -f '{{.NetworkSettings.IPAddress}}' "${registry_name}")"
    echo " ✔ registry running on ${smul}${registry_ip}:${registry_port}${rmul}"    
fi
    

if [[ -n "${rebuild_cluster}" ]]; then
    echo " ▶ dropping cluster ${kind_cluster}..."
    kind delete cluster --name ${kind_cluster} 
fi

if ! kind get clusters | grep -xq ${kind_cluster}; then
    echo " ▶ deploying cluster ${kind_cluster} with ${worker_nodes} worker nodes..."
    
        # create a cluster with the local registry enabled in containerd
    cat <<EOF | kind create cluster --name "${kind_cluster}" --config=-
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
containerdConfigPatches: 
- |-
  [plugins."io.containerd.grpc.v1.cri".registry.mirrors."localhost:${registry_port}"]
    endpoint = ["http://${registry_ip}:${registry_port}"]
nodes:
  - role: control-plane
    kubeadmConfigPatches:
    - |
      kind: InitConfiguration
      nodeRegistration:
        kubeletExtraArgs:
          node-labels: "ingress-ready=true"
          authorization-mode: "AlwaysAllow"
    extraPortMappings:
    - containerPort: 30080
      hostPort: 7070
    - containerPort: 80
      hostPort: 80
      protocol: TCP
    - containerPort: 443
      hostPort: 443
      protocol: TCP
$(seq ${worker_nodes} | sed "c\  - role: worker")
EOF
fi
echo " ✔ cluster ${kind_cluster} ready"


if [[ ! -n "${skip_dashboard}" ]]; then  
    if ! kubectl describe service kubernetes-dashboard --namespace kubernetes-dashboard > /dev/null 2>&1;  then
        kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.0.0-beta8/aio/deploy/recommended.yaml
        kubectl apply -f dashboard.yaml
            
        grep 'client-certificate-data' ~/.kube/config | head -n 1 | awk '{print $2}' | base64 -d >> kubecfg.crt
        grep 'client-key-data' ~/.kube/config | head -n 1 | awk '{print $2}' | base64 -d >> kubecfg.key
        openssl pkcs12 -export -clcerts -inkey kubecfg.key -in kubecfg.crt -out kubecfg.p12 -name "kubernetes-client"
    fi
    
    echo " ✔ kubernetes dashboard: ${smul}https://localhost:7070${rmul}"
    echo " 🔑 $(kubectl -n kubernetes-dashboard get secret $(kubectl -n kubernetes-dashboard get secret | grep admin-user | awk '{print $1}') -o jsonpath='{$.data.token}' | base64 --decode)"
fi




#for port in 80 443
#do
#    node_port=$(kubectl get service -n ingress-nginx ingress-nginx -o=jsonpath="{.spec.ports[?(@.port == ${port})].nodePort}")
#
#    docker run -d --name banzai-kind-proxy-${port} \
#      --publish 127.0.0.1:${port}:${port} \
#      --link banzai-control-plane:target \
#      alpine/socat -dd \
#      tcp-listen:${port},fork,reuseaddr tcp-connect:target:${node_port}
#done


echo " ▶ ingress";
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/master/deploy/static/mandatory.yaml
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/master/deploy/static/provider/cloud-generic.yaml
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/master/deploy/static/provider/baremetal/service-nodeport.yaml


echo " ⚒ building images"

declare -a projects=("k8s1" "webapp1")

registry="localhost:${registry_port}"

for proj in "${projects[@]}"; do
    tag="${registry}/${proj}"
    echo " ▶ building ${tag} image...";
    docker build -f "${repo_root}${proj}/Dockerfile" "${repo_root}${proj}" -t ${tag} > /dev/null
  
    #  echo "-------------------------------";
    echo "   ✔ ${tag} image built.";
    
    docker push ${tag}
    kubectl set image deployment --all ${proj}=localhost:5000/${proj}
  
    if [[ -d ../charts/${proj} ]]; then
        echo "   ▶ deploying ${proj}";
      
        helm upgrade --install ${proj} ../charts/${proj}
    else
        echo "   ❌ don't know how to deploy ${proj}";
    fi
  
done

