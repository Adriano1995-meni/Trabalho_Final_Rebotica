// ======================================================================
// RB2021 version 1.0
// Controller for the RB kit.
//
// Carlos Carreto
// Last revision: 13/05/2021 
// ======================================================================


// ======================================================================
// Constants
// ======================================================================
WAIT = 0
NAVIGATE = 1
APPROACH = 2
PUT_OUT = 3
VOLTAR_INICIO = 4


 
NO_TAG = 0
CIRCLE_TAG = 1
LINE_TAG = 2 
 
DIST_FRONT_LIMIT = 30
DIST1 = 40
DIST2 = 50 
 
// ======================================================================
// Variables
// ======================================================================
state = WAIT

oX = 250
oY = 50


wallColor = GREEN
lineColor = WHITE
startColor = WHITE
floorColor = BLACK
candleColor = RED
penColor = BLUE

flameDirection = 0
flameColor = BLACK
flamDistance = 0
flameFound = false

flameInRoom = false
rooms = 0

stateName = ""

tempoInicial = 0
tempoFinal = 0
tempoTotal = 0
tempoVela = 0

// ======================================================================
// Main Program
// ======================================================================
mainProgram:

 
  goSub initializeGUI
  gosub drawArena
  gosub initializeRobot
  goSub finiteStateMachine  
  
end
   

// ======================================================================
// GUI
// ======================================================================

initializeGUI:
  addButton "START", oX, oY - 30 - 10, 80, 30
  addButton "STOP", oX + 80 + 10, oY - 30 - 10, 80, 30

  call header(10, 10, "Configuration", 12)
    
  addButton "RESET", 10, oY, 80, 30

  xyString 10, oY + 30 + 10, "Flame position: "
  addEdit "EFlamePos", 195, oY + 30 + 10, 23, 23, 0
  setEditMask "EFlamePos", "0" 

  xyString 10, oY + 60 + 10, "Arena configuration: "
  addEdit "EArenaConfig", 195, oY + 60 + 10, 23, 23, 0
  setEditMask "EArenaConfig", "0" 

  addCheckBox "CBPen", 10, oY + 90 + 10, "Pen", true, false
  addCheckBox "CBAStart", 10, oY + 110 + 10, "Arbitrary start", false, false
  addCheckBox "CBFurniture", 10, oY + 130 + 10, "Furniture", false, false  
  addCheckBox "CBRTrip", 10, oY + 150 + 10, "Return trip", false, false
  
  call header(10, 300, "Screen", 12)

  onCheckBox cbHandler

  goSub setLedOFF
return


// ======================================================================
// Initialization
// ======================================================================

initializeRobot:
  rLocate oX + 200, oY + 45, 180
  rInvisible floorColor, lineColor, startColor, penColor
  rPen Down, penColor
  LineWidth 3
  rSlip 20
return




