output "jenkins_public_ip" {
  description = "The public IP of the Jenkins server (static EIP)"
  value       = "18.181.56.52"
}

output "ssh_connection_string" {
  description = "SSH connection string to log into the Jenkins server"
  value       = "ssh -i jenkins-key.pem ubuntu@18.181.56.52"
}

output "jenkins_ui_url" {
  description = "The URL to access the Jenkins UI"
  value       = "http://18.181.56.52:8080"
}
