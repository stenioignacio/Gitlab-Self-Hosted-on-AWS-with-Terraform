variable "name" {
  type        = string
  description = "Secret name"
}

variable "values" {
  description = "Values to store in the secret. Can be a map (map(string)) or a plain string (text/json)."
  type        = any
}