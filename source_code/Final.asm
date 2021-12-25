;Final Project Caesar Cipher
;Group 8
;This Program encrypts/decrypts using Caesar Cipher


;Irvine Library
include irvine32.inc

stringLengthMax = 51 ;null terminator

;Macros, allow us to clear registers with fewer lines
clearEAX TEXTEQU <mov eax, 0>
clearEBX TEXTEQU <mov ebx, 0>
clearECX TEXTEQU <mov ecx, 0>
clearEDX TEXTEQU <mov edx, 0>
clearESI TEXTEQU <mov esi, 0>
clearEDI TEXTEQU <mov edi, 0>

.data
UserOptions BYTE 0h ; Holds User Input

;When user enters
theString BYTE stringLengthMax DUP (0)

theStringLength BYTE ?

;User input key, initialized with 0
keyString BYTE stringLengthMax DUP (0)

keyLength BYTE ? ;holds the length of key

errorMessage BYTE 'Entry not compatible, going back to main menu',0 ;basic error message to display for invalid input

.code
main PROC

;Call Macro functions to clear all registers
clearEAX
clearEBX
clearECX
clearEDX
clearESI
clearEDI

;call menu function
startHere:

	;STRING will be cleared each time
	mov EDX, offset theString
	mov ECX, stringLengthMax

	call DisplayMenu ;shows the menu

	call ReadHex ;stores user input in the EAX

	mov UserOptions, AL ;UserOptions stored

	;Comparison for options
	;jumps to specific section of code if UserOptions = 1/2/3

	cmp UserOptions, 1
	JE EOption  ;Jumps to Encryption Method

	cmp UserOptions, 2
	JE DOption  ;Jumps to Decryption Method

	cmp UserOptions, 3
	JE endit    ;Jumps to end of Main, end program

	jmp emsg

;Encrytion Method Using Caesar Cipher
EOption:

	;-----STRING-------
	;User will enter string for encryption
	mov EDX, OFFSET theString
	mov ECX, stringLengthMax

	call EnterString ;function call

	mov theStringLength, AL ;theString length Is set whcih will be found in EAX

	;Cipher Key
	mov EDX, offset keyString
	mov ECX, stringLengthMax
	clearEAX ;EAX Clear

	;If previous string
	mov AL, BYTE PTR [EDX] ;takes the initial value

	cmp AL, 0
	JE enterkey ;0 it will go to key

	;ask for new key
	;if not it will jump

	call keyhold
	cmp AL, 0
	JE jumpkey
	;otherwise, enter a key

enterkey:
	clearEAX
	call keyEntry ;sets up the key
	mov keyLength, AL ;sets to returned value in EAX
	;string and key all set. Begin encryption process

jumpkey:
	;String Editing

	;non letters are removed
	movzx ECX, theStringLength
	mov EDX, offset theString
	mov EBX, offset theStringLength
	;ESI kept
	call CharOnly ;ECX,EDX  
	call Capitalize  ;Capitalize letters
	mov theStringLength, AL

	;After everything is converted to all caps its ready for encryption

	mov EDX, offset theString
	mov EBX, offset keyString
	movzx ECX, theStringLength
	movzx EAX, keyLength

	call Encrypt ;Encrypt string

	;print encryption
	mov EDX, offset theString ;encryption print
	movzx ECX, thestringlength
	call printString

	;end encryption/Return to main menu
	call crlf
	call waitmsg

	;restart loop
	jmp startHere


;DECRYPTION PROCESSES


