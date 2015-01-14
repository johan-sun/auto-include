auto include
===

auto include header for function and type according to a database, it can read the keyword(as function or type or gloabal var)  in curser and auto include the header.

some command help the user include the header without swith to the head of current buffer.

keep one header include only onces.

#example of database
> \<header1\>:      
> keyword1      
> keyword2      
> "header2":        
> keyword3      
> keyword4      

database file store in rtp/db

#example:
when create a new c, cpp file, a auto include scope will append to the buffer

when the cursor is over cin , press <leader>i will include iostream if iostream is not been included.

when the cursor vector will include vector, press <leader>i will include vector if vector is not included.

when the cursor is over pthread\_create, press <leader>i will include pthread.h if pthread.h is not included.

if there are ambivalent from the database, the candidate headers will show in quickfix window.

the project has not finish

#TODO LIST
- command AIS headers... add the headers after the auto inlcude guard, guarantee it is uniqued( use #include <...>  )
- command AIU headers... add the headers after the auto include guard, guarantee it is uniqued( use #include "")
- finished database format.  the database for STL, posix, Qt
- a program help to generate the database ( base on ctags or libclang AST )
