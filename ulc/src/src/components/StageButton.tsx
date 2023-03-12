import React from 'react'
import { useState, useEffect } from 'react'
import { Box } from '@mantine/core'
import './StageButton.css'

function StageButton(props : any) {

  const [classString, setClassString ] = useState('button')

  // color strings = 'red', 'blue, 'amber'
  useEffect(() => {
  if (props.enabled) {
    setClassString(`button ${props.color}`)
  } else {
    setClassString(`button`)
  }
  }), [props]

  if (props.showHelp) {
    return (
      <div className={classString}>
          {`NUM ${props.numKey}`}
      </div>
    )
  } else {
    return (
      <div className={classString}>
          {props.label}
      </div>
    )
  }

}

export default StageButton