DOption: ;Decryption

	;String
	mov EDX, offset theString
	mov ECX, stringLengthMax

	call EnterString

	mov thestringlength, AL

	;Key
	mov EDX, offset keyString
	mov ECX, stringLengthMax
	clearEAX

	;checks for previous strings
	mov AL, BYTE PTR [EDX]
	cmp AL, 0
	JE newKey

	;asks for key rentry
	call keyhold
	cmp AL, 0
	JE skipDkey
	;otherwise enter a key


	newKey:  ;let users enter a new shift value
		clearEAX
		call keyEntry
		mov keyLength, AL

	skipDkey:
		;Editing
		;all non letters removed, as well as capitalizing all valid letters
		movzx ecx, theStringLength
		mov EDX, offset theString
		mov EBX, offset thestringlength
		call CharOnly
		call Capitalize
		mov thestringlength, AL


	;Decryption
	mov EDX, offset theString
	mov EBX, offset keyString
	movzx ECX, theStringLength
	movzx EAX, keyLength
	call Decrypt

	;print decrypted string
	mov EDX, offset thestring
	movzx ECX, thestringlength
	call printString

	;Decrpytion done, clear screen and return to main menu
	call crlf
	call waitmsg
	jmp startHere

	;Error message, then restart Menu
	emsg:
	mov EDX, offset errorMessage
	call WriteString;
	jmp startHere

	;End program
	endit:
		exit
	main ENDP







;Program Functions


DisplayMenu PROC USES EDX
;Displays the menu for user for proper prompting
;REQUIRES: NOTHING
;RETURNS: Nothing

.data

;Menu screen

menuPrompt BYTE "Main Menu", 0Ah, 0Dh,
"===============", 0Ah, 0Dh,
"Do You Want To Do: ", 0Ah, 0Dh,
"1. Encryption", 0Ah, 0Dh,
"2. Decryption", 0Ah, 0Dh,
"3. Or Quit", 0Ah, 0Dh, 0h

.code

call clrscr ;screen clear
mov EDX, offset menuPrompt  ;push menu screen into EDX
call WriteString   ;Print menu screen
ret

DisplayMenu ENDP


;Enter string to be encrypted/decrypted
;Requires: User entered string
;Returns: Length of string in EAX

EnterString PROC uses ECX

;Asks user to enter string for encryption and/or decryption, the value will be stored into theString
;the length of string will be stored in EAX and will fill theString with values in array


.Data
stringMsg BYTE "Enter A String: ",0
.code

;EDX pushed onto stack
push EDX
mov EDX, offset stringMsg
call WriteString ;prints out BYTE stringMsg stored in EDX
pop EDX ;removes top 4 bytes of EDX and reads string stored
call ReadString ;Irvine Library function, stores String into ECX

ret ;length of the string returned

EnterString ENDP


;Store Key value used for Encryption/Decryption
;Requires: nothing
;Returns: EAX 1 for yes 0 for no

keyhold PROC uses EDX
;Stores current key value, updates key if user wants a different one

;EAX holds 1 or 0 for options
.data

message BYTE "Do you want to enter a new key? 1 for yes, 0 for no", 0Ah, 0Dh, 0
Emesg BYTE "Non Valid Answer",0

.code

;loop to check if User wants to update string. 1 = new key. 0 = old key. Any other response = error message/restart loop
start:
	mov EDX, offset message ;ask for new key entry
	call WriteString  ;Print message for User
	call ReadInt  ;Read User response and push into AL
	;check to see response

	cmp AL, 0 ;Use old key
	JE contin

	cmp AL, 1  ;Enter new key
	JE contin

	;if its not 1 or 0
	mov EDX, offset Emesg  ;send error message
	call WriteString ;print error message
	jmp start ;restart loop

;leave function upon user's entry and completion of loop
contin:
	ret

keyhold ENDP


;Enter key value used for Encryption/Decryption
;Requires: EDX offset as key for array
;returns: size of the key in EAX

keyEntry PROC uses ECX

;Asks user for key value for shifting the string

.data

keyMsg BYTE "Enter The Key: ",0Ah, 0Dh, 0

.code

push EDX ;location of offset is saved
mov EDX, offset keyMsg
call WriteString ;keyMsg printed
pop EDX
call ReadString ;Irvine. Reads user input and puts it in the array keyString

ret
keyEntry ENDP


;Part of converting string into array of Chars for Encryption/Decryption
;Requires:  length of string in ecx
;Returns: string with all letters

