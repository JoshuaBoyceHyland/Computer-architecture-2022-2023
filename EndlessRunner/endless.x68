
    ORG    $1000
START:                  ; first instruction of program
* BASICALLY CONSTANTS
*-----------------------------------------------------------
* Section       : Trap Codes
* Description   : Trap Codes used throughout StarterKit
*-----------------------------------------------------------
* Trap CODES
TC_SCREEN   EQU         33          ; Screen size information trap code
TC_S_SIZE   EQU         00          ; Places 0 in D1.L to retrieve Screen width and height in D1.L
                                    ; First 16 bit Word is screen Width and Second 16 bits is screen Height
TC_KEYCODE  EQU         19          ; Check for pressed keys
TC_DBL_BUF  EQU         92          ; Double Buffer Screen Trap Code
TC_CURSR_P  EQU         11          ; Trap code cursor position

TC_EXIT     EQU         09          ; Exit Trapcode

*-----------------------------------------------------------
* Section       : Charater Setup
* Description   : Size of Player and Enemy and properties
* of these characters e.g Starting Positions and Sizes
*-----------------------------------------------------------
PLYR_W_INIT EQU         08          ; Players initial Width
PLYR_H_INIT EQU         08          ; Players initial Height

PLYR_DFLT_V EQU         00          ; Default Player Velocity
PLYR_JUMP_V EQU        -20          ; Player Jump Velocity
PLYR_DFLT_G EQU         01          ; Player Default Gravity

PLYR_POS_MOVEMENT EQU   01          ; player movement
GND_TRUE    EQU         01          ; Player on Ground True
GND_FALSE   EQU         00          ; Player on Ground False

RUN_INDEX   EQU         00          ; Player Run Sound Index  
JMP_INDEX   EQU         01          ; Player Jump Sound Index  
OPPS_INDEX  EQU         02          ; Player Opps Sound Index

ENMY_W_INIT EQU         30          ; Enemy initial Width
ENMY_H_INIT EQU         10          ; Enemy initial Height
NUM_OF_ENEMYS    EQU    02          ; number of enemys 

BULLET_W    EQU         05          ; bullet width
BULLET_H    EQU         05          ; bullet height


*-----------------------------------------------------------
* Section       : Game Stats
* Description   : Points
*-----------------------------------------------------------
POINTS      EQU         01          ; Points added

*-----------------------------------------------------------
* Section       : Keyboard Keys
* Description   : Spacebar and Escape or two functioning keys
* Spacebar to JUMP and Escape to Exit Game
*-----------------------------------------------------------
SPACEBAR    EQU         $20         ; Spacebar ASCII Keycode
ESCAPE      EQU         $1B         ; Escape ASCII Keycode
D           EQU         $44         ; D ASCII Keycode
W           EQU         $57         ; W ASCII KeyCode
A           EQU         $41         ; A ASCII Keycode
S           EQU         $53         ; S ASCII Keycode   

*-----------------------------------------------------------
* Section       : Speed
* Description   : movement speed 
*-----------------------------------------------------------
SPEED           EQU         20          ; speed for character`   
ENEMY_SPEED     EQU         05  ; will get faster over time   `
BULLET_SPEED    EQU         80          ; speed for bullet
*-----------------------------------------------------------
* Subroutine    : Initialise
* Description   : Initialise game data into memory such as 
* sounds and screen size
*-----------------------------------------------------------
INITIALISE:
    ; Initialise Sounds
    BSR     RUN_LOAD                ; Load Run Sound into Memory
    BSR     JUMP_LOAD               ; Load Jump Sound into Memory
    BSR     OPPS_LOAD               ; Load Opps (Collision) Sound into Memory

    ; Screen Size
    MOVE.B  #TC_SCREEN, D0          ; access screen information
    MOVE.L  #TC_S_SIZE, D1          ; placing 0 in D1 triggers loading screen size information
    TRAP    #15                     ; interpret D0 and D1 for screen size
    MOVE.W  D1,         SCREEN_H    ; place screen height in memory location
    SWAP    D1                      ; Swap top and bottom word to retrive screen size
    MOVE.W  D1,         SCREEN_W    ; place screen width in memory location

    ; Place the Player at the center of the screen
    CLR.L   D1                      ; Clear contents of D1 (XOR is faster)
    MOVE.W  SCREEN_W,   D1          ; Place Screen width in D1
    DIVU    #02,        D1          ; divide by 2 for center on X Axis
    MOVE.L  D1,         PLAYER_X    ; Players X Position

    CLR.L   D1                      ; Clear contents of D1 (XOR is faster)
    * MOVE.W  SCREEN_H,   D1          ; Place Screen width in D1
    * SUB.L    #50,        D1          ; divide by 2 for center on Y Axis
    MOVE.L  #425,         PLAYER_Y    ; Players Y Position

    ; Initialise Player Score
    CLR.L   D1                      ; Clear contents of D1 (XOR is faster)
    MOVE.L  #00,        D1          ; Init Score
    MOVE.L  D1,         PLAYER_SCORE

    ; Initialise Player Velocity
    CLR.L   D1                      ; Clear contents of D1 (XOR is faster)
    MOVE.B  #PLYR_DFLT_V,D1         ; Init Player Velocity
    MOVE.L  D1,         PLYR_VELOCITY


    ; Initialize Player on Ground
    MOVE.L  #GND_TRUE,  PLYR_ON_GND ; Init Player on Ground

    ; intitial pos for test bullet
    CLR.L   D1                      ; Clear contents of D1 (XOR is faster)
    MOVE.W  #100,   D1          ; Place Screen width in D1
    MOVE.L  D1,         BULLET_X     ; Enemy X Position

    CLR.L   D1                      ; Clear contents of D1 (XOR is faster)
    MOVE.W  #100,   D1         ; Place Screen width in D1
    ;DIVU    #02,        D1         ; divide by 2 for center on Y Axis
    MOVE.L  #100,   BULLET_Y     ; Enemy Y Position

    ; initialisation of booleans for bullet been shot and enemy moving right
    CLR.L D1
    MOVE.W #0, D1
    MOVE.B D1, BEEN_SHOT
    MOVE.B D1, ENEMY_MOVING_R ; makes false so is moving left to start

    CLR.L D1
    MOVE.L #50, D1
    MOVE.L D1, BASE_LIVES 
    ; Enable the screen back buffer(see easy 68k help)
	MOVE.B  #TC_DBL_BUF,D0          ; 92 Enables Double Buffer
    MOVE.B  #17,        D1          ; Combine Tasks
	TRAP	#15                     ; Trap (Perform action)

    ; Clear the screen (see easy 68k help)
    MOVE.B  #TC_CURSR_P,D0          ; Set Cursor Position
	MOVE.W  #$FF00,     D1          ; Fill Screen Clear
	TRAP	#15                     ; Trap (Perform action)
