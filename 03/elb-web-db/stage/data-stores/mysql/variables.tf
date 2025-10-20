variable "dbuser" {
  description = "The database admin user"
  type = string 
  sensitive = true 
}

variable "dbpassword" {
  description = "The database admin password"
  type = string
  sensitive = true
}

