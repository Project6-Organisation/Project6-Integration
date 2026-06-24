resource "aws_iam_policy" "aws_load_balancer_controller" {
  name        = "${var.naming_prefix}-AWSLoadBalancerController"
  description = "IAM policy for AWS Load Balancer Controller"

  policy = file("${path.module}/policies/aws-load-balancer-controller.json")
}