
#ifndef _VAB_H
#define _VAB_H

#include "file.h"
class CVag;


// VAB header
struct VABHEAD // 32 bytes
{
 char id[4];               // FOURCC
 unsigned int version;     // 5
 unsigned int u1;          // 0
 unsigned int size;        // size of VAB including header
 unsigned short u2;        // EEEE
 unsigned short progs;     // ???
 unsigned short tones;     // ???
 unsigned short vagnum;    // number of VAG chunks
 unsigned int u3;          // 0000 0000
 unsigned int u4;          // FFFF FFFF
};


// VAB class
class CVab
{
private:

public:
 
 // VAB data
 VABHEAD head;
 unsigned short vagsize[256];
 CVag *vag;
 
 // constructor/destructor
 CVab();
 ~CVab();
 
 // misc
 bool Load(const char *filename);
 bool Load(CFile &fp);
 void Unload();
 
};


#endif