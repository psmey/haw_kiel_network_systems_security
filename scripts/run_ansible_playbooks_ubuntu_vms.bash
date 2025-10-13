#!/usr/bin/env bash

ANSIBLE_DIR="/workspaces/haw_kiel_network_systems_security/ansible"
ANSIBLE_INVENTORY_PATH="${ANSIBLE_DIR}/inventory.yml"
ANSIBLE_PLAYBOOK_DIR="${ANSIBLE_DIR}/playbooks"

ansible-playbook -i "${ANSIBLE_INVENTORY_PATH}" "${ANSIBLE_PLAYBOOK_DIR}/set_up_ubuntu_client.yml"
ansible-playbook -i "${ANSIBLE_INVENTORY_PATH}" "${ANSIBLE_PLAYBOOK_DIR}/set_up_ubuntu_router.yml"
ansible-playbook -i "${ANSIBLE_INVENTORY_PATH}" "${ANSIBLE_PLAYBOOK_DIR}/set_up_ubuntu_server.yml"
