variable "namespace" {
  type    = string
  default = "mykey2"
  # default = [
  #   "mykey2",
  #   "yourkey",
  #   "ourkey",
  #   "theirkey",
  #   "themkeys",
  # ]
}

variable "cluster" {
  default = "my-gke-cluster"
}
variable "app" {
  type        = string
  description = "Name of application"
  default     = "hello-service"
}
variable "zone" {
  default = "us-central1-f"
}
variable "docker-image" {
  type        = string
  description = "name of the docker image to deploy"
  default     = "gcr.io/google-samples/hello-app:2.0"
}

variable "app_printer" {
  type        = string
  description = "Name of application"
  default     = "zone-printer"
}

variable "docker-image_zone_printer" {
  type        = string
  description = "name of the docker image to deploy"
  default     = "gcr.io/google-samples/zone-printer:0.2"
}

variable "whereami" {
  type        = string
  description = "Name of application"
  default     = "whereami"
}

variable "docker-image_whereami" {
  type        = string
  description = "name of the docker image to deploy"
  default     = "gcr.io/google-samples/whereami:v1.2.6"
}

variable "labels" {
  type = map(any)
  default = {
    "owner"       = "precocityllc.com"
    "environment" = "dev"
    "project"     = "apthub-dev-us-south1-app"
  }
}