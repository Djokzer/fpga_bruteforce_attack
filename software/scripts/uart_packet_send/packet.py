from crc import crc_8

def get_payload_crc(payload):
    crc = 0
    for d in payload:
        crc = crc_8(crc, d)
        #print(hex(crc))
    return crc

def create_normal_packet(payload):
    crc = get_payload_crc(payload)
    packet = []
    packet.append(len(payload))
    packet = packet + payload
    packet.append(crc)
    return packet

def cobs_encode(packet):
    packet.append(0) # Add the last 0 (packet end)
    last_zero = len(packet)-1
    for i in range(len(packet)-1, -1, -1):
        if packet[i] == 0:
            packet[i] = last_zero - i
            last_zero = i
    return [last_zero + 1] + packet

def gen_packet(data):
    decoded_packet = create_normal_packet(data)
    encoded_packet = cobs_encode(decoded_packet)
    return encoded_packet

if __name__ == "__main__":
    payload = [0x02]
    print(f"Payload : {payload}")
    encoded_packet = gen_packet(payload)
    print(', '.join([hex(i) for i in encoded_packet]))