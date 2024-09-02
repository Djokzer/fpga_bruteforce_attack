from bcrypt_utils import bcrypt_hash
from packet import gen_packet, decode_packet
from math import log, ceil
import serial
import tqdm

class BcryptCracker:
	def __init__(self, filename):
		with open(filename) as f:
			data = f.readlines()
			data = list(map(lambda x : x.replace('\n', ''), data))
			print(data)
		
		self.port = data[0]
		self.quadcore_count = int(data[1])
		self.max_try_per_qc = int(data[2])
		self.salt = int(data[3][2:], 16)
		self.hash = int(data[4][2:], 16)
		self.init_count = int(data[5])
		self.count_len = int(data[6])
		self.packets = []

	def gen_packets(self):
		for i in range(self.quadcore_count):
			quadcore_init_count = i * self.max_try_per_qc + self.init_count
			#print(quadcore_init_count)
			if i == 0:
				quadcore_count_len = self.count_len
			else:
				quadcore_count_len = ceil(log(quadcore_init_count, 62))
			self.packets.append(self.gen_quadcore_init_packet(
				i, 
				self.max_try_per_qc, 
				self.salt, 
				self.hash,
				quadcore_init_count,
				quadcore_count_len
			))
	
	def start_attack(self):
		ser = serial.Serial(self.port, baudrate=115200)
		decoded_packet = None
		password_found = False

		# SEND QUADCORE INIT PACKETS
		print("SEND QUADCORE INIT PACKET")
		for packet in tqdm.tqdm(self.packets):
			ser.write(packet)
			return_packet = []
			#print(f"PACKET : {packet}")
			while(True):
				data = list(ser.read(1))
				if len(data) > 0:
					return_packet.append(data[0])
					if data[0] == 0:
						#print("RECEIVED PACKET")
						#print(return_packet)
						decoded_packet = decode_packet(return_packet)
						if decoded_packet != None:
							#print("DECODED PACKET")
							#print(decoded_packet)
							if decoded_packet[0] >> 3 == 0:
								break
						return_packet.clear()
		
		# WAIT FOR PASSWORD
		print("WAIT FOR PASSWORD")
		return_packet = []
		while(True):
			data = list(ser.read(1))
			if len(data) > 0:
				return_packet.append(data[0])
				if data[0] == 0:
					#print("RECEIVED PACKET")
					#print(return_packet)
					decoded_packet = decode_packet(return_packet)
					if decoded_packet != None:
						# print("DECODED PACKET")
						# print(decoded_packet)
						
						# password found
						if decoded_packet[0] == 0x10:
							password_found = True
							break
						elif decoded_packet[0] == 0x08:
							status = (decoded_packet[1] << 24) + (decoded_packet[2] << 16) + (decoded_packet[3] << 8) + decoded_packet[4]
							print(f"PASSWORD TRIED : {status * self.quadcore_count}")
							if status >= self.max_try_per_qc-1:
								break
					return_packet.clear()	
		
		# FORMAT PASSWORD
		if password_found:
			password_packet = decoded_packet[1:]
			pwd = ""
			for p in password_packet:
				if p == 0:
					break
				pwd += chr(p)
			print("PASSWORD FOUND !!!!")
			print(f"Password : {pwd}")
		else:
			print("PASSWORD NOT FOUND !!!")
	
		ser.close()

	def gen_quadcore_init_packet(self, id = 0, crack_max=1000, 
					salt=0x7e949a07e88186c649bbeb0a9740c5e0, 
					hash=0, pwd_init=0, pwd_len=1):
		# QUADCORE PACKET VALUE
		q_id = id
		q_crack_max = crack_max
		q_salt = salt
		q_hash = hash	#bcrypt_hash(q_salt, hash)
		#q_hash = 0x1982ade712f9ec3d3a57ce85adf7fc3e2b43d7d89f90d3
		q_pwd_init = pwd_init
		q_pwd_len = pwd_len

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