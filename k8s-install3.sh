
#!/bin/sh


#oar_jobID=956101
nodes="$HOME/node.txt"

#oarsub -C $oar_jobID  &

cat $OAR_NODE_FILE | sort -u > $nodes

master=`head -1 $nodes`
nb_nodes=`wc -l $nodes  | awk {'print $1'}`
nb_workers=`expr $nb_nodes - 1`
workers=`tail -$nb_workers $nodes`



RED=`tput setaf 1`
GREEN=`tput setaf 2`
reset=`tput sgr0`
scp install-pkg.sh  root@$master:
ssh root@$master  sh install-pkg.sh  


scp    kubelet.sh    root@$master:
scp    helm-install.sh   root@$master:
scp    master-config.sh  root@$master:
#scp    fission-update/go.sh      root@$master:
scp     reset-config.sh        root@$master:


ssh root@$master  sh kubelet.sh  
#ssh root@$master  sh docker.sh  

#ssh root@$master  apt-get update && apt-get install -y kubelet=1.11.0-00 kubeadm=1.11.0-00 kubectl=1.11.0-00 kubernetes-cni=0.6.0-00 

echo ".......Running on the master node......."
ssh root@$master  sh reset-config.sh

echo "Initialing the master node..."

tok=$( ssh root@$master kubeadm init   --kubernetes-version stable-1.19 --pod-network-cidr=10.244.0.0/16  | grep -A 2 "kubeadm join" | tr -d \\ )

echo $tok

ssh root@$master sh master-config.sh
#ssh root@$master  sh docker.sh  
#ssh root@$master  sh helm-install.sh   


echo ".......Cluster Information......"
ssh root@$master kubectl get nodes


for worker in $workers; do 
scp install-pkg.sh  root@$worker:
#scp    docker.sh    root@$worker:

#ssh root@$worker  sh install-pkg.sh  


scp kubelet.sh    root@$worker:
scp reset-config.sh   root@$worker:

echo ".......Running on  wrk  node ......."
ssh root@$worker  sh install-pkg.sh 
ssh root@$worker  sh kubelet.sh 
#ssh root@$worker  sh docker.sh  
ssh root@$worker  sh reset-config.sh 


#ssh root@$worker  apt-get update && apt-get install -y kubelet=1.11.0-00 kubeadm=1.11.0-00 kubectl=1.11.0-00 kubernetes-cni=0.6.0-00 
 

echo "Worker joining the cluster..."
ssh root@$worker $tok 
done

echo ".......Cluster Information......"
ssh root@$master kubectl get nodes

if [ $? -eq 0 ]
then
    echo "${GREEN}Cluster validation succeeded${reset}"
    else
    echo "${RED}Cluster validation encountered some problems${reset} "
    fi

scp /home/yabouizem/fission-update/app/deploy.yaml   root@$master:
scp /home/yabouizem/k8s-experiments1/fission-app/fibonacci.py  root@$master:

ssh root@$master sh go.sh
ssh root@$master sh helm-install.sh
#to install fission  AS
scp -r   work-1.10.1/  root@$master:

#scp -r   work-1.5.9-ListPod/  root@$master:
#to install fission vanilla

#scp -r   work-1.12.1/  root@$master:
#scp -r /home/yabouizem/fission-update/scripts/failure-scripts  root@$master:
scp -r /home/yabouizem/monitoring-tools/heapster/deploy/kube-config   root@$master:
scp -r /home/yabouizem/monitoring-tools/heapster.sh   root@$master:

ssh root@$master  sh heapster.sh 

ssh root@$master mv  work-1.10.1 work 
#ssh root@$master cd work/src/github/fission/fission  && 



echo ".......Cluster Information......"
#ssh root@$master kubectl label node $secondnode disktype=ssd
#ssh root@$master  kubectl patch node $lastnode1 -p '{"spec":{"unschedulable":true}}'
#ssh root@$master  kubectl patch node $lastnode2 -p '{"spec":{"unschedulable":true}}'