// ======================================================================
// Arena
// ======================================================================
drawArena:
// Draw the floor.
  rectangle oX, oY, oX + 496, oY + 496, floorColor, floorColor

  // Draw exterior walls
  line oX, oY, oX, oY + 496, 3, wallColor //Left
  line oX, oY, oX + 496, oY, 3, wallColor //Top
  line oX + 496, oY, oX + 496, oY + 496, 3, wallColor //Right
  line oX, oY + 496, oX + 496, oY + 496, 3, wallColor //Botom
 
  // Draw room 1
  line oX + 154, oY, oX + 154, oY + 182, 3, wallColor 
  line oX + 96, oY + 182, oX + 154, oY + 182, 3, wallColor 
  line oX + 3, oY + 182, oX + 93, oY + 182, 3, lineColor //*** line ***
 
  // Draw room 2
  line oX, oY + 274, oX + 154, oY + 274, 3, wallColor 

  line oX + 154, oY + 274, oX + 154, oY + 396, 3, wallColor 
  line oX + 154, oY + 399, oX + 154, oY + 493, 3, lineColor //*** line ***
  
  
 
  
  // Use room configuration given by the user or choose a random configuration.
  arenaConfig = ToNumber(GetEdit("EArenaConfig"))
  if(arenaConfig < 1 or arenaConfig > 4)
    arenaConfig = Random(3) + 1
    SetEdit "EArenaConfig", arenaConfig
  endif  

  // Draw room 3.
  if (arenaConfig = 1) or (arenaConfig = 2)
     Line oX + 246, oY + 314, oX + 496, oY + 314, 3, wallColor 
     Line oX + 246, oY + 406, oX + 246, oY + 496, 3, wallColor 
     Line oX + 246, oY + 317, oX + 246, oY + 403, 3, lineColor //*** line ***
     Line oX + 407, oY + 314, oX + 493, oY + 314, 3, lineColor //*** line ***
   elseif (arenaConfig = 3)  or (arenaConfig = 4)
     Line oX + 246, oY + 314, oX + 496, oY + 314, 3, wallColor 
     Line oX + 246, oY + 314, oX + 246, oY + 396, 3, wallColor 
     Line oX + 246, oY + 399, oX + 246, oY + 493, 3, lineColor //*** line ***
     Line oX + 407, oY + 314, oX + 493, oY + 314, 3, lineColor //*** line ***
  endif
  
  // Draw room 4.
  if (arenaConfig = 1) or (arenaConfig = 4)  
      Line oX + 246, oY + 92, oX + 246, oY + 214, 3, wallColor 
      Line oX + 246, oY + 92, oX + 398, oY + 92, 3, wallColor 
      Line oX + 398, oY + 92, oX + 398, oY + 214, 3, wallColor 
      Line oX + 398, oY + 214, oX + 342, oY + 214, 3, wallColor 
      Line oX + 249, oY + 214, oX + 339, oY + 214, 3, lineColor //*** line ***
  elseif (arenaConfig = 2) or (arenaConfig = 3)
      Line oX + 246, oY + 92, oX + 246, oY + 214, 3, wallColor 
      Line oX + 298, oY + 92, oX + 398, oY + 92, 3,  lineColor 
      Line oX + 398, oY + 92, oX + 398, oY + 214, 3, wallColor 
      Line oX + 246, oY + 92, oX + 298, oY + 92, 3, wallColor 
      Line oX + 249, oY + 214, oX + 398, oY + 214, 3, wallColor 
  endif


  // Draw white circle (start position)
  circle oX + 170, oY + 16, oX + 170 + 60, oY + 16 + 60, startColor, startColor

   // Draw the flame
  // Use position given by the user or choose random position for the flame
  candleBasePos = toNumber(getEdit("EFlamePos"))
  if(candleBasePos < 1 or candleBasePos > 8)
    candleBasePos = random(7) + 1
    setEdit "EFlamePos", candleBasePos
  endif  
  
   if (candleBasePos = 1)
    candleBaseOX = oX + 3
    candleBaseOY = oY + 3
    candleX = 1 
    candleY = 1
   
  elseif (candleBasePos = 2)
    candleBaseOX = oX + 154 - 2
    candleBaseOY = oY + 3
    candleX = -1 
    candleY = 1
  elseif (candleBasePos = 3)
    candleBaseOX = oX + 246 + 3
    candleBaseOY = oY + 92 + 3
    candleX = 1 
    candleY = 1

    // Reposition the candle because of the orientation of the island room.
    if(arenaConfig == 2 or arenaConfig == 3) 
      candleBaseOY = candleBaseOY + 55      
    endif  
    
  elseif (candleBasePos = 4)
    candleBaseOX = oX + 398 - 1
    candleBaseOY = oY + 92 + 3
    candleX = -1 
    candleY = 1

    // Reposition the candle because of the orientation of the island room.
    if(arenaConfig == 2 or arenaConfig == 3)
      candleBaseOY = candleBaseOY + 55
    endif  
  elseif (candleBasePos = 5)
    candleBaseOX = oX + 496 - 1
    candleBaseOY = oY + 496 - 1
    candleX = -1 
    candleY = -1
  elseif (candleBasePos = 6)
    candleBaseOX = oX + 3 
    candleBaseOY = oY + 496 - 1
    candleX = 1 
    candleY = -1
  elseif (candleBasePos = 7)
    candleBaseOX = oX + 3
    candleBaseOY = oY + 274 + 3
    candleX = 1 
    candleY = 1
  elseif (candleBasePos = 8)
    candleBaseOX = oX + 154 - 1
    candleBaseOY = oY + 274 + 3
    candleX = -1 


    candleY = 1
  endif
  
  candleR = 5            // Radius of the candle base (corresponds to the candle itself).
  candleX = candleX * 30 // X position of the candle inside the semicircle.
  candleY = candleY * 30 // Y position of the candle inside the semicircle.
  
  // Draw the candle. 
  circle candleBaseOX + candleX - candleR, candleBaseOY + candleY - candleR, candleBaseOX + candleX + candleR, candleBaseOY + candleY + candleR, candleColor, candleColor 
  
  if(getCheckBox("CBFurniture") == true)
    // Draw the Furniture
    // . . .
  endif  
  
  
