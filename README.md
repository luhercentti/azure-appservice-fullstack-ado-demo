# demo-azure-fullstack-ado

A fullstack demo application featuring a .NET 8 REST API backend and a React frontend, deployed to Azure using Terraform and automated via Azure Pipelines.

**Author:** Luis Angelo Hernandez Centti

---

## Overview

This project implements a simple user management application with full CI/CD, security scanning, and cloud infrastructure-as-code. Users can be listed and created through a React UI that communicates with an ASP.NET Core API.

## Tech Stack

| Layer | Technology |
|---|---|
| Backend | .NET 8 / ASP.NET Core (Minimal API) |
| Frontend | React 18 / Node.js |
| Infrastructure | Terraform → Azure |
| CI/CD | Azure Pipelines |
| Containerization | Docker (multi-stage build) |

---

## Project Structure

```
├── backend/                  # ASP.NET Core API
│   ├── Program.cs            # App entry point, controllers, and routes
│   ├── SimpleApp.csproj      # Project file with dependencies
│   ├── UsersControllerTests.cs # xUnit tests
│   └── Dockerfile            # Multi-stage Docker build
├── frontend/                 # React application
│   ├── src/
│   │   ├── App.js            # Main component (fetch, form, user grid)
│   │   ├── App.css           # Responsive card-based styles
│   │   └── App.test.js       # Jest / React Testing Library tests
│   ├── eslint.config.js      # ESLint rules
│   └── package.json
├── infrastructure/           # Terraform IaC
│   ├── main.tf               # Azure resources definition
│   ├── variables.tf          # Input variables (environment, location)
│   └── outputs.tf            # API and frontend URLs
├── config/
│   └── audit-ci.json         # npm audit-ci configuration (CVE allowlist)
├── azure-pipelines.yml       # CI/CD pipeline definition
└── demo-azure-fullstack-ado.sln
```

---

## Backend API

The backend exposes a REST API with in-memory storage:

| Method | Endpoint | Description |
|---|---|---|
| GET | `/api/users` | Returns all users |
| GET | `/api/users/{id}` | Returns a user by ID (404 if not found) |
| POST | `/api/users` | Creates a new user |

CORS is configured to allow all origins. Swagger/OpenAPI is available in development.

### Running locally

```bash
cd backend
dotnet run
# API available at http://localhost:5000
```

### Running with Docker

```bash
cd backend
docker build -t simpleapp-api .
docker run -p 5000:80 simpleapp-api
```

---

## Frontend

The React app fetches users from `http://localhost:5000/api/users` on load and provides a form to add new users, displayed in a responsive CSS Grid layout.

### Running locally

```bash
cd frontend
npm install
npm start
# App available at http://localhost:3000
```

---

## Infrastructure (Terraform)

Terraform provisions the following Azure resources:

| Resource | Type | Notes |
|---|---|---|
| Resource Group | `azurerm_resource_group` | Named `rg-simpleapp-{environment}` |
| App Service Plan | `azurerm_service_plan` | Linux B1 SKU |
| Linux Web App | `azurerm_linux_web_app` | .NET 8 backend runtime |
| Static Web App | `azurerm_static_site` | React frontend hosting (East US2) |

**Variables:**
- `environment` — deployment environment tag (default: `dev`)
- `location` — Azure region (default: `East US`)

**Outputs:** `api_url`, `frontend_url`

```bash
cd infrastructure
terraform init
terraform plan -var="environment=dev"
terraform apply -var="environment=dev"
```

---

## CI/CD Pipeline (Azure Pipelines)

Triggered on pushes to `main`. Runs on `windows-latest` with .NET 8.x and Node.js 18.x.


az group create --name rg-terraform-state --location "East US"

az storage account create \
  --name stterraformlhctest \
  --resource-group rg-terraform-state \
  --location "East US" \
  --sku Standard_LRS \
  --min-tls-version TLS1_2

az storage container create \
  --name tfstate \
  --account-name stterraformlhctest \
  --auth-mode login

az role assignment create \
  --assignee IDDDDDDDD \
  --role "Storage Blob Data Contributor" \
  --scope "/subscriptions/resourceID/resourceGroups/rg-terraform-state/providers/Microsoft.Storage/storageAccounts/stterraformlhctest"


### Jobs

| Job | Steps |
|---|---|
| **TestBackend** | Restore → Build (Release) → Test + Cobertura coverage |
| **TestFrontend** | `npm install` → `npm test` + coverage report |
| **SecurityScan** | npm `audit-ci` (HIGH+CRITICAL) · .NET vulnerable package check · code format validation |
| **StaticAnalysis** | Roslynator CLI (backend) · DevSkim security scan · ESLint (frontend, JUnit output) |

### Security scanning details

- **npm audit:** Uses `config/audit-ci.json`; only fails on HIGH/CRITICAL severity. Four known CVEs are allow-listed.
- **.NET packages:** `dotnet list package --vulnerable` fails the build on any vulnerable dependency.
- **DevSkim:** SARIF output for security anti-patterns in source code.
- **Roslynator:** Static code analysis for the .NET solution.

---

## Testing

### Backend (xUnit)

```bash
cd backend
dotnet test
```

Covers: `GET /api/users`, `GET /api/users/{id}` (found / not found), `POST /api/users`.

### Frontend (Jest + React Testing Library)

```bash
cd frontend
npm test
```

Covers: title rendering, loading state, user list display after fetch.

### Linting

```bash
cd frontend
npm run lint
```

