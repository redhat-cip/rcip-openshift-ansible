---
- name: config crontab prune master
  lineinfile:
    dest: /var/spool/cron/root
    regexp: "{{ item.regexp }}"
    line: "{{ item.line }}"
    create: yes
  with_items:
    - { regexp: '.* bash /opt/rcip-openshift-scripts/maintenance/prune.sh openshift$', line: "{{ crontab_prune_openshift_time }} bash /opt/rcip-openshift-scripts/maintenance/prune.sh openshift" }

- name: config crontab backup etcd
  lineinfile:
    dest: /var/spool/cron/root
    regexp: "{{ item.regexp }}"
    line: "{{ item.line }}"
    create: yes
  with_items:
    - { regexp: '.* /opt/rcip-openshift-scripts/backup/etcd/backup_etcd.sh >> /var/log/backup_etcd.log$', line: "{{ crontab_etcd_backup_time }} /opt/rcip-openshift-scripts/backup/etcd/backup_etcd.sh >> /var/log/backup_etcd.log" }
    - { regexp: '.* /opt/rcip-openshift-scripts/backup/etcd/cold_backup_etcd.sh >> /var/log/backup_etcd.log$', line: "{{ crontab_etcd_backup_cold_time }} /opt/rcip-openshift-scripts/backup/etcd/cold_backup_etcd.sh >> /var/log/backup_etcd.log" }
    - { regexp: '.* /opt/rcip-openshift-scripts/backup/etcd/purge.sh >> /var/log/purge_backup_etcd.log$', line: "{{ crontab_etcd_prune_time }} /opt/rcip-openshift-scripts/backup/etcd/purge.sh >> /var/log/purge_backup_etcd.log" }
