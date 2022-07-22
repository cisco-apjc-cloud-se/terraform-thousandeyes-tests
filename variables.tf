# variable "agent_list" {
#   type  = list(string)
# }

variable "http_tests" {
  type = map(object({
    name                    = string
    interval                = optional(number)
    url                     = string

    alerts_enabled          = optional(bool)
    bandwidth_measurements  = optional(bool)
    bgp_measurements        = optional(bool)
    content_regex           = optional(string)
    description             = optional(string)
    enabled                 = optional(bool)
    mtu_measurements        = optional(bool)
    network_measurements    = optional(bool)
    num_path_traces         = optional(number)

    agents                  = list(string)
  }))
}
