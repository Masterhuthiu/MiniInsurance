from fastapi import FastAPI  # 1. Import thư viện
import subprocess

app = FastAPI()               # 2. Khởi tạo app (BẮT BUỘC DÒNG NÀY PHẢI CÓ TRƯỚC)

@app.get("/policies")         # 3. Sử dụng app để định nghĩa endpoint
def read_policies():
    process = subprocess.run(['./FETCHTBL'], capture_output=True, text=True)
    return {"status": "success", "output": process.stdout}