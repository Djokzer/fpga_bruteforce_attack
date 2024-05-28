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

payload = [0x01, 0x00, 0x02]
print(f"Payload : {payload}")
packet = create_normal_packet(payload)
#print(packet)
encoded_packet = cobs_encode(packet)
print(', '.join([hex(i) for i in encoded_packet]))