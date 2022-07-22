terraform {
  required_providers {
    # thousandeyes = {
    #   source = "william20111/thousandeyes"
    # }
    thousandeyes = {
      source = "thousandeyes/thousandeyes"
      # version = "1.0.0-alpha.4"
    }
  }
  experiments = [module_variable_optional_attrs]
}

locals {
  combined_agents = distinct(flatten([for test in var.http_tests : test.agents ]))

  http_tests = defaults(var.http_tests, {
    ## BUG: Provider omits empty values meaning TE will use its default value.
    enabled                 = true # BUG: Can't set to false/0
    interval                = 60
    content_regex           = ".*"
    network_measurements    = true # BUG: Can't set to false/0
    mtu_measurements        = false # BUG: Can't set to false/0
    bandwidth_measurements  = false # BUG: Can't set to false/0 # not support on cloud agents
    bgp_measurements        = false # BUG: Can't set to false/0
    # use_public_bgp          = true # not configurable?
    num_path_traces         = 3 # 3-10?
    })
}

### ThousandEyes Agent Data ###

data "thousandeyes_agent" "agents" {
  for_each = toset(local.combined_agents)
  agent_name  = each.key
}

output "test" {
  value = local.http_tests
}
### ThousandEyes HTTP Tests ###

resource "thousandeyes_http_server" "http_tests" {
  for_each = local.http_tests

  test_name               = each.value.name
  interval                = each.value.interval
  url                     = each.value.url

  alerts_enabled          = each.value.alerts_enabled
  bandwidth_measurements  = each.value.bandwidth_measurements
  bgp_measurements        = each.value.bgp_measurements
  content_regex           = each.value.content_regex
  description             = each.value.description
  enabled                 = each.value.enabled
  mtu_measurements        = each.value.mtu_measurements
  network_measurements    = each.value.network_measurements
  num_path_traces         = each.value.num_path_traces

  dynamic "agents" {
    for_each = toset(each.value.agents)
    content {
      agent_id = data.thousandeyes_agent.agents[agents.key].agent_id
    }
  }
}

# resource "thousandeyes_http_server" "http_tests" {
#   for_each = local.http_tests
#
#   test_name               = each.value.name
#   enabled                 = each.value.enabled == true ? 1 : 0
#   interval                = each.value.interval
#   url                     = each.value.url
#   content_regex           = each.value.content_regex
#   network_measurements    = each.value.network_measurements == true ? 1 : 0
#   mtu_measurements        = each.value.mtu_measurements == true ? 1 : 0
#   bandwidth_measurements  = each.value.bandwidth_measurements == true ? 1 : 0
#   bgp_measurements        = each.value.bgp_measurements == true ? 1 : 0
#   # use_public_bgp          = each.value.use_public_bgp == true ? 1 : 0
#   num_path_traces         = each.value.num_path_traces
#
#   dynamic "agents" {
#     for_each = toset(each.value.agents)
#     content {
#       agent_id = data.thousandeyes_agent.agents[agents.key].agent_id
#     }
#   }
# }
