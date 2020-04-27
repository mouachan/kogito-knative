#build and push to quay native image v1
./mvnw quarkus:add-extension -Dextensions="container-image-docker"
./mvnw clean package -Dquarkus.container-image.build=true  -Dquarkus.container-image.name=frequent-flyer -Dquarkus.container-image.tag=native-1.0 -Pnative -Dquarkus.native.container-build=true  
docker run -i --rm -p 8080:8080 mouachani/frequent-flyer:native-1.0 
docker commit 854ec454c3e2 quay.io/mouachan/frequent-flyer:native-1.0
docker push quay.io/mouachan/frequent-flyer:native-1.0

#build native image v2
./mvnw quarkus:add-extension -Dextensions="container-image-docker"
./mvnw clean package -Dquarkus.container-image.build=true  -Dquarkus.container-image.name=frequent-flyer -Dquarkus.container-image.tag=native-2.0 -Pnative -Dquarkus.native.container-build=true  
docker run -i --rm -p 8080:8080 mouachani/frequent-flyer:native-2.0 
docker commit 4fdf77ff491e quay.io/mouachan/frequent-flyer:native-2.0
docker push quay.io/mouachan/frequent-flyer:native-2.0
