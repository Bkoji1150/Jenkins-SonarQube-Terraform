# resource "aws_route53_zone" "kojidnsName" {
#   name = "kojibello.com"
# }

# resource "aws_route53_record" "jenkins" {
#   allow_overwrite = true
#   zone_id         = aws_route53_zone.kojidnsName.zone_id
#   name            = "jenkins.kojibello.com"
#   type            = "A"
#   ttl             = "300"
# #   records         = [aws_eip.lb.public_ip]
# }
