# Aetheria Product Management Suite

A full-stack product management solution built as a monorepo consisting of:
1. **Laravel 11 & Filament v5 Admin Panel** (`backend-admin/`) - Internal database administration (CRUD operations, advanced filters, security validations).
2. **NestJS v11 REST API** (`backend-api/`) - High-performance backend API serving pagination, search, and payload validation.
3. **Nuxt 3 Frontend** (`frontend/`) - Premium public-facing catalog with a glassmorphism design, real-time search, interactive modals, and notifications.
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
5. **View Product Specs:** Click any product card or the **"View Details"** button to open the glassmorphism detailed specifications view displaying the full UUID and creation timestamps.
6. **Login to Admin Panel (Laravel Filament):**
   * Go to `http://127.0.0.1:8000/admin`.
   * Login with `admin@example.com` and `password`.
   * Open the **Products** resource menu. You can perform full CRUD, search, and filter by minimum/maximum price.
   * Any product added in Filament will immediately reflect on the Nuxt frontend and vice-versa, since they share the same PostgreSQL database.

---

## 🚀 GitLab CI/CD Pipeline Overview

The project includes a robust pipeline defined in `.gitlab-ci.yml` supporting:
* **Lint Stage:** Checks Laravel syntax (Laravel Pint), NestJS syntax (ESlint), and Nuxt compilation readiness.
* **Build Stage:** Independently packages all projects for deployment (optimizes Autoloaders in PHP, bundles client/server artifacts in NestJS and Nuxt).
* **Deploy Stage:** A manual production release trigger to remotely pull changes onto the DigitalOcean droplet and reboot docker-compose services via SSH keys safely.

---

## ☁️ Infrastructure as Code (IaC) — Terraform

The system infrastructure on **DigitalOcean** is fully modeled in `terraform/main.tf` mapping:
* **VPC Network:** Private virtual network isolating droplets and databases from the open web.
* **Managed PostgreSQL:** A single-node PostgreSQL v16 managed cluster bound to the VPC for automatic backups and database maintenance.
* **Droplet Server:** An entry-tier Ubuntu droplet configured with Docker and Docker Compose to spin up Laravel, NestJS, and Nuxt 3 containers.
* **Database Firewall:** Restricts access to the PostgreSQL database cluster so it only accepts incoming connections originating from the application server Droplet IP.
