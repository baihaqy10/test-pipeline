# Dockerfile
# Gunakan image base Python resmi
FROM python:3.9-slim

# Set working directory di dalam container
WORKDIR /app

# Salin file requirements.txt ke container
COPY requirements.txt .

# Instal dependensi yang diperlukan
RUN pip install --no-cache-dir -r requirements.txt

# Salin semua file kode aplikasi ke container
COPY . .

# Definisikan port yang akan diekspos oleh container
EXPOSE 8080

# Jalankan aplikasi saat container di-run
CMD ["python", "app.py"]