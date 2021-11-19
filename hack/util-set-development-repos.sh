
#!/bin/bash

# Redirect the root app-of-apps to the users local git repo (usually a fork)
# if that repo is a simple clone this replacement is a noop
# if that repo is a fork, this repo will updated to the forked repo

# This allows any component to be replaced via gitops via a kustomize base development directory
# That directory needs to be modified in the users fork to replace replacing any components in their cluster
# This will minimize the chance of error in pull requests to upstream which may accidentally include
# references to the forked repo.
# note, if accidental merges are accepted in the development directory, they will not affect staging. 

ROOT="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"/..
MANIFEST=$ROOT/argo-cd-apps/app-of-apps/all-applications-staging.yaml
GITURL=$1
OVERLAYDIR=argo-cd-apps/overlays/$2

PATCHREPO="$(printf '.spec.source.repoURL="%q"' $GITURL)" 
PATCHOVERLAY="$(printf '.spec.source.path="%q"' $OVERLAYDIR)"  

# this can be a single apply but I think we should move the repo name update into the bootstrap-cluster.sh script
# yq  e "$PATCHOVERLAY" $MANIFEST | yq  e "$PATCHREPO" - | kubectl apply -f -

# the directory path and content can be updated selectively per user in their fork
# that to replace the specific component they are evolving 

# 2 kubectl apply for later refactoring 
echo
echo "Setting the root application to come from $GITURL"
yq  e "$PATCHREPO" $MANIFEST | kubectl apply -f -
echo "Setting the overlay directory to $OVERLAYDIR" 
yq  e "$PATCHOVERLAY" $MANIFEST | kubectl apply -f -

# this section only gets run when setting the directory to development
# as the development overlay uses kustomize to set override default repos

echo
echo In dev mode, verify that argo-cd-apps/overlays/development includes a kustomization that points to this repo
echo If you want to reset to the default upstream run the upstream-mode.sh script  

PATCH="$(printf '.spec.source.repoURL="%q"' $GITURL)" 
yq  e "$PATCH" $OVERLAYDIR/repo-overlay.yaml -i 

echo
echo The list of components which will be patched is
yq  e '.metadata.name' $OVERLAYDIR/repo-overlay.yaml

echo
echo Each component above is set to the following repositories
echo if you do not see your component in the list, please send a PR update to $OVERLAYDIR/repo-overlay.yaml
yq  e '.spec.source.repoURL' $OVERLAYDIR/repo-overlay.yaml