from fastapi import FastAPI
from fastapi.responses import RedirectResponse
from langserve import add_routes

app = FastAPI()


@app.get("/")
async def redirect_root_to_docs() -> RedirectResponse:
    """将根路径(/)的请求重定向到Swagger文档页面(/docs)"""
    return RedirectResponse("/docs")


# 编辑此处以添加想要暴露为API的LangChain链
# 当前使用NotImplemented作为占位符，表示尚未配置具体的链
# 示例用法：add_routes(app, MyChain(), path="/my-chain")
add_routes(app, NotImplemented)

if __name__ == "__main__":
    import uvicorn

    uvicorn.run(app, host="0.0.0.0", port=8000)
