import React from 'react'
import ReactDOM from 'react-dom/client'
import App from './App'
import { MantineProvider } from '@mantine/core'

ReactDOM.createRoot(document.getElementById('root') as HTMLElement).render(
  <MantineProvider withGlobalStyles withNormalizeCSS theme={{ colorScheme: 'dark', fontFamily: 'Arial, Helvetica, sans-serif', 
    globalStyles: (theme) => ({
      html: {
        colorScheme: 'normal'
      }
    })
  }} >
      <App />
  </MantineProvider>
)
