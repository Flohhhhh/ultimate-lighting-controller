import React from 'react'
import { useState, useEffect } from 'react'
import { Box, Button, Center, Container, Divider, Flex, NavLink, SegmentedControl, Slider, Space, Text } from '@mantine/core'

function Menu({useLeftAnchor, setUseLeftAnchor, scale, setScale, setPosition, opacity, setMenuOpacity} : any) {

    return (
        <Container sx={{opacity: `${opacity}%`, transition: 'opacity 0.25s ease'}}>
            <Center sx={{height: '100vh'}}>
                <Flex direction='column' sx={(theme) => ({
                    height: '30vh',
                    background: 'rgba(33,33,33,0.85)',
                    borderRadius: theme.radius.md,
                    padding: '10px',
                })}>
                    <Container sx={{
                        minWidth: '350px',
                        paddingTop: '15px',
                        WebkitBackdropFilter: 'blur(10px)',
                        display: 'flex', 
                        flexDirection:'row', 
                        justifyContent: 'space-between', 
                        alignItems: 'center'}} 
                        w={"25vw"}>
                        <Center sx={{width: '100%'}}>
                            <Text fz='xl' fw='bold'>Click & drag HUD to reposition!</Text>
                            
                        </Center>
                    </Container>
                    <Divider my={'xl'}/>
                    <Container sx={{
                        minWidth: '350px',
                        display: 'flex', 
                        flexDirection:'row', 
                        justifyContent: 'space-between', 
                        alignItems: 'center'}} 
                        w={"25vw"}>

                        <Text fw='bold'>Anchor Position</Text>

                        <SegmentedControl sx={{float: 'right'}} 
                            value={useLeftAnchor}
                            onChange={(value) => {setUseLeftAnchor(value); setPosition(0, 0)}}
                            data={[
                                {label: 'Right', value: 'false'},
                                {label: 'Left', value: 'true'}
                            ]
                        }/>
                    </Container>
                    <Space h={'md'}/>
                    <Container sx={{
                        minWidth: '350px',
                        display: 'flex', 
                        flexDirection:'row', 
                        justifyContent: 'space-between', 
                        alignItems: 'center'}} 
                        w={"25vw"}>

                        <Text fw='bold'>HUD Scale</Text>
                            
                        <Slider
                            value={scale}
                            onChange={setScale}

                            min={.5}
                            max={2}
                            step={0.1}

                            sx={{width: '60%'}}
                            size="lg"
                            label={(value) => `${value.toFixed(1)}`}
                        />
                    </Container>
                    <Space h={'xl'}/>

                    <Container sx={{
                        minWidth: '350px',
                        marginTop: 'auto',
                        marginBottom: '10px',
                        display: 'flex', 
                        flexDirection:'row', 
                        justifyContent: 'space-between', 
                        alignItems: 'center'}} 
                        w={"25vw"}>
                        <Button onClick={() => {
                                setScale(1.0)
                                setUseLeftAnchor('false')
                                setPosition(0, 0)
                            }}
                            sx={{
                                width: '100%'
                            }}
                        uppercase color='red'>Reset</Button>

                        <Space w='md'></Space>

                        <Button onClick={() => {
                                setMenuOpacity(0)
                                let response = fetch(`https://ulc/focusGame`, {
                                    method: 'POST',
                                    headers: {
                                        'Content-Type': 'application/json'
                                    },
                                    body: JSON.stringify({})
                                });
                            }}
                            sx={{
                                width: '100%'
                            }}
                        uppercase>Done</Button>

                    </Container>
                </Flex>
            </Center>
        </Container>
    )
}

export default Menu