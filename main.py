from fastapi import FastAPI
import subprocess

app = FastAPI()

@app.get("/policies")
def read_policies():
    # Gọi file COBOL và lấy kết quả trả về
    process = subprocess.run(['./FETCHTBL'], capture_output=True, text=True)
    return {"status": "success", "output": process.stdout}