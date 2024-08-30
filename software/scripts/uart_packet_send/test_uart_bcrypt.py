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
    print_ports()

    # OPEN SERIAL PORT
    ser = serial.Serial('/dev/ttyUSB0', 115200, timeout=0.01)

    # for i in range(50):
    #     print(list(ser.read(1)))    

    # SEND UART PACKET    
    # packet = hard_attack()
    # print(f"PACKET TO SEND : {packet}")
    # ser.write(packet)
    for i in range(22):
        packet = hard_attack(i)
        ser.write(packet)

    return_packet = []
    while(True):
        return_val = list(ser.read(1))
        if len(return_val) > 0:
            return_packet.append(return_val[0])
            if return_val[0] == 0:
                print("RECEIVED PACKET")
                print(return_packet)
                if return_packet[2] == 0x10:
                    break
                return_packet.clear()


    # CLOSE SERIAL PORT
    ser.close()


    # while(True):
    #     print(ser.read(1))

    # data_buffer = []
    # for i in range(100):
    #     data_buffer.append(list(ser.read(1)))

    # data = []
    # for i in range(100):
    #     if len(data_buffer[i]) > 0:
    #         data.append(data_buffer[i][0])
    # print("RECEIVED DATA ")
    # print(', '.join([hex(i) for i in data]))

