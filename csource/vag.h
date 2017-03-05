
#ifndef _VAG_H
#define _VAG_H


// VAG class
class CVag
{
private:

public:
 
 // VAG data
 // ...
 
 // internal
 CSound *sound;
 
 // constructor/destructor
 CVag();
 ~CVag();
 
 // misc
 bool Load(const char *filename);
 bool Load(CFile &fp, int size);
 void Unload();

};


#endif
