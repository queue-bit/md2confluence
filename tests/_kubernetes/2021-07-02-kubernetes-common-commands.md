---
title:  "Kubernetes Notes"
excerpt: "Common kubernetes terms and commands used in the CLI"
tags: "kubernetes"
---

## Notes

* 

## Namespaces

> "An abstraction used by Kubernetes to support multiple virtual clusters on the same physical cluster."  
\- *[kubernetes.io/docs/reference/glossary/](https://kubernetes.io/docs/reference/glossary/?fundamental=true)*

| To | Command | Example |
|-|-|-|
| List Namespaces: | ``` kubectl get namespaces ``` | ``` kubectl get namespaces ``` |
| | ```kubectl get ns``` | ```kubectl get ns``` |
| Describe Namespace: | ``` kubectl describe ns <namespace> ``` | ``` kubectl describe ns kube-system ``` |
| Change Namespace you're working on: | ``` kubectl config set-context --current --namespace=<namespace> ``` | ``` kubectl config set-context --current --namespace=kube-system ``` |

## Services

> "An abstract way to expose an application running on a set of Pods as a network service."  
\- *[kubernetes.io/docs/reference/glossary/](https://kubernetes.io/docs/reference/glossary/?fundamental=true)*


| To | Command | Example |
|-|-|-|
| List Services: | ``` kubectl get services -n <namespace> ``` | ``` kubectl get services -n kube-system ``` |

## Pods

> "The smallest and simplest Kubernetes object. A Pod represents a set of running containers on your cluster."  
\- *[kubernetes.io/docs/reference/glossary/](https://kubernetes.io/docs/reference/glossary/?fundamental=true)*

| To | Command | Example |
|-|-|-|
| List Pods in Namespace: | ``` kubectl get pods -n <namespace> ``` | ``` kubectl get pods -n kube-system ``` |
| List all Pods: | ``` kubectl get pods --all-namespaces  ``` | ``` kubectl get pods --all-namespaces  ```|
| Describe Pods: | ``` kubectl describe pods ``` | ``` kubectl describe pods ``` |
| Describe Pod: | ``` kubectl describe pod <podname> -n <namespace> ``` | ``` kubectl describe pod kube-proxy -n kube-system``` |
| Show Pod Manifests: | ``` kubectl explain pods ``` | ``` kubectl explain pods ``` |
| Shell into Pod: | ``` kubectl exec -it <podname> -n <namespace> /bin/bash``` | ``` kubectl exec -it kube-proxy -n kube-system /bin/bash``` |
| Shell into specific Container: | ```kubectl exec -it <podname> -c <containername> /bin/bash ``` | |
| Delete Pod using file: | ``` kubectl delete -f <filename> ``` | ```kubectl delete -f mypod.yaml``` |
| Delete Pod(s) using label: | ``` kubectl delete pods -l <labelkey>=<label-value> ``` | ``` kubectl delete pods -l environment=dev ``` |
| Delete ALL Pods: | ``` kubectl delete pods --all ``` | ``` kubectl delete pods --all ``` |
| Issue Command to Pod: | ``` kubectl exec <podname> -- <command> ``` | ```  ``` |
| Get Output from Command Run on Specific Container in a Pod: | ``` kubectl exec <podname> -c <containername> -- <command> ``` | ```  ``` |
| Get Logs | ``` kubectl logs <podname>  ``` | ``` kubectl logs kube-proxy ``` |
| | ``` kubectl logs --tail=<lines> <podname> ``` | ``` kubectl logs --tail=20 nginx ``` |

## Containers

> "A lightweight and portable executable image that contains software and all of its dependencies."  
\- *[kubernetes.io/docs/reference/glossary/](https://kubernetes.io/docs/reference/glossary/?fundamental=true)*

| To | Command | Example |
|-|-|-|
| List Containers in a Pod: | ```kubectl get pod <podname> -o jsonpath='{.spec.containers[*].name}{"\n"}'``` | ```kubectl get pod kube-proxy -o jsonpath='{.spec.containers[*].name}{"\n"}' ```|
| | ```  ``` | ```  ``` |
| | ```  ``` | ```  ``` |

## Deployments

> "An API object that manages a replicated application, typically by running Pods with no local state."  
\- *[kubernetes.io/docs/reference/glossary/](https://kubernetes.io/docs/reference/glossary/?fundamental=true)*

| To | Command | Example |
|-|-|-|
| List Deployments: | ``` kubectl get deployments -n <namespace> ``` | ``` kubectl get deployments -n kube-system ``` |
| | ```   ``` | ```  ``` |
| | ```  ``` | ```  ``` |

## Nodes

> Node: A worker machine, either virtual or physical machine.

| To | Command | Example |
|-|-|-|
| List Nodes: | ```kubectl get node``` | ```kubectl get node``` |
| Describe Node: | ``` kubectl describe node <nodename> ``` | ```  ``` |
| Get External IP's of all Nodes: | ``` kubectl get nodes -o jsonpath='{.items[*].status.addresses[?(@.type=="ExternalIP")].address}' ``` | ``` kubectl get nodes -o jsonpath='{.items[*].status.addresses[?(@.type=="ExternalIP")].address}' ``` |
| | ```  ``` | ```  ``` |
| | ```  ``` | ```  ``` |
| | ```  ``` | ```  ``` |

## Persistent Volumes

> "An API object that represents a piece of storage in the cluster. Available as a general, pluggable resource that persists beyond the lifecycle of any individual Pod."  
\- *[kubernetes.io/docs/reference/glossary/](https://kubernetes.io/docs/reference/glossary/?core-object=true)*

| To | Command | Example |
|-|-|-|
| List Persistent Volumes: | ```kubectl get pv``` | ```kubectl get pv``` |
| | ```  ``` | ```  ``` |
| | ```  ``` | ```  ``` |

## ConfigMaps

> "An API object used to store non-confidential data in key-value pairs. Pods can consume ConfigMaps as environment variables, command-line arguments, or as configuration files in a volume."  
\- *[kubernetes.io/docs/reference/glossary/](https://kubernetes.io/docs/reference/glossary/?core-object=true)*


| To | Command | Example |
|-|-|-|
| List ConfigMaps: | ``` kubectl get configmaps ``` | ``` kubectl get configmaps ``` |
| Describe ConfigMap: | ``` kubectl describe configmaps <configmapname> ``` | ``` kubectl describe configmaps myconfigmap ``` |
| Describe ConfigMap in yaml: | ``` kubectl describe configmaps <configmapname> -o yaml``` | ``` kubectl describe configmaps myconfigmap -o yaml ``` |
| Create ConfigMap from file: | ``` kubectl create configmap <configmapname> –from-file=<file> ``` | ```  kubectl create configmap myconfigmap --from-file=path/file.name ``` |
| Create ConfigMap from directory: | ``` kubectl create configmap <configmapname> –from-file=<directory> ``` | ``` kubectl create configmap myconfigmap --from-file=mydirectorypath ``` |
| Create ConfigMap from literals: | ``` kubectl create configmap <configmapname> –from-literal=<key>=<value> –from-literal=<key>=<value> ``` | ``` kubectl create configmap myconfigmap --from-literal=admin=root --from-literal=stage.user=frank.grimes ``` |
| | ```  ``` | ```  ``` |
| | ```  ``` | ```  ``` |

kubectl proxy

# References

- [kubernetes.io](https://kubernetes.io)
    - [Cheatsheet](https://kubernetes.io/docs/reference/kubectl/cheatsheet/)
    - [Kubectl Commands](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands)
- [shellhacks.com](https://www.shellhacks.com)
    - [Kubectl: Get Services](https://www.shellhacks.com/kubectl-get-services-kubernetes/)
    - [List & Change Namespace](https://www.shellhacks.com/kubectl-list-change-namespaces-kubernetes/)
- [mankier.com: kubectl-get](https://www.mankier.com/1/kubectl-get)
- [phoenixnap.com: kubectl commands cheat sheet](https://phoenixnap.com/kb/kubectl-commands-cheat-sheet)
