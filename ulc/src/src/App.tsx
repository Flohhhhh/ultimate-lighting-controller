import { useState, useEffect } from 'react'
import { Box, Button } from '@mantine/core'
import './app.css'
import StageButton from './components/StageButton'
import TaModule from './components/TaModule'

function App() {

  console.log("Running function")

  /////////////////
  // STATE HOOKS //
  /////////////////

  const [scale, setScale] = useState(1.0)

  interface ButtonObject{ extra: number, enabled: boolean; color: string; label: string}
  const [buttonObjects, setButtonObjects] = useState<ButtonObject[]>([]);
  useEffect(() => console.log(`buttonObjects set as ${buttonObjects}`), [buttonObjects])


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

    //console.log(`Updated buttons ${JSON.stringify(updatedButtons)}`)
    setButtonObjects(updatedButtons)
  }



  ////////////////////
  // EVENT LISTENER //
  ////////////////////

  const handleMessage = (e : any) => {
    var data = e.data
      
    if (data.type === 'clearButtons') {
      console.log("Clearing buttons")
      setButtonObjects([])
    }

    //takes: extra, color, label
    if (data.type === 'addButton') {
      console.log(`Adding button: ${JSON.stringify(data)}`)
      addButton(data.extra, data.state, data.color, data.label)
    }

    if (data.type === 'populateButtons') {
      console.log(`Populating buttons ${JSON.stringify(data.buttons)}`)
      setButtonObjects(data.buttons)
    }

    // takes: extra, state(0 on, 1 off)
    if (data.type === 'setButton') {
      console.log(`Setting button ${data.extra} ${data.newState}`)
      setButton(data.extra, data.newState)
    }
  }

  useEffect(() => {
    console.log("I am the useEffect")
    
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

    <Box sx={{
      position: 'absolute',
      bottom: 40,
      right: 40,
      transform: `scale(${scale})`
    }}>
      <Button onClick={() => {addButton(1, false, 'green', 'FAKE STAGE')}}>Add button</Button>
      <Button onClick={() => {setButton(1, true)}}>Turn on</Button>
      <Button onClick={() => {setButtonObjects([])}}>Clear</Button>
      <div className='background'>

        <div className="ta">
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

  )
}

export default App
