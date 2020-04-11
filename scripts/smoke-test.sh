echo 'Test secret encryption'
kubectl create secret generic kubernetes-the-hard-way --from-literal="mykey=mydata"
sleep 10
sudo ETCDCTL_API=3 /usr/local/bin/etcdctl get \
  --endpoints=https://127.0.0.1:2379 \
  --cacert=/etc/etcd/ca.pem \
  --cert=/etc/etcd/kubernetes.pem \
  --key=/etc/etcd/kubernetes-key.pem\
  /registry/secrets/default/kubernetes-the-hard-way | hexdump -C
kubectl run nginx --image=nginx
sleep 10
kubectl get pods -l run=nginx
#POD_NAME=$(kubectl get pods -l run=nginx -o jsonpath="{.items[0].metadata.name}")
#nohup kubectl port-forward $POD_NAME 8081:80 &
#curl --head http://127.0.0.1:8081
#sleep 10
POD_NAME=$(kubectl get pods -l run=nginx -o jsonpath="{.items[0].metadata.name}")
echo 'Test exec'
kubectl exec -ti $POD_NAME -- nginx -v
sleep 10
kubectl expose deployment nginx --port 80 --type NodePort
NODEPORT=$(kubectl get svc nginx -o jsonpath="{.spec.ports[0].nodePort}")
kubectl get svc
echo 'Test NodePort'
curl -I node01:$NODEPORT
sleep 2
curl -I node02:$NODEPORT
sleep 10
echo 'Test Logs'
kubectl logs $POD_NAME
sleep 2
echo 'Test Core DNS'
kubectl run busybox --image=busybox:1.28 --command -- sleep 3600
kubectl get pods
POD_NAME=$(kubectl get pods -l run=busybox -o jsonpath="{.items[0].metadata.name}")
sleep 10
kubectl exec -ti $POD_NAME -- nslookup kubernetes
sleep 2
echo 'Cleanup'
kubectl delete secret kubernetes-the-hard-way
kubectl delete svc nginx
kubectl delete deployment nginx
kubectl delete deployment busybox
