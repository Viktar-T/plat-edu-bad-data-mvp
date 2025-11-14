import config from '../config/api';

/**
 * Centralized API service for all HTTP requests
 */
class ApiService {
  constructor() {
    this.baseUrl = config.apiBaseUrl;
    this.timeout = config.timeout;
  }

  /**
   * Generic fetch wrapper with timeout and error handling
   */
  async fetchWithTimeout(url, options = {}) {
    const controller = new AbortController();
    const timeoutId = setTimeout(() => controller.abort(), this.timeout);

    try {
      const response = await fetch(url, {
        ...options,
        signal: controller.signal,
        headers: {
          'Content-Type': 'application/json',
          ...options.headers,
        },
      });

      clearTimeout(timeoutId);

      if (!response.ok) {
        throw new Error(`HTTP error! status: ${response.status}`);
      }

      return await response.json();
    } catch (error) {
      clearTimeout(timeoutId);
      if (error.name === 'AbortError') {
        throw new Error('Request timeout');
      }
      throw error;
    }
  }

  /**
   * Health check
   */
  async healthCheck() {
    try {
      const response = await this.fetchWithTimeout(`${config.apiUrl}/health`);
      return response;
    } catch (error) {
      console.error('Health check failed:', error);
      throw error;
    }
  }

  /**
   * Get machine summary data
   * @param {string} machine - Machine type (big_turbine, charger, heat_boiler, biogas, storage)
   * @param {string} startTime - Time range (e.g., "2m", "1h", "24h")
   */
  async getMachineSummary(machine, startTime = '2m') {
    const url = `${this.baseUrl}/summary/${machine}?start=${startTime}`;
    return await this.fetchWithTimeout(url);
  }

  /**
   * Execute custom Flux query
   * @param {string} fluxQuery - Flux query string
   */
  async executeQuery(fluxQuery) {
    const url = `${this.baseUrl}/query`;
    return await this.fetchWithTimeout(url, {
      method: 'POST',
      body: JSON.stringify({ fluxQuery }),
    });
  }

  /**
   * Get photovoltaic data
   */
  async getPhotovoltaicData(startTime = '2m') {
    return await this.getMachineSummary('charger', startTime);
  }

  /**
   * Get wind turbine data
   */
  async getWindTurbineData(startTime = '2m') {
    return await this.getMachineSummary('big_turbine', startTime);
  }

  /**
   * Get heat boiler data
   */
  async getHeatBoilerData(startTime = '2m') {
    return await this.getMachineSummary('heat_boiler', startTime);
  }

  /**
   * Get biogas plant data
   */
  async getBiogasData(startTime = '2m') {
    return await this.getMachineSummary('biogas', startTime);
  }

  /**
   * Get energy storage data
   */
  async getEnergyStorageData(startTime = '2m') {
    return await this.getMachineSummary('storage', startTime);
  }
}

export const apiService = new ApiService();
export default apiService;

