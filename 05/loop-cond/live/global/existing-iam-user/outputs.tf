# output "all_arns" {
#     value = aws_iam_user.createuser[*].arn
#     description = "The ARNs for all users"
# }

# output "all_users" {
#     value = aws_iam_user.createuser
#     description = "The ARNs for all users"
# }

output "all_users" {
    value = values(aws_iam_user.createuser)[*].arn
    description = "The ARNs for all users"
}