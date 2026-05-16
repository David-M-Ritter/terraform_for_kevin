locals {
  group_entries = [for line in split("\n", trimspace(file("${path.module}/groups.txt"))) : line if length(trimspace(line)) > 0]
  group_map = {
    for entry in local.group_entries :
    trimspace(split(",", entry)[0]) => trimspace(split(",", entry)[1])
  }
}

resource "dynatrace_iam_group" "test_tf_ritter_group" {
  for_each = local.group_map
  name     = each.key
  # description = ""
}

resource "dynatrace_iam_policy" "test-tf-ritter-policy1" {
  name            = "test-tf-ritter-policy1"
  # description   = ""
  account         = "c7dc5f7b-9d89-4837-9c90-ed4d5880cdcb"
  #environment   = "https://vuf89638.sprint.apps.dynatracelabs.com"
  statement_query = "ALLOW storage:buckets:read WHERE storage:bucket-name = \"$${bindParam:bucket-name-param}\";"

}

resource "dynatrace_iam_policy" "test-tf-ritter-policy" {
  name            = "test-tf-ritter-policy"
  # description   = ""
  account         = "c7dc5f7b-9d89-4837-9c90-ed4d5880cdcb"
  #environment   = "https://vuf89638.sprint.apps.dynatracelabs.com"
  statement_query = "ALLOW storage:buckets:read WHERE storage:bucket-name = \"$${bindParam:bucket-name-param}\";"
}

resource "dynatrace_iam_policy_bindings_v2" "test_tf_ritter_policy_binding" {
  for_each   = local.group_map
  group      = dynatrace_iam_group.test_tf_ritter_group[each.key].id
  account    = "c7dc5f7b-9d89-4837-9c90-ed4d5880cdcb"
  #environment   = "https://vuf89638.sprint.apps.dynatracelabs.com"
  policy {
    id = dynatrace_iam_policy.test-tf-ritter-policy.id
    parameters = {
      "bucket-name-param" = each.value
    }
  }
    policy {
    id = dynatrace_iam_policy.test-tf-ritter-policy1.id
    parameters = {
      "bucket-name-param" = each.value
    }
  }
}