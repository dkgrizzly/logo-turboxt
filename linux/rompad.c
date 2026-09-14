#include <stdio.h>
#include <stdint.h>
#include <string.h>
#include <stdlib.h>

int main(int argc, char **argv) {
  uint8_t *buf;
  uint8_t len;
  uint16_t magic;
  uint16_t count;
  uint8_t checksum;

  fread(&magic, 2, 1, stdin);
  if(magic != 0xAA55) {
    fprintf(stderr, "Invalid Option ROM magic: %04x\r\n", magic);
    return -1;
  }

  fread(&len, 1, 1, stdin);
  if((len < 1) || (len>16)) {
    fprintf(stderr, "Invalid Option ROM length: %d\r\n", len * 512);
    return -1;
  }

  buf = malloc(len * 512);
  if(!buf) {
    fprintf(stderr, "Unable to allocate buffer\r\n");
    return -1;
  }

  memset(buf, 0xff, len * 512);
  buf[0] = 0x55;
  buf[1] = 0xAA;
  buf[2] = len;

  fread(buf+3, 1, 512*len-3, stdin);
  checksum = 0;
  for(count = 0; count < ((len*512)-1); count++) {
    checksum += buf[count];
  }
  buf[count] = 255 - checksum + 1;
  fwrite(buf, 512, len, stdout);

  fprintf(stderr, "Checksum %02x, byte %02x\r\n", checksum, buf[count]);
  fprintf(stderr, "done.\r\n");

  return 0;
}
