build:
	cd rate-limit-filter && cargo +nightly build --target=wasm32-unknown-unknown --release 

deploy:
	docker-compose up --build --remove-orphans

# shows only the logs related to WASM filter/singleton 
deploy-filtered:
	docker-compose up --build --remove-orphans | grep "\[wasm\]\|Starting"

run: build deploy

run-filtered: build deploy-filtered

clean:
	cargo clean

build-web:
	cd web && docker build -t kanishkarj/dockercon-2020-web:latest .

build-api:
	cd api && docker build -t kanishkarj/dockercon-2020-api:latest .

build-envoy: build
	cp rate-limit-filter/target/wasm32-unknown-unknown/release/rate_limit_filter.wasm envoy/rate_limit_filter.wasm
	cd envoy && docker build -t kanishkarj/envoy-wasm-filter:latest .

dev-run-api: build-api deploy

dev-run-web: 
	cd web && yarn serve
	
cache-add:
	minikube cache add nicholasjackson/consul-envoy:dev-dev
	minikube cache add nicholasjackson/consul-k8s-dev:dev
	minikube cache add nicholasjackson/example-wasm-filter:dev
	minikube cache add layer5io/dockercon-2020-api:dev
	minikube cache add layer5io/dockercon-2020-web:dev

cache-delete:
	minikube cache delete nicholasjackson/consul-envoy:dev-dev
	minikube cache delete nicholasjackson/consul-k8s-dev:dev
	minikube cache delete nicholasjackson/example-wasm-filter:dev
	minikube cache delete layer5io/dockercon-2020-api:dev
	minikube cache delete layer5io/dockercon-2020-web:dev
	
images-push:
	docker push kanishkarj/dockercon-2020-web:latest
	docker push kanishkarj/dockercon-2020-api:latest
	docker push kanishkarj/envoy-wasm-filter:latest