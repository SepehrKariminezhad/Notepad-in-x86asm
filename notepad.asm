name "notepad"  

org     100h
 
jmp main        

char_count db 8*25 dup(0)    ; array for keep count of chars in every line (200 line in current video mode)
page_num db 0                ; byte to save current pahe nuumber
cur_pos_v db 8  dup(00h)     ; array to save last column which the cursor was in every page 
cur_pos_h db 8  dup(00h)     ; array to save last line which the cursor was in every page 



main:
    mov ah , 05h    ;set window to page zero
    mov al , 0      ;page number in al
    int 10h 
    mov ah,0        ;set video mode to 80*25 
    mov al,03h     
    int 10h      
    mov di , 0

io_loop:
    mov ah,00h      ;get keystroke from keyboard     
    int 16h           
    cmp al , 1bh    ;if ESC was pressed     
    je exit            
    cmp al , 08h    ;if backspace was pressed     
    je backspace       
    cmp al , 0dh    ;if enter was pressed     
    je enter         
    cmp ah , 49h    ;if PgUp was pressed
    je pg_up
    cmp ah , 51h    ;if PgDn was pressed   
    je pg_dn
    cmp ah , 48h    ;if ArrowUp was pressed
    je arrow_up
    cmp ah , 50h    ;if ArrowDn was pressed
    je arrow_dn       
    mov ah,0eh      ;if none of the above was pressed print it on the console    
    int 10h            
    mov ah , 03h
    mov bh , page_num       
    int 10h            
    mov ch , 0         
    mov cl , dh        
    mov si , cx
    mov al , page_num
    mov cl , 25
    mul cl
    cbw
    add si , ax             ;calculating the right index according to the page and line
    inc char_count[si]      ;inc the counter for the line we are in      
    jmp io_loop             ;loop back to getting input

enter:                      ;getting cursor position(row in dh , coloumn in dl)
    mov ah , 03h
    mov bh , page_num
    int 10h
    cmp dh , 24             ;if enter is pressed at the last line
    je pg_dn
    mov al , page_num
    mov cl , 25
    mul cl
    add al , dh
    mov si , ax             ;calculating the right index according to the page and line
    inc si                  ;inc the index
    inc dh                  ;inc the row in dh
    mov dl , char_count[si] ;finding the word count for the next
    mov ah , 2
    mov bh , page_num
    int 10h                 ;seting the cursor according to the word counter for that line
    jmp io_loop             ;loop back to getting input
 
backspace:                  ;getting cursor position(row in dh , coloumn in dl)
    mov ah , 03h
    mov bh , page_num
    int 10h                 ;if the cursor is at the first column
    cmp dl , 0
    ja backspace_currline
    je backspace_prevline
    
backspace_currline:
    mov ah , 03h            ;getting cursor position(row in dh , coloumn in dl)
    mov bh , page_num
    int 10h
    mov ch , 0
    mov cl , dh
    mov si , cx
    mov al , page_num
    mov cl , 25
    mul cl
    cbw
    add si , ax             ;calculating the right index according to the page and line
    dec char_count[si]      ;dec the conter
            
    mov ah , 03h            ;getting cursor position(row in dh , coloumn in dl)
    mov bh , page_num
    int 10h
    dec dl 
    mov ah , 2              ;setting the cursor according to the word counter for that line
    mov bh , page_num
    int 10h
    mov ah,0eh
    mov al,20h              ;printing an space
    int 10h
    mov ah , 2
    mov bh , page_num       ;setting the cursor to th eprev position
    int 10h
    jmp io_loop
    
backspace_prevline:         ;getting cursor position(row in dh , coloumn in dl)
    mov ah , 03h
    mov bh , page_num
    int 10h
    cmp dx , 0000h          ;if the cursor is at the first row and column
    je backspace_firstline
    ja backspace_not_firstline

backspace_firstline:
    jmp pg_up
    
backspace_not_firstline:
    mov ah , 03h
    mov bh , page_num
    int 10h
    mov ch , 0
    mov cl , dh
    mov si , cx
    mov al , page_num
    mov cl , 25
    mul cl
    cbw
    add si , ax 
    mov char_count[si] , 0
    
    mov ch , 0
    dec dh
    mov cl , dh
    mov si , cx
    mov al , page_num
    mov cl , 25
    mul cl
    cbw
    add si , ax 
    mov dl , char_count[si]
    mov ah , 2
    int 10h
    jmp io_loop
    


pg_dn:
    mov ah , 03h
    mov bh , page_num
    int 10h
    mov cl , page_num
    mov ch , 0
    mov si , cx
    mov cur_pos_v[si] , dh
    mov cur_pos_h[si] , dl
    mov ah , 05h
    mov al , page_num
    cmp al , 7
    je  io_loop
    inc al 
    int 10h
    inc page_num
    mov cl , page_num
    mov ch , 00
    mov si , cx
    mov dh , cur_pos_v[si]
    mov dl , cur_pos_h[si]
    mov ah , 2
    mov bh , page_num
    int 10h
    jmp io_loop

        
    
pg_up:
    mov ah , 03h
    mov bh , page_num
    int 10h
    mov cl , page_num
    mov ch , 0
    mov si , cx
    mov cur_pos_v[si] , dh
    mov cur_pos_h[si] , dl
    mov ah , 05h
    mov al , page_num
    cmp al , 0
    je  io_loop
    dec al 
    int 10h
    dec page_num
    mov cl , page_num
    mov ch , 00
    mov si , cx
    mov dh , cur_pos_v[si]
    mov dl , cur_pos_h[si]
    mov ah , 2
    mov bh , page_num
    int 10h
    jmp io_loop
    
                           
arrow_up:
    mov ah , 03h
    mov bh , page_num
    int 10h
    cmp dh , 0
    je arrow_up_first
    mov al , page_num
    mov cl , 25
    mul cl
    add al , dh
    mov si , ax
    dec si
    dec dh
    mov dl , char_count[si]
    mov ah , 2
    mov bh , page_num
    int 10h
    jmp io_loop
    
arrow_dn:
    mov ah , 03h
    mov bh , page_num
    int 10h
    cmp dh , 24
    je arrow_dn_last
    mov al , page_num
    mov cl , 25
    mul cl
    add al , dh
    mov si , ax
    inc si
    inc dh
    mov dl , char_count[si]
    mov ah , 2
    mov bh , page_num
    int 10h
    jmp io_loop
                   

arrow_up_first:
    jmp pg_up
    
arrow_dn_last:
    jmp pg_dn    
            
exit:
    mov ax,4c00h
    int 21h
    