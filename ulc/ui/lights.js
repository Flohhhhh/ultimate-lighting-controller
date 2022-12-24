var hud = document.getElementById("container");
var indicator = document.getElementById("indicator");
var indicatorB = document.getElementById("indicatorB");
var indicatorP= document.getElementById("indicatorP");

var buttons = document.getElementsByClassName('button')
var buttonsArray = Array.from(buttons)
//var helpers = document.getElementsByClassName('helper')
//var helpersArray = Array.from(helpers)
var activeButtons = 0

// events for clearing buttons and showing/hiding hud
window.addEventListener('message', (event) => {
  var data = event.data
  if (data.type === 'clearButtons') {
    console.log('Clearing Buttons')
    buttonsArray.forEach((button, index) => {
      //console.log(`${index} : ${button}`)
      button.style.display = 'none'
      button.setAttribute('data-on', "false")
    })

    // helpersArray.forEach((helper, index) => {
    //   //console.log(`${index} : ${helper}`)
    //   helper.style.display = 'none'
    // })

    activeButtons = 0

  } else if (data.type === 'showParkIndicator') {
    indicatorP.style.display = "block"
  } else if (data.type === 'showBrakeIndicator') {
    indicatorB.style.display = "block"
  } else if (data.type === 'showLightsHUD') {
    hud.style.opacity = 100 + '%'
  } else if (data.type === 'hideLightsHUD') {
    hud.style.opacity = 0 + '%'
  }

  
});

// show and configure button
window.addEventListener('message', (event) => {
  var data = event.data
  if (data.type === 'addButton') {
    console.log(`Adding button ${activeButtons} with label ${data.label} state: ${data.state}`)
    
    buttonsArray[activeButtons].innerHTML = data.label;
    buttonsArray[activeButtons].setAttribute('data-extra', data.extra.toString())
    //console.log(buttonsArray[activeButtons].getAttribute('data-extra'))
    buttonsArray[activeButtons].style.display = 'inline-block';
    //helpersArray[activeButtons].style.display = 'inline-block';

    //console.log(data.state)
    if (data.state === 0) {
      //console.log("Button should be on")
      buttonsArray[activeButtons].setAttribute("data-on", "true")
    } else if (data.state === 1) {
      //console.log("Button should be off")
      buttonsArray[activeButtons].setAttribute("data-on", "false")
    }

    activeButtons++
  }
});

function findButtonByExtra(extra) {
  for (let i = 0; i < buttonsArray.length; i++) {
    let thisButton = buttonsArray[i]
    let thisButtonExtra = thisButton.getAttribute('data-extra')
    if (thisButtonExtra === extra.toString()) {
      return thisButton
    }
  }
}

window.addEventListener('message', (event) => {
  var data = event.data
if (data.type === 'setButton') {
    //console.log('Looking for Button with extra ', data.extra)
    let thisButton = findButtonByExtra(data.extra);
    //console.log('Found ', thisButton)

    if (data.state === 0) {
      thisButton.setAttribute('data-on', "true")
    } else if (data.state === 1) {
      thisButton.setAttribute('data-on', "false")
    }
  }
});

// lights on vs lights off
window.addEventListener('message', (event) => {
  var data = event.data
  if (data.type === 'toggleIndicator') {
    if (data.state === true) {
      // console.log('hi')
      indicator.setAttribute('data-on', "true")
      //indicator.style.backgroundColor = 'var(--col-1)';
    } else {
      indicator.setAttribute('data-on', "false")
      //indicator.style.backgroundColor = 'var(--bg-col-1)';
    }
  } else if (data.type === 'toggleBrakeIndicator') {
    if (data.state === true) {
      // console.log('hi')
      indicatorB.setAttribute('data-on', "true")
      //indicator.style.backgroundColor = 'var(--col-1)';
    } else {
      indicatorB.setAttribute('data-on', "false")
      //indicator.style.backgroundColor = 'var(--bg-col-1)';
    }
  } else if (data.type === 'toggleParkIndicator') {
    if (data.state === true) {
      // console.log('hi')
      indicatorP.setAttribute('data-on', "true")
      //indicator.style.backgroundColor = 'var(--col-1)';
    } else {
      indicatorP.setAttribute('data-on', "false")
      //indicator.style.backgroundColor = 'var(--bg-col-1)';
    }
  }
});

// // more cleanup?
// window.addEventListener('message', (event) => {
//   var data = event.data
//   if (data.type === 'hideHelpers') {
//     helper0.style.display = 'none';
//     helper1.style.display = 'none';
//     helper2.style.display = 'none';
//     helper3.style.display = 'none';
//     helper4.style.display = 'none';
//     helper5.style.display = 'none';
//     helper6.style.display = 'none';
//     helper7.style.display = 'none';
//     helper8.style.display = 'none';
//   }
// });

window.addEventListener('message', (event) => {
  var data = event.data
  if (data.type === 'showHelp') {
    buttonsArray[data.button - 1].innerHTML = `NUM ${data.key}`;
  } else if (data.type === 'hideHelp') {
    buttonsArray[data.button - 1].innerHTML = data.label;
  }
});