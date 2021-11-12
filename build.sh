#!/bin/bash
apt-get update
apt-get -y --force-yes install sudo
# install cuda toolkit and nvidia-prime
sudo apt-get -y --force-yes install nvidia-cuda-dev nvidia-cuda-toolkit nvidia-nsight nvidia-prime
# install git, cmake, SuiteSparse, Lapack, BLAS etc
sudo apt-get -y --force-yes install gcc-5 g++-5 cmake libvtk6-dev libsuitesparse-dev liblapack-dev libblas-dev libgtk2.0-dev pkg-config libopenni-dev libusb-1.0-0-dev wget zip clang
update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-5 20
update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-5 20

cd ..

# Build gflags
git clone https://github.com/gflags/gflags.git
cd gflags
mkdir -p build/ && cd build
cmake .. && make 
cd ../../

# Build glog
git clone https://github.com/google/glog.git
cd glog
mkdir -p build/ && cd build/
cmake .. && make
cd ../../

# Install Eigen 3.3.4
wget https://gitlab.com/libeigen/eigen/-/archive/3.3.4/eigen-3.3.4.tar.gz
tar -xf eigen-3.3.4.tar.gz
cd eigen-3.3.4
mkdir -p build && cd build
cmake ..
sudo make install
cd ../../

# Build Ceres
git clone https://ceres-solver.googlesource.com/ceres-solver
cd ceres-solver
mkdir -p build/ && cd build/
cmake ..
make -j4
sudo make install
cd ../../

# Build OpenCV 2.4.13
git clone https://github.com/opencv/opencv
cd opencv/
git checkout 2.4.13
mkdir -p build && cd build
cmake -DWITH_VTK=ON -DBUILD_opencv_calib3d=ON -DBUILD_opencv_imgproc=ON -DWITH_CUDA=OFF -DWITH_FFMPEG=OFF ..
make -j4
sudo make install
cd ../../

# Build Boost
wget https://boostorg.jfrog.io/artifactory/main/release/1.64.0/source/boost_1_64_0.tar.gz
tar -xf boost_1_64_0.tar.gz
cd boost_1_64_0
sudo ./bootstrap.sh
./b2
cd ..

# Build DynamicFusion

cd dynamicfusion/deps
wget https://github.com/zdevito/terra/releases/download/release-2016-03-25/terra-Linux-x86_64-332a506.zip
unzip terra-Linux-x86_64-332a506.zip
rm terra-Linux-x86_64-332a506.zip
mv terra-Linux-x86_64-332a506 terra

# Build Opt
#	Change line
#		FLAGS += -O3 -g -std=c++11 -I$(SRC) -I$(SRC)/cutil/inc -I../../API/release/include -I$(TERRAHOME)/include -I$(CUDAHOME)/include -I../external/mLib/include -I../external -I../external/OpenMesh/include
#	with
#		FLAGS += -D_MWAITXINTRIN_H_INCLUDED -D_FORCE_INLINES -D__STRICT_ANSI__ -O3 -g -std=c++11 -I$(SRC) -I$(SRC)/cutil/inc -I../../API/release/include -I$(TERRAHOME)/include -I$(CUDAHOME)/include -I../external/mLib/include -I../external -I../external/OpenMesh/include
cd Opt/API/
make -j4
cd ../../../

mkdir -p build && cd build
cmake -DOpenCV_DIR=/kaggle/working/opencv/build -DBOOST_ROOT=/kaggle/working/boost_1_64_0/ -DOPENNI_INCLUDE_DIR=/usr/include/ni -DOpenCV_FOUND=TRUE ..
make -j4
cd ..