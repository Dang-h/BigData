# Reids

## 部署

### 单机部署

- [下载](https://redis.io/download)Reids安装包，解压到指定目录。

- 进入解压目录，执行make命令，安装Redis到指定目录：

  - 先检查是否安装gcc和gcc-c++

    `sudo yum -y install gcc-c++ gcc`

  - 然后执行：

    `make PREFIX=/opt/module/redis-6.0.4 install`

- 将源文件下的配置文件`redis.conf` 和`sentinel.conf`拷贝到安装目录

- 修改配置文件

  ```bash
  vim redis.conf
  将69行，bind 127.0.0.1注释掉，以便外网访问
  # bind 127.0.0.1
  88行，protected-mod yes修改为no
  protected-mod no
  136行，开启后台运行
  daemonize yes
  ```

- 启动；`./bin/redis-server ./conf/redis.conf`

- 查看进程`ps -ef | grep redis`