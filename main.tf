terraform {
  required_providers {
    thousandeyes = {
      source = "william20111/thousandeyes"
    }
  }
  experiments = [module_variable_optional_attrs]
}


locals {
  combined_agents = distinct(flatten([for test in var.http_tests : test.agents ]))

  http_tests = defaults(var.http_tests, {
    interval                = 60
    content_regex           = ".*"
    network_measurements    = true
    mtu_measurements        = true
    bandwidth_measurements  = false # not support on cloud agents
    bgp_measurements        = true
    use_public_bgp          = false
    num_path_traces         = 0
    agents                  = list(string)
    })
}

### ThousandEyes Agent Data ###

data "thousandeyes_agent" "agents" {
  for_each = toset(local.combined_agents)
  agent_name  = each.key
}


### ThousandEyes HTTP Tests ###

resource "thousandeyes_http_server" "http_tests" {
  for_each = local.http_tests

  test_name               = each.value.name
  interval                = each.value.interval
  url                     = each.value.url
  content_regex           = each.value.content_regex
  network_measurements    = each.value.network_measurements
  mtu_measurements        = each.value.mtu_measurements
  bandwidth_measurements  = each.value.bandwidth_measurements
  bgp_measurements        = each.value.bgp_measurements
  use_public_bgp          = each.value.use_public_bgp
  num_path_traces         = each.value.num_path_traces

  dynamic "agents" {
    for_each = toset(each.value.agent_list)
    content {
      agent_id = data.thousandeyes_agent.agents[agents.key].agent_id
    }
  }
}
