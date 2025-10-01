# ServiceExample

This service sample demonstrates how to use .NET Web API service with:
* NATS messaging (sending and receiving messages)
* HTTP endpoint with OpenAPI/Swagger documentation
* Redis cache for list requests
* MongoDB for data storage

Service sends and receives person messages using NATS messaging system, stores them in MongoDB, and caches list requests in Redis for improved performance.