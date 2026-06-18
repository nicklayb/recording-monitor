class SceneMode {
  constructor(modeConfig) {
    this.sceneOn = modeConfig.on;
    this.sceneOff = modeConfig.off;
  }

  sendOn(homeAssistant) {
    this.call(homeAssistant, this.sceneOn);
  }

  sendOff(homeAssistant) {
    this.call(homeAssistant, this.sceneOff);
  }

  call(homeAssistant, scene) {
    try {
      fetch(`${homeAssistant.apiUrl}/api/services/scene/turn_on`, {
        method: 'POST',
        headers: {
          'Authorization': `Bearer ${homeAssistant.token}`,
          'Content-Type': 'application/json'
        },
        body: JSON.stringify({ entity_id: scene })
      });
    } catch (error) {
      console.error('Error calling Home Assistant API:', error);
    }
  }
}

const initMode = (mode, config) =>{
  switch (mode) {
    case 'scene': return new SceneMode(config.scene);
    default: return null
  }
}

class HomeAssistant {
  constructor(config) {
    this.apiUrl = config.host;
    this.token = config.token;
    this.mode = initMode(config.mode, config);
  }

  sendOn() {
    if (this.mode) this.mode.sendOn(this)
  }

  sendOff() {
    if (this.mode) this.mode.sendOff(this)
  }
}

export default HomeAssistant
