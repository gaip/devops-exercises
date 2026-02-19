# Use a lightweight Python base image
FROM python:3.9-slim

# Set the working directory
WORKDIR /app

# Copy requirements and install dependencies
COPY src/requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy the rest of the source code
COPY src/ .

# IMPORTANT: Fix permissions for OpenShift (Random UID)
# We change ownership to a non-root user and allow access to /app
RUN chown -R 1001:0 /app && \
    chmod -R g+w /app

# Switch to the non-root user (Standard UID for unprivileged)
USER 1001

# Expose the application port
EXPOSE 8080

# Run the application
CMD ["python", "main.py"]
