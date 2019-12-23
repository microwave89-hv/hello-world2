 ; Copyright (c) 2019 microwave89-hv
 ;
 ; Licensed under the Apache License, Version 2.0 (the "License");
 ; you may not use this file except in compliance with the License.
 ; You may obtain a copy of the License at
 ;
 ;      http://www.apache.org/licenses/LICENSE-2.0
 ;
 ; Unless required by applicable law or agreed to in writing, software
 ; distributed under the License is distributed on an "AS IS" BASIS,
 ; WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 ; See the License for the specific language governing permissions and
 ; limitations under the License.


 ; derived from https://raw.githubusercontent.com/charlesap/nasm-uefi/master/yo.asm
 ; and the compiled and linked output of hello-world2.c.

BITS 64

IMAGE_DOS_HEADER:
    db 'MZ'
    dw 0
    times 14 dd 0
    dd 0x78
    times 14 dd 0

IMAGE_FILE_HEADER:
    db 'PE',0,0     ; sig
    dw 0x8664       ; type
    dw 2            ; section count
    dd 0
    dd 0
    dd 0
    dw 0xf0         ; oheader size
    dw 0x22         ; characteristics = 

IMAGE_OPTIONAL_HEADER64:
    dw 0x20b        ; oheader
    dw 0
    dd 0
    dd 0
    dd 0
    dd 0x1000       ; * entry RVA
    dd 0
    dq 0x100000000  ; * image base
    dd 0x1000       ; section alignment
    dd 0x200        ; file alignment
    dw 0
    dw 0
    dw 0
    dw 0
    dw 0
    dw 0
    dw 0
    dw 0
    dd 0x3000       ; image virtual size
    dd 0x400        ; headers raw size
    dd 0
    dd 0xa          ; subsystem
    dq 0x100000     ; stack reserve size
    dq 0x1000       ; stack commit size
    dq 0x100000     ; heap reserve size
    dq 0x1000       ; heap reserve commit
    dd 0
    dd 0x10         ; rva count
    times 16 dq 0

IMAGE_SECTION_HEADER1:
    dq  '.text'     ; name
    dd  0xe         ; virtual size, not section size!
    dd  0x1000      ; virtual code address   
    dd  0x200       ; raw code size
    dd  0x400       ; raw code offset
    dq  0
    dd  0
    dd  0x60000020  ; characteristics

IMAGE_SECTION_HEADER2:
    dq  '.rdata'
    dd  0x1e        ; virtual size, not section size!  
    dd  0x2000      ; virtual data address
    dd  0x200       ; raw data size
    dd  0x600       ; raw data offset
    dq  0
    dd  0
    dd  0x40000040  ; characteristics

times 0x400 - ($-$$) db 0  ; manually align the text section on a 1024 byte boundary

section .mytext
		  ; EntryPoint: pUnused0 in rcx, pEfiSystemTable in rdx (See hello-world2.c)
                  ; (Return address to parent caller has already been pushed onto the stack)
                  ; (Stack is unaligned at this point!)
    mov rcx, [rdx + 0x40] ; SIMPLE_TEXT_OUTPUT_INTERFACE* con_out = pEfiSystemTable->pConOut;
    lea rdx, [rel myvar - 0x200 + 0x1000] ; myvar - raw_code_size + (virtual_data_address - virtual_code_address)
    jmp [rcx + 8] ; Executing a jmp won't push a return address to the current function
                  ; onto the stack. As such the current function's callee will return
                  ; straight to the parent caller which will skip the current function
                  ; on return.
                  ; This means that the "hello-world2" program is always going to exit
                  ; with the exit value of the callee function.

                  ; Note that there isn't an instruction "sub rsp, ?8" which would
                  ; align the stack to a 16 byte boundary before invoking the callee.
                  ; Normally, a call to the callee would unalign a previously aligned
                  ; stack thus requiring the callee to realign it again as soon as it
                  ; uses the stack.
                  ; In the "hello-world2"-example no call but rather a jmp is performed.
                  ; In other words, the current function never messes with the
                  ; stack alignment in the first place.
                  ; Thus, the callee will fix the unalignment which was caused by a
                  ; call to the current function or to one of the current function's
                  ; parent callers. To do that it will use something like "sub rsp, ?8".
                  ; If the callee, too, were not to use the stack before or while
                  ; invoking *its* callee it could omit the alignment in a similar way.

                  ; Not having to fix the stack alignment saves a few bytes
                  ; of code which is why a jmp was used here.


times 0x200 - ($-$$) int3 ; manually align the text section on a 512 byte boundary

section .mydata
    myvar dw __utf16__('Hello W0rld!'), 0xd, 0xa, 0 ; In the EFI realm, which has been
                                                    ; heavily influenced by the Microsoft
                                                    ; world, wide chars are required to
                                                    ; have 2 bytes, as opposed to 4 bytes
                                                    ; on *nixes.
                                                    ; Moreover both carriage return and
                                                    ; line feed are required for a new line.
    times 0x200 - ($-$$) db 0