from packet import gen_packet
import serial
import time

if __name__ == "__main__":
    # GENERATE PACKET FROM DATA (TURN OFF ALL THE LEDS)
    data = [0x00]
    packet = gen_packet(data)
    print(f"PACKET TO SEND : {packet}")

    # SEND UART PACKET    
    ser = serial.Serial('/dev/ttyUSB0', 115200)
    ser.write(packet)
    ser.close()

    # TURN ON THE LEDS LIKE A COUNTER
    ser = serial.Serial('/dev/ttyUSB0', 115200)
    for i in range(256):
        data = [i]
        packet = gen_packet(data)
        print(f"PACKET TO SEND : {packet}")
        ser.write(packet)
        time.sleep(0.1)
    ser.close()