return
// ======================================================================
// Finite Satte Machine
// ======================================================================

finiteStateMachine:
   while true
       
     if(state == WAIT)
       goSub waitState
     elseif(state == NAVIGATE)
       goSub navigateState_v2
     elseif(state == APPROACH)
       goSub approachState
     elseif(state == PUT_OUT)
       goSub putOutStateV2 
     elseif(state == VOLTAR_INICIO)
       goSub VOLTAR_INICIO_STATE   
     endif  
     
     getButton btn
     if(btn == "STOP") then state = WAIT
     
     goSub screen_1
     
   wend
return

waitState:
  goSub setLedOFF
  
  enableButton "START", true
  
  repeat
    getButton btn   
    if(btn == "RESET") 
      goSub drawArena
      goSub initializeRobot
    endif
  until btn == "START" 
  
  enableButton "START", false
  enableCheckBox "CBAStart", false
  
  
  goSub maneuverToExitWhiteCircle
  tempoInicial = Timer()// começa a contar o tempo inicial assim que for premido o start
  state = NAVIGATE
return

/*
navigateState:
  if(rRange(0) < DIST_FRONT_LIMIT) then rTurn -90
  
  goSub checkBumpers
  
  dist = rRange(90)
  if(dist >= DIST1 and dist <= DIST2)
    rForward 1
  elseif(dist < DIST1)
    rTurn -1
    rForward 1
  elseif(dist > DIST2)
    rTurn 1
    rForward 1
  endif      
    
  goSub getFlameDirection
  if(flameDirection != 0)
    state = APPROACH  
    return
  endif  
  
   // . . .   
return
*/

navigateState_v2:
  if(rRange(0) < DIST_FRONT_LIMIT) then rTurn -90    //Parede frontal detectada.
  
  goSub checkBumpers
  
  dist = rRange(90)
  if(dist >= DIST1 and dist <= DIST2) //Distância ideal para a parede.
    rForward 1
  elseif(dist < DIST1)   //Muito perto da parede.
    rTurn -1
    rForward 1
  elseif(dist > DIST2)     //Muito longe da parede.
    rTurn 1
    rForward 1
  endif      

    
  gosub getFloorTag
  if(tag == LINE_TAG)     //// É na entrada no quarto.
    rooms = rooms + 1      
    
    //rForward 50
    call moveForward(50)
                     
              if(rooms == 4) // no caso se o quarto for numero 4 o robô simplesmente continua andando sem fazer o scaner  
                call moveForward(50) 
                return
             endif
                   
    goSub scanRoom
           
    if(flameInRoom == true) //  Verifique se a chama está no quarto. Se for verdadeiro, entre no quarto, se for falso, vá para a próximo quarto.
      goSub getFlameDirection
      if(flameDirection != 0)
        state = APPROACH  
        return
      endif
               
    else
       goSub maneuverToGoToNextRoom //  navegar para outro quarto caso não tiver chama
      
    endif    
  elseif(tag == CIRCLE_TAG)    //Está na posição inicial.
     // goSub meneuverToGoToIslandRoom
     rTurn 180 //caso robo chegar ao circulo branco e chama tiver acesa ele gira 180 graus e vai ao quarto ilha
  endif    
      
