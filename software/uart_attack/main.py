from bcrypt_cracker import BcryptCracker
import serial

def print_ports():
    import serial.tools.list_ports
    ports = list(serial.tools.list_ports.comports())
    for p in ports:
        print(p)

if __name__ == "__main__":
    #print_ports()
    cracker = BcryptCracker("abc.conf")
    cracker.gen_packets()
    cracker.start_attack()

