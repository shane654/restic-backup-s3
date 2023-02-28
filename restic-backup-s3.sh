#!/bin/bash

export HOSTNAME=$(hostname)
export PUBLIC_IP=$(curl -s http://checkip.amazonaws.com)
export PRIVATE_IP=$(hostname -I | awk '{print $1}')

repository_name="s3:f1k7.la.idrivee2-19.com/server-backup/[$PUBLIC_IP]-[$PRIVATE_IP]-$HOSTNAME"

# 检查restic是否安装
if ! command -v restic &> /dev/null
then
    echo "restic 未安装，现在开始安装..."
    # 安装restic
    # 这里假设使用apt-get进行安装
    sudo apt-get update && sudo apt-get install restic -y
fi

# 检查存储库是否存在
if ! restic -r $repository_name snapshots &> /dev/null
then
    echo "存储库 $repository_name 不存在，现在开始创建..."
    # 创建存储库
    restic init -r $repository_name
fi

# 备份
restic -r $repository_name --verbose backup "/www/backup/site" "/www/backup/database" "/www/wwwroot/apps" "/www/apps"
