from packet import gen_packet
from bcrypt_utils import bcrypt_hash
from attack_packet import easy_attack, crc_error, big_packet, small_packet, hard_attack, wrong_id
import serial

def print_ports():
    import serial.tools.list_ports
    ports = list(serial.tools.list_ports.comports())
    for p in ports:
        print(p)

if __name__ == "__main__":

    #print_ports()

    packet = easy_attack()
    print(f"PACKET TO SEND : {packet}")

    # SEND UART PACKET    
    #ser = serial.Serial('/dev/ttyUSB0', 115200)
    ser = serial.Serial('COM4', 115200, timeout=5.0)
    ser.write(packet)
    return_val = list(ser.read(5))
    print(', '.join([hex(i) for i in return_val]))
    ser.close()