*-----------------------------------------------------------
* Subroutine    : initialise enemey positions
* Description   : sets up the positions for enemys 
*-----------------------------------------------------------
INITIALISE_ENEMYS:
    CLR.L   D1                      ; Clear contents of D1 (XOR is faster)
    MOVE.W  #100,   D1          ; Place Screen width in D1
    MOVE.L  D1,         ENEMY_1_X     ; Enemy X Position
    CLR.L   D1                      ; Clear contents of D1 (XOR is faster)
    MOVE.W  #0,   D1          ; Place Screen width in D1
    SUB.L   #10, D1
    MOVE.L  D1,         ENEMY_1_Y     ; Enemy X Position

    CLR.L   D1                      ; Clear contents of D1 (XOR is faster)
    MOVE.W  #200,   D1          ; Place Screen width in D1
    MOVE.L  D1,         ENEMY_2_X     ; Enemy X Position
    CLR.L   D1                      ; Clear contents of D1 (XOR is faster)
    MOVE.W  #0,   D1          ; Place Screen width in D1
    SUB.L   #200, D1
    MOVE.L  D1,         ENEMY_2_Y     ; Enemy X Position

    CLR.L   D1                      ; Clear contents of D1 (XOR is faster)
    MOVE.W  #300,   D1          ; Place Screen width in D1
    MOVE.L  D1,         ENEMY_3_X     ; Enemy X Position
    CLR.L   D1                      ; Clear contents of D1 (XOR is faster)
    MOVE.W  #00,   D1          ; Place Screen width in D1
    SUB.L   #300, D1
    MOVE.L  D1,         ENEMY_3_Y     ; Enemy X Position

    CLR.L   D1                      ; Clear contents of D1 (XOR is faster)
    MOVE.W  #400,   D1          ; Place Screen width in D1
    MOVE.L  D1,         ENEMY_4_X     ; Enemy X Position
    CLR.L   D1                      ; Clear contents of D1 (XOR is faster)
    MOVE.W  #0,   D1          ; Place Screen width in D1
    SUB.L   #250, D1
    MOVE.L  D1,         ENEMY_4_Y     ; Enemy X Position

    CLR.L   D1                      ; Clear contents of D1 (XOR is faster)
    MOVE.W  #500,   D1          ; Place Screen width in D1
    MOVE.L  D1,         ENEMY_5_X     ; Enemy X Position
    CLR.L   D1                      ; Clear contents of D1 (XOR is faster)
    MOVE.W  #0,   D1          ; Place Screen width in D1
    SUB.L   #400, D1
    MOVE.L  D1,         ENEMY_5_Y     ; Enemy X Position

    * CLR.L   D1
    * MOVE.L  #5,    D1
    * MOVE.L  D1,     ENEMY_SPEED



*-----------------------------------------------------------
* Subroutine    : Game
* Description   : Game including main GameLoop. GameLoop is like
* a while loop in that it runs forever until interupted
* (Input, Update, Draw). The Enemies Run at Player Jump to Avoid
*-----------------------------------------------------------
GAME:
    BSR     PLAY_RUN                ; Play Run Wav
GAMELOOP:
    ; Main Gameloop
    MOVE.B #8, D0                   ; D0 IS ONLY USED FOR COMMANDS, OUTPUST FROM THIS GOINTO OTHER DATA REGISTERS, THIS WILL BE STORED IN D1 
    TRAP #15     
    MOVE.L D1, DELTA_TIME                   ; TRAP 15 RUNS COMMAND 15   
    BSR     INPUT                   ; Check Keyboard Input
    BSR     UPDATE                  ; Update positions and points
    BSR     UPDATE_BULLET
    BSR     UPDATE_ENEMYS
    ;BSR     IS_PLAYER_ON_GND        ; Check if player is on ground
    BSR     CHECK_COLLISIONS        ; Check for Collisions
    BSR     DRAW                    ; Draw the Scene
    BSR     CHECK_FOR_EXIT
    

GAME_DELTA_t:
    MOVE.B #8, D0                   ;CURRENT TIME 
    TRAP #15  
    SUB.L DELTA_TIME, D1            ; TAKING AWAY DELTATIME FROM CURRENT TO CHECK REMAINDER, 
    
    CMP.L #4, D1
    BMI.S GAME_DELTA_t                     ; if deltam time is lesser or equal to 17; branch lesser or equal to 
    BRA GAMELOOP



*checks if base lives has is higher than -
CHECK_FOR_EXIT:
    CMP.L #0, BASE_LIVES
    BLE END_SCREEN_LOOP
    RTS



UPDATE_BULLET:
    BSR CHECK_FOR_BULLET_RESPAWN
    CMP.B #0, BEEN_SHOT
    BEQ BULLET_TRACK_PLAYER ; if the bullet has not been shot will track player
    BRA SHOOT_BULLET
    RTS

UPDATE_ENEMYS:
   BSR ENEMY_MOVE_DOWN
   BSR CHECK_ENEMY_RESETS
    RTS
ENEMY_MOVE_DOWN:

    MOVE.L ENEMY_2_Y, D1
    ADD.L #ENEMY_SPEED, ENEMY_1_Y
    ADD.L #ENEMY_SPEED, ENEMY_2_Y
    ADD.L #ENEMY_SPEED, ENEMY_3_Y
    ADD.L #ENEMY_SPEED, ENEMY_4_Y
    ADD.L #ENEMY_SPEED, ENEMY_5_Y
    RTS

