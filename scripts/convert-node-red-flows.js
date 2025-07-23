#!/usr/bin/env node

const fs = require('fs');
const path = require('path');

/**
 * Convert Node-RED flow file from custom format to proper import format
 * Node-RED expects a JSON array of nodes, not a nested object structure
 */

function convertFlowFile(inputPath, outputPath) {
    try {
        // Read the original file
        const originalData = JSON.parse(fs.readFileSync(inputPath, 'utf8'));
        
        // Extract all nodes from the flows array
        const allNodes = [];
        
        if (originalData.flows && Array.isArray(originalData.flows)) {
            originalData.flows.forEach(flow => {
                if (flow.nodes && Array.isArray(flow.nodes)) {
                    allNodes.push(...flow.nodes);
                }
            });
        }
        
        // Add tab nodes if they exist
        if (originalData.nodes && Array.isArray(originalData.nodes)) {
            allNodes.push(...originalData.nodes);
        }
        
        // Add configs if they exist
        if (originalData.configs && Array.isArray(originalData.configs)) {
            allNodes.push(...originalData.configs);
        }
        
        // Write the converted file
        fs.writeFileSync(outputPath, JSON.stringify(allNodes, null, 2));
        
        console.log(`✅ Successfully converted ${inputPath} to ${outputPath}`);
        console.log(`📊 Total nodes: ${allNodes.length}`);
        
        // Show node types summary
        const nodeTypes = {};
        allNodes.forEach(node => {
            const type = node.type || 'unknown';
            nodeTypes[type] = (nodeTypes[type] || 0) + 1;
        });
        
        console.log('\n📋 Node types summary:');
        Object.entries(nodeTypes).forEach(([type, count]) => {
            console.log(`  ${type}: ${count}`);
        });
        
    } catch (error) {
        console.error('❌ Error converting flow file:', error.message);
        process.exit(1);
    }
}

// Main execution
if (require.main === module) {
    const args = process.argv.slice(2);
    
    if (args.length < 1) {
        console.log('Usage: node convert-node-red-flows.js <input-file> [output-file]');
        console.log('');
        console.log('Examples:');
        console.log('  node convert-node-red-flows.js flows/renewable-energy-simulation.json');
        console.log('  node convert-node-red-flows.js flows/renewable-energy-simulation.json flows/converted-flows.json');
        process.exit(1);
    }
    
    const inputFile = args[0];
    const outputFile = args[1] || inputFile.replace('.json', '-converted.json');
    
    if (!fs.existsSync(inputFile)) {
        console.error(`❌ Input file not found: ${inputFile}`);
        process.exit(1);
    }
    
    convertFlowFile(inputFile, outputFile);
}

module.exports = { convertFlowFile }; 