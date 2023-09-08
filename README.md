# xp-flux-removal

When employing Flux as a GitOps tool, we have the option to prevent accidental removal or garbage collection by using the annotation `kustomize.toolkit.fluxcd.io/prune: disabled`. We can apply this annotation to essential objects like namespaces, XRDs, and CRDs. For more check Flux Documentation https://fluxcd.io/flux/components/kustomize/kustomizations/#prune


## tests

In our test cases, we aim to demonstrate that deleting a CRD or XRD will result in the removal of all managed resources associated with a deployed claim or composite. To prevent GitOps systems like Flux from accidentally removing these resources, using the annotations we've mentioned is a wise choice.

## test-case 1

In this test case, we aim to setup an XRD and composition, create a claim, wait for the managed resource to be created, and then delete the CRDs. The result would be for Crossplane to remove all managed resources linked to the composite and claim.

### execute
```bash
kubectl apply -f apis/
kubectl apply -f examples/
sleep 30
kubectl get managed
kubectl delete crds testobjects.test.haarchri.io  xtestobjects.test.haarchri.io 
kubectl get managed
```

### output
```bash
composition.apiextensions.crossplane.io/xtestobjects.test.haarchri.io created
compositeresourcedefinition.apiextensions.crossplane.io/xtestobjects.test.haarchri.io created
testobject.test.haarchri.io/test-conversion created
NAME                          READY   SYNCED   EXTERNAL-NAME         AGE
test-conversion-pr2xv-htpqw   True    True     7024500145830237848   30s
customresourcedefinition.apiextensions.k8s.io "testobjects.test.haarchri.io" deleted
customresourcedefinition.apiextensions.k8s.io "xtestobjects.test.haarchri.io" deleted
No resources found
```

all managed resources have been removed.

## test-case 2

In this test case, we aim to setup an XRD and composition, create a claim, wait for the managed resource to be created, and then delete the XRD. The result would be for Crossplane to remove all managed resources linked to the composite and claim.

### execute
```bash
kubectl apply -f apis/
kubectl apply -f examples/
sleep 30
kubectl get managed
kubectl delete -f apis/definition.yaml
sleep 30
kubectl get managed
```

### output
```bash
composition.apiextensions.crossplane.io/xtestobjects.test.haarchri.io created
compositeresourcedefinition.apiextensions.crossplane.io/xtestobjects.test.haarchri.io created
testobject.test.haarchri.io/test-conversion created
NAME                          READY   SYNCED   EXTERNAL-NAME         AGE
test-conversion-9kvcr-dxfql   True    True     5534450267510906465   31s
compositeresourcedefinition.apiextensions.crossplane.io "xtestobjects.test.haarchri.io" deleted
No resources found
```
all managed resources have been removed.