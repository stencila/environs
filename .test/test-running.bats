#!./libs/bats/bin/bats

load 'libs/bats-support/load'
load 'libs/bats-assert/load'

# Port to publish containers to on host machine
PORT=2121

# Starts a container
function start {
    echo "Starting container $1 $PORT"
    export CONTAINER=$(docker run --detach --publish $PORT:2000 --rm "$1")
    echo "Started $CONTAINER"
}

# Stop the last container
function stop {
    if [ -n "$CONTAINER" ] ; then
        echo "Stopping $CONTAINER"
        docker stop "$CONTAINER"
        CONTAINER=
    fi
}

# Test teardown stops the container (even after a test failiure)
function teardown {
    stop
}

# Some tests are skipped on Travis CI (due to time limit on build)
function skip_if_ci {
    if [ "$CI" = true ] ; then
        skip
    fi
}

# Helper functions to make HTTP requests to hosts in containers
function request {
    # Request body options
    if [ -n "$3" ] ; then
        body="--header Content-Type:application/json --data $3"
    fi
    # Curl's retry option does not retry when "connection refused" error so use
    # a loop for retries. This is necessary while Host server startups up.
    retries=60
    while [ "$retries" -gt 0 ] ; do
        curl --silent \
             --header Accept:application/json \
             $body \
             -X "$1" \
             localhost:$PORT"$2" && break
        let retries=retries-1
        sleep 0.5
    done
}
function GET {
    request "GET" "$1"
}
function POST {
    request "POST" "$1"
}
function PUT {
    request "PUT" "$1" "$2"
}

@test "base/node image should run" {
    skip_if_ci

    start "stencila/base/node"

    run GET "/"
    assert_output --partial '"stencila":{"package":"node","version":"0.28.1"}'

    run POST "/NodeContext"
    assert_output '"nodeContext1"'

    run PUT "/nodeContext1!runCode" '{"code":"2*3*4"}'
    assert_output '{"errors":null,"output":{"type":"integer","format":"text","content":"24"}}'
}

@test "base/py image should run" {
    skip_if_ci

    start "stencila/base/py"

    skip "Currenly authorization is on. Needs to be turned off for testing"
}

@test "base/r image should run" {
    skip_if_ci

    start "stencila/base/r"

    skip "Currenly authorization is on. Needs to be turned off for testing"
}

@test "base image should run" {
    start "stencila/base"

    # All languages should be peers of the primary host
    
    run GET "/"
    assert_output --partial '"stencila":{"package":"node","version":"0.28.1"}'
    assert_output --partial '"stencila":{"package":"py","version":"0.28.0"}'
    assert_output --partial '"stencila":{"package":"r","version":"0.28.1"}'

    # Each language context should be instantiable
    
    run POST "/NodeContext"
    assert_output '"nodeContext1"'

    run POST "/PythonContext"
    assert_output '"pythonContext1"'

    run POST "/RContext"
    assert_output '"rContext1"'
}
