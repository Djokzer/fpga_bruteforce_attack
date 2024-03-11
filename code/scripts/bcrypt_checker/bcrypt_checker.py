import bcrypt
from base64 import b64encode, b64decode

def base64_to_bcrypt_base64(input_bytes):
    base64 = b'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
    bcrypt_base64 = b'./ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789'
    output_bytes = bytearray()
    for i in range(0, len(input_bytes)):
        for j in range(0, len(base64)):
            if input_bytes[i] == base64[j]:
                output_bytes.append(bcrypt_base64[j])
                break
    return bytes(output_bytes)

def bcrypt_base64_to_base64(input_bytes):
    base64 = b'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
    bcrypt_base64 = b'./ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789'
    output_bytes = bytearray()
    for i in range(0, len(input_bytes)):
        for j in range(0, len(bcrypt_base64)):
            if input_bytes[i] == bcrypt_base64[j]:
                output_bytes.append(base64[j])
                break
    return bytes(output_bytes)

header = '$2a$04$'  # Cost factor 4
passwd = "620062006200620062006200620062006200620062006200620062006200620062006200620062006200620062006200620062006200620062006200620062006200620062006200"
passwd = bytes.fromhex(passwd)
passwd = b'aaaab'
passwd = b'pomme'
salt = "70949a17e89186c649bbeb0a9740c630"
salt = b64encode(bytes.fromhex(salt)).decode()[:22]
salt = salt.encode('utf-8')
salt = base64_to_bcrypt_base64(salt)
salt = header + salt.decode()
salt = salt.encode('utf-8')
hashed = bcrypt.hashpw(passwd, salt)
print(hashed)
hashed_pwd = bcrypt_base64_to_base64(hashed[-31:])
hashed_pwd = hashed_pwd + b'='
h = b64decode(hashed_pwd).hex()

#val_hex = "d14485763c99f8b88725385c91ce57d5937dbec181c0a2c5"
#val = b64encode(bytes.fromhex(val_hex[:-2]))
#val = base64_to_bcrypt_base64(val)
print(f"Salt: {salt}")
print(f"Hashed password: {hashed[-31:]}")
print(f"Hashed password hex: {h}")
#print(f"Tested hash    : {val}")
#print(f"Tested hash on hex : {val_hex}")