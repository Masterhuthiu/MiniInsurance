from fastapi import FastAPI
import subprocess
import os

app = FastAPI()

@app.get("/")
def root():
    return {"message": "COBOL Microservice API is Online", "port": 8000}

@app.get("/policies")
def read_policies():
    process = subprocess.run(['./FETCHTBL'], capture_output=True, text=True)
    
    # 1. Tách chuỗi thành các dòng
    lines = process.stdout.split('\n')
    
    # 2. Lọc lấy các dòng chứa dữ liệu (Bỏ dòng có dấu * hoặc - hoặc rỗng)
    # Dòng dữ liệu bắt đầu bằng số (NO)
    data_lines = [line for line in lines if line.strip() and not line.startswith('*') and not line.startswith('-') and 'NO' not in line]
    
    results = []
    for line in data_lines:
        # Cắt chuỗi dựa trên khoảng trắng (splitting by multiple spaces)
        parts = line.split()
        if len(parts) >= 3:
            # Ghép tên lại nếu tên có khoảng trắng (ví dụ: Master Huthiu)
            results.append({
                "no": parts[0],
                "name": " ".join(parts[1:-1]),
                "salary": parts[-1]
            })

    return {
        "status": "success",
        "total": len(results),
        "data": results
    }

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