// Legacy API server URL - kept for backward compatibility
// New code should use apiService from '../services/apiService' instead
import config from '../config/api';

const API_SERVER_URL = config.apiUrl;
export default API_SERVER_URL;