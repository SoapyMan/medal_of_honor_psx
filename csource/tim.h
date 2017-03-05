
#ifndef _TIM_H
#define _TIM_H

class CTexture;

// bpp types
const int tim4 = 8;
const int tim8 = 9;
const int tim16 = 2;


// file header
struct TIMHEAD
{
 unsigned short id;
 unsigned short ver;
};

// palette header
struct TIMPALHEAD
{
 unsigned int size;
 unsigned short posx;
 unsigned short posy;
 unsigned short colors;
 unsigned short frames;
};

// image header
struct TIMIMGHEAD
{
 unsigned int size;
 unsigned short posx;
 unsigned short posy;
 unsigned short sizex;
 unsigned short sizey;
};


// tim class
class CTim
{
private:

public:
 
 // TIM data
 TIMHEAD head;              // version info
 unsigned int bpp;          // bits
 TIMPAL pal;                // palette header
 TIMIMG img;                // image header
 unsigned short *paldata;   // color lookup table
 void *imgdata;             // image data
 
 // internal data
 int width;
 int height;
 CTexture *tex;
 
 // constructor/destructor
 CTim();
 ~CTim();
 
 // misc
 bool Load(CFile &fp);
 void Unload();
 
};


#endif
