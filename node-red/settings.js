module.exports = {
    // =============================================================================
    // NODE-RED SETTINGS
    // =============================================================================

    // The tcp port that the Node-RED web server is listening on
    uiPort: process.env.NODE_RED_PORT || 1880,

    // By default, the Node-RED UI accepts connections on all IPv4 interfaces.
    // To use the IPv6 loopback interface, set uiHost to "::1"
    // The following property can be used to listen on a specific interface. For
    // example, the following would only allow connections from the local machine.
    // uiHost: "127.0.0.1",

    // Retry time in milliseconds for MQTT connections
    mqttReconnectTime: 15000,

    // Retry time in milliseconds for Serial port connections
    serialReconnectTime: 15000,

    // Retry time in milliseconds for TCP socket connections
    //tcpReconnectTime: 10000,

    // The maximum length, in characters, of any message sent to the debug sidebar tab
    debugMaxLength: 1000,

    // The maximum number of messages nodes will buffer internally as part of their
    // operation. This applies across a range of nodes that operate on message sequences.
    // exec, trigger, inject, file in, read file, websocket in, tcp in, udp in, http in, mqtt in, oauth2, http request, http response, http in, websocket out, tcp out, udp out, http out, mqtt out, file out, write file, and batch can all work with message sequences.
    // The default value is 0, meaning no buffering. A value of 10 would work with legacy
    // behavior, but would be very memory intensive for large numbers of messages.
    // A value of 100 provides a good balance between memory usage and performance.
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
    // If you want to disable encryption of credentials, set this property to false.
    // Note: once you set this property, do not change it - doing so will prevent
    // node-red from being able to decrypt your existing credentials and they will be
    // lost.
    credentialSecret: process.env.NODE_RED_CREDENTIAL_SECRET || "your-node-red-secret",

    // By default, all user data is stored in a directory called `.node-red` under
    // the user's home directory. To use a different location, the following
    // property can be used
    userDir: process.env.NODE_RED_USER_DIR || '/data/',

    // Node-RED scans the `nodes` directory in the userDir to find local node files.
    // The following property can be used to specify an additional directory to scan.
    //nodesDir: '/home/nol/.node-red/nodes',

    // By default, the Node-RED UI is available at http://localhost:1880/
    // The following property can be used to specify a different root path.
    // If set to false, this is disabled.
    //httpRoot: '/red/',

    // The following property can be used to add a custom middleware function
    // in front of all http in nodes. This allows custom authentication to be
    // applied to all http in nodes, or any other sort of common request processing.
    //httpNodeMiddleware: function(req,res,next) {
    //    // Handle/reject requests as required. example:
    //    // Reject requests with a user-agent that matches 'bot'
    //    // if (req.headers['user-agent'].match(/bot/i)) {
    //    //     res.sendStatus(403);
    //    // } else {
    //    //     next();
    //    // }
    //},

    // The following property can be used to verify websocket connection attempts.
    // This allows, for example, the HTTP request headers to be checked to ensure
    // they include valid authentication information.
    //webSocketNodeVerifyClient: function(info) {
    //    // 'info' has three properties:
    //    //   - origin : the value in the Origin header
    //    //   - req : the HTTP request
    //    //   - secure : true if req.connection.authorized !== undefined
    //    // return true if the connection should be accepted, false otherwise
    //    // return false;
    //    return true;
    //},

    // Anything in this hash is globally available to all functions.
    // It is accessed as context.global.
    // eg:
    //    functionGlobalContext: { os:require('os') }
    // can be accessed in a function block as:
    //    context.global.os
    functionGlobalContext: {
        // os:require('os'),
        // jfive:require("johnny-five"),
        // j5board:require("johnny-five").Board({repl:false})
    },

    // Configure the logging output
    logging: {
        // Only console logging is currently supported
        console: {
            // Level of logging to be recorded. Options are:
            // fatal - only those errors which make the application unusable should be recorded
            // error - record errors which are deemed fatal for a particular request + fatal errors
            // warn - record problems which are non fatal + errors + fatal errors
            // info - record information about the general running of the application + warn + error + fatal errors
            // debug - record information which is more verbose than info + info + warn + error + fatal errors
            // trace - record very detailed logging + debug + info + warn + error + fatal errors
            // off - turn off all logging (doesn't affect metrics or audit)
            level: "info",
            // Whether or not to include metric events in the log output
            metrics: false,
            // Whether or not to include audit events in the log output
            audit: false
        }
    },

    // =============================================================================
    // SECURITY SETTINGS
    // =============================================================================

    // Enable authentication
    adminAuth: {
        type: "credentials",
        users: [{
            username: process.env.NODE_RED_USERNAME || "admin",
            password: process.env.NODE_RED_PASSWORD || "adminpassword",
            permissions: "*"
        }]
    },

    // =============================================================================
    // EDITOR SETTINGS
    // =============================================================================

    // The following property can be used to set the default location of the 'edit dialog'
    // The options are: 'left', 'right', 'top', 'bottom', 'center'
    // If not specified, the default is 'center'
    //editDialog: 'center',

    // The following property can be used to enable the Projects feature
    // This allows you to save your flows to a git repository, including version
    // control. In addition, you can use the Projects feature to share your flows
    // with other users.
    // For more information about Projects, see: https://nodered.org/docs/user-guide/projects/
    //
    // To enable the Projects feature, uncomment the following property:
    // The property must be set to a git repository and can be either a HTTP or HTTPS location.
    // If the user is not authenticated, the git repository must be public and have a
    // .node-red/project.json file in the root directory that contains a JSON object
    // with the following structure:
    // {
    //    "name": "node-red-project-name",
    //    "git": {
    //        "remote": "git remote repository location",
    //        "user": "git user name",
    //        "email": "git user email"
    //    }
    // }
    //projects: {
    //    // Mode for user authentication, can be either 'local' or 'git'
    //    mode: "local",
    //    // Allow develoment mode to be enabled from the editor
    //    allowDevMode: true
    //},

    // =============================================================================
    // CUSTOM SETTINGS FOR IOT MONITORING
    // =============================================================================

    // Enable projects for flow version control
    enableProjects: process.env.NODE_RED_ENABLE_PROJECTS === 'true',

    // Editor theme
    editorTheme: {
        projects: {
            enabled: process.env.NODE_RED_ENABLE_PROJECTS === 'true'
        },
        palette: {
            editable: true
        },
        tours: false,
        menu: {
            "menu-item-help": {
                label: "Documentation",
                url: "https://nodered.org/docs"
            }
        }
    },

    // =============================================================================
    // PERFORMANCE SETTINGS
    // =============================================================================

    // The following property can be used to disable the editor. The admin API
    // is not affected by this option. To disable both the editor and the admin
    // API, use editorTheme.admin instead
    disableEditor: process.env.NODE_RED_DISABLE_EDITOR === 'true',

    // The following property can be used to disable flows. The admin API
    // is not affected by this option
    disableFlows: process.env.NODE_RED_DISABLE_FLOWS === 'true',

    // The following property can be used to configure cross-origin resource sharing
    // in the HTTP nodes.
    // See https://github.com/troygoode/node-cors#configuration-options for
    // details on its contents. The following is a basic permissive set of options:
    //httpNodeCors: {
    //    origin: "*",
    //    methods: "GET,PUT,POST,DELETE"
    //},

    // If you need to set an http proxy please set an environment variable
    // called http_proxy (or HTTP_PROXY) outside of Node-RED in your operating
    // system.
    //
    // http_proxy=http://proxy.mycorp.com:8080
    //
    // (http_proxy is automatically read and set by node-red)

    // The following property can be used to add a custom middleware function
    // in front of all http in nodes. This allows custom authentication to be
    // applied to all http in nodes, or any other sort of common request processing.
    //httpNodeMiddleware: function(req,res,next) {
    //    // Handle/reject requests as required. example:
    //    // Reject requests with a user-agent that matches 'bot'
    //    // if (req.headers['user-agent'].match(/bot/i)) {
    //    //     res.sendStatus(403);
    //    // } else {
    //    //     next();
    //    // }
    //},

    // =============================================================================
    // MQTT SETTINGS
    // =============================================================================

    // MQTT broker settings for internal communication
    mqttBroker: {
        host: process.env.MQTT_BROKER_HOST || "mosquitto",
        port: process.env.MQTT_BROKER_PORT || 1883,
        clientId: process.env.MQTT_CLIENT_ID || "node-red-simulation",
        username: process.env.MQTT_USERNAME || "node-red",
        password: process.env.MQTT_PASSWORD || "node-red-password",
        keepalive: 60,
        reconnectPeriod: 5000,
        connectTimeout: 30000,
        clean: true,
        encoding: 'utf8'
    },

    // =============================================================================
    // INFLUXDB SETTINGS
    // =============================================================================

    // InfluxDB configuration for time-series data storage
    influxdb: {
        host: process.env.INFLUXDB_HOST || "influxdb",
        port: process.env.INFLUXDB_PORT || 8086,
        protocol: process.env.INFLUXDB_PROTOCOL || "http",
        token: process.env.INFLUXDB_TOKEN || "your-influxdb-token",
        organization: process.env.INFLUXDB_ORG || "renewable_energy",
        bucket: process.env.INFLUXDB_BUCKET || "iot_data",
        precision: "ms",
        timeout: 10000
    },

    // =============================================================================
    // SIMULATION SETTINGS
    // =============================================================================

    // Device simulation configuration
    simulation: {
        // Simulation intervals (seconds)
        intervals: {
            photovoltaic: 30,
            wind_turbine: 30,
            biogas_plant: 30,
            heat_boiler: 30,
            energy_storage: 30
        },
        
        // Fault probabilities (0-1)
        faultProbabilities: {
            photovoltaic: 0.001,
            wind_turbine: 0.002,
            biogas_plant: 0.0015,
            heat_boiler: 0.002,
            energy_storage: 0.001
        },
        
        // Data validation ranges
        validationRanges: {
            photovoltaic: {
                irradiance: { min: 0, max: 1200 },
                temperature: { min: -40, max: 100 },
                voltage: { min: 0, max: 100 },
                current: { min: 0, max: 20 },
                power_output: { min: 0, max: 1000 }
            },
            wind_turbine: {
                wind_speed: { min: 0, max: 50 },
                wind_direction: { min: 0, max: 360 },
                rotor_speed: { min: 0, max: 25 },
                vibration: { min: 0, max: 20 },
                power_output: { min: 0, max: 2500 },
                temperature: { min: -20, max: 80 }
            },
            biogas_plant: {
                gas_flow: { min: 0, max: 200 },
                methane_concentration: { min: 30, max: 85 },
                temperature: { min: 20, max: 60 },
                ph: { min: 6.0, max: 8.5 },
                power_output: { min: 0, max: 500 }
            },
            heat_boiler: {
                temperature: { min: 50, max: 150 },
                pressure: { min: 0.5, max: 5.0 },
                efficiency: { min: 60, max: 98 },
                power_output: { min: 0, max: 500 }
            },
            energy_storage: {
                state_of_charge: { min: 0, max: 100 },
                voltage: { min: 300, max: 500 },
                current: { min: -100, max: 100 },
                temperature: { min: -10, max: 60 },
                cycle_count: { min: 0, max: 10000 },
                power_output: { min: -50, max: 50 }
            }
        }
    },

    // =============================================================================
    // ERROR HANDLING SETTINGS
    // =============================================================================

    // Error handling and monitoring configuration
    errorHandling: {
        // Maximum retry attempts for failed operations
        maxRetries: 3,
        
        // Retry delay in milliseconds
        retryDelay: 5000,
        
        // Error logging configuration
        logging: {
            enabled: true,
            level: "error", // error, warn, info, debug
            maxLogSize: 1000,
            retention: "7d"
        },
        
        // Alert thresholds
        alerts: {
            dataValidationErrors: 10, // Alert after 10 validation errors
            mqttConnectionFailures: 5, // Alert after 5 connection failures
            influxdbWriteFailures: 5, // Alert after 5 write failures
            simulationFaults: 20 // Alert after 20 simulation faults
        }
    },

    // =============================================================================
    // PERFORMANCE SETTINGS
    // =============================================================================

    // Performance optimization settings
    performance: {
        // Message buffer settings
        messageBuffer: {
            maxLength: 100,
            flushInterval: 5000 // milliseconds
        },
        
        // Database batch settings
        database: {
            batchSize: 100,
            batchTimeout: 10000, // milliseconds
            maxConcurrentWrites: 5
        },
        
        // MQTT settings
        mqtt: {
            maxConcurrentPublishes: 10,
            publishTimeout: 5000, // milliseconds
            qos: 1
        }
    },

    // =============================================================================
    // SECURITY SETTINGS
    // =============================================================================

    // Security configuration
    security: {
        // Data encryption
        encryption: {
            enabled: process.env.ENCRYPTION_ENABLED === 'true',
            algorithm: 'aes-256-gcm',
            key: process.env.ENCRYPTION_KEY || 'your-encryption-key'
        },
        
        // Authentication
        authentication: {
            enabled: true,
            method: 'credentials', // credentials, oauth2, jwt
            sessionTimeout: 3600000 // 1 hour in milliseconds
        },
        
        // Access control
        accessControl: {
            enabled: true,
            defaultRole: 'user',
            roles: {
                admin: ['read', 'write', 'delete', 'configure'],
                operator: ['read', 'write'],
                viewer: ['read']
            }
        }
    }
        host: process.env.MQTT_BROKER_HOST || 'localhost',
        port: process.env.MQTT_BROKER_PORT || 1883,
        username: process.env.MQTT_USERNAME,
        password: process.env.MQTT_PASSWORD,
        clientId: process.env.MQTT_CLIENT_ID || 'node-red-client'
    },

    // =============================================================================
    // INFLUXDB SETTINGS
    // =============================================================================

    // InfluxDB connection settings
    influxdb: {
        url: process.env.INFLUXDB_URL || 'http://localhost:8086',
        token: process.env.INFLUXDB_TOKEN,
        org: process.env.INFLUXDB_ORG || 'renewable_energy',
        bucket: process.env.INFLUXDB_BUCKET || 'iot_data'
    },

    // =============================================================================
    // CUSTOM NODE SETTINGS
    // =============================================================================

    // Custom node settings for renewable energy monitoring
    customNodes: {
        // Enable TypeScript support
        typescript: true,
        // Enable ES6 modules
        es6Modules: true,
        // Enable async/await support
        asyncAwait: true
    }
}; 