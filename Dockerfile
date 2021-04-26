
#
# more info @ https://ngc.nvidia.com/catalog/containers/nvidia:nvhpc
#

ARG RELEASE=20.04
FROM nvcr.io/nvidia/nvhpc:21.3-devel-cuda11.2-ubuntu$RELEASE

# stop tzdata blocking script looking for inputs
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update
# linux-tools-common = perf
RUN apt-get install -y git make cmake ccache tar gzip unzip \
                   gcovr environment-modules wget m4 python3-pip \
                   linux-tools-common python3 python3-sphinx  \
                   python3-breathe python3-docutils python3-numpy python3-scipy  \
                   lcov python3-ddt python3-yaml libpython3-dev \
                   wget doxygen cppcheck libtool-bin \
                   python3-matplotlib ninja-build ffmpeg python3-seaborn

RUN echo "gcc: $(gcc --version)"

# have to build hdf5 from source as nvhpc comes with openmpi
#RUN cd ~/ && git clone https://github.com/HDFGroup/hdf5 --depth 10 && cd hdf5
#RUN mkdir build && cd build
#RUN cmake .. -DCMAKE_INSTALL_PREFIX=/usr/local/hdf5 -DHDF5_ENABLE_PARALLEL=ON -G Ninja
#RUN ninja && ninja install && ninja clean

# cmake for SAMRAI needs -DHDF5_ROOT=/usr/local/netcdf

RUN cd ~/ && wget https://raw.githubusercontent.com/PHAREHUB/PHARE/master/requirements.txt
RUN python3 -m pip install pip --upgrade
RUN python3 -m pip install wheel --upgrade

RUN export OMPI_CC=gcc
# mpi4py doesn't build with pgcc
RUN python3 -m pip install -r requirements.txt
RUN unset OMPI_CC

# this file is broken
# /opt/nvidia/hpc_sdk/Linux_x86_64/21.3/comm_libs/hpcx/hpcx-2.7.4/ompi/share/openmpi/mpicxx-wrapper-data.txt
# replace "linker_flags=..."
# with
# linker_flags=

RUN export OMPI_CC=pgcc
RUN export OMPI_CXX=pgc++

RUN echo "export OMPI_CC=$OMPI_CC" >> ~/.bashrc
RUN echo "export OMPI_CXX=$OMPI_CXX" >> ~/.bashrc
RUN echo "export OMPI_ALLOW_RUN_AS_ROOT=1" >> ~/.bashrc
RUN echo "export OMPI_ALLOW_RUN_AS_ROOT_CONFIRM=1" >> ~/.bashrc

# https://github.com/open-mpi/ompi/issues/5070
RUN echo "export OMPI_MCA_ess_singleton_isolated=true" >> ~/.bashrc

RUN cat ~/.bashrc

# possible file descriptor leak running ctest
# https://github.com/open-mpi/ompi/issues/4336
