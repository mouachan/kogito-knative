
#build and push to quay java image v1
./mvnw clean package  -Dquarkus.container-image.build=true -Dquarkus.container-image.name=frequent-flyer -Dquarkus.container-image.tag=java-1.0  -Dquarkus.native.container-build=true 
docker tag mouachani/frequent-flyer:java-1.0 quay.io/mouachan/frequent-flyer:java-1.0
docker push quay.io/mouachan/frequent-flyer:java-1.0
oc apply -f manifest/frequent-flyer-service-java-v1.yml 

#build and push to quay java image v2
./mvnw clean package  -Dquarkus.container-image.build=true -Dquarkus.container-image.name=frequent-flyer -Dquarkus.container-image.tag=java-2.0  -Dquarkus.native.container-build=true 
docker tag mouachani/frequent-flyer:java-2.0 quay.io/mouachan/frequent-flyer:java-2.0
docker push quay.io/mouachan/frequent-flyer:java-2.0
oc apply -f manifest/frequent-flyer-service-java-v2.yml 
#build and push to quay native image v1
./mvnw clean package  -Dquarkus.container-image.build=true -Dquarkus.container-image.name=frequent-flyer -Dquarkus.container-image.tag=native-1.0 -Pnative  -Dquarkus.native.container-build=true 
docker tag mouachani/frequent-flyer:native-1.0 quay.io/mouachan/frequent-flyer:native-1.0
docker push quay.io/mouachan/frequent-flyer:native-1.0
oc apply -f manifest/frequent-flyer-service-native-v1.yml 

#build native image v2
./mvnw clean package -Dquarkus.container-image.build=true  -Dquarkus.container-image.name=frequent-flyer -Dquarkus.container-image.tag=native-2.0 -Pnative -Dquarkus.native.container-build=true  
docker tag mouachani/frequent-flyer:native-2.0 quay.io/mouachan/frequent-flyer:native-2.0
docker push quay.io/mouachan/frequent-flyer:native-2.0
oc apply -f manifest/frequent-flyer-service-native-v2.yml 



    oc secrets link builder quay-secret
    oc secrets link default quay-secret --for=pull


    curltime -X POST "http://frequent-flyer-native.kogito-knative.apps.ocp4.ouachani.net/frequent_score" --data '{"Score":700, "Status":"Silver"}' 

    curl -X POST "http://native-v2-frequent-flyer-native.kogito-knative.apps.ocp4.ouachani.net/frequent_score" --data '{"Score":700, "Status":"Silver"}' 


    curl -X POST http://frequent-flyer-java.kogito-knative.apps.ocp4.ouachani.net/frequent_score --data '{"Score":700, "Status":"Silver"}' 


./manifest/curltime  -X POST "http://frequent-flyer-java.kogito-knative.apps.ocp4.ouachani.net/frequent_score" -H "accept: application/json" -H "Content-Type: application/json" -d "{\"Score\":700,\"Status\":\"Silver\"}"

curl -X POST "http://frequent-flyer-java.kogito-knative.apps.ocp4.ouachani.net/frequent_score" -H "accept: application/json" -H "Content-Type: application/json" -d "{\"Score\":700,\"Status\":\"Silver\"}"

curl -X POST "http://localhost:8090/frequent_score" -H "accept: application/json" -H "Content-Type: application/json" -d "{\"Score\":700,\"Status\":\"Silver\"}"

curl -X POST --header 'Content-Type: application/json' --header 'Accept: application/json' -d '{ "model-namespace" : "https://kiegroup.org/dmn/_BA94EDFD-79C3-49C4-80D6-D96462F9BA2C", "model-name" : "frequent_score", "decision-name" : [ ], "decision-id" : [ ], "dmn-context" : {"Score":700,"Status":"Silver"}}' 'http://localhost:8090/rest/server/containers/frequent-flyer-sb-kjar-1_0-SNAPSHOT/dmn'


curl -X POST http://frequent-flyer-native.kogito-knative.apps.ocp4.ouachani.net/frequent_score -H "accept: application/json" -H "Content-Type: application/json" -d "{\"Score\":700,\"Status\":\"Silver\"}"

