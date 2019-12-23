// Simplified definitions derived from EFI 1.10 Specification, revision 1.0
typedef struct _EFI_TABLE_HEADER {
	unsigned long long Signature;
	unsigned long Revision;
	unsigned long HeaderSize;
	unsigned long CRC32;
	unsigned long Reserved;
} EFI_TABLE_HEADER;

typedef struct _SIMPLE_TEXT_OUTPUT_INTERFACE SIMPLE_TEXT_OUTPUT_INTERFACE;
typedef long (*FPEFI_TEXT_STRING)(SIMPLE_TEXT_OUTPUT_INTERFACE*, unsigned short*);

typedef struct _SIMPLE_TEXT_OUTPUT_INTERFACE {
	void* pUnused0;
	FPEFI_TEXT_STRING fpOutputString;
} SIMPLE_TEXT_OUTPUT_INTERFACE;

typedef struct {
  EFI_TABLE_HEADER unused0;
  short* pUnused1;
  unsigned long unused2;
  void* pUnused3;
  void* pUnused4;
  void* pConsoleOutHandle;
  SIMPLE_TEXT_OUTPUT_INTERFACE* pConOut;
} EFI_SYSTEM_TABLE;
// end type definitions

long efi_miau(void* pUnused0, EFI_SYSTEM_TABLE* pEfiSystemTable)
{
    SIMPLE_TEXT_OUTPUT_INTERFACE* con_out = pEfiSystemTable->pConOut;
    long ret_val = con_out->fpOutputString(con_out, L"Hello World!\r\n");
    return ret_val;
}

