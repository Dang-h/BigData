#!/bin/bash
#1. 判断参数个数
if [ $# -lt 1 ]
then
    echo Not Enough Arguement!
    exit;
fi

#2. 遍历所有目录，挨个发送
for file in $@
do
    #4.5 判断文件是否存在
    if [ -e $file ]
    then
        #3. 获取父目录
        pdir=$(cd -P $(dirname $file); pwd)
        
        #4. 获取当前文件的名称
        fname=$(basename $file)
        
        
        
        #5. 遍历集群所有机器，拷贝
        for host in $(cat /etc/hosts | grep 192)
        do
            echo ====================    $host    ====================
            rsync -av $pdir/$fname $USER@$host:$pdir
        done
    else
        echo $file does not exists!
    fi
done
