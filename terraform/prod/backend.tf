terraform {
  backend "gcs" {
    bucket  = "storage-bucket-dmonakhov"
    prefix  = "terraform/prod"
  }
}
