# static-code-analyzer-docker
This project has been started as a part of Digital Security's Research Centre internship "Summer of Hack 2020".

This project implements static code analyzing for C/C++ code in Docker.

It's based on [Clang Static Analyzer](https://clang-analyzer.llvm.org/)

Available checkers in [documentatoin](https://clang.llvm.org/docs/analyzer/checkers.html)

**For what this image is needed:**
- Analyzing C++ projects with builder systems. CMake is only available for now
- Analyzing C/C++ files with Clang frontend
- Performing analysis with necessary checkers

## Usage with single file

To analyze source code in docker:

```shell
docker run --rm -v $HOME/Documents/static-code-analyzer-docker/example/:/home/csa/analyze --name csa-test csa -f analyze/file/main.cpp
```
**NOTE: core group of checkers is set by default**

To enable custom checkers:

```shell
docker run --rm -v $HOME/Documents/static-code-analyzer-docker/example/:/home/csa/analyze --name csa-test csa -f analyze/file/main.cpp -c analyze/file/checkers
```

## Usage in project with builder

```shell
docker run --rm -v $HOME/Documents/static-code-analyzer-docker/example/cmake:/home/csa/analyze --name csa-test csa --analyze -p ./analyze -i cmake
```

To enable custom checkers in project:

```shell
docker run --rm -v $HOME/Documents/static-code-analyzer-docker/example/cmake:/home/csa/analyze --name csa-test csa --analyze -p ./analyze -i cmake -c analyze/checkers
```

## Building Docker image

```shell
docker build -f Dockerfile -t csa .
```