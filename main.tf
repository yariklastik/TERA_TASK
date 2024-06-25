# Define the MongoDB Atlas Provider
terraform {
  required_providers {
    mongodbatlas = {
      source = "mongodb/mongodbatlas"
    }
  }
  required_version = ">= 0.13"
}

provider "mongodbatlas" {
  public_key  = var.TF_VAR_MONGODB_ATLAS_PUBLIC_KEY
  private_key = var.TF_VAR_MONGODB_ATLAS_PRIVATE_KEY
}


# Create a Project
resource "mongodbatlas_project" "myproject" {
  name        = "myproject"
  org_id      = var.TF_VAR_MONGODB_ATLAS_ORGANIZATION_ID
}


# Create an Atlas Cluster
resource "mongodbatlas_cluster" "mycluster" {
  project_id   = var.TF_VAR_MONGODB_ATLAS_PROJECT_ID
  name         = "mycluster"
  cluster_type = "REPLICASET"
  provider_name = "TENANT"
  backing_provider_name = "AWS"
  provider_region_name = "US_EAST_1"
  provider_instance_size_name = "M0"
}


# Create a Database User
resource "mongodbatlas_database_user" "bob" {
  username           = "bob"
  password           = "fXUJAFkf5ZZbuY6z"
  project_id         = var.TF_VAR_MONGODB_ATLAS_PROJECT_ID
  auth_database_name = "admin"
    roles {
    role_name     = "readWrite"
    database_name = "db"
  }
    scopes {
    name   = "mycluster"
    type = "CLUSTER"
  }
  depends_on = [mongodbatlas_cluster.mycluster]
}


# Open up your IP Access List to all, but this comes with significant potential risk.

resource "mongodbatlas_project_ip_access_list" "cidr" {
    project_id = var.TF_VAR_MONGODB_ATLAS_PROJECT_ID
    cidr_block = "0.0.0.0/1"
    depends_on = [mongodbatlas_cluster.mycluster]
}
