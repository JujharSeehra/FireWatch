import serial
import threading
from flask import Flask, jsonify
from flask_cors import CORS

app = Flask(__name__)
CORS(app)
latest = {
    "temperature": None,
    "humidity": None,
}

def serial_reader():

    ser = serial.Serial(
        "/dev/ttyACM0",
        9600,
        timeout = 1
    )

    while True:
        try:
            line = ser.readline().decode().strip()
            if line:
                temp, hum = line.split(",")
                latest["temperature"]=float(temp)
                latest["humidity"]=float(hum)

                print(latest)
        except Exception as e:
            print(e)
@app.route("/sensor")
def sensor():
    return jsonify(latest)
if __name__ == "__main__":
    thread = threading.Thread(target = serial_reader)
    thread.daemon = True
    thread.start()
    app.run(host = "0.0.0.0", port = 5000)
