.global secondary_words, secondary_words_length

.data 2
secondary_words:
.incbin "nucleus.gossamer"
.equ secondary_words_length, .-secondary_words
