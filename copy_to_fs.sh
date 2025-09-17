#!/usr/bin/env bash

storage_device="${1}"

umount "${storage_device}"
echo "MOUNTING..."
mkdir -p mount
mount "${storage_device}" mount

echo "COPYING..."
cp -v build/PONG.DDI mount

echo "UNMOUNTING..."
umount "${storage_device}"
echo "COMPLETE"
