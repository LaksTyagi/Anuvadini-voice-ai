#!/usr/bin/env bash
# Local Voice AI - Quick Start Script
# This script checks prerequisites and starts the application

set -e

echo "=================================="
echo "Local Voice AI - Quick Start"
echo "=================================="
echo ""

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Check Docker
echo -e "${YELLOW}Checking Docker...${NC}"
if command -v docker &> /dev/null; then
    docker_version=$(docker --version)
    echo -e "${GREEN}✓ Docker installed: $docker_version${NC}"
else
    echo -e "${RED}✗ Docker not found${NC}"
    echo -e "${RED}Please install Docker from https://www.docker.com/${NC}"
    exit 1
fi

# Check if Docker daemon is running
echo -e "${YELLOW}Checking Docker daemon...${NC}"
if docker ps &> /dev/null; then
    echo -e "${GREEN}✓ Docker daemon is running${NC}"
else
    echo -e "${RED}✗ Docker daemon is not running${NC}"
    echo -e "${YELLOW}Please start Docker and wait for it to fully initialize${NC}"
    echo -e "${YELLOW}Then run this script again${NC}"
    exit 1
fi

# Check Docker Compose
echo -e "${YELLOW}Checking Docker Compose...${NC}"
if docker compose version &> /dev/null; then
    compose_version=$(docker compose version)
    echo -e "${GREEN}✓ Docker Compose installed: $compose_version${NC}"
else
    echo -e "${RED}✗ Docker Compose not found${NC}"
    exit 1
fi

echo ""
echo -e "${CYAN}==================================${NC}"
echo -e "${GREEN}All prerequisites met!${NC}"
echo -e "${CYAN}==================================${NC}"
echo ""

# Detect macOS
if [[ "$(uname -s)" == "Darwin" ]]; then
    echo -e "${YELLOW}Detected macOS - using CPU mode${NC}"
    mode="cpu"
    compose_files="-f docker-compose.yml"
    if [[ "$(uname -m)" == "arm64" ]]; then
        compose_files="$compose_files -f docker-compose.macos.yml"
    fi
else
    # Ask user for CPU or GPU mode
    echo -e "${YELLOW}Select target:${NC}"
    echo "  1) CPU (works on all systems)"
    echo "  2) GPU (requires NVIDIA GPU with CUDA)"
    echo ""
    read -p "Enter choice (1/2): " choice

    compose_files="-f docker-compose.yml"
    mode="CPU"

    if [[ "$choice" == "2" ]]; then
        compose_files="$compose_files -f docker-compose.gpu.yml"
        mode="GPU"
        echo ""
        echo -e "${YELLOW}⚠ GPU mode requires NVIDIA GPU with CUDA support${NC}"
    elif [[ "$choice" != "1" ]]; then
        echo -e "${YELLOW}Invalid choice. Defaulting to CPU mode.${NC}"
        mode="CPU"
    fi
fi

echo ""
echo -e "${CYAN}==================================${NC}"
echo -e "${CYAN}Starting Local Voice AI ($mode mode)${NC}"
echo -e "${CYAN}==================================${NC}"
echo ""
echo -e "${YELLOW}⏳ First run will take 10-30 minutes to:${NC}"
echo -e "${YELLOW}   - Build Docker images${NC}"
echo -e "${YELLOW}   - Download AI models (several GB)${NC}"
echo ""
echo -e "${YELLOW}📊 You can monitor progress in the output below${NC}"
echo ""
echo -e "${GREEN}🌐 Once ready, open: http://localhost:3000${NC}"
echo ""
echo -e "${YELLOW}Press Ctrl+C to stop the application${NC}"
echo ""
echo -e "${CYAN}Starting in 3 seconds...${NC}"
sleep 3

# Start Docker Compose
docker compose $compose_files up --build
