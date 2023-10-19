echo "***********************************************************************"
echo "Node Compute"
echo "***********************************************************************"
kubectl get nodes --no-headers | awk '{print $1}' | xargs -I {} sh -c 'echo {}; kubectl describe node {} | grep Allocated -A 5 | grep -ve Event -ve Allocated -ve percent -ve -- ; echo'

echo "***********************************************************************"
echo "Pod Compute"
echo "***********************************************************************"
kubectl top pod --all-namespaces

echo "***********************************************************************"
echo "Pod Autoscale"
echo "***********************************************************************"
kubectl get hpa --all-namespaces
