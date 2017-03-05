
// cleaned up VAG-Depack, originally by Bitmaster

#include <stdio.h>
#include <string.h>

double f[5][2] = { { 0.0, 0.0 },
                   { 60.0 / 64.0,  0.0 },
                   {115.0 / 64.0, -52.0 / 64.0 },
                   { 98.0 / 64.0, -55.0 / 64.0 },
                   {122.0 / 64.0, -60.0 / 64.0 } };

double samples[28];


int main(int argc, char *argv[])
{
 // print arguments
 if (argc != 2) {
  printf( "usage: depack *.vag\n" );
  return( -1 );
 }
 
 // open input file
 FILE *vag = fopen(argv[1], "rb");
 if (!vag) {
  printf("Cannot open input file.\n");
  return 0;
 }
 
 // skip first 64 bytes
 fseek(vag, 64, SEEK_SET);
 
 // create output filename
 char *p;
 char fname[128];
 strcpy(fname, argv[1]);
 p = strrchr(fname, '.');
 p++;
 strcpy(p, "PCM");
 
 // open output file
 FILE *pcm = fopen(fname, "wb");
 if (!pcm) {
  printf( "Cannot open output file.\n" );
  return -8;
 }
 
 // process data
 int predict_nr, shift_factor, flags;
 int i;
 int d, s;
 static double s_1 = 0.0;
 static double s_2 = 0.0;
 while(1)
 {
  // get packet head
  predict_nr = fgetc(vag);
  shift_factor = predict_nr & 0xf;
  predict_nr >>= 4;
  
  // get packet flag
  flags = fgetc(vag); // flags
  if (flags == 7) break;
  
  // flag 00 == normal packet
  // flag 01 == last packet
  // flag 06 == start loop
  // flag 07 == end of sound
  
  // decompress to 28 byte PCM
  for (i=0; i<28; i+=2)
  {
   d = fgetc(vag);
   
   s = (d & 0xf) << 12;
   if (s & 0x8000) s |= 0xFFFF0000;
   samples[i] = (double)(s >> shift_factor);
   
   s = (d & 0xf0) << 8;
   if (s & 0x8000) s |= 0xFFFF0000;
   samples[i+1] = (double)(s >> shift_factor);
  }
  
  // ???
  for (i=0; i<28; i++)
  {
   samples[i] = samples[i] + s_1 * f[predict_nr][0] + s_2 * f[predict_nr][1];
   s_2 = s_1;
   s_1 = samples[i];
   d = (int)(samples[i] + 0.5);
   
   fputc(d & 0xff, pcm);
   fputc(d >> 8, pcm);
  }
  
 }
 
 // close output
 fclose(pcm);
 
 // close input
 fclose(vag);
 
 return 0;
}
