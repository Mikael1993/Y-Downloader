# Use a lightweight Python base image
FROM python:3.10-slim

# Install system dependencies (FFmpeg, Curl, Node.js, Deno)
RUN apt-get update && apt-get install -y \
    ffmpeg \
    curl \
    unzip \
    && curl -fsSL https://deno.land/x/install/install.sh | sh \
    && mv /root/.deno/bin/deno /usr/local/bin/deno \
    && curl -fsSL https://deb.nodesource.com/setup_18.x | bash - \
    && apt-get install -y nodejs \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Set the working directory inside the container
WORKDIR /app

# Copy requirements and install python packages
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy the rest of the application files
COPY . .

# Expose port (Render overrides this with the PORT environment variable)
EXPOSE 8000

# Start Uvicorn, binding to Render's injected PORT environment variable (default to 8000)
CMD ["sh", "-c", "uvicorn main:app --host 0.0.0.0 --port ${PORT:-8000}"]
