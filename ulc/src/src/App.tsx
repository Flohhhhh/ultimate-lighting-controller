import { useState } from 'react'
import { Box } from '@mantine/core'
import './app.css'
import StageButton from './components/StageButton'

function App() {

  const [scale, setScale] = useState(1.0)

  window.addEventListener('message', (event) => {
    var data = event.data
  });

  return (
    <Box sx={{
      position: 'absolute',
      bottom: 20,
      right: 20,
      transform: `scale(${scale})`
    }}>
      <div className='background'>
        
        <StageButton enabled={false} color='' label='STAGE 1'></StageButton>
        <StageButton enabled={false} color='' label='STAGE 2'></StageButton>
        <StageButton enabled={false} color='' label='STAGE 3'></StageButton>
        <StageButton enabled={false} color='' label='TA'></StageButton>

      </div>
    </Box>

  )
}

export default App
