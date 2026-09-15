GetMonDisplayName::
; Get a nickname suitable for display.
; Input: b = species, de = raw nickname.
; Output: display name in wStringBuffer1.
; In Mode 2, an English canonical nickname is displayed as the Chinese
; species name. All other raw nicknames are copied unchanged.
	push de
	ld a, [wEngPKMNNameMark]
	cp 2
	jr nz, .copy_raw
	; Keep this helper free of persistent context side effects.  Callers pass
	; the species explicitly in b; wNamedObjectIndex is only a temporary input
	; to the species-name table routines.
	ld a, [wNamedObjectIndex]
	push af
	ld a, b
	ld [wNamedObjectIndex], a
	push bc
	call GetPokemonNameENG
	pop bc
	pop af
	pop de
	push af
	push de
	ld hl, wStringBuffer1
	ld c, MON_NAME_LENGTH
	call CompareBytes
	jr nz, .copy_raw_restore_context
	pop de
	ld a, b
	ld [wNamedObjectIndex], a
	call GetPokemonNameCHS
	jr .restore_context

.copy_raw_restore_context
	pop de
	ld h, d
	ld l, e
	ld de, wStringBuffer1
	ld bc, MON_NAME_LENGTH
	call CopyBytes
	jr .restore_context

.copy_raw
	; Modes 0 and 1 need only a raw nickname copy.
	pop de
	ld h, d
	ld l, e
	ld de, wStringBuffer1
	ld bc, MON_NAME_LENGTH
	call CopyBytes
	ret

.restore_context
	pop af
	ld [wNamedObjectIndex], a
	ld de, wStringBuffer1
	ret

GetPartyMonDisplayName::
; Input: c = party slot. Output: display name in wStringBuffer1.
	ld b, 0
	ld hl, wPartySpecies
	add hl, bc
	ld b, [hl]
	push bc
	ld hl, wPartyMonNicknames
	ld a, c
	call SkipNames
	pop bc
	ld d, h
	ld e, l
	call GetMonDisplayName
	; Correct only the display copy.  CorrectNickErrors is deliberately not
	; allowed to mutate a party nickname while a menu is merely reading it.
	ld de, wStringBuffer1
	callfar CorrectNickErrors
	ret
