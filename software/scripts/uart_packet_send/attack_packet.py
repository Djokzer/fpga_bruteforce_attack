from packet import gen_packet
from bcrypt_utils import bcrypt_hash

## UTILS
def format_to_pwd_init(init):
    size = len(init)
    out = 0
    for i in range(size-1, -1, -1):
        if init[i] < 2**6:
            out = out + (init[i] << (((size-1) - i) * 6))
    return out

## WORKING PACKETS
def easy_attack():
    # QUADCORE PACKET VALUE
    q_id = 0
    q_crack_max = 100
    q_salt = 0x7e949a07e88186c649bbeb0a9740c5e0
    q_hash = bcrypt_hash(q_salt, b'z')
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
    #print(f"PAYLOAD : {b_q_data}")
    #print(f"PAYLOAD SIZE : {len(b_q_data)}")

    packet = gen_packet(b_q_data)
    return packet

def hard_attack():
    # QUADCORE PACKET VALUE
    q_id = 0
    q_crack_max = 10000
    q_salt = 0x7e949a07e88186c649bbeb0a9740c5e0
    q_hash = bcrypt_hash(q_salt, b'aaa')
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
    #print(f"PAYLOAD : {b_q_data}")
    #print(f"PAYLOAD SIZE : {len(b_q_data)}")

    packet = gen_packet(b_q_data)
    return packet


## NOT WORKING PACKETS
def crc_error():
    # QUADCORE PACKET VALUE
    q_id = 0
    q_crack_max = 100
    q_salt = 0x7e949a07e88186c649bbeb0a9740c5e0
    q_hash = bcrypt_hash(q_salt, b'z')
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
    #print(f"PAYLOAD : {b_q_data}")
    #print(f"PAYLOAD SIZE : {len(b_q_data)}")

    packet = gen_packet(b_q_data)
    packet[-2] = 24 # CRC ERROR
    return packet

def big_packet():    
    # QUADCORE PACKET VALUE
    q_id = 0
    q_crack_max = 100
    q_salt = 0x7e949a07e88186c649bbeb0a9740c5e0
    q_hash = bcrypt_hash(q_salt, b'z')
    #q_hash = 0x1982ade712f9ec3d3a57ce85adf7fc3e2b43d7d89f90d3
    q_pwd_init = 0#format_to_pwd_init([1, 1, 1])
    q_pwd_len = 1
    q_random_data = 55 # Add random bytes to expand packet size

    # PAYLOAD FORMAT
    endianess = "little"
    b_q_id        = q_id.to_bytes(1, endianess)
    b_q_crack_max = q_crack_max.to_bytes(4, endianess)
    b_q_salt      = q_salt.to_bytes(16, endianess)
    b_q_hash      = q_hash.to_bytes(23, endianess)
    b_q_pwd_init  = q_pwd_init.to_bytes(54, endianess)
    b_q_pwd_len   = q_pwd_len.to_bytes(1, endianess)
    b_q_random_data = q_random_data.to_bytes(10, endianess)

    b_q_data = b_q_id + b_q_crack_max + b_q_salt + b_q_hash + b_q_pwd_init + b_q_pwd_len + b_q_random_data
    b_q_data = list(b_q_data)
    #print(f"PAYLOAD : {b_q_data}")
    #print(f"PAYLOAD SIZE : {len(b_q_data)}")

    packet = gen_packet(b_q_data)
    return packet

def small_packet():    
    # QUADCORE PACKET VALUE
    q_id = 0
    q_crack_max = 100
    q_salt = 0x7e949a07e88186c649bbeb0a9740c5e0
    q_hash = bcrypt_hash(q_salt, b'z')
    #q_hash = 0x1982ade712f9ec3d3a57ce85adf7fc3e2b43d7d89f90d3
    q_pwd_init = 0#format_to_pwd_init([1, 1, 1])
    q_pwd_len = 1

    # PAYLOAD FORMAT
    endianess = "little"
    b_q_id        = q_id.to_bytes(1, endianess)
    b_q_crack_max = q_crack_max.to_bytes(4, endianess)
    b_q_salt      = q_salt.to_bytes(16, endianess)
    b_q_hash      = q_hash.to_bytes(23, endianess)
    b_q_pwd_init  = q_pwd_init.to_bytes(50, endianess)  # Normally size = 54, reduced packet size
    b_q_pwd_len   = q_pwd_len.to_bytes(1, endianess)

    b_q_data = b_q_id + b_q_crack_max + b_q_salt + b_q_hash + b_q_pwd_init + b_q_pwd_len
    b_q_data = list(b_q_data)
    #print(f"PAYLOAD : {b_q_data}")
    #print(f"PAYLOAD SIZE : {len(b_q_data)}")

    packet = gen_packet(b_q_data)
    return packet

def wrong_id():    
    # QUADCORE PACKET VALUE
    q_id = 100  # Wrong ID
    q_crack_max = 100
    q_salt = 0x7e949a07e88186c649bbeb0a9740c5e0
    q_hash = bcrypt_hash(q_salt, b'z')
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
    #print(f"PAYLOAD : {b_q_data}")
    #print(f"PAYLOAD SIZE : {len(b_q_data)}")

    packet = gen_packet(b_q_data)
    return packet

