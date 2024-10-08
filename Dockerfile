# Use an official Python runtime as a parent image
FROM python:3.9-slim

# Set the working directory
WORKDIR /app

# Copy the requirements file first
COPY app/requirements.txt /app/
RUN pip install --upgrade pip

# Install any needed packages specified in requirements.txt
RUN pip install --no-cache-dir -r requirements.txt

# Copy the rest of the application files
COPY app /app

# Make port 80 available to the world outside this container
EXPOSE 80

# Debug: List the contents of the working directory
RUN ls -la /app

# Run app.py when the container launches
CMD ["python", "shodan_app.py"]
