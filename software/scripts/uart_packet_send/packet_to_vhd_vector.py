from packet import gen_packet

if __name__ == "__main__":
    # QUADCORE PACKET VALUE
    q_id = 0
    q_crack_max = 5
    q_salt = 0x7e949a07e88186c649bbeb0a9740c5e0
    q_hash = 0x1982ade712f9ec3d3a57ce85adf7fc3e2b43d7d89f90d3
    q_pwd_init = 0
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

    packet = gen_packet(b_q_data)
    #print(f"PACKET LEN : {len(packet)}")

    # Create our base output
    out = "constant PACKET : std_logic_vector(823 downto 0) :=\n"

    # For each line
    count = 0
    for data in packet:        
        if count == 0:
            out += "x\""
        
        out += f"{data:02x}"
        count += 1

        if count < 20:
            out += "_"
        else:
            out += "\" &\n"
            count = 0

    if out[-1] == '_':
        out = out[:-1] + "\""
    out += ";"

    print(out)