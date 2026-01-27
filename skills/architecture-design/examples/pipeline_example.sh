#!/bin/bash
###############################################################################
# Training Pipeline Script
#
# This script demonstrates the standard training pipeline execution pattern.
# It handles environment setup, configuration, and execution with proper
# error handling and logging.
#
# Usage:
#   ./run/pipeline/training/train.sh --config-name=config_example
###############################################################################

set -e  # Exit on error
set -o pipefail  # Exit on pipe failure

# Script configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"
EXPERIMENT_NAME="baseline_experiment"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

###############################################################################
# Helper Functions
###############################################################################

log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

cleanup() {
    log_info "Cleaning up..."
    # Add cleanup logic here (e.g., kill background processes)
}

trap cleanup EXIT

###############################################################################
# Environment Setup
###############################################################################

setup_environment() {
    log_info "Setting up environment..."

    # Activate virtual environment if it exists
    if [ -f "${PROJECT_ROOT}/.venv/bin/activate" ]; then
        source "${PROJECT_ROOT}/.venv/bin/activate"
        log_info "Activated virtual environment"
    fi

    # Check required commands
    command -v python >/dev/null 2>&1 || { log_error "Python not found"; exit 1; }

    # Set Python path
    export PYTHONPATH="${PROJECT_ROOT}/src:${PYTHONPATH}"
    log_info "PYTHONPATH set to: ${PYTHONPATH}"
}

###############################################################################
# Configuration
###############################################################################

parse_arguments() {
    # Default values
    CONFIG="default"
    GPUS=0
    SEED=42

    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            --config-name|-c)
                CONFIG="$2"
                shift 2
                ;;
            --gpus|-g)
                GPUS="$2"
                shift 2
                ;;
            --seed|-s)
                SEED="$2"
                shift 2
                ;;
            *)
                log_warn "Unknown argument: $1"
                shift
                ;;
        esac
    done

    log_info "Configuration: ${CONFIG}"
    log_info "GPUs: ${GPUS}"
    log_info "Seed: ${SEED}"
}

###############################################################################
# Main Training Function
###############################################################################

run_training() {
    log_info "Starting training..."

    # Output directory for this run
    OUTPUT_DIR="${PROJECT_ROOT}/outputs/${EXPERIMENT_NAME}/${TIMESTAMP}"
    mkdir -p "${OUTPUT_DIR}"

    log_info "Output directory: ${OUTPUT_DIR}"

    # Training command with Hydra
    python "${PROJECT_ROOT}/train.py" \
        --config-name="${CONFIG}" \
        seed=${SEED} \
        dir.output_dir="${OUTPUT_DIR}" \
        training.device=cuda \
        hydra.output_dir="${OUTPUT_DIR}/hydra" \
        hydra.run.dir="${OUTPUT_DIR}/hydra" || {
        log_error "Training failed!"
        exit 1
    }

    log_info "Training completed successfully!"
}

###############################################################################
# Post-Processing
###############################################################################

post_process() {
    log_info "Post-processing results..."

    # Copy logs to output directory
    if [ -f "${OUTPUT_DIR}/hydra/*.log" ]; then
        cp "${OUTPUT_DIR}/hydra/"*.log "${OUTPUT_DIR}/"
    fi

    # Generate summary
    log_info "Run summary:"
    log_info "  Config: ${CONFIG}"
    log_info "  Seed: ${SEED}"
    log_info "  Output: ${OUTPUT_DIR}"

    # Print path to best checkpoint
    BEST_CHECKPOINT=$(find "${OUTPUT_DIR}" -name "best*.pt" | head -n 1)
    if [ -n "${BEST_CHECKPOINT}" ]; then
        log_info "  Best checkpoint: ${BEST_CHECKPOINT}"
    fi
}

###############################################################################
# Main Execution
###############################################################################

main() {
    log_info "=========================================="
    log_info "Training Pipeline"
    log_info "=========================================="

    # Setup
    setup_environment

    # Parse arguments
    parse_arguments "$@"

    # Run training
    run_training

    # Post-process
    post_process

    log_info "=========================================="
    log_info "Pipeline completed successfully!"
    log_info "=========================================="
}

# Run main function
main "$@"
