# 使用Python 3.11的轻量级slim版本作为基础镜像，减少最终镜像体积
FROM python:3.11-slim

# 安装Poetry包管理工具的指定版本（1.6.1）
# 指定版本号可确保构建环境的一致性
RUN pip install poetry==1.6.1

# 配置Poetry不在虚拟环境中安装依赖（直接安装到系统环境）
# 这是Docker容器中的常见做法，可简化依赖管理
RUN poetry config virtualenvs.create false

# 设置容器内的工作目录为/code
# 后续的COPY和RUN命令都将在此目录下执行
WORKDIR /code

# 复制项目的配置文件和依赖锁定文件
# 这些文件变更频率较低，提前复制可利用Docker缓存机制
COPY ./pyproject.toml ./README.md ./poetry.lock* ./

# 复制packages目录（使用[s]处理方括号）
# 包含项目依赖的自定义包或本地模块
COPY ./package[s] ./packages

# 安装项目依赖（不包括项目本身）
# --no-interaction：非交互式安装，用于自动化构建
# --no-ansi：禁用ANSI输出，避免构建日志中出现颜色代码
# --no-root：不安装项目本身，仅安装依赖
# 这一步与后续的安装步骤分离，可避免代码变更时重复安装相同依赖
RUN poetry install  --no-interaction --no-ansi --no-root

# 复制应用代码到工作目录
# 这一步放在依赖安装后，可利用Docker缓存加速构建
COPY ./app ./app

# 安装项目本身（包括项目代码）
# 这一步会覆盖之前的--no-root选项，确保项目代码被正确安装
RUN poetry install --no-interaction --no-ansi

# 声明容器运行时将监听的端口
# 注意：这只是一个声明，不会实际绑定端口
# 对应FastAPI应用配置的端口
EXPOSE 8080

# 使用exec形式运行uvicorn服务器，启动FastAPI应用
# app.server:app 表示从app/server.py模块导入app实例
# --host 0.0.0.0 允许外部访问容器内的服务
# --port 8080 指定服务监听的端口
# 使用exec可使uvicorn直接作为PID 1进程运行，正确处理信号
CMD exec uvicorn app.server:app --host 0.0.0.0 --port 8080