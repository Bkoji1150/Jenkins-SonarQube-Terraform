 output "lb_target_group_arn" {
     value = aws_lb_target_group.Project-OmegalbTargetGroup.arn 
 }

 output "lb_endpoint" {
     value = aws_lb.Project-Omegalb.dns_name
 }
  
   output "loadBalancingSecurityGroup" {
     value = aws_lb_listener.front_end.id
   }
