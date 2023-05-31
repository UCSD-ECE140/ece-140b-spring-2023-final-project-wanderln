import serial # the PySerial library
import time   # for timing purposes

# Send serial message
def send_message(ser, message):
  if(message[-1] != '\n'):
    message = message + '\n'
  ser.write(message.encode('utf-8'))

# Setup serial port
def setup(serial_name, baud_rate):
  ser = serial.Serial(serial_name, baudrate=baud_rate)
  return ser

# Close serial port
def close(ser):
  ser.close()

# Receive a message from Serial and limit it to num_bytes (default of 50)
def receive_message(ser, num_bytes=50):
  if(ser.in_waiting > 0):
      return ser.readline(num_bytes).decode('utf-8')
  else:
      return None

# Main code
def main():
  ser = setup("COM5", 115200)
  send_message(ser, "hello world\n")
  time.sleep(3)
  message = receive_message(ser)
  print(message)  
  close(ser)

# Main entrypoint for the application
if __name__== "__main__":
  main()