import React from 'react'
import { useState, useEffect } from 'react'
import { Box, Button, Center, Container, Divider, Flex, NavLink, SegmentedControl, Slider, Space } from '@mantine/core'

function Menu({useLeftAnchor, setUseLeftAnchor, scale, setScale, setPosition, opacity} : any) {

    return (
        <Container sx={{opacity: `${opacity}%`, transition: 'opacity 0.25s ease'}}>
            <Center sx={{height: '100vh'}}>
                <Flex direction='column' sx={(theme) => ({
                    height: '30vh',
                    background: theme.colors.dark[7],
                    borderRadius: theme.radius.sm,
                    padding: '10px',
                })}>
                    <Container sx={{
                        minWidth: '350px',
                        paddingTop: '15px',
                        display: 'flex', 
                        flexDirection:'row', 
                        justifyContent: 'space-between', 
                        alignItems: 'center'}} 
                        w={"25vw"}>
                        <Center sx={{width: '100%'}}>
                            Click & drag HUD to reposition!
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
                        Anchor Position
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
                            HUD Scale
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
                        display: 'flex', 
                        flexDirection:'row', 
                        justifyContent: 'space-between', 
                        alignItems: 'center'}} 
                        w={"25vw"}>
                        <Button uppercase onClick={() => {
                                setScale(1.0)
                                setUseLeftAnchor('false')
                                setPosition(0, 0)
                            }}
                            sx={{
                                width: '100%'
                            }}
                        >Reset</Button>
                    </Container>
                </Flex>
            </Center>
        </Container>

    )
}

export default Menu