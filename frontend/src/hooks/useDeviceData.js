import { useState, useEffect, useCallback } from 'react';
import apiService from '../services/apiService';

/**
 * Custom hook for fetching device data
 * @param {string} deviceType - Type of device (photovoltaic, wind_turbine, etc.)
 * @param {string} timeRange - Time range for data (default: '2m')
 * @param {number} refreshInterval - Auto-refresh interval in ms (default: 30000)
 */
export const useDeviceData = (deviceType, timeRange = '2m', refreshInterval = 30000) => {
  const [data, setData] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const [lastUpdate, setLastUpdate] = useState(null);

  const fetchData = useCallback(async () => {
    try {
      setLoading(true);
      setError(null);

      let result;
      switch (deviceType) {
        case 'photovoltaic':
          result = await apiService.getPhotovoltaicData(timeRange);
          break;
        case 'wind_turbine':
          result = await apiService.getWindTurbineData(timeRange);
          break;
        case 'heat_boiler':
          result = await apiService.getHeatBoilerData(timeRange);
          break;
        case 'biogas':
          result = await apiService.getBiogasData(timeRange);
          break;
        case 'storage':
          result = await apiService.getEnergyStorageData(timeRange);
          break;
        default:
          throw new Error(`Unknown device type: ${deviceType}`);
      }

      setData(result);
      setLastUpdate(new Date());
    } catch (err) {
      setError(err.message || 'Failed to fetch data');
      console.error(`Error fetching ${deviceType} data:`, err);
    } finally {
      setLoading(false);
    }
  }, [deviceType, timeRange]);

  useEffect(() => {
    fetchData();

    // Set up auto-refresh
    if (refreshInterval > 0) {
      const intervalId = setInterval(fetchData, refreshInterval);
      return () => clearInterval(intervalId);
    }
  }, [fetchData, refreshInterval]);

  return { data, loading, error, lastUpdate, refetch: fetchData };
};

export default useDeviceData;

