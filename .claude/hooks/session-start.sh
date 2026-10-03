#!/bin/bash
# Instala R y paquetes para análisis de rasgos funcionales / ecología forestal
# en las sesiones de Claude Code en la nube.
set -euo pipefail

if [ "${CLAUDE_CODE_REMOTE:-}" != "true" ]; then
  exit 0
fi

export DEBIAN_FRONTEND=noninteractive

# Paquetes binarios de Ubuntu (rápidos, sin compilar)
APT_PKGS="r-base r-base-dev r-cran-readxl r-cran-tidyverse r-cran-vegan r-cran-lme4"
missing=""
for p in $APT_PKGS; do
  dpkg -s "$p" >/dev/null 2>&1 || missing="$missing $p"
done
if [ -n "$missing" ]; then
  apt-get update -qq
  apt-get install -y -qq --no-install-recommends $missing
fi

# Paquetes que no están en apt: se instalan desde CRAN.
# Requiere que cloud.r-project.org esté permitido en la red del entorno;
# si no, solo emite un aviso y el hook continúa.
Rscript -e '
pkgs <- c("FD")
falta <- pkgs[!pkgs %in% rownames(installed.packages())]
if (length(falta)) install.packages(falta, repos = "https://cloud.r-project.org", Ncpus = parallel::detectCores())
'
