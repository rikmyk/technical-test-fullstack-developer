terraform {
  required_version = ">= 1.0.0"
  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "~> 2.0"
    }
  }
}

provider "digitalocean" {
  token = var.do_token
}

# Variables
variable "do_token" {
  type        = string
  description = "DigitalOcean API Personal Access Token"
  sensitive   = true
}

variable "region" {
  type        = string
  default     = "sgp1" # Singapore region (low latency for South East Asia)
  description = "DigitalOcean region to deploy resources"
}

variable "droplet_size" {
  type        = string
  default     = "s-1vcpu-1gb" # Standard entry tier droplet
  description = "Hardware specifications for the application server"
}

# VPC (Virtual Private Cloud)
resource "digitalocean_vpc" "app_vpc" {
  name     = "vapecloud-vpc"
  region   = var.region
  ip_range = "10.10.10.0/24"
}

# Managed PostgreSQL Database Cluster
resource "digitalocean_database_cluster" "postgres_cluster" {
  name       = "vapecloud-postgres"
  engine     = "pg"
  version    = "16"
  size       = "db-s-1vcpu-1gb" # Minimal tier for DB cluster
  region     = var.region
  node_count = 1
  private_network_uuid = digitalocean_vpc.app_vpc.id
}

# Database definition
resource "digitalocean_database_db" "app_db" {
  cluster_id = digitalocean_database_cluster.postgres_cluster.id
  name       = "technical_test_fullstack"
}

# SSH Key for authentication
resource "digitalocean_ssh_key" "default" {
  name       = "vapecloud-ssh-key"
  public_key = file("~/.ssh/id_rsa.pub")
}

# Application Server (Droplet)
resource "digitalocean_droplet" "app_server" {
  name       = "vapecloud-app-server"
  image      = "docker-20-04" # Ubuntu image with Docker pre-installed
  region     = var.region
  size       = var.droplet_size
  vpc_uuid   = digitalocean_vpc.app_vpc.id
  ssh_keys   = [digitalocean_ssh_key.default.id]

  # Inject custom startup configurations via user_data
  user_data = <<-EOF
              #!/bin/bash
              # Update package lists
              apt-get update
              apt-get install -y git curl docker-compose
              
              # Enable firewall rules
              ufw default deny incoming
              ufw default allow outgoing
              ufw allow 22/tcp
              ufw allow 80/tcp
              ufw allow 443/tcp
              ufw --force enable
              EOF
}

# Firewall rule to restrict DB access only to the Droplet
resource "digitalocean_database_firewall" "db_fw" {
  cluster_id = digitalocean_database_cluster.postgres_cluster.id

  rule {
    type  = "droplet"
    value = digitalocean_droplet.app_server.id
  }
}

# Organize resources under a unified DigitalOcean Project
resource "digitalocean_project" "vapecloud_project" {
  name        = "VapeCloud Indo Application Suite"
  description = "A combined fullstack system comprising Laravel, NestJS, and Nuxt 3"
  purpose     = "Web Application"
  environment = "Production"

  resources = [
    digitalocean_droplet.app_server.urn,
    digitalocean_database_cluster.postgres_cluster.urn
  ]
}

# Outputs
output "droplet_ip" {
  value       = digitalocean_droplet.app_server.ipv4_address
  description = "Public IP Address of the application host server"
}

output "db_private_uri" {
  value       = digitalocean_database_cluster.postgres_cluster.private_uri
  description = "Private Connection URI for database (VPC bound)"
  sensitive   = true
}
