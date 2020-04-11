0 value timer
: shutdown
    deinit
    al_uninstall_system
;
: empty  shutdown empty ;
: read-mouse
    etype case
        ALLEGRO_EVENT_MOUSE_AXES of
            alevt MOUSE_EVENT.dx 2@ or if
                alevt MOUSE_EVENT.x @
                alevt MOUSE_EVENT.y @ 2dup to mousey to mousex
                ms0 ALLEGRO_MOUSE_STATE.y ! ms0 ALLEGRO_MOUSE_STATE.x !
            then
\            alevt MOUSE_EVENT.dz 2@ or if
\                alevt MOUSE_EVENT.z 2@ to mwheelx to mwheely
\            then
        endof
        ALLEGRO_EVENT_MOUSE_BUTTON_DOWN of
            alevt MOUSE_EVENT.button @ case
                1 of ms0 ALLEGRO_MOUSE_STATE.buttons dup @ 1 or swap ! endof
                2 of ms0 ALLEGRO_MOUSE_STATE.buttons dup @ 2 or swap ! endof
                3 of ms0 ALLEGRO_MOUSE_STATE.buttons dup @ 4 or swap ! endof
            endcase
        endof
        ALLEGRO_EVENT_MOUSE_BUTTON_UP of
            alevt MOUSE_EVENT.button @ case
                1 of ms0 ALLEGRO_MOUSE_STATE.buttons dup @ 1 invert and swap ! endof
                2 of ms0 ALLEGRO_MOUSE_STATE.buttons dup @ 2 invert and swap ! endof
                3 of ms0 ALLEGRO_MOUSE_STATE.buttons dup @ 4 invert and swap ! endof
            endcase
        endof        
    endcase
;
: read-keyboard
    etype case
        ALLEGRO_EVENT_KEY_DOWN of
            1 alevt KEYBOARD_EVENT.keycode @ kbs0 + c!
        endof
        ALLEGRO_EVENT_KEY_UP of
            0 alevt KEYBOARD_EVENT.keycode @ kbs0 + c!
        endof
    endcase
;

: frame
    me >r step r> to me
    [ dev ] [if] me >r system r> to me [then]
    [ dev ] [if] pause [then]
    me >r update r> to me
    display al_flip_display
    kbs0 kbs1 /ALLEGRO_KEYBOARD_STATE move
\    kbs0 al_get_keyboard_state
    ms0 ms1 /ALLEGRO_MOUSE_STATE move
\    ms2 ms0 /ALLEGRO_MOUSE_STATE move
\    ms0 al_get_mouse_state
;
: (go)
    begin
        queue alevt al_wait_for_event 
        etype ALLEGRO_EVENT_TIMER = if
            frame
            kbs0 59 + c@ if exit then
        then
        read-mouse
        read-keyboard
        me >r pump r> to me
    again
;
: go
    kbs0 /ALLEGRO_KEYBOARD_STATE erase
    kbs1 /ALLEGRO_KEYBOARD_STATE erase
    al_uninstall_keyboard  al_install_keyboard drop
    queue al_get_keyboard_event_source al_register_event_source
    display al_flip_display
    1e 60e f/ al_create_timer dup al_start_timer to timer
    queue timer al_get_timer_event_source al_register_event_source
    (go)
    timer al_destroy_timer
    [ fullscreen dev and ] [if] shutdown bye [then]
;
: init
    init-allegro
    load-data
    init-game
    [ mswin dev and ] [if] vfx-hwnd SetForegroundWindow drop [then]
;
: warm
    init
    go
;
: cold
    warm
    shutdown
;

dev fullscreen not and mswin and [if]
    : go
        display al_get_win_window_handle SetForegroundWindow drop
        go
        vfx-hwnd SetForegroundWindow drop
    ;
[then]

' cold is EntryPoint
