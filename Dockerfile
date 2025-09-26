FROM node:18-alpine

# Buat direktori kerja di dalam container
WORKDIR /app

# Salin package.json dan package-lock.json
COPY package*.json ./

# Instal dependensi
RUN npm install && \
    npm fund
# Salin sisa kode aplikasi
COPY . .

# Ekspos port 3000
EXPOSE 3000

# Jalankan aplikasi saat container dimulai
CMD ["npm", "start"]
