import React from 'react'
import { useState, useEffect } from 'react'
import { Box } from '@mantine/core'
import './StageButton.css'

function StageButton(props : any) {

    // TODO change class name of button to include a color when enabling it ex. " className='button blue' "

     const [classString, setClassString ] = useState('button')

     // color strings = 'red', 'blue, 'amber'
     useEffect(() => {
      if (props.enabled) {
        setClassString(`button ${props.color}`)
      } else {
        setClassString(`button`)
      }
     }), [props]

    return (
    <div className={classString}>
        {props.label}
    </div>
  )
}

export default StageButton