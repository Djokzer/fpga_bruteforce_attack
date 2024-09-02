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

def cobs_decode(encoded_packet):
    packet = []
    index = 0
    while index < len(encoded_packet)-1:
        length = encoded_packet[index]
        if length == 0 or index + length > len(encoded_packet):
            print("Invalid COBS encoded packet")
            return None
        packet.extend(encoded_packet[index + 1:index + length])
        index += length
        if index < len(encoded_packet) - 1:
            packet.append(0)
    return packet

def decode_packet(encoded_packet):
    decoded_packet = cobs_decode(encoded_packet)
    #print(decoded_packet)
    if decoded_packet == None or len(decoded_packet) == 0:
        return None
    payload_length = decoded_packet[0]
    payload = decoded_packet[1:1 + payload_length]
    received_crc = decoded_packet[1 + payload_length]
    computed_crc = get_payload_crc(payload)

    if received_crc != computed_crc:
        print("CRC mismatch: data might be corrupted")
        return None
    
    return payload

if __name__ == "__main__":
    payload = [0x00, 0x05, 0xFF]
    print(f"Payload : {payload}")
    encoded_packet = gen_packet(payload)
    print(', '.join([hex(i) for i in encoded_packet]))
    decoded_payload = decode_packet(encoded_packet)
    print(f"Payload : {payload}")