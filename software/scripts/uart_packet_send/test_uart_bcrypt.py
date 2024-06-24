from packet import gen_packet
from bcrypt_utils import bcrypt_hash
from attack_packet import easy_attack, crc_error, big_packet, small_packet, hard_attack, wrong_id
import serial



if __name__ == "__main__":

    packet = crc_error()
    print(f"PACKET TO SEND : {packet}")

    # SEND UART PACKET    
    ser = serial.Serial('/dev/ttyUSB0', 115200)
    ser.write(packet)
    ser.close()