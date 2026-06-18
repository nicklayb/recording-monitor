import fs from 'fs';
import Yaml from 'js-yaml'

const CONFIF_FILE = process.env.CONFIG_FILE || 'config.yaml';

const Config = Yaml.load(fs.readFileSync(CONFIF_FILE, 'utf-8'));

export default Config