return


approachState:   //Classe de aproximar
  goSub setLedON   
  goSub getFlameDirection
  
       if(flameDirection == 0)  // se o robo estiver no centro e detetar a chama
         goSub setLedOFF
         state = NAVIGATE
         return
       elseif(flameDirection == 1) //Chama ta a direita    
         rTurn 2
       elseif(flameDirection == 2)  // chama mais a direita ainda   
         rTurn 1
       elseif(flameDirection == 3) //chama a frente do robo
         rForward 1
         
         if(rRange(0) < 15) // o que faz depois de detetar a chama a uma distancia mais perto
           state = PUT_OUT
           return
         endif  
       elseif(flameDirection == 4)    // chama a esquerda                    
         rTurn -1
       elseif(flameDirection == 5)   //chama  mais a esquerda ainda         
         rTurn -2
       endif
     
return


putOutStateV1:  //chama fica com a cor cizenta
   circle candleBaseOX + candleX - candleR, candleBaseOY + candleY - candleR, candleBaseOX + candleX + candleR, candleBaseOY + candleY + candleR, GRAY, GRAY       
   state = WAIT
return


putOutStateV2:   //apagar a chama
   x = random(99) + 1 // gera um valor aleatorio entre 0-100
   
   if(x < 75)   // a chama foi apagada. Se o robô atingir este estado, ele tem 75% de chance de apagar a vela.
     circle candleBaseOX + candleX - candleR, candleBaseOY + candleY - candleR, candleBaseOX + candleX + candleR, candleBaseOY + candleY + candleR, GRAY, GRAY       
   
    endif
   
     
   rForward -20   // robo recuar
   goSub getFlameDirection
   if(flameDirection != 0) // a chama ainda ta presente e o sensor ainda ta detetalo;  se a chama ainda está presente, então, vá para o estado ABORDAGEM.
     state = APPROACH
     return
   endif 
     tempoFinal = Timer()
    tempoVela = (tempoFinal - tempoInicial)/ 1000 //calcula o valor do tempo em que durou até o robô apagar a vela
  goSub setLedOFF
 
    rTurn 180
  gosub VoltarCasa
   
   

return


// ======================================================================
// Actuator functions
// ======================================================================
maneuverToExitWhiteCircle:
 repeat
   rForward 1
   goSub getFloorTag
 until tag == NO_TAG  
return

Sub moveForward(dist):
  for d = 1 to dist
    rForward 1
    
    delay 10
  next  
return




// ======================================================================
// Sensor functions
// ======================================================================

checkBumpers:

  bmp = rBumper()
  
  if(bmp & 4)      //0   bmp = 1001 & 4 = 0100 = 0000  bmp = x1xx  &  4 = 0100 = x1xx !=0 , bumper 4 para frente
    rForward -10
    rTurn -45
  elseif(bmp & 8)   //bumper 8 para esquerda
    rForward -10
    rTurn 45
  elseif(bmp & 2)   // bumper 2   para direita
    rForward -10
    rTurn -45  
  endif  
return


getFlameDirection_old:     //getFlamerDiretionV2
  flameDirection = 0
  
  for i = 1 to 5
    rSensor i, 150, flameColor, flameDistance, flameFound
    if(flameColor == RED)
      flameDirection = i
      break
    endif  
  next
return

getFlameDirection:     //getFlamerDiretionV1
  flameDirection = 0
  
  for i = -12 to 12
    if(rLook(i) == RED)
      if(i < - 8)
        flameDirection = 5
      elseif(i < -2)
        flameDirection = 4
      elseif(i  < 2)
        flameDirection = 3
      elseif(i < 8)
        flameDirection = 2
      else
        flameDirection = 1
      endif           
    endif
  next

return




getFloorTag:
  if(rSense(WHITE) & 2)
    rForward 5
    if(rSense(WHITE) & 2)
      tag = CIRCLE_TAG
    else
      tag = LINE_TAG
    endif
  else
    tag = NO_TAG
  endif        
