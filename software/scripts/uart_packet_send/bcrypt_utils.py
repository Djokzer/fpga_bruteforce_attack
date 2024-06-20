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

def bcrypt_hash(h_salt, pwd):
    salt = f"{h_salt:x}"
    header = '$2b$04$'  # Cost factor 4
    salt = b64encode(bytes.fromhex(salt)).decode()[:22]
    salt = salt.encode('utf-8')
    salt = base64_to_bcrypt_base64(salt)
    salt = header + salt.decode()
    salt = salt.encode('utf-8')
    hashed = bcrypt.hashpw(pwd, salt)
    hashed_pwd = bcrypt_base64_to_base64(hashed[-31:])
    hashed_pwd = hashed_pwd + b'='
    h = b64decode(hashed_pwd).hex()
    return int(h, 16)

if __name__ == "__main__":
    h = bcrypt_hash(0x7e949a07e88186c649bbeb0a9740c5e0, b'a')