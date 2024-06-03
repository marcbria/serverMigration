#!/bin/bash

# Mostrar los snaps que ocupan espacio en el dataset:
zfs list -t snapshot -o name -o space -r ${1:-srv} | grep -v '0B'
echo ""

# Mostrar el número total de snaps del dataset:
echo "Total snaps in [${1:-srv}]:" $(zfs list -t snapshot -o name -r ${1:-srv} | grep -c '@')

# Mostrar el espacio ocupado por los snaps del dataset:
zfs list -t snapshot -o space -r ${1:-srv} | awk -v dataset="${1:-srv}" '{sum += $3} END {print "Total space used by [" dataset "] snapshots: " sum " MB"}'
echo ""

# Mostrar el número total de snaps:
echo "Total snaps in pool [srv]:" $(zfs list -t snapshot -o name | grep -c '@')

# Mostrar el total de espacio ocupado por todos los snaps:
zfs list -t snapshot -o space | awk '{sum += $3} END {print "Total space used by ALL the snapshots: " sum " MB"}'
