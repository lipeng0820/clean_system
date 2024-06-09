#!/bin/bash

# 定义总的步骤数
TOTAL_STEPS=10
CURRENT_STEP=0

# 显示进度条函数
show_progress() {
    CURRENT_STEP=$((CURRENT_STEP + 1))
    echo -ne "[$CURRENT_STEP/$TOTAL_STEPS] $1...\r"
}

# 更新包列表
show_progress "更新包列表"
sudo apt-get update | pv -lep -s $TOTAL_STEPS > /dev/null

# 清理包缓存
show_progress "清理包缓存"
sudo apt-get clean | pv -lep -s $TOTAL_STEPS > /dev/null

# 移除不再需要的依赖包
show_progress "移除不再需要的依赖包"
sudo apt-get autoremove -y | pv -lep -s $TOTAL_STEPS > /dev/null

# 清理日志文件
show_progress "清理日志文件"
sudo journalctl --vacuum-time=2weeks | pv -lep -s $TOTAL_STEPS > /dev/null

# 停止所有容器
show_progress "停止所有容器"
docker stop $(docker ps -aq) | pv -lep -s $TOTAL_STEPS > /dev/null

# 删除所有容器
show_progress "删除所有容器"
docker rm $(docker ps -aq) | pv -lep -s $TOTAL_STEPS > /dev/null

# 删除所有未使用的镜像
show_progress "删除所有未使用的镜像"
docker image prune -a -f | pv -lep -s $TOTAL_STEPS > /dev/null

# 删除所有未使用的卷
show_progress "删除所有未使用的卷"
docker volume prune -f | pv -lep -s $TOTAL_STEPS > /dev/null

# 删除所有未使用的网络
show_progress "删除所有未使用的网络"
docker network prune -f | pv -lep -s $TOTAL_STEPS > /dev/null

# 查找并显示超过 100M 的文件
show_progress "查找大文件"
find / -type f -size +100M -exec ls -lh {} \; | pv -lep -s $TOTAL_STEPS > /dev/null

# 清理大文件（如果确定可以删除这些大文件，可以取消注释下面的命令）
# show_progress "删除大文件"
# find / -type f -size +100M -exec rm -f {} \; | pv -lep -s $TOTAL_STEPS > /dev/null

echo -ne "\n系统和 Docker 清理完成\n"
