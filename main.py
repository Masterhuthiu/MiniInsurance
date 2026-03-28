from fastapi import FastAPI
import subprocess

# KHỞI TẠO APP TRƯỚC KHI DÙNG DECORATOR
app = FastAPI()

@app.get("/policies")
def read_policies():
    # Gọi file thực thi COBOL
    process = subprocess.run(['./FETCHTBL'], capture_output=True, text=True)
    return {
        "status": "success", 
        "data": process.stdout
    }

@app.get("/")
def root():
    return {"message": "COBOL API is running on port 8000"}