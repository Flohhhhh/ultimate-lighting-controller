import { useState, useEffect } from 'react'
import Draggable from "react-draggable";
import { Box, Button, SegmentedControl } from '@mantine/core'
import './app.css'
import StageButton from './components/StageButton'
import TaModule from './components/TaModule'
import Menu from './components/Menu'

function App() {

  //console.log("Running function")

  /////////////////
  // STATE HOOKS //
  /////////////////

  const [ opacity, setOpacity ] = useState(100)
  const [ menuOpacity, setMenuOpacity ] = useState(100)
  const [ scale, setScale ] = useState(1.0)
  const [ taClassString, setTaClassString ] = useState('ta ta-off')
  const [ useLeftAnchor, setUseLeftAnchor ] = useState('false')

  const [ x, setX ] = useState(0)
  const [ y, setY ] = useState(0)

  interface ButtonObject{ extra: number, enabled: boolean; color: string; label: string}
  const [buttonObjects, setButtonObjects] = useState<ButtonObject[]>([]);


  ///////////////
  // FUNCTIONS //
  ///////////////

  function addButton(extra: number, enabled : boolean, color : string, label: string) {
    setButtonObjects([...buttonObjects, {extra: extra, enabled: enabled, color: color, label: label}])
  }


  // TODO: THIS WIPES THE TABLE FOR SOME REASON
  function setButton(extra: number, newState : boolean) {
    //console.log(`Setting buttons! Original buttons: ${buttonObjects}`)
    let updatedButtons = buttonObjects.map((item) => item.extra === extra ? {
      ...item,
      enabled: newState
    } : item);

    ////console.log(`Updated buttons ${JSON.stringify(updatedButtons)}`)
    setButtonObjects(updatedButtons)
  }

  // for ta stuff i guess
  function strContains(string1 : string, string2 : string) {
    if (string1.indexOf(string2) >= 0) {
      return true
    } else {
      return false
    }
  }

  function calculateTaClassString(buttons : any) {
    let result = 'ta ta-off'
    for (let i = 0; i < buttons.length; i++) {
      const element = buttons[i];
      if (element.label.toUpperCase() === 'TA') {
        result = 'ta ta-on'
      }
    }
    return result
  }

  // DRAGGING UI

  const handleDragEvent = async (e: any, data : any) => {
    console.log(data.x, data.y);
    let newX = data.x
    let newY = data.y
    
    setPosition(newX, newY)
    //send this position back to lua to save it for later
  }

  function setPosition(newX : number, newY : number) {
    setX(newX)
    setY(newY)
    let response = fetch(`https://ulc/savePosition`, {
      method: 'POST',
      headers: {
          'Content-Type': 'application/json'
      },
      body: JSON.stringify({newX, newY})
    });
  }


  ////////////////////
  // EVENT LISTENER //
  ////////////////////

  const handleMessage = (e : any) => {
    var data = e.data

    if (data.type === 'showHUD') { setOpacity(100) } 
    else if (data.type === 'hideHUD') { setOpacity(0) }
    else if (data.type === 'setPosition') {setX(data.x); setY(data.y)}
    else if (data.type === 'setScale') {setScale(data.scale)}
    else if (data.type === 'setAnchor') {setUseLeftAnchor(data.bool)}
    else if (data.type === 'showMenu') {setMenuOpacity(100)}
    else if (data.type === 'hideMenu') {setMenuOpacity(0)}

    if (data.type === 'clearButtons') {
      //console.log("Clearing buttons")
      setButtonObjects([])
    }

    if (data.type === 'populateButtons') {
      //console.log(`Populating buttons ${JSON.stringify(data.buttons)}`)
      setButtonObjects(data.buttons)
      setTaClassString(calculateTaClassString(data.buttons))
    }

    // takes: extra, state(0 on, 1 off)
    if (data.type === 'setButton') {
      //console.log(`Setting button ${data.extra} ${data.newState}`)
      setButton(data.extra, data.newState)
    }
  }

  useEffect(() => {
    //console.log("I am the useEffect")
    
    window.removeEventListener('message', handleMessage)
    window.addEventListener('message',handleMessage);
      
    return () => {
      window.removeEventListener('message', handleMessage)
    }
  
  }, [handleMessage]);



  /////////////////
  // DEFINITIONS //
  /////////////////

  let buttons = buttonObjects.map((buttonObject, index) => (
    <>
      <StageButton key={index} extra={buttonObject.extra} enabled={buttonObject.enabled} color={buttonObject.color} label={buttonObject.label}/>
    </>
    
  ))

  return (
    <>
      {/* MENU */}
      <Menu opacity={menuOpacity} setMenuOpacity={setMenuOpacity} scale={scale} setScale={setScale} useLeftAnchor={useLeftAnchor} setUseLeftAnchor={setUseLeftAnchor} setPosition={setPosition} />


      {/* HUD */}
      <Draggable defaultPosition={{x, y}} scale={scale} position={{x, y}} onStop={(e, data) => {handleDragEvent(e, data)}}>
        <Box sx={{
          position: 'absolute',
          bottom: 40,
          ...(useLeftAnchor === 'true' ? { left: 40 } : { right: 40 }),
          scale: `${scale}`,
          opacity: `${opacity}%`,
          transition: 'opacity 0.25s ease'
        }}>
          {/* <Button onClick={() => {addButton(1, false, 'green', 'STAGE 2')}}>Add button</Button>
          <Button onClick={() => {setButton(1, true)}}>Turn on</Button>
          <Button onClick={() => {setButtonObjects([])}}>Clear</Button>
          <Button onClick={() => {if (menuOpacity === 100) {setMenuOpacity(0)} else {setMenuOpacity(100)}}}>Menu</Button> */}
          <div className='background'>

            <div className={taClassString}>
              <TaModule on={false}></TaModule>
              <TaModule on={false}></TaModule>
              <TaModule on={true}></TaModule>
              <TaModule on={true}></TaModule>
              <TaModule on={true}></TaModule>
              <TaModule on={true}></TaModule>
              <TaModule on={false}></TaModule>
            </div>

            <div className="buttons">
              {buttons}
            </div>

          </div>
        </Box>
      </Draggable>
    </>
    
    

  )
}

export default App
