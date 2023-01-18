wait_cpu_low() {
    awk -v target="$1" '
    $12 ~ /^[0-9.]+$/ {
      current = 100 - $12
      if(current <= target) { exit(0); }
    }' < <(LC_ALL=C mpstat 1)
}
