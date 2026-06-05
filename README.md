# VapeCloud Indo Product Management Suite

A full-stack product management solution built as a monorepo consisting of:
1. **Laravel 11 & Filament v5 Admin Panel** (`backend-admin/`) - Internal database administration (CRUD operations, advanced filters, security validations).
2. **NestJS v11 REST API** (`backend-api/`) - High-performance backend API serving pagination, search, and payload validation.
3. **Nuxt 3 Frontend** (`frontend/`) - Premium public-facing catalog containing product lists, real-time search, dynamic forms, and detail modals.
4. **PostgreSQL** - Shared database mapping the schema seamlessly across admin and public layers.

---

## 🛠️ Local Installation & Setup

### Prerequisites
* **PHP >= 8.2** (with `pdo_pgsql` and `pgsql` extensions enabled)
* **Composer** (PHP Package Manager)
* **Node.js >= 20.0** & **NPM**
* **PostgreSQL Server** (e.g. running via Laragon, Docker, or native service)

---

### Step 1: Database Setup
1. Ensure your PostgreSQL service is active.
2. The system is configured to connect to database named: `technical_test_fullstack`
   * *Note: During the migration command, Laravel will automatically ask to create this database if it does not exist.*

---

### Step 2: Backend Admin Panel Setup (Laravel & Filament)
1. Navigate into the admin panel folder:
   ```bash
   cd backend-admin
   ```
2. Install dependencies:
   ```bash
   composer install --ignore-platform-reqs
   ```
3. Copy environment variables file:
   ```bash
   cp .env.example .env
   ```
4. Confirm database properties inside `.env`:
   ```env
   DB_CONNECTION=pgsql
   DB_HOST=127.0.0.1
   DB_PORT=5432
   DB_DATABASE=technical_test_fullstack
   DB_USERNAME=postgres
   DB_PASSWORD=
   ```
5. Run migrations:
   ```bash
   php artisan migrate
   ```
6. Spin up the Laravel development server:
   ```bash
   php artisan serve
   ```
   * *Laravel Admin will run on:* `http://127.0.0.1:8000`
   * *Access the Filament Login Panel at:* `http://127.0.0.1:8000/admin`
   * *Use the pre-created admin user:*
     * **Email:** `admin@example.com`
     * **Password:** `password`

---

### Step 3: Backend REST API Setup (NestJS)
1. Open a new terminal and navigate to the API folder:
   ```bash
   cd backend-api
   ```
2. Install dependencies:
   ```bash
   npm install
   ```
3. Verify your `.env` properties (already configured with local defaults):
   ```env
   DB_HOST=127.0.0.1
   DB_PORT=5432
   DB_DATABASE=technical_test_fullstack
   DB_USERNAME=postgres
   DB_PASSWORD=
   PORT=3001
   ```
4. Start the API server in watch mode:
   ```bash
   npm run start:dev
   ```
   * *NestJS API will run on:* `http://localhost:3001/api`
   * *Exposed REST Endpoints:*
     * `GET /api/products` (Accepts queries: `page`, `limit`, `search`)
     * `POST /api/products` (Accepts JSON body: `name`, `description`, `price`)

---

### Step 4: Web Frontend Setup (Nuxt 3)
1. Open a new terminal and navigate to the frontend folder:
   ```bash
   cd frontend
   ```
2. Install dependencies:
   ```bash
   npm install
   ```
3. Start the Nuxt client server in development mode:
   ```bash
   npm run dev
   ```
   * *Nuxt Web Client will run on:* `http://localhost:3000`

---

## 🧪 Local Verification & Testing Guide

1. **Access Nuxt Catalog:** Open your browser and go to `http://localhost:3000`. You will see the beautiful catalog UI.
2. **Search Products:** Type any term in the search bar. The grid will debounce and dynamically fetch products matching your keywords in the `name` or `description`.
3. **Verify Paginating:** If you have more than 8 products, paginating numbers will allow navigating through pages.
4. **Create a Product (Frontend):** 
   * Click **"+ Add Product"** in the top right.
   * Input name, description, and price. Try inputting negative prices or leaving fields blank to test the client-side validations.
   * On success, a green notification will slide in, the modal will close, and the list will instantly refresh.
