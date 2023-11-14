resource "aws_resourcegroups_group" "one_percent_resources" {
  name = "1-percent-resource-group"

  resource_query {
    query = <<JSON
{
  "ResourceTypeFilters": [
    "AWS::AllSupported"
  ],
  "TagFilters": [
    {
      "Key": "Application",
      "Values": ["1-percent"]
    }
  ]
}
JSON
  }
}
