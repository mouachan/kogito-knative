

![Ouachani Logo](/img/logo.png) 

# kogito-knative demo

## Goal

This demo uses Quarkus, Kogito and Knative, it aims to :
- create a discount service for a traveler, a dmn rule will calculate a ticket discount depending on the status and the destination city 
- build and push 2 natives images versions on an external registry (Quay) 
- deploy 2 versions of a servless application on Openshift, apply a 50% routing

## Business Rules
DMN Discount Business Decision Service
![DMN decision service 1](/img/dmn_decision_service.png) 
DMN Decision Table V1
![DMN version 1](/img/dmn_decision_table_v1.png) 

DMN Decision Table V2
![DMN version 2](/img/dmn_decision_table_v2.png) 

## Prerequesties 
Install :
- oc client
- knative client (kn)
- Openshift serverless operator from the operatorhub on your Openshift cluster

## Create a registry secret

```
oc create secret docker-registry quay-secret \
    --docker-server=quay.io/username \
    --docker-username=username \
    --docker-password=password\
    --docker-email=email

oc secrets link builder quay-secret
oc secrets link default quay-secret --for=pull
```

## Clone the source from github

```
git clone https://github.com/mouachan/kogito-knative
```

## Checkout frequent-flyer-v1 brnach

```
git checkout frequent-flyer-v1
```

## Build and generate native container image

```
./mvnw clean package  -Dquarkus.container-image.build=true -Dquarkus.container-image.name=ff-discount-svc -Dquarkus.container-image.tag=native-1.0 -Pnative  -Dquarkus.native.container-build=true 

```

## Push the image to your registry (change the username by yours)

Make sure that you are connected to your images registry and create a repo named frequent-flyer
```
docker tag 'mouachan/ff-discount-svc:native-1.0 quay.io/mouachan/ff-discount-svc:native-1.0
docker push quay.io/mouachan/ff-discount-svc:native-1.0
```

## Apply the service v1

Connect to your openshift cluster and apply the service (it will create a new revision with version 2)
```
echo "apiVersion: serving.knative.dev/v1
kind: Service
metadata:
  name: ff-discount-svc-native
spec:
  template:
    metadata:
      name: ff-discount-svc-native-v1
    spec:
      containers:
        - image: >-
            quay.io/mouachan/ff-discount-svc:native-1.0
          env:
            - name: JAVA_OPTS
              value: "-Dvertx.cacheDirBase=/work/vertx"
      imagePullSecrets:
        - name: quay-secret" | oc apply -f -
```

## Clone the source from github

```
git clone https://github.com/mouachan/kogito-knative
```

## Checkout frequent-flyer v2 branch

```
git checkout frequent-flyer-v2
```

## Build and generate native container image

```
./mvnw clean package  -Dquarkus.container-image.build=true -Dquarkus.container-image.name=ff-discount-svc -Dquarkus.container-image.tag=native-2.0 -Pnative  -Dquarkus.native.container-build=true 

```
## Push the generated image to your registry (change the username by yours)

Make sure that you are connected to your registry hub and create a repo named 'frequent-flyer'

```
docker tag mouachan/ff-discount-svc:native-2.0 quay.io/mouachan/frequent-flyer/ff-discount-svc:native-2.0
docker push quay.io/mouachan/frequent-flyer/ff-discount-svc:native-1.0
```

## Apply the service v2

Connect to your openshift cluster and apply the service (it will create a new revision with image version 2)

```
echo "apiVersion: serving.knative.dev/v1
kind: Service
metadata:
  name: ff-discount-svc-native
spec:
  template:
    metadata:
      name: ff-discount-svc-native-v2
    spec:
      containers:
        - image: >-
            quay.io/mouachan/ff-discount-svc:native-2.0
          env:
            - name: JAVA_OPTS
              value: "-Dvertx.cacheDirBase=/work/vertx"
      imagePullSecrets:
        - name: quay-secret" | oc apply -f -
```

## Get the route

```
MacBook-Pro:kogito-knative mouachani$ kn route list
NAME                    URL                                                                  READY
frequent-flyer-native   http://ff-discount-svc-native.kogito-knative.apps.ocp4.ouachani.net   True 
```

## Apply 50% routing for each service from Openshift console 
![Routing](/img/routing.png)

## Verify that the routing is 50% 

Depending on the service routing you will have one of the below results,  using this input data : `{\"Status\":\"Silver\",\"From\":\"Paris\",\"To\":\"New York\"}`

**_"Discount": 20_**
```
MacBook-Pro:kogito-knative mouachani$ curl -X POST http://ff-discount-svc-native.kogito-knative.apps.ocp4.ouachani.net/frequent_discount -H "accept: application/json" -H "Content-Type: application/json" -d "{\"Status\":\"Silver\",\"From\":\"Paris\",\"To\":\"New York\"}"

{
  "Status": "Silver",
  "Discount": 20,
  "From": "Paris",
  "To": "New York"
}
```

**_"Discount": 40_**
```
MacBook-Pro:kogito-knative mouachani$ curl -X POST http://ff-discount-svc-native.kogito-knative.apps.ocp4.ouachani.net/frequent_discount -H "accept: application/json" -H "Content-Type: application/json" -d "{\"Status\":\"Silver\",\"From\":\"Paris\",\"To\":\"New York\"}"

{
  "Status": "Silver",
  "Discount": 40,
  "From": "Paris",
  "To": "New York"
}
```


#for i in {1..20}; do sleep 1 ;  curl -X POST http://frequent-flyer-native.kogito-knative.apps.ocp4.ouachani.net/frequent_discount -H "accept: application/json" -H "Content-Type: application/json" -d "{\"Status\":\"Silver\",\"From\":\"Paris\",\"To\":\"New York\"}";done