return

scanRoom:
  for ang = 1 to 45
    gosub getFlameDirection
    if(flameDirection != 0)
      flameInRoom = true
      return
    endif
    rTurn 2
    delay 10
  next
  
  for ang = 1 to 45
    rTurn -2
    delay 10
  next
  
  for ang = 1 to 45
    gosub getFlameDirection
    if(flameDirection != 0)
      flameInRoom == true
      return
    endif
    rTurn -2
    delay 10
  next
  
  for ang = 1 to 45
    rTurn 2
    delay 10
  next
return


// ======================================================================
// Interface functions
// ======================================================================
setLedON:   // a led maior
  circleWH oX + 200, oY - 43, 35, 35, BLACK, RED
return

setLedOFF:
  circleWH oX + 200, oY - 43, 35, 35, BLACK, GRAY
return

cbHandler:
  cb = lastCheckbox()
  if(cb == "CBPen") 
    if(getCheckBox("CBPen") == true)
      rPen Down, penColor
    else
      rPen Up
    endif   
  elseif(cb == "CBAStart")
  
  elseif(cb == "CBFurniture")
  
  elseif(cb == "CBRTrip")
  
  endif
  onCheckBox cbHandler
return


sub header(x, y, str, size):
  xyText x, y, str, "Verdana", size, FS_BOLD, RED, WHITE  
return


screen_1:
  if(state == 0)
    stateName = "WAIT       "
  elseif(state == 1)
    stateName = "NAVIGATE   "
  elseif(state == 2)
    stateName = "APPROACH   " 
  elseif(state == 3)
    stateName = "PUT OUT    " 
  elseif(state == 4)
    stateName = "RETURN HOME"   
  endif
  xyString 10, 340, "State: " + stateName
  
  xyString 10, 360, "Rooms: " + rooms
  
  xyString 10, 380, "Flame: " + flameDirection 
  
  xyString 10, 400, "Time Flame: " + tempoVela
     
   xyString 10, 420, "Time Circle: " + tempoTotal 
   
return




Sub MoveForward(dist):
  for d = 1 to dist
    rForward 1
    
    delay 10
  next
return

 maneuverToGoToNextRoom:
  if(rooms == 1)
    rTurn 180
    call MoveForward(50)
  elseif(rooms == 2)
    rTurn 180
    call MoveForward(50)
  elseif(rooms == 3)  
  
  elseif(rooms == 4)   
      
  endif
return

 VoltarCasa:
             gosub SairQuarto
             state = VOLTAR_INICIO
  return

  SairQuarto:
           while flameInRoom
  
           gosub checkBumpers
  
           dist = rRange(90)
           if(dist >= DIST1 and dist <= DIST2) // Distância ideal à parede.
              rForward 1
           elseif(dist < DIST1)  // Muito perto da parede.
              rTurn -1
              rForward 1
           elseif(dist > DIST2)  // Muito longe da parede.

              rTurn 1
              rForward 1
           endif  

  gosub getFloorTag
  if(tag==LINE_TAG)
     flameInRoom = false
  endif
  wend
   goSub  VOLTAR_INICIO_STATE
 return
 VOLTAR_INICIO_STATE:
             if(rRange(0) < 30) then rTurn -90 // Parede frontal detectada..
  
                   gosub checkBumpers
  
  dist = rRange(90)
  if(dist >= DIST1 and dist <= DIST2)  // Distância ideal à parede.
    rForward 1
  elseif(dist < DIST1)  // Muito perto da parede
    rTurn -1
    rForward 1
  elseif(dist > DIST2)  //Muito longe da parede.
    rTurn 1
    rForward 1
  endif  

  gosub getFloorTag

  if (tag == CIRCLE_TAG)
     state = WAIT
     rForward 50    //centralizar o robo no circulo branco
     tempoFinal = Timer()
     tempoTotal = (tempoFinal - tempoInicial) / 1000
  return
  elseif (tag == LINE_TAG)
         delay 100
         rTurn -90
         rForward 40
  endif
  
 return 



