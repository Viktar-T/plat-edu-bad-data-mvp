/**
 * Reusable Tree View Component
 * Used for displaying hierarchical schema information
 * Renewable Energy IoT Monitoring System
 */

class TreeView {
    constructor(containerId, options = {}) {
        this.container = document.getElementById(containerId);
        this.options = {
            expandable: true,
            multiSelect: false,
            showIcons: true,
            onNodeClick: options.onNodeClick || (() => {}),
            onNodeExpand: options.onNodeExpand || (() => {}),
            onNodeCollapse: options.onNodeCollapse || (() => {}),
            ...options
        };
        this.selectedNodes = new Set();
        this.expandedNodes = new Set();
        this.nodeIdCounter = 0;
        
        this.initializeTree();
    }

    /**
     * Initialize the tree view container
     */
    initializeTree() {
        if (!this.container) {
            console.error('Tree view container not found');
            return;
        }

        this.container.className = 'tree-view';
        this.container.innerHTML = '';
    }

    /**
     * Render the tree with provided data
     */
    render(data) {
        this.container.innerHTML = '';
        
        if (!data || data.length === 0) {
            this.container.innerHTML = '<div class="tree-empty">No data available</div>';
            return;
        }

        const treeList = document.createElement('ul');
        treeList.className = 'tree-root';
        
        data.forEach(node => {
            const treeItem = this.createTreeNode(node);
            treeList.appendChild(treeItem);
        });

        this.container.appendChild(treeList);
    }

    /**
     * Create a tree node element
     */
    createTreeNode(nodeData, level = 0) {
        const nodeId = nodeData.id || `node_${this.nodeIdCounter++}`;
        const li = document.createElement('li');
        li.className = 'tree-node';
        li.setAttribute('data-node-id', nodeId);
        li.setAttribute('data-level', level);

        // Create node content container
        const nodeContent = document.createElement('div');
        nodeContent.className = 'tree-node-content';
        
        // Add indentation
        const indent = document.createElement('span');
        indent.className = 'tree-indent';
        indent.style.width = `${level * 20}px`;
        nodeContent.appendChild(indent);

        // Add expand/collapse button if node has children
        if (nodeData.children && nodeData.children.length > 0) {
            const expandBtn = document.createElement('button');
            expandBtn.className = 'tree-expand-btn';
            expandBtn.innerHTML = this.expandedNodes.has(nodeId) ? '▼' : '▶';
            expandBtn.onclick = (e) => {
                e.stopPropagation();
                this.toggleNode(nodeId, nodeData);
            };
            nodeContent.appendChild(expandBtn);
        } else {
            // Add spacer for leaf nodes
            const spacer = document.createElement('span');
            spacer.className = 'tree-spacer';
            spacer.innerHTML = '&nbsp;&nbsp;&nbsp;';
            nodeContent.appendChild(spacer);
        }

        // Add node icon
        if (this.options.showIcons) {
            const icon = document.createElement('span');
            icon.className = 'tree-icon';
            icon.innerHTML = this.getNodeIcon(nodeData);
            nodeContent.appendChild(icon);
        }

        // Add node label
        const label = document.createElement('span');
        label.className = 'tree-label';
        label.textContent = nodeData.label || nodeData.name || 'Unnamed';
        
        // Add node metadata if available
        if (nodeData.metadata) {
            const metadata = document.createElement('span');
            metadata.className = 'tree-metadata';
            metadata.textContent = ` (${nodeData.metadata})`;
            label.appendChild(metadata);
        }

        nodeContent.appendChild(label);

        // Add loading indicator placeholder
        if (nodeData.loading) {
            const loading = document.createElement('span');
            loading.className = 'tree-loading';
            loading.innerHTML = ' <i>Loading...</i>';
            nodeContent.appendChild(loading);
        }

        // Add click handler
        nodeContent.onclick = (e) => {
            e.stopPropagation();
            this.selectNode(nodeId, nodeData);
        };

        li.appendChild(nodeContent);

        // Add children if node is expanded
        if (nodeData.children && this.expandedNodes.has(nodeId)) {
            const childrenContainer = document.createElement('ul');
            childrenContainer.className = 'tree-children';
            
            nodeData.children.forEach(child => {
                const childNode = this.createTreeNode(child, level + 1);
                childrenContainer.appendChild(childNode);
            });
            
            li.appendChild(childrenContainer);
        }

        return li;
    }

    /**
     * Get appropriate icon for node type
     */
    getNodeIcon(nodeData) {
        const iconMap = {
            database: '🗃️',
            measurement: '📊',
            field: '📋',
            tag: '🏷️',
            folder: '📁',
            file: '📄'
        };

        return iconMap[nodeData.type] || '📄';
    }

    /**
     * Toggle node expansion
     */
    toggleNode(nodeId, nodeData) {
        if (this.expandedNodes.has(nodeId)) {
            this.collapseNode(nodeId, nodeData);
        } else {
            this.expandNode(nodeId, nodeData);
        }
    }

    /**
     * Expand a node
     */
    expandNode(nodeId, nodeData) {
        this.expandedNodes.add(nodeId);
        this.options.onNodeExpand(nodeId, nodeData);
        this.updateNodeDisplay(nodeId, nodeData);
    }

