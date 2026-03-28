from fastapi import FastAPI
import subprocess
import os

app = FastAPI()

@app.get("/")
def root():
    return {"message": "COBOL Microservice API is Online", "port": 8000}

@app.get("/policies")
def read_policies():
    try:
        # Kiểm tra file FETCHTBL có tồn tại không trước khi gọi
        if not os.path.exists("./FETCHTBL"):
            return {"status": "error", "message": "File FETCHTBL không tồn tại trong thư mục /app"}

        # Gọi file COBOL và lấy kết quả
        process = subprocess.run(
            ['./FETCHTBL'], 
            capture_output=True, 
            text=True, 
            timeout=10 # Tránh treo API nếu COBOL bị loop vô tận
        )

        if process.returncode == 0:
            return {
                "status": "success",
                "output": process.stdout
            }
        else:
            return {
                "status": "error",
                "message": "COBOL Execution Failed",
                "error_details": process.stderr
            }

    except Exception as e:
        return {"status": "exception", "details": str(e)}

# Để debug: nếu chạy python main.py trực tiếp
if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)

# from fastapi import FastAPI
# import subprocess

# app = FastAPI()

# @app.get("/policies")
# def read_policies():
#     # Gọi file COBOL và lấy kết quả trả về
#     process = subprocess.run(['./FETCHTBL'], capture_output=True, text=True)
#     return {"status": "success", "output": process.stdout}