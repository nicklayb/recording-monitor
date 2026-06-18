import JZZ from 'jzz';
import Observable from './Observable.js'
import Adapter from './Adapter.js'
import Config from './Config.js'

const DEVICE_NAME = Config.midi.device_name
const RECORDING_NOTE = Config.midi.recording_note || 95

const recording = new Observable(false)

recording.subscribe(value => {
    if (value) {
        Adapter.sendOn()
        console.log("Recording")
    } else {
        Adapter.sendOff()      
        console.log("Stoppped")
    }
})

const midi = JZZ();

midi.openMidiIn(DEVICE_NAME)
    .connect(msg => {
        if ((msg.isNoteOn() || msg.isNoteOff()) && msg.getNote() == RECORDING_NOTE) {
            recording.set(msg.isNoteOn())
        }
    });

console.log(`Waiting for messages from ${DEVICE_NAME}...`)
setInterval(() => {

}, 1000);
