workspace "TestApplication" "C4 model for TestApplication." {

    !identifiers hierarchical

    model {

        researcher = person "Researcher" "Carries out the experiment using the application."

        smtpServer = softwareSystem "SmtpServer" "External SMTP SaaS service provided through Google."
        ollama = softwareSystem "OllamaLlmInstance" "External Ollama LLM instance hosted in a Kubernetes cluster."
        authSystem = softwareSystem "AuthenticationSystem" "External authentication SaaS provider used for researcher login and JWT validation."

        app = softwareSystem "TestApplication" "Experiment support system for running LLM estimation tests against user stories." {

            database = container "PostgreSqlDatabase" "Stores user story dataset, user stories selections, context selections, prompts, LLM model information, test round information, and test results." "PostgreSQL" {
                tags "Database"
            }

            restApi = container "RestApi" "Provides HTTP endpoints for triggering tests, managing prompt segments, reading results, and exporting experiment data through Scalar." ".NET / ASP.NET Core" {

                apiLayer = component "ApiLayer" "Handles HTTP requests from researchers, exposes endpoints through Scalar, and coordinates application operations." "ASP.NET Core Web API"

                domainLayer = component "DomainLayer" "Defines service interfaces used by the API layer, domain entities used by Persistence, and models used by Persistence for database migrations." "ASP.NET Core Class Library"

                persistenceLayer = component "PersistenceLayer" "Provides persistence-related services to the API layer, implements domain-defined interfaces, uses domain entities, and performs CRUD operations against the database through Entity Framework." "ASP.NET Core Class Library / Entity Framework Core"

                group "DomainLayerInternalCodeStructure" {

                    testQueueInterface = component "ITestQueue" "Defines queue operations for adding test rounds, reading queued test rounds, counting queued tests, and listing queue information." "C# Interface" {
                        tags "Code"
                    }

                    iTestRunner = component "ITestRunner" "Defines the operation used to execute queued test rounds." "C# Interface" {
                        tags "Code"
                    }
                }

                group "ApiLayerInternalCodeStructure" {

                    testController = component "TestController" "Validates test trigger requests, creates test items, and adds valid test rounds to the queue." "ASP.NET Core Controller" {
                        tags "Code"
                    }

                    testBackgroundWorker = component "TestBackgroundWorker" "Hosted BackgroundService that continuously reads queued test rounds and processes them sequentially." "ASP.NET Core BackgroundService" {
                        tags "Code"
                    }

                    testQueue = component "TestQueue" "Implements the test queue using a bounded .NET channel to store test rounds before they are processed." "C# Service" {
                        tags "Code"
                    }
                }

                group "PersistenceLayerInternalCodeStructure" {

                    runTestOperations = component "RunTestOperations" "Persistence Layer service that implements the test runner operation by orchestrating experiment setup, prompt construction, LLM calls, result handling, persistence, and failure notifications." "C# Service / Entity Framework Core" {
                        tags "Code"
                    }

                    applicationDbContext = component "ApplicationDbContext" "Entity Framework Core database context used to retrieve experiment data and persist test rounds and test results." "Entity Framework Core DbContext" {
                        tags "Code"
                    }

                    promptGeneration = component "PromptGeneration" "Builds structured chat requests by combining prompt templates, context stories, estimation strategies, system role messages, and model options." "Internal methods" {
                        tags "Code"
                    }

                    resultProcessing = component "ResultProcessing" "Parses LLM responses, extracts estimated minutes, creates test results, and persists completed or failed test rounds." "Internal methods" {
                        tags "Code"
                    }

                    emailService = component "EmailService" "Sends email notifications when test rounds or user story estimations fail." "C# Service" {
                        tags "Code"
                    }
                }

                apiLayer -> authSystem "Validates JWT tokens from HTTP requests such as test round triggers" "JWT/HTTP"

                apiLayer -> domainLayer "Uses service interfaces defined by" "C# project reference"

                apiLayer -> persistenceLayer "Calls services provided by" "C# method calls / dependency injection"

                persistenceLayer -> domainLayer "Implements service interfaces and uses domain entities/models from" "C# project reference"

                persistenceLayer -> database "Reads from and writes to" "Entity Framework Core / SQL"

                persistenceLayer -> smtpServer "Sends generated test failure emails through" "SMTP"

                persistenceLayer -> ollama "Sends generated prompts and receives user story estimations through" "HTTP/API"

                researcher -> testController "Sends test trigger requests to" "HTTP"

                testController -> testQueueInterface "Adds validated test rounds to" "C# method calls / dependency injection"

                testQueue -> testQueueInterface "Implements" "C# interface implementation"

                testBackgroundWorker -> testQueueInterface "Reads queued test rounds from" "C# method calls / dependency injection"

                testBackgroundWorker -> iTestRunner "Runs each queued test round through" "C# method calls / scoped dependency injection"

                runTestOperations -> iTestRunner "Implements" "C# interface implementation"

                runTestOperations -> applicationDbContext "Retrieves selections, prompts, LLM models, estimation strategies, and persists experiment data through" "Entity Framework Core"

                runTestOperations -> promptGeneration "Builds chat requests using" "C# method calls"

                promptGeneration -> applicationDbContext "Reads prompt and model information from" "Entity Framework Core"

                runTestOperations -> ollama "Sends generated chat requests and receives estimation responses through" "HTTP/API"

                runTestOperations -> resultProcessing "Parses responses and creates test results through" "C# method calls"

                resultProcessing -> applicationDbContext "Persists test rounds and test results through" "Entity Framework Core transaction"

                applicationDbContext -> database "Reads from and writes to" "Entity Framework Core / SQL"

                runTestOperations -> emailService "Sends failure notifications through" "C# method calls"

                emailService -> smtpServer "Sends emails through" "SMTP"
            }
        }

        researcher -> app "Uses to carry out the experiment" "HTTP"

        researcher -> app.restApi "Uses through Scalar and sends HTTP requests to" "HTTP"

        researcher -> authSystem "Authenticates with and receives JWT tokens from" "HTTP/JWT"

        deploymentEnvironment "ExperimentExecutionEnvironment" {

            deploymentNode "UiA Internal Network" {

                deploymentNode "UiA Virtual Machine" "Linux VM hosted on UiA infrastructure" {

                    deploymentNode "Docker Compose" "Docker Compose runtime environment" {

                        deploymentNode "RestApiContainer" "Docker container running the ASP.NET Core REST API" {

                            containerInstance app.restApi
                        }

                        deploymentNode "PostgreSqlContainer" "Docker container running PostgreSQL with persistent Docker volume storage" {

                            containerInstance app.database

                            infrastructureNode "PostgreSqlDockerVolume" "Persistent Docker volume for PostgreSQL data"
                        }
                    }
                }

                deploymentNode "Kubernetes Cluster" "Kubernetes v1.32.7 cluster managed through the Ollama Operator" {

                    softwareSystemInstance ollama
                }

                deploymentNode "Researcher Access" {

                    infrastructureNode "UniversityNetworkAccess" "Internal university network access path used by researchers"
                }
            }

            deploymentNode "External SaaS Services" {

                softwareSystemInstance authSystem

                softwareSystemInstance smtpServer
            }
        }
    }

    views {

        systemContext app "SystemContext" {

            include researcher
            include app
            include smtpServer
            include ollama
            include authSystem

            autolayout lr
        }

        container app "Containers" {

            include researcher
            include app.restApi
            include app.database
            include smtpServer
            include ollama
            include authSystem

            autolayout tb
        }

        component app.restApi "Components" {

            include app.restApi.apiLayer
            include app.restApi.domainLayer
            include app.restApi.persistenceLayer

            include app.database
            include smtpServer
            include ollama
            include authSystem

            autolayout tb
        }

        component app.restApi "ApiLayerQueueExecutionFlow" {

            title "API Layer - Queue Execution Flow"

            include app.restApi.testController
            include app.restApi.testBackgroundWorker
            include app.restApi.testQueueInterface
            include app.restApi.iTestRunner
            include app.restApi.testQueue

            autolayout lr
        }

        component app.restApi "PersistenceLayerTestRunnerFlow" {

            title "Persistence Layer - Test Runner Flow"

            include app.restApi.runTestOperations
            include app.restApi.applicationDbContext
            include app.restApi.promptGeneration
            include app.restApi.resultProcessing
            include app.restApi.emailService
            include app.restApi.iTestRunner

            include app.database
            include ollama
            include smtpServer

            autolayout lr
        }

        dynamic app.restApi "TestExecutionDynamicFlow" {

            title "Test Execution Dynamic Flow"

            researcher -> app.restApi.testController "Sends HTTP request to add a test to the queue"

            app.restApi.testController -> app.restApi.testQueueInterface "Uses ITestQueue to add the test to the queue"

            app.restApi.testBackgroundWorker -> app.restApi.testQueueInterface "Uses ITestQueue to read the next test item from the queue"

            app.restApi.testBackgroundWorker -> app.restApi.iTestRunner "Uses ITestRunner to run the queued test"

            app.restApi.runTestOperations -> app.restApi.promptGeneration "Generates prompt for the test run"

            app.restApi.promptGeneration -> app.restApi.applicationDbContext "Fetches prompt details, context, model information, and estimation strategy"

            app.restApi.runTestOperations -> ollama "Sends generated prompt and receives user story estimation"

            app.restApi.runTestOperations -> app.restApi.resultProcessing "Parses estimations and gathers all results for the test"

            app.restApi.resultProcessing -> app.restApi.applicationDbContext "Persists gathered estimations and test results"

            app.restApi.applicationDbContext -> app.database "Writes completed test results to PostgreSQL"

            autolayout tb
        }

        deployment app "ExperimentExecutionEnvironment" "ExperimentDeployment" {

            title "Deployment for Conducting the Experiment"

            include *

            autolayout tb
        }

        properties {
            "structurizr.metadata" "false"
        }

        styles {

            element "Element" {
                background #ffffff
                color #1f1f1f
                stroke #5e35b1
                strokeWidth 2
                shape roundedbox
                fontSize 24
            }

            element "Person" {
                shape person
                background #f3e5f5
                color #1f1f1f
                stroke #6a1b9a
            }

            element "Software System" {
                background #ede7f6
                color #1f1f1f
                stroke #512da8
            }

            element "Container" {
                background #f5f0ff
                color #1f1f1f
                stroke #5c2d91
            }

            element "Component" {
                background #faf7ff
                color #1f1f1f
                stroke #7e57c2
            }

            element "Code" {
                background #f8f5ff
                color #1f1f1f
                stroke #9575cd
            }

            element "Database" {
                shape cylinder
                background #ede7f6
                color #1f1f1f
                stroke #4527a0
            }

            relationship "Relationship" {
                color #333333
                thickness 2
                fontSize 20
            }
        }
    }

    configuration {
        scope softwaresystem
    }
}