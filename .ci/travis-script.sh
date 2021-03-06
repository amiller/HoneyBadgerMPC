#!/bin/bash

set -ev

BASE_CMD="docker-compose -f .travis.compose.yml run test-hbmpc"

if [ "${BUILD}" == "tests" ]; then
    $BASE_CMD pytest -v \
        --cov \
        --cov-report=term-missing \
        --cov-report=xml \
        -Wignore::DeprecationWarning \
        -nauto \
        --dist=loadfile

    IMAGE_NAME=$(docker ps -alq --format "{{.Names}}")
    docker cp $IMAGE_NAME:/usr/src/HoneyBadgerMPC/coverage.xml .
elif [ "${BUILD}" == "flake8" ]; then
    flake8
elif [ "${BUILD}" == "docs" ]; then
    $BASE_CMD sphinx-build -M html docs docs/_build -c docs -W
    $BASE_CMD doc8 docs/
fi