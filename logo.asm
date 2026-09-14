ideal
p8086
model	tiny
warn

assume	ds:code, ss:code, cs:code, es:code

segment _BDA at 40h
ends _BDA

segment	code

;  cpu 8086
  org   00000h				; Boot Logo Option ROM BIOS starts at F000:C000

  dw    0AA55h				; Option ROM Signature Magic
  db    004h				; Size in 512 byte blocks = 2048
  jmp   init

init:
  pushf
  push  ax
  push  bx
  push  cx
  push  dx
  push  si
  push  di
  push  es
  push  ds

assume  es:_BDA
  mov   ax, seg _BDA
  mov   es, ax

  mov   ah, 0fh				; Reset current video mode (clear screen)
  int   10h
  mov   ah, 00h
  int   10h

  call  put_logo

; Print TurboXT Text
  mov   ax, 0802h			; Where to move cursor
  call  locate				; Position cursor
  mov   si, offset prodstr
  call  print				; Print string in si

; Print memory total
  mov   ax, 0848h			; Where to move cursor
  call  locate				; Position cursor

  int   12h				; How much Conventional RAM do we have?
  call  print_dec
  mov   al, 'K'
  call  out_char			; Print character in ax
  mov   al, 'B'
  call  out_char			; Print character in ax

  mov   ax, 0a00h			; Where to move cursor
  call  locate				; Position cursor

  pop   ds
  pop   es
  pop   di
  pop   si
  pop   dx
  pop   cx
  pop   bx
  pop   ax
  popf
  retf


;--------------------------------------------------------------------------------------------------
; Display logo
;--------------------------------------------------------------------------------------------------
proc	put_logo	near
  mov   si, offset logo
  mov   dx, 0000h			; Logo at line 0, column 0
  mov   ah, 2
  mov   bh, 0				;   page 0
  int   10h
  mov   cx, 1				; Character repeat count

@@loop:
  lodsb					; Get Repeat Count
  or    al, al
  jz    @@done				; Zero characters remain?

  mov   cl, al
  add   dl, cl				; New cursor position after

@@out:
  lodsb					; Get Attribute Byte
  mov   bl, al

  lodsb					; Get Character Byte
  xor   ah, ah

  call  color_out_char			; Print character in ax and advance cursor

  cmp   dl, 050h			; End of line?
  jl    @@loop				; Nope, keep swapping characters

  inc   dh				; Yep, jump down a line
  xor   dl, dl				; Reset to first column

  jmp   @@loop				;   back for more

@@done:
  ret

endp	put_logo


;--------------------------------------------------------------------------------------------------
; Write a text character with attributes
;--------------------------------------------------------------------------------------------------
proc color_out_char  near
  push  bx
  push  ax

;  cmp   [byte es:49h], 7		; Get CRT mode
;  jne   @@color
;  mov   bx, 000Fh			; White on Black
;@@color:

  mov   ah, 09h 			; Write character and attribute
  int   10h

  mov   ah, 02h				; Set cursor position
  int   10h

  pop   ax
  pop   bx
  ret
endp color_out_char


;--------------------------------------------------------------------------------------------------
; Display character
;--------------------------------------------------------------------------------------------------
proc	out_char	near
  push  bx
  push  ax
  xor   bx, bx
  mov   ah, 0Eh 			; Teletype print service
  mov   bl, 7				;   normal intensity
  int   10h
  pop   ax
  pop   bx
  ret
endp	out_char


;--------------------------------------------------------------------------------------------------
; Display null-terminated string (si)
;--------------------------------------------------------------------------------------------------
proc	print	near

@@loop:
  lodsb					; Print zero terminated string
  or    al, al				; Terminator in ax?
  jz    @@done
  call  out_char			; Print character in ax
  jmp   @@loop				;   back for more
@@done:
  ret
endp	print


;--------------------------------------------------------------------------------------------------
; Print 4 digit decimal number from AX
;--------------------------------------------------------------------------------------------------
proc print_dec near
  mov   bx, 10				; Set the divisor to 10
  xor   cx, cx				; Clear the counter (tracks digit count)

