# 食用指南

这里是用于构建 Lotus Docker 镜像的一些文件，构建时的目录结构如下所示。

```
.
├── certs
│   └── ...
├── daemon-entrypoint.sh
├── Dockerfile
├── lib
│   ├── libdl-2.27.so
│   ├── libgcc_s.so.1
│   ├── libOpenCL.so.1
│   ├── librt-2.27.so
│   └── libutil-2.27.so
├── lotus
├── run-daemon.sh
└── tini
```

构建前请自行编译 Lotus 可执行文件，请确保编译机器使用 Ubuntu 18.04.4 server 系统，编译后在本机上能正常运行。

运行 Lotus 所需的文件可以使用 build-docker.sh 生成，此脚本也会自动打包镜像。~~或者在 release 页面下载已经准备好的文件（certs 目录请自行准备）。~~

使用 run-daemon.sh 脚本可在后台启动 Lotus。