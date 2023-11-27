#!/bin/bash
echo "source <(kubectl completion bash)" >>~/.bashrc # add autocomplete permaneently to your bash shell.
echo 'alias k=kubectl' >>~/.bashrc
echo 'complete -o default -F __start_kubectl k' >>~/.bashrc
source ~/.bashrc
