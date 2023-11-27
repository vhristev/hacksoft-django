# Base image
FROM python:3.11-slim-bullseye

# Set working directory
WORKDIR /app

# Prevents Python from writing pyc files to disc
ENV PYTHONDONTWRITEBYTECODE 1
#Prevents Python from buffering stdout and stderr
ENV PYTHONUNBUFFERED 1
# Copy whole project to your docker home directory.
COPY requirements.txt /app

# install dependencies
RUN pip install --upgrade pip
# run this command to install all dependencies
RUN pip install -r requirements.txt
# port where the Django app runs

COPY myproject  /app
# start server
CMD python manage.py runserver 0.0.0.0:8000
