variable "dbuser" {
  description = "The database admin user"
  type = string 
  sensitive = true ## 중요 데이터 암호화 
}

variable "dbpassword" {
  description = "The database admin password"
  type = string
  sensitive = true ## 중요 데이터 암호화 
}