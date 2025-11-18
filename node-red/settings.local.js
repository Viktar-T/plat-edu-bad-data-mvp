// =============================================================================
// NODE-RED SETTINGS - Local Development with Nginx Reverse Proxy
// Renewable Energy IoT Monitoring System
// =============================================================================
// 
// This configuration is for local development when using nginx reverse proxy
// with path-based routing (/nodered/)
// =============================================================================

module.exports = {
    // The tcp port that the Node-RED web server is listening on
    uiPort: process.env.NODE_RED_PORT || 1880,

    // By default, the Node-RED UI accepts connections on all IPv4 interfaces.
    uiHost: "0.0.0.0",

    // Retry time in milliseconds for MQTT connections
    mqttReconnectTime: 15000,

    // Retry time in milliseconds for Serial port connections
    serialReconnectTime: 15000,

    // The maximum length, in characters, of any message sent to the debug sidebar tab
    debugMaxLength: 1000,

    // The maximum number of messages nodes will buffer internally as part of their
    // operation.
    nodeMessageBufferMaxLength: 0,

    // To disable the option for using local files for storing keys and certificates in the TLS configuration
    // node, set this to true
    tlsConfigDisableLocalFiles: true,

    // Colourise the console output of the debug node
    debugUseColors: true,

    // The file containing the flows. If not set, it defaults to flows_<hostname>.json
    flowFile: 'flows.json',

    // To enabled pretty-printing of the flow within the flow file, set the following
    // property to true:
    flowFilePretty: true,

    // By default, credentials are encrypted in storage using a generated key. To
    // specify your own secret, set the following property.
    // If you need to share your flow file between instances, you should set this to
    // a common value.
    credentialSecret: process.env.NODE_RED_CREDENTIAL_SECRET || "your-node-red-secret",

    // The following property can be used to set a custom http path root for Node-RED.
    // This allows Node-RED to be run alongside other services on the same server.
    // When using nginx reverse proxy with path-based routing, set this to match the nginx location path.
    httpRoot: '/nodered',

    // Editor theme
    editorTheme: {
        theme: {
            name: "dark"
        }
    },

    // Logging
    logging: {
        console: {
            level: "info",
            metrics: false,
            audit: false
        }
    }
};

