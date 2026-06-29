# Recodring monitor

An extremely simple, quite over complicated for no reason, to hook on a DAW's (Digital Audio Workstation) transport property (Play, Record etc...).

I created this project to trigger Home Automation scene when I'm starting to record on a DAW (so far only tested with Studio One, but it uses Mackie Control MIDI devices so, _in theory_, every daw that supports Mackie Control MIDI should be supported).

### Important note

- This project was only tested with macOS and its default virtual MIDI devices. I'm assuming this should work alright on Linux and Windows but I haven't tried.
- It only implements Home Assistant scene trigger so far it would be fairly simple to trigger Automation or entity directly.
- It hooks only to Recording MIDI note (95, in Studio One, which I think is Mackie Control's standard, but not sure). This can be overriden with configuration.
- I'm using nix-darwin to generate a launchd agent, this would need to be done manually, if you're not using nix-darwin. If you do, there's a nix module in place that streamlines the process.

## Getting started

1. Create a virtual MIDI device, take note of the name.
2. Create a config file (I'm placing it in `~/.config/recording-monitor.yaml`, you can place it where you want, make sure to update the `RECORDING_MONITOR_CONFIG_FILE` env variable). You can copy paste the `config.example.yaml` to have a starter.
3. Start the project (`npm run dev`)
4. Connect the Virtual MIDI device as an output on your DAW. **Don't connect it as an input**, I can't tell if it's Studio One specific, but my daw started to act crazy, I think the device was looping message back in.
5. It should work.


### Nix example

To have a Nix example, you can look at [this commit](https://github.com/nicklayb/nixos-config/commit/7827b30d5ce1b4fb60f387784c0809b218fb4d38) to see how it's implemented on my studio's Mac Mini.

## Configuration

- `adapter`: Valid values are `homeassistant`
- `midi.device_name`: The name of your virtual MIDI device.
- `midi.recording_note`: The note that means "Recording" (defaults to `95`).
- `homeassistant.host`: Host of the Home Assistant server.
- `homeassistant.token`: Token of the Home Assistant server.

### Home Assistant

**Note**: As of now, the only available adapter is `homeassistant` and its only supported mode is `scene`. 

- `homeassistant.mode`: Valid values are `scene`.

#### Scene mode

- `homeassistant.scene.on`: Scene name to trigger when the daw is Recording
- `homeassistant.scene.off`: Scene name to trigger when the daw is no longer Recording


## How adapter works

So far there's only a Home Assistant adapter but one could implement one fairly easily by defining a class that exposes methods `sendOn` and `sendOff` methods. The way adapter are loaders, the config expects a key named based off the adapter's name (If you set it to `homeassistant`, a `homeassistant` key should exist if you want some configs).
