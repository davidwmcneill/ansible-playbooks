#!/bin/bash
set -e
#TODO: Support python virtual environments for now global

COLOR_END='\e[0m'
COLOR_RED='\e[0;31m'

# This current directory.
DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
ROOT_DIR=$(cd "$DIR/../../" && pwd)
EXTERNAL_COLLECTION_DIR="$ROOT_DIR/collections/external"
COLLECTIONS_REQUIREMNTS_FILE="$ROOT_DIR/collections/collections_requirements.yml"

# Exit msg
msg_exit() {
    printf "$COLOR_RED$@$COLOR_END"
    printf "\n"
    printf "Exiting...\n"
    exit 1
}

# Trap if ansible-galaxy failed and warn user
cleanup() {
    msg_exit "Update failed. Please don't commit or push collections till you fix the issue"
}
trap "cleanup"  ERR INT TERM

# Check ansible-galaxy
[[ -z "$(which ansible-galaxy)" ]] && msg_exit "Ansible is not installed or not in your path."

# Check COLLECTIONs req file
[[ ! -f "$COLLECTIONS_REQUIREMNTS_FILE" ]]  && msg_exit "collections_requirements '$COLLECTIONS_REQUIREMNTS_FILE' does not exist or permssion issue.\nPlease check and rerun."

# Remove existing COLLECTIONs
if [ -d "$EXTERNAL_COLLECTION_DIR" ]; then
    cd "$EXTERNAL_COLLECTION_DIR"
	if [ "$(pwd)" == "$EXTERNAL_COLLECTION_DIR" ];then
	  echo "Removing current collections in '$EXTERNAL_COLLECTION_DIR/*'"
	  rm -rf *
	else
	  msg_exit "Path error could not change dir to $EXTERNAL_COLLECTION_DIR"
	fi
fi



# Install COLLECTIONs
ansible-galaxy collection install -r "$COLLECTIONS_REQUIREMNTS_FILE" --force --no-deps -p "$EXTERNAL_COLLECTION_DIR"

exit 0
