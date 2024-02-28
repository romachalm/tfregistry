NAMESPACE := tfregistry

validate:
	helm template test . -n ${NAMESPACE} --debug -f values-test.yaml  > rendered.yaml

dependency:
	helm dependency update .
