256 constant max-prefabs

/OBJECT
    getset objtype objtype!
    getset action# action#!
    fgetset vx vx!
    fgetset vy vy!
drop

128 constant /userfields

max-prefabs /objslot array prefab
max-prefabs 256 cells array sdata  \ static data such as actions

: prefab: ( n - <name> ) ( - n )
    dup constant dup prefab [[
    dup objtype!
        16 * s>f fdup xy!  \ default positioning; can be changed using the prefabs.iol file
    true en!
;

: ;prefab ]] ;

: (vector!) create dup , does> @ objtype sdata + ! ;
: (vector) create dup , does> @ objtype sdata + @ execute ;
: vector  (vector) (vector!) cell+ ;
: ::  ( prefab - <vector> )
    prefab [[ :noname ' >body @ objtype sdata + ! ]] ;


( TODO: actions )

0
    vector start start!
    vector think think!   \ temporary
value /sdata

: become  prefab me /objslot move ;

: script  ( n - <name> )
    false to warnings?
    include
    true to warnings?
;

: changed  ( - <name> )
    false to warnings?
    >in @ ' >body @ swap >in ! bl parse GetPathSpec included
    true to warnings? ;  

: load-prefabs
    z" prefabs.iol" ?dup if ?exist if
        file[ 0 prefab [ lenof prefab /objslot * ]# read ]file
    then then
    s" scripts.f" included
;   