DOCKER_REPOSITORY?=docker.io
DOCKER_IMAGE?=kong/python
DOCKER_TAG?=latest

venv:
	python3 -m venv .venv

install: venv
	.venv/bin/pip install -r requirements.txt

clean:
	kind delete cluster
	rm -rf .venv

docker/push: docker/build
	docker push ${DOCKER_REPOSITORY}/${DOCKER_IMAGE}:${DOCKER_TAG}

docker/build:
	docker build -t ${DOCKER_REPOSITORY}/${DOCKER_IMAGE}:${DOCKER_TAG} .

develop:
	./charts/kind.sh
	DOCKER_REPOSITORY=localhost:5000 DOCKER_TAG=local make docker/push
	kubectl wait -n kube-system --for=condition=ready pod --selector=tier=control-plane
	helm install -f charts/values-dev.yaml -f charts/values-local.yaml local-python ./charts/

develop/upgrade:
	helm upgrade -f charts/values-dev.yaml -f charts/values-local.yaml local-python ./charts/