    /**
     * Collapse a node
     */
    collapseNode(nodeId, nodeData) {
        this.expandedNodes.delete(nodeId);
        this.options.onNodeCollapse(nodeId, nodeData);
        this.updateNodeDisplay(nodeId, nodeData);
    }

    /**
     * Select a node
     */
    selectNode(nodeId, nodeData) {
        if (!this.options.multiSelect) {
            this.selectedNodes.clear();
            // Remove selection styling from all nodes
            this.container.querySelectorAll('.tree-node-content.selected').forEach(node => {
                node.classList.remove('selected');
            });
        }

        this.selectedNodes.add(nodeId);
        
        // Add selection styling
        const nodeElement = this.container.querySelector(`[data-node-id="${nodeId}"] .tree-node-content`);
        if (nodeElement) {
            nodeElement.classList.add('selected');
        }

        this.options.onNodeClick(nodeId, nodeData);
    }

    /**
     * Update node display after expand/collapse
     */
    updateNodeDisplay(nodeId, nodeData) {
        const nodeElement = this.container.querySelector(`[data-node-id="${nodeId}"]`);
        if (!nodeElement) return;

        // Update expand button
        const expandBtn = nodeElement.querySelector('.tree-expand-btn');
        if (expandBtn) {
            expandBtn.innerHTML = this.expandedNodes.has(nodeId) ? '▼' : '▶';
        }

        // Remove existing children
        const existingChildren = nodeElement.querySelector('.tree-children');
        if (existingChildren) {
            existingChildren.remove();
        }

        // Add children if expanded
        if (this.expandedNodes.has(nodeId) && nodeData.children) {
            const level = parseInt(nodeElement.getAttribute('data-level')) || 0;
            const childrenContainer = document.createElement('ul');
            childrenContainer.className = 'tree-children';
            
            nodeData.children.forEach(child => {
                const childNode = this.createTreeNode(child, level + 1);
                childrenContainer.appendChild(childNode);
            });
            
            nodeElement.appendChild(childrenContainer);
        }
    }

    /**
     * Add a new node to the tree
     */
    addNode(parentId, nodeData) {
        // Find parent node in data structure and add child
        // This would require maintaining a reference to the data structure
        // For now, trigger a re-render
        console.log('Adding node to parent:', parentId, nodeData);
    }

    /**
     * Remove a node from the tree
     */
    removeNode(nodeId) {
        const nodeElement = this.container.querySelector(`[data-node-id="${nodeId}"]`);
        if (nodeElement) {
            nodeElement.remove();
        }
        this.selectedNodes.delete(nodeId);
        this.expandedNodes.delete(nodeId);
    }

    /**
     * Update node loading state
     */
    setNodeLoading(nodeId, loading = true) {
        const nodeElement = this.container.querySelector(`[data-node-id="${nodeId}"] .tree-node-content`);
        if (!nodeElement) return;

        let loadingElement = nodeElement.querySelector('.tree-loading');
        
        if (loading) {
            if (!loadingElement) {
                loadingElement = document.createElement('span');
                loadingElement.className = 'tree-loading';
                nodeElement.appendChild(loadingElement);
            }
            loadingElement.innerHTML = ' <i>Loading...</i>';
        } else {
            if (loadingElement) {
                loadingElement.remove();
            }
        }
    }

    /**
     * Filter tree nodes based on search term
     */
    filter(searchTerm) {
        const allNodes = this.container.querySelectorAll('.tree-node');
        const term = searchTerm.toLowerCase();

        allNodes.forEach(node => {
            const label = node.querySelector('.tree-label').textContent.toLowerCase();
            const matches = !term || label.includes(term);
            
            node.style.display = matches ? '' : 'none';
            
            // If a node matches, ensure its parents are visible
            if (matches) {
                let parent = node.parentElement.closest('.tree-node');
                while (parent) {
                    parent.style.display = '';
                    parent = parent.parentElement.closest('.tree-node');
                }
            }
        });
    }

    /**
     * Clear all selections
     */
    clearSelection() {
        this.selectedNodes.clear();
        this.container.querySelectorAll('.tree-node-content.selected').forEach(node => {
            node.classList.remove('selected');
        });
    }

    /**
     * Get currently selected node IDs
     */
    getSelected() {
        return Array.from(this.selectedNodes);
    }

    /**
     * Expand all nodes
     */
    expandAll() {
        const allNodes = this.container.querySelectorAll('.tree-node[data-node-id]');
        allNodes.forEach(node => {
            const nodeId = node.getAttribute('data-node-id');
            this.expandedNodes.add(nodeId);
        });
        // Would need to trigger re-render or update display
    }

    /**
     * Collapse all nodes
     */
    collapseAll() {
        this.expandedNodes.clear();
        // Remove all children containers
        this.container.querySelectorAll('.tree-children').forEach(children => {
            children.remove();
        });
        // Update expand buttons
        this.container.querySelectorAll('.tree-expand-btn').forEach(btn => {
            btn.innerHTML = '▶';
        });
    }
}

// Export for use in other modules
if (typeof module !== 'undefined' && module.exports) {
    module.exports = TreeView;
} else if (typeof window !== 'undefined') {
    window.TreeView = TreeView;
} 