CHECK_ENEMY_RESETS
    BSR CHECK_ENEMY_RESET_1
    BSR CHECK_ENEMY_RESET_2
    BSR CHECK_ENEMY_RESET_3
    BSR CHECK_ENEMY_RESET_4
    BSR CHECK_ENEMY_RESET_5
    RTS
CHECK_ENEMY_RESET_1:
    CLR.L D1
    CLR.L D2

    MOVE.L #480, D1      ; point in which on screen respawn will happen 
    MOVE.L ENEMY_1_Y, D2
    
    CMP.L D1, D2
    BGE   ENEMY_1_REACHED_BASE
    RTS

ENEMY_1_REACHED_BASE:
    SUB.L #01, BASE_LIVES
RESET_ENEMY_1:
    MOVE.L #0, ENEMY_1_Y
    RTS

CHECK_ENEMY_RESET_2:
    CLR.L D1
    CLR.L D2

    MOVE.L #480, D1      ; point in which on screen respawn will happen 
    MOVE.L ENEMY_2_Y, D2
    
    CMP.L D1, D2
    BGE   ENEMY_2_REACHED_BASE
    RTS

ENEMY_2_REACHED_BASE:
    SUB.L #01, BASE_LIVES
RESET_ENEMY_2:
    MOVE.L #0, ENEMY_2_Y
    RTS

CHECK_ENEMY_RESET_3:
    CLR.L D1
    CLR.L D2

    MOVE.L #480, D1      ; point in which on screen respawn will happen 
    MOVE.L ENEMY_3_Y, D2
    
    CMP.L D1, D2
    BGE   ENEMY_3_REACHED_BASE
    RTS
    
ENEMY_3_REACHED_BASE:
    SUB.L #01, BASE_LIVES
RESET_ENEMY_3:
    MOVE.L #0, ENEMY_3_Y
    RTS

CHECK_ENEMY_RESET_4:
    CLR.L D1
    CLR.L D2

    MOVE.L #480, D1      ; point in which on screen respawn will happen 
    MOVE.L ENEMY_4_Y, D2
    
    CMP.L D1, D2
    BGE   ENEMY_4_REACHED_BASE
    RTS

ENEMY_4_REACHED_BASE:
    SUB.L #01, BASE_LIVES
RESET_ENEMY_4:
    MOVE.L #0, ENEMY_4_Y
    RTS

CHECK_ENEMY_RESET_5:
    CLR.L D1
    CLR.L D2

    MOVE.L #480, D1      ; point in which on screen respawn will happen 
    MOVE.L ENEMY_5_Y, D2
    
    CMP.L D1, D2
    BGE   ENEMY_5_REACHED_BASE
    RTS

ENEMY_5_REACHED_BASE:
    SUB.L #01, BASE_LIVES
RESET_ENEMY_5:
    MOVE.L #0, ENEMY_5_Y
    RTS

CHECK_FOR_BULLET_RESPAWN:
    CMP.L #0, BULLET_Y
    BLT RESPAWN_BULLET
    RTS

RESPAWN_BULLET:
    SUB.L #1, BEEN_SHOT
    RTS
    

SHOOT_BULLET:
    SUB.L #50, BULLET_Y
    RTS

BULLET_TRACK_PLAYER:
    MOVE.L PLAYER_X, BULLET_X
    MOVE.L PLAYER_Y, BULLET_Y
    RTS


*-----------------------------------------------------------
* Subroutine    : Input
* Description   : Process Keyboard Input
*-----------------------------------------------------------
INPUT:
    ; Process Input
    CLR.L   D1                      ; Clear Data Register
    MOVE.B  #TC_KEYCODE,D0          ; Listen for Keys
    MOVE.L #$20415344,D1            ; ALL THE INPUTS PUT IN D1 WASD, IN ONE BYTE
    TRAP   #15                      ; DEXCUTES ABOVE AND CHECKS IF ny have been pushed

   * CHECKS CORRESPONG NUMBERS ARE BEING PRESSED
    CMP.L  #$FFFF0000, D1           ; SPACE
    BEQ    SHOOT
    BEQ    MOVE_LEFT

    CMP.L  #$FF0000FF, D1           ; SPACE
    BEQ    SHOOT
    BEQ    MOVE_RIGHT

    CMP.L  #$FF000000, D1           ; SPACE
    BEQ    SHOOT

    CMP.L  #$00FF0000, D1           ; A
    BEQ    MOVE_LEFT

    CMP.L  #$0000FF00, D1           ; S
    BEQ    MOVE_DOWN

    CMP.L  #$000000FF, D1           ; D
    BEQ    MOVE_RIGHT
    RTS                             ; Return to subroutine



*-----------------------------------------------------------
* Subroutine    : Update
* Description   : Main update loop update Player and Enemies
*-----------------------------------------------------------
UPDATE:
    ; Update the Players Positon based on Velocity and Gravity
    CLR.L   D1                      ; Clear contents of D1 (XOR is faster)
    MOVE.L  PLYR_VELOCITY, D1       ; Fetch Player Velocity
    MOVE.L  D1,         PLYR_VELOCITY ; Update Player Velocity
    ADD.L   PLAYER_Y,   D1          ; Add Velocity to Player
    MOVE.L  D1,         PLAYER_Y    ; Update Players Y Position 

    RTS                             ; Return to subroutine  


*-----------------------------------------------------------
* Subroutine    : Draw
* Description   : Draw Screen
*-----------------------------------------------------------
DRAW: 
    ; Enable back buffer
    MOVE.B  #94,        D0
    TRAP    #15

    ; Clear the screen
    MOVE.B	#TC_CURSR_P,D0          ; Set Cursor Position
	MOVE.W	#$FF00,     D1          ; Clear contents
	TRAP    #15                     ; Trap (Perform action)

    
    
    BSR     DRAW_PLAYER             ; Draw Player
    BSR     DRAW_ENEMYS             ; Draw Enemy
    BSR     DRAW_BULLET             ; draw bullet
    BSR     DRAW_BASE
    BSR     DRAW_PLYR_DATA          ; Draw Draw Score, HUD, Player X and Y
    RTS                             ; Return to subroutine

