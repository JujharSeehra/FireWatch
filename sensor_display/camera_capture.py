import subprocess
import time
import os

IMAGE = "/var/www/html/images/latest.jpg"

while True:
    result = subprocess.run([
        "rpicam-still",
        "-n",
        "--immediate",
        "--width",
        "640",
        "--height",
        "480",
        "-o",
        IMAGE
    ])

    if result.returncode == 0:
        print("Image captured")
    else:
        print("Camera capture failed")

    time.sleep(2)