@@divide_loop:
  xor   dx, dx				; Clear DX before 16-bit division (DX:AX / BX)
  div   bx				; AX = Quotient, DX = Remainder
  add   dl, '0'				; Convert the remainder digit to ASCII ('0' = 48)
  push  dx				; Push the ASCII character onto the stack
  inc   cx				; Increment our digit counter
  cmp   ax, 0				; Is the quotient zero yet?
  jne   @@divide_loop			; If not, keep dividing

  mov   al, 020h
@@pad_loop:
  cmp   cx, 4
  jge   @@print_loop
  push  ax
  inc   cx
  jmp   @@pad_loop

@@print_loop:
  pop   ax				; Pop the last pushed digit (MSB first now)
  call  out_char			; Print character in ax
  loop  @@print_loop			; Decrement CX and loop until CX = 0
  ret
endp  print_dec


;--------------------------------------------------------------------------------------------------
; Positions display cursor
;--------------------------------------------------------------------------------------------------
proc	locate	near
  push  dx
  push  bx
  mov   dx, ax				; Get position for cursor
  mov   ah, 2
  mov   bh, 0				;   page 0
  int   10h
  pop   bx
  pop   dx
  ret
endp	locate

; Product String
prodstr  db  'T','u','r','b','o','X','T'
         db  0