*-----------------------------------------------------------
* Subroutine    : Draw Player Data
* Description   : Draw Player X, Y, Velocity, Gravity and OnGround
*-----------------------------------------------------------
DRAW_PLYR_DATA:
    CLR.L   D1                      ; Clear contents of D1 (XOR is faster)

    ; Player Score Message
    MOVE.B  #TC_CURSR_P,D0          ; Set Cursor Position
    MOVE.W  #$0201,     D1          ; Col 02, Row 01
    TRAP    #15                     ; Trap (Perform action)
    LEA     SCORE_MSG,  A1          ; Score Message
    MOVE    #13,        D0          ; No Line feed
    TRAP    #15                     ; Trap (Perform action)

    ; Player Score Value
    MOVE.B  #TC_CURSR_P,D0          ; Set Cursor Position
    MOVE.W  #$0901,     D1          ; Col 09, Row 01
    TRAP    #15                     ; Trap (Perform action)
    MOVE.B  #03,        D0          ; Display number at D1.L
    MOVE.L  PLAYER_SCORE,D1         ; Move Score to D1.L
    TRAP    #15                     ; Trap (Perform action)
    
  
    ; Show Keys Pressed
    MOVE.B  #TC_CURSR_P,D0          ; Set Cursor Position
    MOVE.W  #$0202,     D1          ; Col 20, Row 1
    TRAP    #15                     ; Trap (Perform action)
    LEA     BASE_LIVES_MSG, A1         ; Keycode
    MOVE    #13,        D0          ; No Line feed
    TRAP    #15                     ; Trap (Perform action)

    ; Show KeyCode
    MOVE.B  #TC_CURSR_P,D0          ; Set Cursor Position
    MOVE.W  #$1002,     D1          ; Col 30, Row 1
    TRAP    #15                     ; Trap (Perform action)    
    MOVE.L  BASE_LIVES ,D1          ; Move Key Pressed to D1
    MOVE.B  #03,        D0          ; Display the contents of D1
    TRAP    #15                     ; Trap (Perform action)

   
    RTS  




*-----------------------------------------------------------
* Subroutine    : Idle
* Description   : Perform a Idle
*----------------------------------------------------------- 
IDLE:
    BSR     PLAY_RUN                ; Play Run Wav
    RTS                             ; Return to subroutine


*-----------------------------------------------------------
* Subroutine    : MOVE_RIGHT
* Description   : Perform a move right
*-----------------------------------------------------------
MOVE_RIGHT:
    BEQ     PERFORM_MOVE_RIGHT  ; do actual move ment to right
    BRA     MOVEMENT_DONE       ; return back 
PERFORM_MOVE_RIGHT:
    ADD.L   #SPEED, PLAYER_X       ; adds movement to the position
    RTS



*-----------------------------------------------------------
* Subroutine    : MOVE_LEFT
* Description   : Perform a move left
*-----------------------------------------------------------

MOVE_LEFT:
    BEQ     PERFORM_MOVE_LEFT   ; do actual movement left
    BRA     MOVEMENT_DONE      ; RETURN BACK

PERFORM_MOVE_LEFT:  
    SUB.L #SPEED, PLAYER_X         ; takes away movement from position
    RTS

*-----------------------------------------------------------
* Subroutine    : MOVE_UP
* Description   : Perform a move up
*-----------------------------------------------------------
SHOOT:
    ADD.L #01, BEEN_SHOT  ; do actual movement left
    BRA     MOVEMENT_DONE      ; RETURN BACK
    RTS


*-----------------------------------------------------------
* Subroutine    : MOVE_DOWN
* Description   : Perform a move down
*-----------------------------------------------------------
MOVE_DOWN:
    BEQ     PERFORM_MOVE_DOWN   ; do actual movement down
    BRA     MOVEMENT_DONE     ; RETURN BACK
    RTS

PERFORM_MOVE_DOWN:  
    ADD.L #01, PLAYER_Y         ; takes away movement from position

MOVEMENT_DONE:
    RTS




*-----------------------------------------------------------
* Subroutines   : Sound Load and Play
* Description   : Initialise game sounds into memory 
* Current Sounds are RUN, JUMP and Opps for Collision
*-----------------------------------------------------------
RUN_LOAD:
    LEA     RUN_WAV,    A1          ; Load Wav File into A1
    MOVE    #RUN_INDEX, D1          ; Assign it INDEX
    MOVE    #71,        D0          ; Load into memory
    TRAP    #15                     ; Trap (Perform action)
    RTS                             ; Return to subroutine

PLAY_RUN:
    MOVE    #RUN_INDEX, D1          ; Load Sound INDEX
    MOVE    #72,        D0          ; Play Sound
    TRAP    #15                     ; Trap (Perform action)
    RTS                             ; Return to subroutine

JUMP_LOAD:
    LEA     JUMP_WAV,   A1          ; Load Wav File into A1
    MOVE    #JMP_INDEX, D1          ; Assign it INDEX
    MOVE    #71,        D0          ; Load into memory
    TRAP    #15                     ; Trap (Perform action)
    RTS                             ; Return to subroutine

PLAY_JUMP:
    MOVE    #JMP_INDEX, D1          ; Load Sound INDEX
    MOVE    #72,        D0          ; Play Sound
    TRAP    #15                     ; Trap (Perform action)
    RTS                             ; Return to subroutine

OPPS_LOAD:
    LEA     OPPS_WAV,   A1          ; Load Wav File into A1
    MOVE    #OPPS_INDEX,D1          ; Assign it INDEX
    MOVE    #71,        D0          ; Load into memory
    TRAP    #15                     ; Trap (Perform action)
    RTS                             ; Return to subroutine

