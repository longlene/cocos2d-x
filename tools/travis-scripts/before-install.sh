#!/bin/bash

# exit this script if any commmand fails
set -e

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
COCOS2DX_ROOT="$DIR"/../..
HOST_NAME=""
mkdir -p $HOME/bin
pushd $HOME/bin


install_android_ndk()
{
    # Download android ndk
    if [ "$PLATFORM"x = "ios"x ]; then
        HOST_NAME="darwin"
    else
        HOST_NAME="linux"
    fi
    echo "Download android-ndk-r8e-${HOST_NAME}-x86_64.tar.bz2 ..."
    curl -O http://dl.google.com/android/ndk/android-ndk-r8e-${HOST_NAME}-x86_64.tar.bz2
    echo "Decompress android-ndk-r8e-${HOST_NAME}-x86_64.tar.bz2 ..."
    tar xjf android-ndk-r8e-${HOST_NAME}-x86_64.tar.bz2
    # Rename ndk
    mv android-ndk-r8e android-ndk
}

install_llvm()
{
    if [ "$PLATFORM"x = "ios"x ]; then
        HOST_NAME="apple-darwin11"
    else
        HOST_NAME="linux-ubuntu_12.04"
    fi
    # Download llvm3.1
    echo "Download clang+llvm-3.1-x86_64-${HOST_NAME}.tar.gz"
    curl -O http://llvm.org/releases/3.1/clang+llvm-3.1-x86_64-${HOST_NAME}.tar.gz
    echo "Decompress clang+llvm-3.1-x86_64-${HOST_NAME}.tar.gz ..."
    tar xzf clang+llvm-3.1-x86_64-${HOST_NAME}.tar.gz
    # Rename llvm
    mv clang+llvm-3.1-x86_64-${HOST_NAME} clang+llvm-3.1
}

install_llvm_3_2()
{
    if [ "$PLATFORM"x = "ios"x ]; then
        HOST_NAME="apple-darwin11"
    else
        HOST_NAME="linux-ubuntu-12.04"
    fi
    # Download llvm3.2
    echo "Download clang+llvm-3.2-x86_64-${HOST_NAME}.tar.gz"
    curl -O http://llvm.org/releases/3.2/clang+llvm-3.2-x86_64-${HOST_NAME}.tar.gz
    echo "Decompress clang+llvm-3.2-x86_64-${HOST_NAME}.tar.gz ..."
    tar xzf clang+llvm-3.2-x86_64-${HOST_NAME}.tar.gz
    # Rename llvm
    mv clang+llvm-3.2-x86_64-${HOST_NAME} clang+llvm-3.2
}

if [ "$GEN_JSB"x = "YES"x ]; then
    if [ "$TRAVIS_PULL_REQUEST" != "false" ]; then
        exit 0
    fi
    install_android_ndk
    install_llvm
fi

if [ "$PLATFORM"x = "linux"x ]; then
    bash $COCOS2DX_ROOT/install-deps-linux.sh
fi

if [ "$PLATFORM"x = "nacl"x ]; then
    # NaCl compilers are built for 32-bit linux so we need to install
    # the runtime support for this.
    sudo apt-get update
    sudo apt-get install libc6:i386 libstdc++6:i386
    echo "Download nacl_sdk ..."
    wget http://storage.googleapis.com/nativeclient-mirror/nacl/nacl_sdk/nacl_sdk.zip
    echo "Decompress nacl_sdk.zip" 
    unzip nacl_sdk.zip
    nacl_sdk/naclsdk update --force pepper_canary
fi

if [ "$PLATFORM"x = "android"x ]; then 
    install_android_ndk
    install_llvm
fi

if [ "$PLATFORM"x = "emscripten"x ]; then 
    sudo rm -rf /dev/shm && sudo ln -s /run/shm /dev/shm
    install_llvm_3_2
fi

if [ "$PLATFORM"x = "ios"x ]; then
    install_android_ndk
    install_llvm
    
    pushd $COCOS2DX_ROOT
    git submodule add https://github.com/facebook/xctool.git ./xctool
    git submodule init
    git submodule update
    popd
fi

popd
