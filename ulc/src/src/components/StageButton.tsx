import React from 'react'
import { Box } from '@mantine/core'
import './StageButton.css'

function StageButton(props : any) {

    // TODO change class name of button to include a color when enabling it ex. " className='button blue' "


    return (
    <div className='button'>
        {props.label}
    </div>
  )
}

export default StageButton