PLAY_OPPS:
    MOVE    #OPPS_INDEX,D1          ; Load Sound INDEX
    MOVE    #72,        D0          ; Play Sound
    TRAP    #15                     ; Trap (Perform action)
    RTS                             ; Return to subroutine

*-----------------------------------------------------------
* Subroutine    : Draw Player
* Description   : Draw Player Square
*-----------------------------------------------------------
DRAW_PLAYER:
    ; Set Pixel Colors
    MOVE.L  #WHITE,     D1          ; Set Background color
    MOVE.B  #80,        D0          ; Task for Background Color
    TRAP    #15                     ; Trap (Perform action)

    ; Set X, Y, Width and Height
    MOVE.L  PLAYER_X,   D1          ; X
    MOVE.L  PLAYER_Y,   D2          ; Y
    MOVE.L  PLAYER_X,   D3
    ADD.L   #PLYR_W_INIT,   D3      ; Width
    MOVE.L  PLAYER_Y,   D4 
    ADD.L   #PLYR_H_INIT,   D4      ; Height
    
    ; Draw Player
    MOVE.B  #87,        D0          ; Draw Player
    TRAP    #15                     ; Trap (Perform action)
    RTS                             ; Return to subroutine


*-----------------------------------------------------------
* Subroutine    : Draw base
* Description   : Draw base Square
*-----------------------------------------------------------
DRAW_BASE:
    CLR.L D0
    CLR.L D1
    CLR.L D2
    CLR.L D3
    CLR.L D4

    MOVE.L #PURPLE,     D1
    MOVE.B  #80,        D0          
    TRAP    #15

    MOVE.L #PURPLE,     D1
    MOVE.B  #81,        D0          
    TRAP    #15

    MOVE.L  #WHITE,     D1          ; Set out line color
    MOVE.B  #80,        D0          ; Task for Background Color
    TRAP    #15                     ; Trap (Perform action)

    ; Set X, Y, Width and Height
    MOVE.L  #0,   D1          ; X
    SUB.L   #1, D1     
    MOVE.L  #500,   D2          ; Y
    MOVE.L  #0,   D3
    ADD.L   #SCREEN_W,   D3      ; Width

    ADD.L   #450,   D4      ; Height
    
    ; Draw Player
    MOVE.B  #87,        D0          ; Draw Player
    TRAP    #15                     ; Trap (Perform action)
    RTS                             ; Return to subroutine

*-----------------------------------------------------------
* Subroutine    : Draw Enemy
* Description   : Draw Enemy Square
*-----------------------------------------------------------
DRAW_ENEMYS:
    CLR.L D1
    CLR.L D2
    CLR.L D3
    ; Set Pixel Colors
    MOVE.L  #RED,       D1          ; Set Background color
    MOVE.B  #80,        D0          ; Task for Background Color
    TRAP    #15                     ; Trap (Perform action)

    CLR D0
    CLR D1
    CLR D2  
    CLR D3
    CLR D4
    CLR D5

DRAW_ENEMY_1:
    MOVE.L  ENEMY_1_X,      D1       ; X   
    MOVE.L  ENEMY_1_Y,      D2       ; Y

    * Width and Height *
    MOVE.L  ENEMY_1_X,      D3
    ADD.L   #ENMY_W_INIT,   D3      ; Width
    MOVE.L  ENEMY_1_Y,      D4 
    ADD.L   #ENMY_H_INIT,   D4      ; Height
    
    ; Draw Enemy    
    MOVE.B  #87,            D0          ; Draw Enemy
    TRAP    #15                     ; Trap (Perform action)

DRAW_ENEMY_2:
    MOVE.L  ENEMY_2_X,      D1       ; X   
    MOVE.L  ENEMY_2_Y,      D2       ; Y

    * Width and Height *
    MOVE.L  ENEMY_2_X,      D3
    ADD.L   #ENMY_W_INIT,   D3      ; Width
    MOVE.L  ENEMY_2_Y,      D4 
    ADD.L   #ENMY_H_INIT,   D4      ; Height
    
    ; Draw Enemy    
    MOVE.B  #87,        D0          ; Draw Enemy
    TRAP    #15                     ; Trap (Perform action)

DRAW_ENEMY_3:
    MOVE.L  ENEMY_3_X,      D1       ; X   
    MOVE.L  ENEMY_3_Y,      D2       ; Y

    * Width and Height *
    MOVE.L  ENEMY_3_X,      D3
    ADD.L   #ENMY_W_INIT,   D3      ; Width
    MOVE.L  ENEMY_3_Y,      D4 
    ADD.L   #ENMY_H_INIT,   D4      ; Height
    
    ; Draw Enemy    
    MOVE.B  #87,        D0          ; Draw Enemy
    TRAP    #15                     ; Trap (Perform action)


DRAW_ENEMY_4:
    MOVE.L  ENEMY_4_X,      D1       ; X   
    MOVE.L  ENEMY_4_Y,      D2       ; Y

    * Width and Height *
    MOVE.L  ENEMY_4_X,      D3
    ADD.L   #ENMY_W_INIT,   D3      ; Width
    MOVE.L  ENEMY_4_Y,      D4 
    ADD.L   #ENMY_H_INIT,   D4      ; Height
    
    ; Draw Enemy    
    MOVE.B  #87,        D0          ; Draw Enemy
    TRAP    #15                     ; Trap (Perform action)

DRAW_ENEMY_5:
    MOVE.L  ENEMY_5_X,      D1       ; X   
    MOVE.L  ENEMY_5_Y,      D2       ; Y

    * Width and Height *
    MOVE.L  ENEMY_5_X,      D3
    ADD.L   #ENMY_W_INIT,   D3      ; Width
    MOVE.L  ENEMY_5_Y,      D4 
    ADD.L   #ENMY_H_INIT,   D4      ; Height
    
    ; Draw Enemy    
    MOVE.B  #87,        D0          ; Draw Enemy
    TRAP    #15                     ; Trap (Perform action)

    RTS


