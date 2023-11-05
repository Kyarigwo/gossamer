# gossamer

gossamer - yet another Risc V forth like language

## Next

interpret now implemented in gossamer.
Next:
  redefine header.
  add variable.
  add constant.
  add has >does ? or should this be before variable, constant, since they can be
      written in these terms.

  new header will also have a documentation pointer field, intially empty
  so I can add documentation to the words.

  Add internal documentation.
  Write wordlist in gossamer, and permit searching documentation.

  Move to virt bare metal?

## Names

Names are not obvious. I want to have a naming scheme that is consistent,
suggestive (ie, you can guess what it means) but also clean and not too silly.

We can have glyphs associated with usages.  Curly braces represent memory,
hence:

1. The input buffer is input, the values are input{ is the bottom of the buffer,
  }input is the top of the buffer.  {input} is the parse point.  {input&}  is
  the address of the variable containing {input}.
2. The format buffer is format.  }format is then the top of that area.  format{
   is the bottom of the area.  format&{ is then the address of the mutable
   value associated with the buffer.
3. }data is then the (current) top of the data area,  and }data& is the multable
  value of this.
5. ds is the data stack, so ds{ is the bottom of the stack, and }ds is the top.
6. rt is the return stack.  rs{ is the bottom, and }rs is the top

Also associate glyphs with the basic types?  ' is char, so 'nl is newline, 'bl
  is the space character, '0 is the ascii 0.  Then ' is the equventy of ascii.
  " is string, # is number, { is memory ?

Copying from one location to another is >.  This is either destructive or not
depends on the source. Use ? if the operation is normally destruction, but now
non destructive, and ! if normally destructive is now not so.

Also, ? indicates that a word only returns data, rather then modifies things,
and ! if it is destructive  where you woudl expective it to be otherwise.

rs>ds pops from the return stack to the data stack.  dup-rs>ds copies.

Types are indicated by a :.  So dup duplicates the cell on the stack, dup:2
duplicates two items.

? at the start of the element indicates it is conditional.  So ?dup only dups
if the values != 0?

if I have a pair of pointers into a buffer, b{ and }b,  we can change it to a
pair of b{ and b#.  Operator would be {#, and variable name is b{#

Should print be print, or >output?

Parsing.  If we had parsing combinators, then we could say word parse to
run a parser word.   And say the string addr-u could be pushed on the stack
first.   Ie, {input#} word parse?
For the moment, use word-parse