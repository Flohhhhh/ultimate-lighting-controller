import React from 'react'
import ReactDOM from 'react-dom/client'
import App from './App'
import { MantineProvider } from '@mantine/core'

ReactDOM.createRoot(document.getElementById('root') as HTMLElement).render(
  <MantineProvider theme={{ colorScheme: 'dark',         colors: {
    // override dark colors to change them for all components
    dark: [
      '#d5d7e0',
      '#acaebf',
      '#8c8fa3',
      '#666980',
      '#4d4f66',
      '#34354a',
      '#2b2c3d',
      'rgba(29, 30, 48, 0)',
      '#0c0d21',
      '#01010a',
    ],
  },fontFamily: 'Arial, Helvetica, sans-serif' }} withGlobalStyles withNormalizeCSS>
      <App />
  </MantineProvider>
)
