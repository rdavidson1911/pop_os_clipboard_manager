#!/bin/bash

# Improved temporary directory handling
setup_test_env() {
    local temp_dir
    
    # Create temporary directory with proper error checking
    temp_dir=$(mktemp -d) || {
        echo "ERROR: Failed to create temporary test directory" >&2
        exit 1
    }
    
    # Set restrictive permissions
    chmod 700 "$temp_dir"
    
    # Setup cleanup trap
    trap 'rm -rf "$temp_dir"' EXIT
    
    # Export for use in tests
    TEST_DIR="$temp_dir"
    CLIPBOARD_DIR="$TEST_DIR/.clipboard_history"
    DB_FILE="$CLIPBOARD_DIR/clipboard.db"
}

# Setup
setUp() {
    mkdir -p "$CLIPBOARD_DIR"
    chmod 700 "$CLIPBOARD_DIR"
}

# Cleanup
tearDown() {
    rm -rf "$TEST_DIR"
}

# Test database initialization
testDatabaseInit() {
    source ../clipboard_manager.sh
    init_clipboard
    if [ ! -f "$DB_FILE" ]; then
        echo "FAIL: Database file not created"
        exit 1
    fi
    echo "PASS: Database initialization"
}

# Run tests
setup_test_env
testDatabaseInit
tearDown 