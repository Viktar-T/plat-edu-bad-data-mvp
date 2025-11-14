import { useDeviceData } from '../hooks/useDeviceData';

/**
 * Example component using the new useDeviceData hook
 * This demonstrates the recommended pattern for fetching device data
 */
export const PhotovoltaicData = () => {
  const { data, loading, error, lastUpdate, refetch } = useDeviceData(
    'photovoltaic',
    '2m',
    30000 // Refresh every 30 seconds
  );

  if (loading && !data) {
    return <div>Loading photovoltaic data...</div>;
  }

  if (error) {
    return (
      <div>
        <p>Error: {error}</p>
        <button onClick={refetch}>Retry</button>
      </div>
    );
  }

  return (
    <div>
      <h2>Photovoltaic Data</h2>
      {lastUpdate && (
        <p>Last updated: {lastUpdate.toLocaleTimeString()}</p>
      )}
      <pre>{JSON.stringify(data, null, 2)}</pre>
      <button onClick={refetch}>Refresh</button>
    </div>
  );
};

export default PhotovoltaicData;