*-----------------------------------------------------------
* Subroutine    : Draw bullet
* Description   : Draw Enemy bullet
*-----------------------------------------------------------
DRAW_BULLET:
; Set Pixel Colors
    MOVE.L  #AQUA,       D1          ; Set Background color
    MOVE.B  #80,        D0          ; Task for Background Color
    TRAP    #15                     ; Trap (Perform action)

    ; Set X, Y, Width and Height
    MOVE.L  BULLET_X,    D1          ; X
    MOVE.L  BULLET_Y,    D2          ; Y
    MOVE.L  BULLET_X,    D3
    ADD.L   #BULLET_W,   D3      ; Width
    MOVE.L  BULLET_Y,    D4 
    ADD.L   #BULLET_H,   D4      ; Height
    
    ; Draw Enemy    
    MOVE.B  #87,        D0          ; Draw Enemy
    TRAP    #15                     ; Trap (Perform action)
    RTS                             ; Return to subroutine




*-----------------------------------------------------------
* Subroutine    : Collision Check
* Description   : Axis-Aligned Bounding Box Collision Detection
* Algorithm checks for overlap on the 2 sides of the Player and 
* Not checking top of enemy as this gives less time to detect collision, it kept missing collision somtimes
* Enemy rectangles
* BULLET_X <= ENEMY_X + ENEMY_W &&
* BULLET_X>= ENEMY_X &&
* BULLET< = ENEMY_Y
*-----------------------------------------------------------
CHECK_COLLISIONS:

    BSR CHECK_BULLET_Y_GREATER_ENEMY_1_Y
    BSR CHECK_BULLET_Y_GREATER_ENEMY_2_Y
    BSR CHECK_BULLET_Y_GREATER_ENEMY_3_Y
    BSR CHECK_BULLET_Y_GREATER_ENEMY_4_Y
    BSR CHECK_BULLET_Y_GREATER_ENEMY_5_Y


    RTS

CHECK_BULLET_Y_GREATER_ENEMY_1_Y:    
    CLR.L   D1
    CLR.L   D2
     MOVE.L  Bullet_Y,   D1          ; Move Player Y to D1
     MOVE.L  ENEMY_1_y,    D2          ; Move Enemy Y to D2

     CMP.L   D1,         D2          ; Do they Overlap ?
     BGE     CHECK_BULLET_X_LESSER_1_WIDTH  ; Less than or Equal
     BRA     COLLISION_CHECK_DONE    ; If not no collision 



CHECK_BULLET_X_LESSER_1_WIDTH:     ; Check player is not  
    CLR.L   D1
    CLR.L   D2
    MOVE.L   Bullet_X,      D1          ; Move Player Width to D1
    MOVE.L  ENEMY_1_X,           D2          ; Move Enemy X to D2
    ADD.L   #ENMY_W_INIT,    D2         ; add enemy width to its x position to get its right corner position
    CMP.L   D2,             D1          ; Do they OverLap ?
    BLE     CHECK_BULLET_X_GREATER_ENEMY_1_X ; Less than or Equal
    BRA     COLLISION_CHECK_DONE    ; If not no collision   

CHECK_BULLET_X_GREATER_ENEMY_1_X:
    CLR.L   D1
    CLR.L   D2
    MOVE.L  Bullet_X,   D1          ; Move bullet X to D1
    MOVE.L  ENEMY_1_X,    D2          ; Move Enemy X to D2
    CMP.L   D2,         D1          ;   Do the Overlap ?
    BGE     COLLISION_1 ; greater than or equal ?
    BRA     COLLISION_CHECK_DONE    ; If not no collision

COLLISION_1:
    BSR     PLAY_OPPS               ; Play Opps Wav
    ADD.L  #01, PLAYER_SCORE       ; adds to Player Score

    
    BSR RESPAWN_BULLET
    
    BSR RESET_ENEMY_1
    
    BRA     COLLISION_CHECK_DONE

CHECK_BULLET_Y_GREATER_ENEMY_2_Y:    
    CLR.L   D1
    CLR.L   D2
     MOVE.L  Bullet_Y,   D1          ; Move Player Y to D1
     MOVE.L  ENEMY_2_y,    D2          ; Move Enemy Y to D2

     CMP.L   D1,         D2          ; Do they Overlap ?
     BGE     CHECK_BULLET_X_LESSER_2_WIDTH  ; Less than or Equal
     BRA     COLLISION_CHECK_DONE    ; If not no collision 



CHECK_BULLET_X_LESSER_2_WIDTH:     ; Check player is not  
    CLR.L   D1
    CLR.L   D2
    MOVE.L   Bullet_X,      D1          ; Move Player Width to D1
    MOVE.L  ENEMY_2_X,           D2          ; Move Enemy X to D2
    ADD.L   #ENMY_W_INIT,    D2         ; add enemy width to its x position to get its right corner position
    CMP.L   D2,             D1          ; Do they OverLap ?
    BLE     CHECK_BULLET_X_GREATER_ENEMY_2_X ; Less than or Equal
    BRA     COLLISION_CHECK_DONE    ; If not no collision   

CHECK_BULLET_X_GREATER_ENEMY_2_X:
    CLR.L   D1
    CLR.L   D2
    MOVE.L  Bullet_X,   D1          ; Move bullet X to D1
    MOVE.L  ENEMY_2_X,    D2          ; Move Enemy X to D2
    CMP.L   D2,         D1          ;   Do the Overlap ?
    BGE     COLLISION_2 ; greater than or equal ?
    BRA     COLLISION_CHECK_DONE    ; If not no collision

COLLISION_2:
    BSR     PLAY_OPPS               ; Play Opps Wav
    ADD.L  #01, PLAYER_SCORE       ; adds to Player Score

    
    BSR RESPAWN_BULLET
    BSR RESET_ENEMY_2
    
    BRA     COLLISION_CHECK_DONE

CHECK_BULLET_Y_GREATER_ENEMY_3_Y:    
    CLR.L   D1
    CLR.L   D2
     MOVE.L  Bullet_Y,   D1          ; Move Player Y to D1
     MOVE.L  ENEMY_3_y,    D2          ; Move Enemy Y to D2

     CMP.L   D1,         D2          ; Do they Overlap ?
     BGE     CHECK_BULLET_X_LESSER_3_WIDTH  ; Less than or Equal
     BRA     COLLISION_CHECK_DONE    ; If not no collision 


