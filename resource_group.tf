data "aws_default_tags" "default_tags" {}

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
      "Values": ["${data.aws_default_tags.default_tags.tags.Application}"]
    }
  ]
}
JSON
  }

  tags = {
    Name = "Hello-World-resource-group"
  }
}
