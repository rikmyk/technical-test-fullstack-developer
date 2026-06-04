# Technical Test: Full-Stack Developer

## Overview

Your task is to develop a full-stack application to manage a list of products, integrating a RESTful API, frontend interaction, and an admin panel.

## Stack to Use

- **Frontend:** Nuxt.js
- **Backend (API):** NestJS
- **Backend (Admin Panel):** Laravel Filament
- **Database:** PostgreSQL
- **Deployment & CI/CD:** GitLab CI  
  Provide a pipeline configuration.
- **Infrastructure:** Digital Ocean (briefly describe your deployment approach using Terraform. 
  **NO NEED TO DO A REAL DEPLOYMENT**

---

## Requirements

## Frontend — Nuxt.js

- Create a responsive web page that displays a list of products fetched from the NestJS backend.
- Include functionalities for:
  - Viewing product details:
    - Name
    - Description
    - Price
  - Adding new products through a form.
  - Searching from the list of products.
  - Pagination feature on the product lists.

## Backend API — NestJS

- Develop a RESTful API with the following endpoints:
  - `GET /api/products` to list all products.
  - `POST /api/products` to add a new product.
- Each product must include fields:
  - `id`
  - `name`
  - `description`
  - `price`
- Validate incoming data with proper error handling.

## Backend Admin Panel — Laravel Filament

- Create an admin panel for managing products with CRUD operations.
- Allow administrators to:
  - View products
  - Create products
  - Update products
  - Delete products
  - Perform basic product searches and filters.

## Database

- Set up PostgreSQL and define the required schema.

## CI/CD

- Provide a basic GitLab CI pipeline file:

```yml
.gitlab-ci.yml
```

The pipeline should include:

- The application build process.
- Deployment.

> Describe deployment steps. Actual deployment is not required.

## Infrastructure as Code — IaC

- Briefly describe your infrastructure provisioning strategy using Terraform to deploy on Digital Ocean.

> Actual Terraform files are not required, but a short explanation of the resources you'd manage with Terraform is expected.

---

## Submission Requirements

- Provide source code in a public Git repository:
  - GitLab
  - GitHub
- Include clear README documentation covering:
  - Project setup instructions.
  - How to run and test your application locally.
  - Overview of your CI/CD pipeline setup.
  - Infrastructure description:
    - Digital Ocean
    - Terraform

---

## Deadline

We expected the result of this test in **48h** from the time you received this message.