CHECK_BULLET_X_LESSER_3_WIDTH:     ; Check player is not  
    CLR.L   D1
    CLR.L   D2
    MOVE.L   Bullet_X,      D1          ; Move Player Width to D1
    MOVE.L  ENEMY_3_X,           D2          ; Move Enemy X to D2
    ADD.L   #ENMY_W_INIT,    D2         ; add enemy width to its x position to get its right corner position
    CMP.L   D2,             D1          ; Do they OverLap ?
    BLE     CHECK_BULLET_X_GREATER_ENEMY_3_X ; Less than or Equal
    BRA     COLLISION_CHECK_DONE    ; If not no collision   

CHECK_BULLET_X_GREATER_ENEMY_3_X:
    CLR.L   D1
    CLR.L   D2
    MOVE.L  Bullet_X,   D1          ; Move bullet X to D1
    MOVE.L  ENEMY_3_X,    D2          ; Move Enemy X to D2
    CMP.L   D2,         D1          ;   Do the Overlap ?
    BGE     COLLISION_3 ; greater than or equal ?
    BRA     COLLISION_CHECK_DONE    ; If not no collision

COLLISION_3:
    BSR     PLAY_OPPS               ; Play Opps Wav
    ADD.L  #01, PLAYER_SCORE       ; adds to Player Score

    
    BSR RESPAWN_BULLET
    BSR RESET_ENEMY_3
    
    BRA     COLLISION_CHECK_DONE

CHECK_BULLET_Y_GREATER_ENEMY_4_Y:    
    CLR.L   D1
    CLR.L   D2
     MOVE.L  Bullet_Y,   D1          ; Move Player Y to D1
     MOVE.L  ENEMY_4_y,    D2          ; Move Enemy Y to D2

     CMP.L   D1,         D2          ; Do they Overlap ?
     BGE     CHECK_BULLET_X_LESSER_4_WIDTH  ; Less than or Equal
     BRA     COLLISION_CHECK_DONE    ; If not no collision 

CHECK_BULLET_X_LESSER_4_WIDTH:     ; Check player is not  
    CLR.L   D1
    CLR.L   D2
    MOVE.L   Bullet_X,      D1          ; Move Player Width to D1
    MOVE.L  ENEMY_4_X,           D2          ; Move Enemy X to D2
    ADD.L   #ENMY_W_INIT,    D2         ; add enemy width to its x position to get its right corner position
    CMP.L   D2,             D1          ; Do they OverLap ?
    BLE     CHECK_BULLET_X_GREATER_ENEMY_4_X ; Less than or Equal
    BRA     COLLISION_CHECK_DONE    ; If not no collision   

CHECK_BULLET_X_GREATER_ENEMY_4_X:
    CLR.L   D1
    CLR.L   D2
    MOVE.L  Bullet_X,   D1          ; Move bullet X to D1
    MOVE.L  ENEMY_4_X,    D2          ; Move Enemy X to D2
    CMP.L   D2,         D1          ;   Do the Overlap ?
    BGE     COLLISION_4 ; greater than or equal ?
    BRA     COLLISION_CHECK_DONE    ; If not no collision

COLLISION_4:
    BSR     PLAY_OPPS               ; Play Opps Wav
    ADD.L  #01, PLAYER_SCORE       ; adds to Player Score
    
    BSR RESPAWN_BULLET
    BSR RESET_ENEMY_4
    
    BRA     COLLISION_CHECK_DONE

CHECK_BULLET_Y_GREATER_ENEMY_5_Y:    
    CLR.L   D1
    CLR.L   D2
     MOVE.L  Bullet_Y,   D1          ; Move Player Y to D1
     MOVE.L  ENEMY_5_y,    D2          ; Move Enemy Y to D2

     CMP.L   D1,         D2          ; Do they Overlap ?
     BGE     CHECK_BULLET_X_LESSER_5_WIDTH  ; Less than or Equal
     BRA     COLLISION_CHECK_DONE    ; If not no collision 

CHECK_BULLET_X_LESSER_5_WIDTH:     ; Check player is not  
    CLR.L   D1
    CLR.L   D2
    MOVE.L   Bullet_X,      D1          ; Move Player Width to D1
    MOVE.L  ENEMY_5_X,           D2          ; Move Enemy X to D2
    ADD.L   #ENMY_W_INIT,    D2         ; add enemy width to its x position to get its right corner position
    CMP.L   D2,             D1          ; Do they OverLap ?
    BLE     CHECK_BULLET_X_GREATER_ENEMY_5_X ; Less than or Equal
    BRA     COLLISION_CHECK_DONE    ; If not no collision   

CHECK_BULLET_X_GREATER_ENEMY_5_X:
    CLR.L   D1
    CLR.L   D2
    MOVE.L  Bullet_X,   D1          ; Move bullet X to D1
    MOVE.L  ENEMY_5_X,    D2          ; Move Enemy X to D2
    CMP.L   D2,         D1          ;   Do the Overlap ?
    BGE     COLLISION_5 ; greater than or equal ?
    BRA     COLLISION_CHECK_DONE    ; If not no collision

COLLISION_5:
    BSR     PLAY_OPPS               ; Play Opps Wav
    ADD.L  #01, PLAYER_SCORE       ; adds to Player Score
    
    
    BSR RESPAWN_BULLET
    BSR RESET_ENEMY_5
    
    BRA     COLLISION_CHECK_DONE




COLLISION_CHECK_DONE:               ; No Collision Update points
    RTS                             ; Return to subroutine





*-----------------------------------------------------------
* Subroutine    : end screen
* Description   : can exit program from here or restart
*-----------------------------------------------------------
END_SCREEN_LOOP:
    MOVE.B #8, D0                   ; D0 IS ONLY USED FOR COMMANDS, OUTPUST FROM THIS GOINTO OTHER DATA REGISTERS, THIS WILL BE STORED IN D1 
    TRAP #15     
    MOVE.L D1, DELTA_TIME                   ; TRAP 15 RUNS COMMAND 15   


