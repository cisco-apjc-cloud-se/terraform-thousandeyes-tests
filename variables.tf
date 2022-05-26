# variable "agent_list" {
#   type  = list(string)
# }

variable "http_tests" {
  type = map(object({
    name                    = string
    interval                = optional(number)
    url                     = string
    content_regex           = optional(string)
    network_measurements    = optional(bool) # 1
    mtu_measurements        = optional(bool) # 1
    bandwidth_measurements  = optional(bool) # 0
    bgp_measurements        = optional(bool) # 1
    use_public_bgp          = optional(bool) # 1
    num_path_traces         = optional(number) # 0
    agents                  = list(string)
  }))
}
