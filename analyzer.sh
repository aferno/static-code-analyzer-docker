#!/bin/sh

set -e

BUILD_TOOL=""
PROJECT_PATH=""
CHECKERS=""
CHECKERS_PATH=""
ANALYZE=false
INIT_ARGS=""
SIN_FILE=""

function print_usage {
    cat << EOF
    
Usage: analyzer.sh [options]

Run clang static analyzer for cmake project.
Firstly initialize the project with path and then analyze the code if necessary
Ouput of analyzing stores in provided path in HTML format

REQUIRED OPTIONS FOR SINGLE FILE:
    -f|--file       specify file path

AVAIABLE OPTIONS FOR SINGLE FILE:
    -c|--checkers   provide the path to necessary checkers in file
                    note that by default core group of checkers is set to override specify path to file
                    file format is a list of avaiable checkers
                    see https://clang.llvm.org/docs/analyzer/checkers.html

REQUIRED OPTIONS FOR PROJECT:
    -p|--path       specify project directory
    -i|--init       initialize project with provided tool. CMake is only avaiable for now

AVAIABLE OPTIONS:
    -c|--checkers   provide the path to necessary checkers in file if default set of checkers in not enough
                    file format is a list of avaiable checkers
                    see https://clang.llvm.org/docs/analyzer/checkers.html
    -a|--analyze    perform analyzing after initialization
    -h|--help       show this message
    --              specify project builder arguments after all other

EOF
}

function analyze_file {
    
    file_checkers=${2:-core}
    output_path=$(dirname $1)
    clang++ -cc1 -analyze -analyzer-checker=$file_checkers -o $output_path -I/usr/include/c++/10.2.0/x86_64-alpine-linux-musl/ -I/usr/include/c++/10.2.0/ -I/usr/include/ $1
    
}

function init_project {
    echo "Init with" $1 $2
    #Init project
    CC=clang CXX=clang++ scan-build $1 $2 .
}

function analyze {
    make clean
    if [ "$CHECKERS" == "" ];
    then
        scan-build -o ./ make
    else
        scan-build -o ./ -enable-checker $1 make
    fi
    exit 0
}

function get_checkers {
    while IFS='' read -r l || [ -n "$l" ]; do
        CHECKERS="${CHECKERS}${l},"
    done < $1
    #remove last comma
    CHECKERS="${CHECKERS%?}"
    echo "Picked checkers $CHECKERS"
}

while [[ $# -gt 0 ]]; do
    case $1 in
        -i|--init)
            shift
            BUILD_TOOL=$1
            shift
            ;;
        -p|--path)
            shift
            PROJECT_PATH=$1
            shift
            ;;
        -c|--checkers)
            shift
            CHECKERS_PATH=$1
            get_checkers $CHECKERS_PATH
            shift
            ;;    
        -a|--analyze)
            ANALYZE=true
            shift
            ;;
        -f|--file)
            shift
            SIN_FILE=$1
            shift
            ;;
        --)
            shift
            INIT_ARGS="$@"
            shift $#
            ;;
        -h|--help)
            print_usage
            exit 0
            ;;
        *)
            echo "Unknown options: $1"
            exit 1
            ;;
    esac
done

#Analyzing one file
if [ ! -z $SIN_FILE ];
then
    echo "Starting analyzing single file"
    if [ -f $SIN_FILE ];
    then
        analyze_file $SIN_FILE $CHECKERS
        exit 0
    else
        echo "Couldn't find file"
        exit 127
    fi
fi

if [ ! -d $PROJECT_PATH ] || [ "$PROJECT_PATH" == "" ];
then
    echo "Unable to get directory"
    print_usage
    exit 1
fi

if ! command -v $BUILD_TOOL &> /dev/null || [ "$BUILD_TOOL" == "" ];
then
    echo "Could not find build command"
    print_usage
    exit 127
fi

cd $PROJECT_PATH

init_project $BUILD_TOOL "$INIT_ARGS"

#After project initialization try to analyze
if [ $ANALYZE = true ];
then
    echo "Starting analyzing"
    analyze $CHECKERS
else
    echo "analyzing parameter wasn't set. Skipping..."
    exit 0
fi
