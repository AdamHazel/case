workspace "Race Results Platform" "C4 model for a scalable race result platform hosted in Azure" {

    model {

        publicUser = person "Public User" "Views race results."

        administrator = person "Administrator" "Manages races, tracks, and participants."

        cameraSystem = softwareSystem "Race Camera System" "Detects participant numbers and sends race result events."

        entra = softwareSystem "Microsoft Entra External ID" "External identity provider used for administrator authentication."

        racePlatform = softwareSystem "Race Results Platform" "Publishes race results and manages race administration." {

            edgeRouting = container "Edge Routing & CDN" "Routes public traffic and caches static assets/result documents." "Azure Front Door"

            publicResultsWebApp = container "Public Results Web App" "Static frontend used to view race results." "React + Azure Static Web Apps"

            publicResultStore = container "Public Result Store" "Stores generated JSON result documents for fast public retrieval." "Azure Blob Storage"

            resultExportFunction = container "Result Export Function" "Reads race data and generates public result documents." "Azure Function"

            raceDatabase = container "Race Database" "Stores races, tracks, participants, and official results." "Azure SQL Database"

            adminWebApp = container "Admin Web App" "Static frontend used by administrators to manage race data." "React + Azure Static Web Apps"

            adminBackend = container "Admin Backend" "Provides endpoints for managing races, tracks, and participants." ".NET Web App + Azure App Service" {

                apiRequestHandlers = component "API Request Handlers" "Handles HTTPS requests from the Admin Web App and exposes admin endpoints." "ASP.NET Core Web API"

                domainLayer = component "Domain Layer" "Defines domain models, interfaces, and contracts for race administration." ".NET Class Library"

                persistenceLayer = component "Persistence Layer" "Implements database access and modifies race, track, and participant data." ".NET Class Library + Entity Framework Core"
            }

            resultQueue = container "Result Queue" "Receives result messages from the camera system for asynchronous processing." "Azure Service Bus Queue"

            resultWorker = container "Result Worker" "Processes queued result messages and stores valid results." ".NET Background Service + Azure App Service"
        }

        publicUser -> edgeRouting "Accesses public results" "HTTPS"
        edgeRouting -> publicResultsWebApp "Serves static frontend" "HTTPS"
        publicResultsWebApp -> edgeRouting "Fetches result documents" "HTTPS"
        edgeRouting -> publicResultStore "Routes and caches result document requests" "HTTPS"

        administrator -> adminWebApp "Uses admin interface" "HTTPS"
        adminWebApp -> entra "Authenticates administrator" "OpenID Connect / OAuth2"
        adminWebApp -> adminBackend "Calls race and participant endpoints" "HTTPS"
        adminBackend -> entra "Validates access tokens" "OpenID Connect / OAuth2"
        adminBackend -> raceDatabase "Reads and modifies race, track, and participant data" "SQL"

        cameraSystem -> resultQueue "Adds result messages" "HTTPS"
        resultWorker -> resultQueue "Consumes result messages"
        resultWorker -> raceDatabase "Stores validated race results" "SQL"

        resultExportFunction -> raceDatabase "Reads official results" "SQL"
        resultExportFunction -> publicResultStore "Updates generated JSON result documents" "HTTPS"

        publicUser -> racePlatform "Views race results" "HTTPS"
        administrator -> racePlatform "Manages races, tracks, and participants" "HTTPS"
        cameraSystem -> racePlatform "Sends race result events" "HTTPS"
        racePlatform -> entra "Authenticates administrators using OpenID Connect / OAuth2" "HTTPS"

        adminWebApp -> apiRequestHandlers "Calls admin endpoints" "HTTPS"
        apiRequestHandlers -> entra "Validates administrator access tokens" "OpenID Connect / OAuth2"
        apiRequestHandlers -> domainLayer "Uses domain models and interfaces"
        apiRequestHandlers -> persistenceLayer "Uses persistence services"
        persistenceLayer -> domainLayer "Implements domain interfaces"
        persistenceLayer -> raceDatabase "Reads and modifies race, track, and participant data" "SQL"
    }

    views {

        systemContext racePlatform "SystemContext" {
            include racePlatform
            include publicUser
            include administrator
            include cameraSystem
            include entra

            autolayout lr
        }

        container racePlatform "Containers" {
            include publicUser
            include administrator
            include cameraSystem
            include entra

            include edgeRouting
            include publicResultsWebApp
            include publicResultStore
            include resultExportFunction
            include raceDatabase
            include adminWebApp
            include adminBackend
            include resultQueue
            include resultWorker

            autolayout tb
        }

        component adminBackend "AdminBackendComponents" {
            include adminWebApp
            include entra
            include apiRequestHandlers
            include domainLayer
            include persistenceLayer
            include raceDatabase

            autolayout tb
        }

        theme default
    }
}