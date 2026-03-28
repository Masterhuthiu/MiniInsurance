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
    lines = process.stdout.split('\n')
    
    results = []
    for line in lines:
        line = line.strip()
        # LOẠI BỎ: Dòng trống, dòng tiêu đề, dòng gạch ngang, và dòng TOTAL RECORD
        if not line or line.startswith('*') or line.startswith('-') or 'NAME' in line or 'TOTAL' in line:
            continue
            
        parts = line.split()
        if len(parts) >= 3:
            # Lấy số thứ tự (no)
            no = parts[0]
            # Lấy lương (salary) là phần tử cuối cùng
            salary = parts[-1]
            # Ghép tất cả các phần tử ở giữa lại thành tên (name)
            name = " ".join(parts[1:-1])
            
            results.append({
                "no": no,
                "name": name,
                "salary": salary
            })

    return {
        "status": "success",
        "total_records": len(results),
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