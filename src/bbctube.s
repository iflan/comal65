.include "src/zif.inc"

.extern p0
.zeropage p0

zproc _start
    lda #<brk_handler
    sta BRKV+0
    lda #>brk_handler
    sta BRKV+1
    jmp start_interpreter
zendproc

zproc brk_handler
    ldx #0xff
    txs
    jsr OSNEWL
    ldy #1
    zloop
        lda (0xfd), y
        zbreakif_eq
        jsr OSWRCH
        iny
    zendloop
    jsr OSNEWL
    jmp error_return
zendproc

zproc platform_get_progtop
    ; Top of memory on a Tube is $f800.
    lda #$00
    ldx #$f8
    rts
zendproc

zproc platform_read_line
    lda #$00 ; read line
    ldx #<osword_block
    ldy #>osword_block
    jsr OSWORD
    zif_cc
        lda #0
        sta text_buffer+2, y
        sty text_buffer+1
    zendif
    rts

.data
osword_block:
    .word text_buffer+2
    .byte 252
    .byte 0
    .byte 255
zendproc

zproc platform_quit
    lda #142 ; start ROM
    ldx #0
    jmp OSBYTE
zendproc

zproc platform_openin
    ldy #0x40
    bra platform_open_common
zendproc

zproc platform_openout
    ldy #0x80
    bra platform_open_common
zendproc

zproc platform_openup
    ldy #0xc0
    bra platform_open_common
zendproc

zproc platform_open_common
    phy
    jsr munge_filename
    ldx p0+0
    ldy p0+1
    pla
    jsr OSFIND
    pha
    jsr unmunge_filename
    pla
    clc
    zif_eq
        sec
    zendif
    rts
zendproc

; Stores XA in p0 and converts it to \r-ending.

zproc munge_filename
    sta p0+0
    stx p0+1

    ldy #0
    zloop
        lda (p0), y
        zbreakif_eq
        iny
    zendloop
    lda #0x0d
    sta (p0), y
    rts
zendproc

; Converts p0 to \0-ending.

zproc unmunge_filename
    ldy #0
    zloop
        lda (p0), y
        cmp #0x0d
        zbreakif_eq
        iny
    zendloop
    lda #0x00
    sta (p0), y
    rts
zendproc

; Takes: Y = file handle

zproc platform_close
    lda #0
    jmp OSFIND
zendproc

.data