CharOnly PROC USES ecx edx esi

;Convert string into series of Chars

.data
tempstr BYTE 50 dup(0)       ;holds string
.code

push edx
push ecx
mov ESI, 0
;clears tempstr
mov edx, offset tempstr
mov ecx, 50
call ClearString

pop ecx
pop edx
push ecx                      ;values of ecx is saved
clearEDI                      
L3:
	mov al, byte ptr [edx + esi]  ;element in string
	;is it a letter?
	cmp al, 5Ah
	ja lowercase    
	cmp al, 41h    
	jb skipit
	jmp addit      
	lowercase:
		cmp al, 61h    
		jb skipit      
		cmp al, 7Ah    
		ja skipit
	addit:          ;// if letter add it
		mov tempstr[edi], al
		inc edi         ;// next element moved
		inc esi        
		jmp endloop     ;end of loop
	skipit:         ;jumps over the element
		inc esi         ;//next element
	endloop:
		loopnz L3
		;mov [ebx], edi   ;updating
		pop ecx  ;ecx value back to reg

mov EAX, EDI
push EAX
;// temp string is copied
clearEDI
L3a:    
	mov al, tempstr[edi]
	mov byte ptr [edx + edi], al
	inc edi
	loop L3a
	pop EAX

ret
CharOnly ENDP


;Capitalize all Chars in String array
;Requires: EDX for offset of string ECX for length of string
;Returns: string in all capitals

Capitalize PROC uses ECX EDX
;Turns all letters capital
.data
.code

L1:
	AND BYTE PTR [EDX], 11011111b ;clear bit 5
	inc EDX
	loop L1
	ret
Capitalize ENDP

;Clearing string for new string to be encrypted/decrypted


ClearString PROC USES EDX ECX ESI
;clears byte array

; passed array incrementation
clearESI
ClearIt:
	mov byte ptr [edx + esi], 0
	inc esi
	loop ClearIt
ret
ClearString ENDP


;String Printing
;Requires: EDX for offset for the string and ECX for the size of string
;Returns: Nothing


PrintString PROC uses EBX ECX EDX
;Prints the string stored in ECX

.data
quotent BYTE 0 ;# of large loops
remainder BYTE 0 ;remaining chars
.code
;Used DIV to divide string by 5, quotient will be used for counting inside the loop. 5 chars will be printed and a space. It will mainly use ECX to push



mov EAX, 0 ;clear the EAX register
mov ESI, 0 ;for traversal later

;used for finding remainder
mov ax, cx ;high Div
mov bl, 5
DIV bl ;al is the quotient and ah is reminader

mov quotent, AL
mov remainder, AH


movzx ECX, quotent ;large loops # set
loop1:
	push ECX ;large loop count
	mov ECX, 5 ;loop next 5

	loop2: ;char print and incrementation
		mov AL, BYTE PTR [EDX+ESI]
		call WriteChar
		inc ESI
		loop loop2
		;space

	mov AL, 20h
	call WriteChar
	pop ECX ;restore original ECX counter, then decrement in loop
	loop loop1
	;groups rest of letters/characters
	cmp remainder, 0
	JE endit ;jumps to remainder

;prints
movzx ECX, remainder

loop3:
	mov AL, BYTE PTR [EDX+ESI]
	call WriteChar
	inc ESI
	loop loop3

endit:
	ret
PrintString ENDP

;Encryption method
;Requires: EDX of theString , EBX of keyString Offset, ECX theString size and EAX keyString size also uses EDI/ESI for movement
;Returns: Nothing


Encrypt PROC uses EDX ECX ESI EDI EBX
;Encrypts the string

;Utilizes thestring EDX, keystring EBX, thestring ECX, and keystring EAX.

; EDI/ESI for moving/traversing


.data
Ssize BYTE ? ;string size
keySize DWORD ? ;key size

shift BYTE ?

.code
mov ESI, 0 ;clear iterator
mov EDI, 0

