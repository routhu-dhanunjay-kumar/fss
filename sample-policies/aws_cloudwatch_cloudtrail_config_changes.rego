#----------------------------------------------------------------------#
# CIS Policy: to ensure a log metric filter and alarm exist for        #
#  CloudTrail configuration changes                                    #
#----------------------------------------------------------------------#

package terraform.aws.logging
import data.terraform

default allow = false

allow {
    // Find all resources of type "aws_cloudwatch_log_metric_filter" in the Terraform code.
    metric_filters := [resource |
        resource := terraform.aws_cloudwatch_log_metric_filter[_]
    ]

    // Check that each metric filter has a matching alarm resource.
    all(metric_filters, filter_has_matching_alarm)
}

filter_has_matching_alarm(filter) {
    // Check that the metric filter has a filter pattern that matches CloudTrail configuration changes.
    filter_pattern := filter.filter_pattern
    contains(filter_pattern, "\"eventName\": \"CreateTrail\"")
    contains(filter_pattern, "\"eventName\": \"UpdateTrail\"")
    contains(filter_pattern, "\"eventName\": \"DeleteTrail\"")
    contains(filter_pattern, "\"eventName\": \"StartLogging\"")
    contains(filter_pattern, "\"eventName\": \"StopLogging\"")

    // Find an alarm resource that has the same name and dimensions as the metric filter.
    alarm := terraform.aws_cloudwatch_metric_alarm[filter.name]
    alarm.name == filter.name
    alarm.dimensions == filter.metric_transformation.dimensions
}
