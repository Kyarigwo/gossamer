.global secondary_words, secondary_words_length
.global bootstrap_words, bootstrap_words_length

.data 2
bootstrap_words:
.incbin "src/gossamer/bootstrap.gossamer"
.equ bootstrap_words_length, .-bootstrap_words

.data 2
secondary_words:
.incbin "src/gossamer/nucleus.gossamer"
.equ secondary_words_length, .-secondary_words

