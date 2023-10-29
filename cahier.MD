# FPGA BRUTEFORCE ATTACK

## Docs
### Articles
Bcrypt :
- https://hackaday.com/2020/05/15/all-your-passwords-are-belong-to-fpga/
- https://ieeexplore.ieee.org/document/7032529

HLS :
- https://arodes.hes-so.ch/record/11719

### Docs
Bcrypt :
- https://en.wikipedia.org/wiki/Bcrypt
- ??

Blowfish :
- https://en.wikipedia.org/wiki/Blowfish_(cipher)
- https://www.geeksforgeeks.org/blowfish-algorithm-with-examples/

### Other

VHDL code :
- https://github.com/rub-hgi/high-speed_bcrypt

## Bcrypt algorithm

Pseudo-code example :

```js
Function bcrypt
   Input:
      cost:     Number (4..31)                      log2(Iterations). e.g. 12 ==> 212 = 4,096 iterations
      salt:     array of Bytes (16 bytes)           random salt
      password: array of Bytes (1..72 bytes)        UTF-8 encoded password
   Output: 
      hash:     array of Bytes (24 bytes)

   //Initialize Blowfish state with expensive key setup algorithm
   //P: array of 18 subkeys (UInt32[18])
   //S: Four substitution boxes (S-boxes), S0...S3. Each S-box is 1,024 bytes (UInt32[256])
   P, S ← EksBlowfishSetup(password, salt, cost)   

   //Repeatedly encrypt the text "OrpheanBeholderScryDoubt" 64 times
   ctext ← "OrpheanBeholderScryDoubt"  //24 bytes ==> three 64-bit blocks
   repeat (64)
      ctext ← EncryptECB(P, S, ctext) //encrypt using standard Blowfish in ECB mode

   //24-byte ctext is resulting password hash
   return Concatenate(cost, salt, ctext)
```

```js
Function EksBlowfishSetup
   Input:
      password: array of Bytes (1..72 bytes)   UTF-8 encoded password
      salt:     array of Bytes (16 bytes)      random salt
      cost:     Number (4..31)                 log2(Iterations). e.g. 12 ==> 212 = 4,096 iterations
   Output: 
      P:        array of UInt32                array of 18 per-round subkeys
      S1..S4:   array of UInt32                array of four SBoxes; each SBox is 256 UInt32 (i.e. each SBox is 1 KiB)

   //Initialize P (Subkeys), and S (Substitution boxes) with the hex digits of pi 
   P, S ← InitialState() 
 
   //Permute P and S based on the password and salt     
   P, S ← ExpandKey(P, S, password, salt)

   //This is the "Expensive" part of the "Expensive Key Setup".
   //Otherwise the key setup is identical to Blowfish.
   repeat (2cost)
      P, S ← ExpandKey(P, S, password, 0)
      P, S ← ExpandKey(P, S, salt, 0)

   return P, S
```

```js
Function ExpandKey
   Input:
      P:        array of UInt32               Array of 18 subkeys
      S1..S4:   UInt32[1024]                  Four 1 KB SBoxes
      password: array of Bytes (1..72 bytes)  UTF-8 encoded password
      salt:     Byte[16]                      random salt
   Output: 
      P:        array of UInt32               Array of 18 per-round subkeys
      S1..S4:   UInt32[1024]                  Four 1 KB SBoxes       
 
   //Mix password into the P subkeys array
   for n ← 1 to 18 do
      Pn ← Pn xor password[32(n-1)..32n-1] //treat the password as cyclic
 
   //Treat the 128-bit salt as two 64-bit halves (the Blowfish block size).
   saltHalf[0] ← salt[0..63]  //Lower 64-bits of salt
   saltHalf[1] ← salt[64..127]  //Upper 64-bits of salt

   //Initialize an 8-byte (64-bit) buffer with all zeros.
   block ← 0

   //Mix internal state into P-boxes   
   for n ← 1 to 9 do
      //xor 64-bit block with a 64-bit salt half
      block ← block xor saltHalf[(n-1) mod 2] //each iteration alternating between saltHalf[0], and saltHalf[1]

      //encrypt block using current key schedule
      block ← Encrypt(P, S, block) 
      P2n ← block[0..31]      //lower 32-bits of block
      P2n+1 ← block[32..63]  //upper 32-bits block

   //Mix encrypted state into the internal S-boxes of state
   for i ← 1 to 4 do
      for n ← 0 to 127 do
         block ← Encrypt(state, block xor salt[64(n-1)..64n-1]) //as above
         Si[2n]   ← block[0..31]  //lower 32-bits
         Si[2n+1] ← block[32..63]  //upper 32-bits
    return state
```

## Blowfish algorithm

```c
uint32_t P[18];
uint32_t S[4][256];

uint32_t f (uint32_t x) {
   uint32_t h = S[0][x >> 24] + S[1][x >> 16 & 0xff];
   return ( h ^ S[2][x >> 8 & 0xff] ) + S[3][x & 0xff];
}

void blowfish_encrypt(uint32_t *L, uint32_t *R) {
    for (short r = 0; r < 16; r++) {
		*L = *L ^ P[r];
		*R = f(*L) ^ *R;
		swap(L, R);
	}
	swap(L, R);
	*R = *R ^ P[16];
	*L = *L ^ P[17];
}

void blowfish_decrypt(uint32_t *L, uint32_t *R) {
	for (short r = 17; r > 1; r--) {
		*L = *L ^ P[r];
		*R = f(*L) ^ *R;
		swap(L, R);
	}
	swap(L, R);
	*R = *R ^ P[1];
	*L = *L ^ P[0];
}

  // ...
  // initializing the P-array and S-boxes with values derived from pi; omitted in the example
  // ...
  
{
	/* initialize P box w/ key*/
	uint32_t k;
	for (short i = 0, p = 0; i < 18; i++) {
		k = 0x00;
		for (short j = 0; j < 4; j++) {
			k = (k << 8) | (uint8_t) key[p];
			p = (p + 1) % key_len;
		}
		P[i] ^= k;
	}
   
	/* blowfish key expansion (521 iterations) */
	uint32_t l = 0x00, r = 0x00;
	for (short i = 0; i < 18; i+=2) {
		blowfish_encrypt(&l, &r);
		P[i] = l; 
		P[i+1] = r;
	}
	for (short i = 0; i < 4; i++) {
		for (short j = 0; j < 256; j+=2) {
			blowfish_encrypt(&l, &r);
			S[i][j] = l;
			S[i][j+1] = r;
		}
	}
}
```