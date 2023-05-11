# debug rsync 

## 服务器上操作

### 开启rsync服务端
> debug rsync

## 本地机器上操作
### 本地编译Go二进制文件
> GOOS=linux GOARCH=amd64 go build -gcflags=all='-N -l'

### 上传编译后的二进制文件
> rsync -avzP --port 8014 <二进制文件> xiaoju@<服务器IP>::xiaoju