---
title:  "Docker Notes"
excerpt: "Common Docker terms and commands used in the CLI"
tags: "docker cp copy image container context"
---

## Notes

* Since docker requires elevated privileges, `sudo` is typically required when running these commands unless the current user has privileges.
* These commands are run on the Host system.
* Most commands support the `--help` flag and provide good documentation.

## Images

Think of it as the template, a Image include the instructions needed to create a Container. They are read-only (immutable), so can be easily shared, but can be additionally customized. Similar in concept to a Virtual Machine Snapshot.

There are public and private registries that contain Docker Images. [DockerHub](https://hub.docker.com/), for example, is a public registry maintained by Docker Inc.


| To | Command |
|-|-|
| List: | ``` docker image ls ``` |
| Start: | ``` docker run {repository-name} ```|
| Build: | `docker build -f /path/to/a/Dockerfile .` <br /><br />Or, if running from directory that has the Dockerfile:<br /> <br />`docker build -t {new-name} .` |

## Containers

Think of it as the running instance of an Image, a Container is a *runnable instance* of a Docker Image. 

Changes can be made while a Container is running but they won't persist, if needed, you can persist data by creating a named volume that is stored on the host [https://docs.docker.com/get-started/05_persisting_data/](https://docs.docker.com/get-started/05_persisting_data/). If changes are needed to the Image (for example, to add a webserver), you can create a new image from a container. 

Containers run in isolation by default, but containers on the same network can talk to each other with container networking [https://docs.docker.com/get-started/07_multi_container/](https://docs.docker.com/get-started/07_multi_container/)



| To | Command |
|-|-|
| List: | ``` docker container ls ``` |
| List Running: | ``` docker ps ``` |
| Start: | ``` docker run {container-id} ``` |
| Stop: | ``` docker stop {container-id} ``` |
| Delete: | ``` docker rm {container-id} ``` |
| Copy a File: | ``` docker cp [OPTIONS] {container-id}:{src-path} {dest-path} ``` |
| Run Command in Container: | ``` docker exec [OPTIONS] {container-id} {command} [ARG...] ``` <br /> ```docker exec -ti pop_container sh -c "echo Hello World!"``` |
| Create new Image from Container's changes: | ```docker commit {options} {container-id} ```|

## Contexts

Contexts allow a single Docker CLI to manage multiple Docker nodes, Kubernetes clusters, etc.

| To | Command |
|-|-|
| List: | ``` docker context ls ``` |
| Inspect Current: | ``` docker context inspect ``` |
| Inspect Other: | ``` docker context inspect {context-name}``` |
| Create: | ``` docker context create ``` |
| Delete: | ``` docker context rm {context-name}``` |
| Switch: | ``` docker context use {context-name} ``` |
| Export: | ``` docker context export {context-name} ``` <br /><br />Kubernetes: <br />``` docker context export {context-name} --kubeconfig ``` |
| Import (not for Kubernetes): | ``` docker context import {context-name} {filename} ``` <br/><br/>Won't work for Kubernetes, instead, merge with existing `~/.kube/config` file |
| Update: | ```docker context update {context-name} {--flag} {"text"}``` <br /><br />Flags: <br /> *--default-stack-orchestrator* <br /> *--description* <br />*--docker* <br /> *--kubernetes*|

