# set base image (host OS)
FROM python:3.8

# set the working directory in the container
WORKDIR /code

# copy the dependencies file to the working directory
COPY requirements.txt .

# install dependencies
RUN pip install -r requirements.txt

# copy the content of the local src directory to the working directory
COPY /compliancescanner .

# command to run on container start
CMD [ "python", "./app.py" ]

# exposing the container on port no 5000 so within docker network other containers can access it
EXPOSE 5000