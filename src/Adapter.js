import HomeAssistant from './adapters/HomeAssistant.js'
import Config from './Config.js'

const ADAPTERS = {
  homeassistant: HomeAssistant
}

const ADAPTER = ADAPTERS[Config.adapter]

const Adapter = new ADAPTER(Config[Config.adapter])

export default Adapter
