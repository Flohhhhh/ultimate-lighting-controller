import React from 'react'
import { useState, useEffect } from 'react'
import { Box } from '@mantine/core'
import './StageButton.css'

function StageButton(props: any) {
  const { label, numKey, enabled, color, showHelp } = props
  const [classString, setClassString ] = useState('button')

  // color strings = 'red', 'blue, 'amber'
  useEffect(() => {
  if (enabled) {
    setClassString(`button ${color}`)
  } else {
    setClassString(`button`)
  }
  }), [props]

  if (showHelp) {
    return (
      <div className={classString}>
          {`NUM ${numKey}`}
      </div>
    )
  } else {
    return (
      <div className={classString}>
          {label}
      </div>
    )
  }

}

export default StageButton