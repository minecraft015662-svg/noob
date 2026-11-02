run_update(){
  banner; title "System Update"
  if [ -f /etc/apt/sources.list.d/docker.list ]; then info "Checking docker repo..."; fix_docker_repo; fi
  info "Running apt update..."; apt-get update -y
  info "Running apt upgrade -y..."; DEBIAN_FRONTEND=noninteractive apt-get upgrade -y
  ok "System updated"
}
