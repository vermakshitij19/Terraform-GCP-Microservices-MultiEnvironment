output "environment" {
  value = var.environment
}

output "project_id" {
  value = var.project_id
}

output "network_name" {
  value = module.network.network_name
}

output "subnet_name" {
  value = module.network.subnet_name
}

output "subnet_cidr" {
  value = module.network.subnet_cidr
}

output "microservices" {
  value = {
    for key, service in module.microservices : key => {
      name                     = service.name
      url                      = service.url
      runtime_service_account  = service.runtime_service_account
    }
  }
}
