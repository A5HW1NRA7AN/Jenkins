output "jenkins_public_ip" {
  description = "Current public IP of the Jenkins server (auto-assigned; changes on stop/start)."
  value       = aws_instance.jenkins.public_ip
}

output "ssh_connection_string" {
  description = "SSH command to log into the Jenkins server."
  value       = "ssh -i jenkins-key.pem ubuntu@${aws_instance.jenkins.public_ip}"
}

output "jenkins_ui_url" {
  description = "URL of the Jenkins UI."
  value       = "http://${aws_instance.jenkins.public_ip}:8080"
}
