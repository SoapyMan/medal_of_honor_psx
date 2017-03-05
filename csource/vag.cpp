
#include "vag.h"

// ADPCM decoder based on VAG-Depack by Bitmaster


// lookup table
/*
double f[5][2] = {{         0.0,          0.0 },
                  { 60.0 / 64.0,          0.0 },
                  {115.0 / 64.0, -52.0 / 64.0 },
                  { 98.0 / 64.0, -55.0 / 64.0 },
                  {122.0 / 64.0, -60.0 / 64.0 }};
*/
const double fa[5] = { 0.0, 60.0/64.0, 115.0/64.0,  98.0/64.0, 122.0/64.0 };
const double fb[5] = { 0.0,       0.0, -52.0/64.0, -55.0/64.0, -60.0/64.0 };


// constructor
CVag::CVag()
{
 sound = NULL;
}


// loads VAG from file
bool CVag::Load(const char *filename)
{
 if (!fp.Open(filename)) {
  Console.Printf("File \"%s\" not found.\n",filename);
  return false;
 }
 bool r = Load(fp,fp.GetSize());
 fp.Close();
 return r;
}


// loads VAG chunk
bool CVag::Load(CFile &fp, int size)
{
 // allocate PCM data
 int packetnum = (size/16) - 2;
 int pcmsize = packetnum*4;
 char *pcm = new char(pcmsize);
 
 // skip first 16 bytes
 fp.Skip(16); // todo: correct?
 
 // read packets
 int predictor;            // ???
 int shift;                // number of bits to shift
 int flags;                // packet flag
 int i;                    // temp iterator
 int d;                    // ???
 int s;                    // ???
 static double s1 = 0.0;   // ???
 static double s2 = 0.0;   // ???
 double samples[28];       // ???
 
 unsigned char packet[16];
 bool last = false;
 while(1)
 {
  fp.Read(&packet,16,1);
  
  // packet predict
  predictor = packet[0];
  shift = predictor & 0xF;
  predict >>= 4;
  
  // packet flag
  flags = packet[1];
  if (flags == 7) return true;
  // flag 00 == normal packet
  // flag 01 == last packet
  // flag 06 == start loop
  // flag 07 == end of sound
  
  // decompress 14 byte ADPCM to 28 byte PCM
  for (i=0; i<28; i+=2)
  {
   d = packet[2+i];
   
   s = (d & 0xF) << 12;
   if (s & 0x8000) s |= 0xFFFF0000;
   samples[i+0] = (double)(s >> shift);
   
   s = (d & 0xF0) << 8;
   if (s & 0x8000) s |= 0xFFFF0000;
   samples[i+1] = (double)(s >> shift);
  }
  for (i=0; i<28; i++)
  {
   //samples[i] = samples[i] + s_1 * f[predict][0] + s_2 * f[predict][1];
   samples[i] += (s1 * fa[predictor]) + (s2 * fb[predictor]);
   s2 = s1;
   s1 = samples[i];
   
   d = (int)(samples[i] + 0.5);
   //if (d < -32768) d = -32768; 
	  //if (d > 32767)	d = 32767;
   
   // output
   pcm[(i*2)+0] = (d & 0xFF);
   pcm[(i*2)+1] = (d >> 8);
  }
  
 }
 
 // create sound
 sound = new CSound;
 sound->Create(pcm,pcmsize); // 16,22050
 
 // free pcm data
 delete [] pcm;
 
 // never found last packet
 return false;
}


// unload
void CVag::Unload()
{
 // todo??
 
 // delete sound
 if (sound) {
  delete sound;
  sound = NULL;
 }
}


// destructor
CVag::~CVag()
{
 Unload();
}
