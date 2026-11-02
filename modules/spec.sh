run_spec(){
  banner; title "System Spec"
  local cpu g; cpu=$(grep -m1 'model name' /proc/cpuinfo | cut -d: -f2 | xargs)
  printf "${TEAL}%-18s${R}%s\n" "CPU Model:" "$cpu"
  printf "${TEAL}%-18s${R}%s\n" "Cores/Threads:" "$(nproc)"
  echo
  printf "${TEAL}%-18s${R}%s\n" "RAM Total:" "$(free -g | awk '/Mem/{print $2" GB"}')"
  printf "${TEAL}%-18s${R}%s\n" "RAM Used:" "$(free -g | awk '/Mem/{print $3" GB"}')"
  printf "${TEAL}%-18s${R}%s\n" "RAM Available:" "$(free -g | awk '/Mem/{print $7" GB"}')"
  echo
  printf "${TEAL}%-18s${R}%s\n" "Storage Total:" "$(df -h / | awk 'NR==2{print $2}')"
  printf "${TEAL}%-18s${R}%s\n" "Storage Used:" "$(df -h / | awk 'NR==2{print $3}')"
  printf "${TEAL}%-18s${R}%s\n" "Storage Free:" "$(df -h / | awk 'NR==2{print $4}')"
  echo
  if command -v nvidia-smi >/dev/null; then g=$(nvidia-smi --query-gpu=name --format=csv,noheader|head -1); else g="No GPU detected / nvidia-smi not installed"; fi
  printf "${TEAL}%-18s${R}%s\n" "GPU:" "$g"
  echo; printf "${TEAL}%-18s${R}%s\n" "Uptime:" "$(uptime -p)"
}
