#!/bin/bash
#
# Script pro automatické čištění Docker artefaktů
# Doporučené spouštění pomocí cronu:
# 0 1 * * 0 /path/to/docker_cleanup.sh >> /var/log/docker_cleanup.log 2>&1
#

# Nastavení
LOG_FILE="/var/log/docker_cleanup.log"
PRUNE_IMAGES_OLDER_THAN="30d"
KEEP_LAST_N_IMAGES=3
MIN_FREE_SPACE_GB=20
PROJECT_NAME="spark-etl-project"

# Funkce pro logování
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1"
}

log "=== Zahájení čištění Docker artefaktů ==="

# Kontrola volného místa
FREE_SPACE_GB=$(df -BG / | awk 'NR==2 {print $4}' | sed 's/G//')
log "Aktuální volné místo: ${FREE_SPACE_GB}GB"

if [[ $FREE_SPACE_GB -lt $MIN_FREE_SPACE_GB ]]; then
    log "VAROVÁNÍ: Méně než ${MIN_FREE_SPACE_GB}GB volného místa. Provádím agresivnější čištění."
    AGGRESSIVE_CLEANUP=true
else
    AGGRESSIVE_CLEANUP=false
fi

# 1. Odstranění zastavených kontejnerů
STOPPED_CONTAINERS=$(docker ps -aq --filter "status=exited")
if [[ -n "$STOPPED_CONTAINERS" ]]; then
    log "Odstraňuji zastavené kontejnery..."
    docker rm $STOPPED_CONTAINERS
    log "Odstraněno $(echo $STOPPED_CONTAINERS | wc -w) kontejnerů."
else
    log "Žádné zastavené kontejnery k odstranění."
fi

# 2. Odstranění dangling images
log "Odstraňuji dangling images..."
docker image prune -f
log "Dangling images odstraněny."

# 3. Odstranění starých images
if [[ "$AGGRESSIVE_CLEANUP" == true ]]; then
    log "Agresivní čištění: Odstraňuji všechny nepoužívané images..."
    docker image prune -a -f
else
    log "Odstraňuji images starší než ${PRUNE_IMAGES_OLDER_THAN}..."
    docker image prune -a -f --filter "until=${PRUNE_IMAGES_OLDER_THAN}"
fi

# 4. Zachování posledních N verzí našeho projektu
log "Zachovávám posledních ${KEEP_LAST_N_IMAGES} verzí ${PROJECT_NAME} images..."
PRESERVE_IMAGES=$(docker images --format "{{.Repository}}:{{.Tag}}" | grep "${PROJECT_NAME}" | sort -r | head -n ${KEEP_LAST_N_IMAGES})

for IMAGE in $PRESERVE_IMAGES; do
    log "Zachovávám image: $IMAGE"
done

# 5. Čištění volumes
log "Odstraňuji nepoužívané volumes..."
docker volume prune -f
log "Nepoužívané volumes odstraněny."

# 6. Čištění sítí
log "Odstraňuji nepoužívané sítě..."
docker network prune -f
log "Nepoužívané sítě odstraněny."

# 7. Čištění build cache
log "Odstraňuji build cache..."
docker builder prune -f
log "Build cache odstraněna."

# Zobrazení výsledků
log "=== Výsledky čištění ==="
log "Kontejnery:"
docker ps -a | wc -l
log "Images:"
docker images | wc -l
log "Volumes:"
docker volume ls | wc -l
log "Sítě:"
docker network ls | wc -l

# Kontrola volného místa po čištění
FREE_SPACE_AFTER_GB=$(df -BG / | awk 'NR==2 {print $4}' | sed 's/G//')
SPACE_SAVED_GB=$((FREE_SPACE_AFTER_GB - FREE_SPACE_GB))

log "Nové volné místo: ${FREE_SPACE_AFTER_GB}GB"
log "Ušetřeno: ${SPACE_SAVED_GB}GB"
log "=== Čištění Docker artefaktů dokončeno ==="

exit 0 