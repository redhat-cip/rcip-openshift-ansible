---
- name: config crontab prune node
  lineinfile:
    dest: /var/spool/cron/root
    regexp: "{{ item.regexp }}"
    line: "{{ item.line }}"
    create: yes
  with_items:
    - { regexp: '.* bash /opt/rcip-openshift-scripts/maintenance/prune.sh docker$', line: "{{ crontab_prune_docker_time }} bash /opt/rcip-openshift-scripts/maintenance/prune.sh docker" }
    - { regexp: '.* bash /opt/rcip-openshift-scripts/maintenance/prune.sh docker-images$', line: "{{ crontab_prune_dockerimage_time }} bash /opt/rcip-openshift-scripts/maintenance/prune.sh docker-images" }
