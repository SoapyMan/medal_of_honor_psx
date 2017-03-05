
#include "vag.h"
#include "file.h"
#include "vab.h"


// constructor
CVab::CVab()
{
 memset(&head,0,sizeof(head));
 vag = NULL;
}


// loads VAB from file
bool CVab::Load(const char *filename)
{
 if (!fp.Open(filename)) {
  Console.Printf("File \"%s\" not found.\n",filename);
  return false;
 }
 bool r = Load(fp);
 fp.Close();
 return r;
}


// loads VAB
bool CVab::Load(CFile &fp)
{
 // read header
 fp.Read(&head,sizeof(head),1);
 if (strncmp(head.id,"pBAV",4) != 0) {
  Console.Printf("Invalid VAB header.\n");
  return false;
 }
 if (head.version != 5) {
  Console.Printf("VAB version not supported.\n");
  return false;
 }
 
 // skip unknown table
 fp.Skip(2048); // 16 byte stride
 
 // read VAG size table
 fp.Read(vagsize,512,1);
 
 // read VAG chunks
 vag = new CVag(head.vagnum);
 for (int i=0; i<head.vagnum; i++)
 {
  size = (int)vagsize[i+1] * 8;
  vag.Read(fp,size);
 }
 
 // success
 return true;
}


// unloads VAB data
void CVab::Unload()
{
 // clear header
 memset(&head,0,sizeof(head));
 
 // delete VAGs
 if (vag) {
  delete [] vag;
  vag = NULL;
 }
}


// destructor
CVab::~CVab()
{
 Unload();
}
