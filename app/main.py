from fastapi import FastAPI

app = FastAPI(title="github-devops")


@app.get("/")
def root():
    return {
        "service": "github-devops",
        "version": "0.1.0",
    }


@app.get("/health")
def health():
    return {
        "status": "ok",
    }
