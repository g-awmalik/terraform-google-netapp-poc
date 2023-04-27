variable "project_id" {
  description = "The project id for the associated resources"
  type        = string
}

variable "cvo_instances" {
  description = "List of CVO instance IDs to add to the instance group"
  type        = list(string)
  default     = []
}