5. **View Product Specs:** Click any product card or the **"View Details"** button to open the product detailed specifications view displaying the full UUID and creation timestamps.
6. **Login to Admin Panel (Laravel Filament):**
   * Go to `http://127.0.0.1:8000/admin`.
   * Login with `admin@example.com` and `password`.
   * Open the **Products** resource menu. You can perform full CRUD, search, and filter by minimum/maximum price.
   * Any product added in Filament will immediately reflect on the Nuxt frontend and vice-versa, since they share the same PostgreSQL database.

---

## 🚀 GitLab CI/CD Pipeline & Deployment Guide

The project includes an automated pipeline defined in `.gitlab-ci.yml` supporting:
* **Lint Stage:** Checks Laravel syntax (Laravel Pint), NestJS syntax (ESlint), and Nuxt compilation readiness.
* **Build Stage:** Packages all projects for deployment (optimizes autoloaders in PHP, bundles client/server production artifacts in NestJS and Nuxt).
* **Deploy Stage:** Connects remotely to the target server via SSH to pull the latest main branch and restart the application stack.

### Production Deployment Steps (Execution Plan)
To deploy this application to production, follow these steps:
1. **Prepare credentials:** Create a Personal Access Token on DigitalOcean and generate an SSH Key pair (`id_rsa`/`id_rsa.pub`).
2. **Provision Infrastructure:** Run Terraform (see below) to create the cloud server, network, and database.
3. **Configure CI/CD Variables:** In your GitLab repository settings under **CI/CD > Variables**, add the following secure variables:
   * `SSH_PRIVATE_KEY`: The contents of your private SSH key (`id_rsa`).
   * `SSH_SERVER_IP`: The public IP address of the provisioned Droplet.
   * `SSH_USER`: The username of the server (e.g. `root`).
4. **Push Code:** Push your commits to the `main` branch. The GitLab runner will automatically run tests and compile the code.
5. **Trigger Deployment:** Go to **CI/CD > Pipelines** in GitLab, and manually trigger the `deploy:production` job. The pipeline will remotely SSH into the server and run Docker Compose to bring up the updated application stack.

---

## ☁️ Infrastructure as Code (IaC) — Terraform

The cloud infrastructure on **DigitalOcean** is modeled in `terraform/main.tf`.

### Infrastructure Provisioning Strategy
Our strategy focuses on security, low latency, and isolation:
* **VPC Network (`digitalocean_vpc`):** Establishes an isolated private network (`10.10.10.0/24`) in the Singapore (`sgp1`) region for minimal South East Asia latency. All internal communication between the application server and the database runs through this private network.
* **Managed Database Cluster (`digitalocean_database_cluster`):** Provisions a managed PostgreSQL 16 cluster. Using a managed service offloads database maintenance, automated security updates, backups, and failover management.
* **Database Firewall (`digitalocean_database_firewall`):** Restricts access so that incoming traffic to the PostgreSQL cluster is ONLY accepted from the private IP of the application server Droplet, closing all public database ports.
* **Application Host Server (`digitalocean_droplet`):** A standard Ubuntu Droplet preinstalled with Docker and Docker Compose. A custom `user_data` bash script automatically secures the host OS on startup by installing packages and enabling `ufw` (Uncomplicated Firewall) rules (only TCP ports `22`, `80`, and `443` are open).
* **DigitalOcean Project (`digitalocean_project`):** Dynamically groups the droplet and database under a single project for clean resource monitoring and access controls.
*Note: As per the test requirements, actual infrastructure provisioning and deployment are not required to run this application locally. The provided Terraform configurations (`terraform/main.tf`) serve as a production-ready blueprint mapping the target cloud infrastructure.*
