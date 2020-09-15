FROM nvidia/cudagl:10.0-devel-ubuntu18.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update -y && \
    apt-get install -y --no-install-recommends \
        aptitude build-essential \
        python3 python3-pip python3-dev python3-setuptools \
        libatlas-base-dev libprotobuf-dev libleveldb-dev libsnappy-dev \
        libhdf5-serial-dev protobuf-compiler libboost-all-dev libgflags-dev \
        libgoogle-glog-dev liblmdb-dev libviennacl-dev libopencv-dev \
        pciutils \
        opencl-headers ocl-icd-opencl-dev \
        libglib2.0-0 libcanberra-gtk-module libsm6 freeglut3-dev \
        python-opencv \
        bash parallel less vim git unzip ffmpeg wget && \
    apt remove cmake cmake-data

RUN cd /opt && \
    mkdir /opt/cmake-3.16.8-Linux-x86_64 && \
    wget https://github.com/Kitware/CMake/releases/download/v3.16.8/cmake-3.16.8-Linux-x86_64.sh && \
    bash cmake-3.16.8-Linux-x86_64.sh --skip-license --prefix=/opt/cmake-3.16.8-Linux-x86_64 && \
    ln -s /opt/cmake-3.16.8-Linux-x86_64/bin/* /usr/local/bin

RUN wget -c "http://developer.download.nvidia.com/compute/redist/cudnn/v5.1/cudnn-8.0-linux-x64-v5.1.tgz" && \
    tar -xzf cudnn-8.0-linux-x64-v5.1.tgz -C /usr/local && \
    rm cudnn-8.0-linux-x64-v5.1.tgz && \
    ldconfig

RUN pip3 install --upgrade pip setuptools && pip3 install --force-reinstall pip==19
RUN pip3 install protobuf opencv-python numpy==1.17.5 torch==1.4.0 torchvision==0.5.0
RUN pip3 install git+https://github.com/giacaglia/pytube.git --upgrade

# OPENPOSE-STAF
RUN cd /opt && \
    git clone https://github.com/soulslicer/openpose.git openpose-staf && \
    cd /opt/openpose-staf && git checkout staf

ENV OPENPOSE_ROOT=/opt/openpose-staf

RUN cd /opt/openpose-staf && \
    mkdir -p build && cd build && \
    /opt/cmake-3.16.8-Linux-x86_64/bin/cmake \
     -DCMAKE_BUILD_TYPE="Release" \
     -DBUILD_CAFFE=ON \
     -DBUILD_EXAMPLES=ON \
     -DBUILD_DOCS=OFF \
     -DBUILD_SHARED_LIBS=ON \
     -DDOWNLOAD_BODY_25_MODEL=OFF \
     -DDOWNLOAD_BODY_COCO_MODEL=OFF \
     -DDOWNLOAD_BODY_MPI_MODEL=OFF \
     -DDOWNLOAD_FACE_MODEL=OFF \
     -DDOWNLOAD_HAND_MODEL=OFF \
     -DWITH_3D_RENDERER:BOOL=OFF \
     -DBUILD_PYTHON=ON ../ && \
    make all -j"$(nproc)"

RUN ln -s /workspace/staf_data/pose_body_21a_video_pose_iter_264000.caffemodel /opt/openpose-staf/models/pose/body_21a_video/pose_iter_264000.caffemodel && \
    ln -s /workspace/staf_data/pose_body_25_pose_iter_584000.caffemodel /opt/openpose-staf/models/pose/body_25/pose_iter_584000.caffemodel && \
    ln -s /workspace/staf_data/pose_coco_pose_iter_440000.caffemodel /opt/openpose-staf/models/pose/coco/pose_iter_440000.caffemodel && \
    ln -s /workspace/staf_data/pose_mpi_pose_iter_160000.caffemodel /opt/openpose-staf/models/pose/mpi/pose_iter_160000.caffemodel && \
    ln -s /workspace/staf_data/face_pose_iter_116000.caffemodel /opt/openpose-staf/models/face/pose_iter_116000.caffemodel && \
    ln -s /workspace/staf_data/hand_pose_iter_102000.caffemodel /opt/openpose-staf/models/hand/pose_iter_102000.caffemodel

# VIBE
COPY . /opt/vibe
WORKDIR /opt/vibe

RUN pip3 install -r requirements.txt
RUN pip3 install -U numba==0.49.1

RUN ln -s /workspace/vibe_data data && \
    mkdir -p /root/.torch/models/ /root/.torch/config/ /root/.cache/torch/checkpoints/ && \
    ln -s /workspace/vibe_data/yolov3.weights /root/.torch/models/yolov3.weights && \
    ln -s /workspace/vibe_data/yolov3.cfg /root/.torch/config/yolov3.cfg && \
    ln -s /workspace/vibe_data/resnet50-19c8e357.pth /root/.cache/torch/checkpoints/resnet50-19c8e357.pth


VOLUME [/workspace]
CMD ["/bin/bash"]