mov keySize, EAX ;store keySize
mov Ssize, CL

loop1:
	push EAX ;keysize location pushed
	EDICheck:
		cmp EDI, EAX ;checks EDI
		JB cont
		mov EDI, 0 ;possible reset

	cont:
		movzx EAX, BYTE PTR [EBX+EDI] ;extends byte to keystring
		call FindShift ;returns in eax for remainder and quotient
		mov shift, AL ;reminder into shift
		; if shift > bounds
		inc EDI ;incrementation
		mov EAX, 0
		mov AL, BYTE PTR [EDX+ESI] ;put the byte value in the array into al
		add AL, shift ;add shift to AL, then test the value

		cmp AL, 5Ah ;compare to 'Z'
		JBE keepgoing ;if the added value is below 'Z', jump to keep going

		;OUT OF BOUNDS BELOW
		;we need to find the difference between Z, and the letter we are at now.
		push ECX ;save count
		mov ECX, 0
		sub AL, shift ;return AL to the original byte value from array
		mov CL, 5Ah ;final will go into C
		sub CL, AL ;difference
		mov AH, shift
		sub AH, CL ;needs to be added at begining
		mov al, 41h ;set al at the beginning
		add al, AH ;al = new value
		sub AL, 1
		mov BYTE PTR [EDX+ESI], AL ;ESI points to byte that should be moved to
		pop ECX ;count value
		inc ESI
		pop EAX ;keysize
		loop loop1

		;Needs to be in bounds
		jmp exit1


	;IN BOUNDS BELOW
	keepgoing:
		add AL, AH
		mov BYTE PTR [EDX+ESI], AL
		inc ESI
		pop EAX
		loop loop1

exit1:
	ret
Encrypt ENDP


;Decryption
;Requires: EDX of theString , EBX of keyString Offset, ECX theString size and EAX keyString size also uses EDI/ESI for movement
;Returns: Nothing

Decrypt PROC uses EDX ECX ESI EDI EBX
;Decrpyts string using EDX,ECX,EDI,EBX

.data
Lshift BYTE ?

.code

mov ESI, 0
mov EDI, 0 ;Traversals


LooD:
	push EAX ;keystring size held

	EDIChk:
		cmp EDI, EAX
		JB contine
		mov EDI,0 ;possible reset if reached

	contine:
		movzx EAX, BYTE PTR [EBX+EDI] ;move byte in the key to AX, the dividend
		call FindShift ;figures our shift value
		mov Lshift, AL ;2 the shift value
		inc EDI ;next val
		mov EAX, 0
		mov AL, BYTE PTR [EDX+ESI] ;moves byte value of theString into al
		sub AL, Lshift ;subtracts the shift amount from AL
		cmp AL, 41h ;compare to 'Z'
		JAE keepitup

	;out of bounds below
	push ECX ;Holds count
	mov ECX, 0
	add AL, Lshift ;thestring value is returned
	mov CL, 41h ;A in CL

	;difference between current location and 41h is A1
	sub AL, CL
	mov AH, Lshift
	sub AH, AL ;shift is subtracted from
	mov AL, 5Ah ;Z is set
	sub AL, AH ;takes away from z val
	add AL, 1

	mov BYTE PTR [EDX+ESI], AL ;Al val into string lcoation
	pop ECX
	inc ESI
	pop EAX
	loop LooD
	;in bounds below
	jmp eit ;exit

	keepitup:
		mov BYTE PTR [EDX+ESI], AL ;left value into the key
		inc ESI
		pop EAX
		loop LooD

	eit:
		ret

Decrypt ENDP


FindShift PROC uses EBX ECX
;finds shift value

.data
.code

;EAX contains the key value
mov ECX, 0 ;clear ECX to use
mov CX, AX ;moves the value in AX, into CX
mov EAX, 0
mov AX, CX ;kinda redundant but couldnt figure out where to go

mov bl, 26d
DIV bl
ret
FindShift ENDP

end main