import fs from 'fs';
import Yaml from 'js-yaml'

const CONFIG_FILE = process.env.RECORDING_MONITOR_CONFIG_FILE || 'config.yaml';

const Config = Yaml.load(fs.readFileSync(CONFIG_FILE, 'utf-8'));

export default Config
