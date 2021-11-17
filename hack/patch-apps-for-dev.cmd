
@echo off
git config --get remote.origin.url >remote.url

set /P GITURLQ=< remote.url
del remote.url
Set GITURL=%GITURLQ:"=%

echo %GITURL%
 
set PATCH="{\"spec\":{\"source\": {\"repoURL\": \"%GITURL%\"}}}" --type=merge
echo %PATCH%
kubectl patch applications/all-components-staging -n openshift-gitops -p %PATCH%

set PATCH="{\"spec\":{\"source\": {\"path\": \"argo-cd-apps/overlays/jduimovich\"}}}" --type=merge
echo %PATCH%
kubectl patch applications/all-components-staging -n openshift-gitops -p %PATCH%
  