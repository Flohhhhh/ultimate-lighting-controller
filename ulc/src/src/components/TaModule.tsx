import React from 'react'
import { useState, useEffect } from 'react'
import './TaModule.css'

function TaModule(props : any) {

    const [classString, setClassString ] = useState('ta-module')

     // color strings = 'red', 'blue, 'amber'
     useEffect(() => {
      console.log("Props have changed!")
      if (props.on) {
        setClassString(`ta-module on`)
      } else {
        setClassString(`ta-module`)
      }
     }), [props]


  return (
    <div className={classString}></div>
  )
}

export default TaModule