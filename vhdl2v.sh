#!/bin/bash

set -eu

OPTS=$(getopt -o h \
              -l help \
              -n "$(basename $0)" \
              -- "$@")

if [ $? != 0 ] ; then exit 2 ; fi

eval set -- "$OPTS"

if [ $# -lt 2 ]; then
    echo "APB_UART_DIR required" >&2
    exit 2
fi

HELP=
VHDL_UART_DIR=

while true; do
    case "${1-}" in
        -h | --help)        HELP=true; shift;;
        -- ) shift;;
        * )  if [ -z "${1-}" ]; then
                 break
             else 
                 if [ -z "${VHDL_UART_DIR}" ]; then
                     VHDL_UART_DIR="$1"
                     shift
                 else
                     echo "Redundant APB_UART_DIR: $1" >&2
                     echo "APB_UART_DIR has been specified: $VHDL_UART_DIR" >&2
                     exit 2
                 fi
             fi
             ;;
    esac
done


function show_help {
    echo "Usage: $(basename "$0") [-h] <APB_UART_DIR>"
    echo
    echo "Convert VHDL APB UART to Verilog version"
    echo
    echo "Options:"
    echo
    echo "-h, --help        display this help"
}

if [ "$HELP" = true ]; then
    show_help
    exit 0
fi


# Get absolute path for docker
VHDL_UART_DIR="$(readlink -f "$VHDL_UART_DIR")"
THIS_DIR="$(readlink -f "$(dirname "$0")")"

docker run -it --rm \
    --user `id -u`:`id -g` \
    --mount type=bind,src="$VHDL_UART_DIR"/,dst=/prj/vhdl,readonly \
    --mount type=bind,src="$THIS_DIR",dst=/prj/v \
    \
    hdlc/ghdl:yosys \
    yosys -m ghdl -s /prj/v/script