; Italic Turbo XT Logo
; RLE Attribute/Character pairs
logo  db  4, 000h, 020h
      db  9, 00Ch, 0DCh
      db  2, 000h, 020h
      db  2, 00Ch, 0DCh
      db  4, 000h, 020h
      db  2, 00Ch, 0DCh
      db  2, 000h, 020h
      db  6, 00Ch, 0DCh
      db  4, 000h, 020h
      db  6, 00Ch, 0DCh
      db  5, 000h, 020h
      db  5, 00Ch, 0DCh
      db  7, 000h, 020h
      db  2, 00Fh, 0DCh
      db  4, 000h, 020h
      db  3, 00Fh, 0DCh
      db  2, 000h, 020h
      db  9, 00Fh, 0DCh
      db  2, 000h, 020h

      db  7, 000h, 020h
      db  2, 00Ch, 0DCh
      db  5, 000h, 020h
      db  2, 00Ch, 0DCh
      db  4, 000h, 020h
      db  2, 00Ch, 0DCh
      db  2, 000h, 020h
      db  2, 00Ch, 0DCh
      db  4, 000h, 020h
      db  2, 00Ch, 0DCh
      db  2, 000h, 020h
      db  2, 00Ch, 0DCh
      db  4, 000h, 020h
      db  2, 00Ch, 0DCh
      db  2, 000h, 020h
      db  2, 00Ch, 0DCh
      db  4, 000h, 020h
      db  2, 00Ch, 0DCh
      db  6, 000h, 020h
      db  2, 00Fh, 0DCh
      db  2, 000h, 020h
      db  3, 00Fh, 0DCh
      db  7, 000h, 020h
      db  2, 00Fh, 0DCh
      db  6, 000h, 020h

      db  6, 000h, 020h
      db  2, 00Ch, 0DCh
      db  5, 000h, 020h
      db  2, 00Ch, 0DCh
      db  4, 000h, 020h
      db  2, 00Ch, 0DCh
      db  2, 000h, 020h
      db  2, 00Ch, 0DCh
      db  4, 000h, 020h
      db  2, 00Ch, 0DCh
      db  2, 000h, 020h
      db  2, 00Ch, 0DCh
      db  4, 000h, 020h
      db  2, 00Ch, 0DCh
      db  2, 000h, 020h
      db  2, 00Ch, 0DCh
      db  4, 000h, 020h
      db  2, 00Ch, 0DCh
      db  7, 000h, 020h
      db  2, 00Fh, 0DCh
      db  1, 000h, 020h
      db  2, 00Fh, 0DCh
      db  8, 000h, 020h
      db  2, 00Fh, 0DCh
      db  7, 000h, 020h

      db  5, 000h, 020h
      db  2, 00Ch, 0DCh
      db  5, 000h, 020h
      db  2, 00Ch, 0DCh
      db  4, 000h, 020h
      db  2, 00Ch, 0DCh
      db  2, 000h, 020h
      db  7, 00Ch, 0DCh
      db  3, 000h, 020h
      db  7, 00Ch, 0DCh
      db  3, 000h, 020h
      db  2, 00Ch, 0DCh
      db  4, 000h, 020h
      db  2, 00Ch, 0DCh
      db  8, 000h, 020h
      db  4, 00Fh, 0DCh
      db  8, 000h, 020h
      db  2, 00Fh, 0DCh
      db  8, 000h, 020h

      db  4, 000h, 020h
      db  2, 00Ch, 0DCh
      db  5, 000h, 020h
      db  2, 00Ch, 0DCh
      db  4, 000h, 020h
      db  2, 00Ch, 0DCh
      db  2, 000h, 020h
      db  2, 00Ch, 0DCh
      db  4, 000h, 020h
      db  2, 00Ch, 0DCh
      db  2, 000h, 020h
      db  2, 00Ch, 0DCh
      db  4, 000h, 020h
      db  2, 00Ch, 0DCh
      db  2, 000h, 020h
      db  2, 00Ch, 0DCh
      db  4, 000h, 020h
      db  2, 00Ch, 0DCh
      db  8, 000h, 020h
      db  2, 00Fh, 0DCh
      db  1, 000h, 020h
      db  2, 00Fh, 0DCh
      db  7, 000h, 020h
      db  2, 00Fh, 0DCh
      db  9, 000h, 020h

      db  3, 000h, 020h
      db  2, 00Ch, 0DCh
      db  5, 000h, 020h
      db  2, 00Ch, 0DCh
      db  4, 000h, 020h
      db  2, 00Ch, 0DCh
      db  2, 000h, 020h
      db  2, 00Ch, 0DCh
      db  4, 000h, 020h
      db  2, 00Ch, 0DCh
      db  2, 000h, 020h
      db  2, 00Ch, 0DCh
      db  4, 000h, 020h
      db  2, 00Ch, 0DCh
      db  2, 000h, 020h
      db  2, 00Ch, 0DCh
      db  4, 000h, 020h
      db  2, 00Ch, 0DCh
      db  7, 000h, 020h
      db  3, 00Fh, 0DCh
      db  2, 000h, 020h
      db  2, 00Fh, 0DCh
      db  6, 000h, 020h
      db  2, 00Fh, 0DCh
      db 10, 000h, 020h

      db  2, 000h, 020h
      db  2, 00Ch, 0DCh
      db  7, 000h, 020h
      db  5, 00Ch, 0DCh
      db  3, 000h, 020h
      db  2, 00Ch, 0DCh
      db  4, 000h, 020h
      db  2, 00Ch, 0DCh
      db  2, 000h, 020h
      db  7, 00Ch, 0DCh
      db  5, 000h, 020h
      db  5, 00Ch, 0DCh
      db  7, 000h, 020h
      db  3, 00Fh, 0DCh
      db  4, 000h, 020h
      db  2, 00Fh, 0DCh
      db  5, 000h, 020h
      db  2, 00Fh, 0DCh
      db 11, 000h, 020h

      db 80, 007h, 020h

      db 11, 007h, 020h

      db  4, 001h, 0DBh
      db  4, 002h, 0DBh
      db  4, 003h, 0DBh
      db  4, 004h, 0DBh
      db  4, 005h, 0DBh
      db  4, 006h, 0DBh
      db  4, 007h, 0DBh
      db  4, 008h, 0DBh
      db  4, 009h, 0DBh
      db  4, 00Ah, 0DBh
      db  4, 00Bh, 0DBh
      db  4, 00Ch, 0DBh
      db  4, 00Dh, 0DBh
      db  4, 00Eh, 0DBh
      db  4, 00Fh, 0DBh

      db  9, 007h, 020h

      db 80, 007h, 020h

      db  0, 0, 0

ends	code

end
