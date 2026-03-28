@app.get("/policies")
def read_policies():
    process = subprocess.run(['./FETCHTBL'], capture_output=True, text=True)
    # Tách các dòng, lọc bỏ các dòng tiêu đề và dấu gạch ngang
    lines = process.stdout.split('\n')
    data_only = [line for line in lines if line.strip() and not line.startswith('*') and not line.startswith('-') and 'NAME' not in line]
    return {"status": "success", "data": data_only}