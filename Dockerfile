
#
# more info @ https://ngc.nvidia.com/catalog/containers/nvidia:nvhpc
#

FROM nvcr.io/nvidia/nvhpc:21.3-devel-cuda11.2-ubuntu20.04
ENV NVHCP_VERSION=21.3
ENV HPCX_VERSION=2.7.4

# stop tzdata blocking script looking for inputs
ENV DEBIAN_FRONTEND=noninteractive

# dunno tbh
RUN mv /etc/apt/sources.list.d/mellanox_mlnx_ofed.list /root
RUN apt-get update
# linux-tools-common = perf
RUN apt-get install -y git make cmake ccache tar gzip unzip \
                   gcovr environment-modules wget m4 python3-pip \
                   linux-tools-common python3 python3-sphinx  \
                   python3-breathe python3-docutils python3-numpy python3-scipy  \
                   lcov python3-ddt python3-yaml libpython3-dev \
                   wget doxygen cppcheck libtool-bin curl \
                   python3-matplotlib ninja-build ffmpeg python3-seaborn

RUN apt-get autoremove -y && apt-get autoclean -y && apt-get clean -y

# file on nvidia docker container causes build failures for some unknown reason
RUN curl -Lo /opt/nvidia/hpc_sdk/Linux_x86_64/${NVHCP_VERSION}/comm_libs/hpcx/hpcx-${HPCX_VERSION}/ompi/share/openmpi/mpicxx-wrapper-data.txt \
        https://raw.githubusercontent.com/PHARCHIVE/teamcity-ubuntu-nvhpc/master/mpic%2B%2B-wrapper-data.txt

# mpi4py fails to build with pgcc
# OMPI_MCA_ess_singleton_isolated = https://github.com/open-mpi/ompi/issues/5070
RUN export _CC=$CC && \
    export _OMPI_CC=$OMPI_CC && \
    export CC=gcc && \
    export OMPI_CC=gcc && \
    python3 -m pip install pip --upgrade && \
    python3 -m pip install wheel --upgrade && \
    python3 -m pip install ddt mpi4py h5py numpy scipy --upgrade && \
    export CC=$_CC && \
    export OMPI_CC=pgcc && \
    export OMPI_CXX=pgc++ && \
    echo "" >> ~/.bashrc && \
    echo "##############################" >> ~/.bashrc && \
    echo "#### docker build appends ####" >> ~/.bashrc && \
    echo "##############################" >> ~/.bashrc && \
    echo "export OMPI_CC=$OMPI_CC" >> ~/.bashrc && \
    echo "export OMPI_CXX=$OMPI_CXX" >> ~/.bashrc && \
    echo "export OMPI_ALLOW_RUN_AS_ROOT=1" >> ~/.bashrc && \
    echo "export OMPI_ALLOW_RUN_AS_ROOT_CONFIRM=1" >> ~/.bashrc && \
    echo "export OMPI_MCA_ess_singleton_isolated=true" >> ~/.bashrc && \
    cat ~/.bashrc

# possible file descriptor leak running ctest
# https://github.com/open-mpi/ompi/issues/4336

RUN echo "gcc: $(gcc --version)"