END_SCREEN_DELTA_t:
    MOVE.B #8, D0                   ;CURRENT TIME 
    TRAP #15  
    SUB.L DELTA_TIME, D1            ; TAKING AWAY DELTATIME FROM CURRENT TO CHECK REMAINDER, 
    
    CMP.L #4, D1
    BMI.S END_SCREEN_DELTA_t                     ; if deltam time is lesser or equal to 17; branch lesser or equal to 
    BRA END_SCREEN_LOOP
*-----------------------------------------------------------
* Subroutine    : EXIT
* Description   : Exit message and End Game
*-----------------------------------------------------------
EXIT:
    ; Show if Exiting is Running
    MOVE.B  #TC_CURSR_P,D0          ; Set Cursor Position
    MOVE.W  #$4004,     D1          ; Col 40, Row 1
    TRAP    #15                     ; Trap (Perform action)
    LEA     EXIT_MSG,   A1          ; Exit
    MOVE    #13,        D0          ; No Line feed
    TRAP    #15                     ; Trap (Perform action)
    MOVE.B  #TC_EXIT,   D0          ; Exit Code
    TRAP    #15                     ; Trap (Perform action)
    SIMHALT

*-----------------------------------------------------------
* Section       : Messages
* Description   : Messages to Print on Console, names should be
* self documenting
*-----------------------------------------------------------

* BASICALLY VARIABLES DECALRED AT BTTOM 
* dc.b is text
* ds.b is number 
* becarefull how you store l/b, long/byte

SCORE_MSG           DC.B     'Score : ', 0  
BASE_LIVES_MSG      DC.B     'Base lives : ', 0     ; Keycode Message
JUMP_MSG            DC.B    'Jump....', 0       ; Jump Message

IDLE_MSG        DC.B    'Idle....', 0       ; Idle Message
UPDATE_MSG      DC.B    'Update....', 0     ; Update Message
DRAW_MSG        DC.B    'Draw....', 0       ; Draw Message

X_MSG           DC.B    'X:', 0             ; X Position Message
Y_MSG           DC.B    'Y:', 0             ; Y Position Message
V_MSG           DC.B    'V:', 0             ; Velocity Position Message
G_MSG           DC.B    'G:', 0             ; Gravity Position Message
GND_MSG         DC.B    'GND:', 0           ; On Ground Position Message

EXIT_MSG        DC.B    'Exiting....', 0    ; Exit Message

*-----------------------------------------------------------
* Section       : Graphic Colors
* Description   : Screen Pixel Color
*-----------------------------------------------------------
WHITE           EQU     $00FFFFFF
RED             EQU     $000000FF
AQUA            EQU     $00FFFF00
PURPLE          EQU     $00800080


*-----------------------------------------------------------
* Section       : Screen Size
* Description   : Screen Width and Height
*-----------------------------------------------------------
SCREEN_W        DS.W    01  ; Reserve Space for Screen Width
SCREEN_H        DS.W    01  ; Reserve Space for Screen Height

*-----------------------------------------------------------
* Section       : Bullet status
* Description   : whether bullet has been shot or not
* 0 = false
* 1 = true
*-----------------------------------------------------------
BEEN_SHOT       DS.L    01      ; reserve of space
*-----------------------------------------------------------
* Section       : Base lives
* Description   : Used for storing bases current lives
*-----------------------------------------------------------
BASE_LIVES      DS.L    01  ; Reserve Space for Current Key Pressed
*-----------------------------------------------------------
* Section       : Character Positions
* Description   : Player and Enemy Position Memory Locations
*-----------------------------------------------------------
PLAYER_X        DS.L    01  ; Reserve Space for Player X Position
PLAYER_Y        DS.L    01  ; Reserve Space for Player Y Position
PLAYER_SCORE    DS.L    01  ; Reserve Space for Player Score

PLYR_VELOCITY   DS.L    01  ; Reserve Space for Player Velocity
PLYR_GRAVITY    DS.L    01  ; Reserve Space for Player Gravity
PLYR_ON_GND     DS.L    01  ; Reserve Space for Player on Ground

ENEMY_1_X         DS.L    01 ; Reserve Space for Enemy X Position
ENEMY_1_Y         DS.L    01  ; Reserve Space for Enemy Y Position

ENEMY_2_X         DS.L    01
ENEMY_2_Y         DS.L    01

ENEMY_3_X         DS.L    01 ; Reserve Space for Enemy X Position
ENEMY_3_Y         DS.L    01  ; Reserve Space for Enemy Y Position

ENEMY_4_X         DS.L    01
ENEMY_4_Y         DS.l    01

ENEMY_5_X         DS.L    01 ; Reserve Space for Enemy X Position
ENEMY_5_Y         DS.L    01  ; Reserve Space for Enemy Y Position


ENEMY_MOVING_R    DS.L    01  ; RES SPACE FOR MOVING RIGHT BOOLEAN

ENEMY_SPEED_MODIFIER DS.L 01
BULLET_X        DS.L    01   ; space for bullet x pos    
BULLET_Y        DS.L    01   ; space for bullet y pos

*-----------------------------------------------------------
* Section       : TIme
* Description   : Sound files, which are then loaded and given
* an address in memory, they take a longtime to process and play
* so keep the files small. Used https://voicemaker.in/ to 
* generate and Audacity to convert MP3 to WAV
*-----------------------------------------------------------
DELTA_TIME      DS.L   01 ; empty 

*-----------------------------------------------------------
* Section       : Sounds
* Description   : Sound files, which are then loaded and given
* an address in memory, they take a longtime to process and play
* so keep the files small. Used https://voicemaker.in/ to 
* generate and Audacity to convert MP3 to WAV
*-----------------------------------------------------------
JUMP_WAV        DC.B    'jump.wav',0        ; Jump Sound
RUN_WAV         DC.B    'run.wav',0         ; Run Sound
OPPS_WAV        DC.B    'opps.wav',0        ; Collision Opps

    END    START        ; last line of source




*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
