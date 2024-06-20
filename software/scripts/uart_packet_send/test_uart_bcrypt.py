from packet import gen_packet
from bcrypt_utils import bcrypt_hash
import serial

def format_to_pwd_init(init):
    size = len(init)
    out = 0
    for i in range(size-1, -1, -1):
        if init[i] < 2**6:
            out = out + (init[i] << (((size-1) - i) * 6))
    return out


if __name__ == "__main__":
    # QUADCORE PACKET VALUE
    q_id = 10
    q_crack_max = 5
    q_salt = 0x7e949a07e88186c649bbeb0a9740c5e0
    q_hash = bcrypt_hash(q_salt, b'aaaz')
    #q_hash = 0x1982ade712f9ec3d3a57ce85adf7fc3e2b43d7d89f90d3
    q_pwd_init = 0#format_to_pwd_init([1, 1, 1])
    q_pwd_len = 1

    # PAYLOAD FORMAT
    endianess = "little"
    b_q_id        = q_id.to_bytes(1, endianess)
    b_q_crack_max = q_crack_max.to_bytes(4, endianess)
    b_q_salt      = q_salt.to_bytes(16, endianess)
    b_q_hash      = q_hash.to_bytes(23, endianess)
    b_q_pwd_init  = q_pwd_init.to_bytes(54, endianess)
    b_q_pwd_len   = q_pwd_len.to_bytes(1, endianess)

    b_q_data = b_q_id + b_q_crack_max + b_q_salt + b_q_hash + b_q_pwd_init + b_q_pwd_len
    b_q_data = list(b_q_data)
    print(f"PAYLOAD : {b_q_data}")
    print(f"PAYLOAD SIZE : {len(b_q_data)}")

    packet = gen_packet(b_q_data)
    print(f"PACKET TO SEND : {packet}")

    # SEND UART PACKET    
    ser = serial.Serial('/dev/ttyUSB0', 115200)
    ser.write(packet)
    ser.close()