
######################################################################################################
#
#   GPU Testing - Red Hat 7.5 (RHEL)
#   Kernel: Linux 3.10.0-862.3.2.el7.x86_64
#   CentOS Linux release 7.5.1804 (Core) 
#
#   Reference: 
#       https://docs.nvidia.com/cuda/cuda-installation-guide-linux/index.html#axzz4rhm3n5RO
#
#   Versions:
#       OS          Red Hat 7.5 (Kernel: Linux 3.10.0-862.3.2.el7.x86_64)
#       GCC         [GCC 4.8.5 20150623 (Red Hat 4.8.5-28)] on linux2
#       Python      2.7.5
#       Tensorflow  1.4.0 (tensorflow-gpu)
#
######################################################################################################

######################################################################################################
#
#   Install OS Dependancies
#
######################################################################################################

sudo yum -y update
sudo yum -y install epel-release
sudo yum -y install gcc gcc-c++ python-pip python-devel atlas atlas-devel gcc-gfortran openssl-devel libffi-devel

sudo yum -y install wget
sudo yum -y install dkms

######################################################################################################
#
#   Download and Install Nvidia Driver
#
#   Download from here: http://www.nvidia.com/object/unix.html
#   Reference: https://www.server-world.info/en/note?os=CentOS_7&p=nvidia
#
######################################################################################################

echo 'blacklist nouveau' >> /etc/modprobe.d/blacklist-nouveau.conf
echo 'options nouveau modeset=0' >> /etc/modprobe.d/blacklist-nouveau.conf
dracut --force
echo '[ INFO ] Rebooting in 10 seconds...'
sleep 10 
reboot
# Log back in to server, and execute:
sudo su
yum -y install kernel-devel-$(uname -r) kernel-header-$(uname -r) gcc make
wget http://us.download.nvidia.com/XFree86/Linux-x86_64/396.24/NVIDIA-Linux-x86_64-396.24.run -O /tmp/nvidia_driver.run
#wget http://us.download.nvidia.com/XFree86/Linux-x86_64/390.67/NVIDIA-Linux-x86_64-390.67.run -O /tmp/nvidia_driver.run
# Execute this script, select yes/ok to all prompts 
sh /tmp/nvidia_driver.run
# Verify Nvidia Driver
nvidia-smi
# Enabled persistence mode
nvidia-smi -pm 1

######################################################################################################
#
#   Download and Install Cuda
#
#   https://docs.nvidia.com/cuda/cuda-installation-guide-linux/index.html
#   https://developer.nvidia.com/cuda-toolkit-archive
#
######################################################################################################

wget https://developer.nvidia.com/compute/cuda/8.0/Prod2/local_installers/cuda-repo-rhel7-8-0-local-ga2-8.0.61-1.x86_64-rpm -O /tmp/cuda8_repo.rpm
#wget https://developer.nvidia.com/compute/cuda/9.0/Prod/local_installers/cuda-repo-rhel7-9-0-local-9.0.176-1.x86_64-rpm -O /tmp/cuda9.repo.rpm

sudo rpm -i /tmp/cuda8_repo.rpm
sudo yum clean all
sudo yum repolist
sudo yum install -y cuda

######################################################################################################
#
#   Download and Install CudNN
#
#   https://developer.nvidia.com/rdp/cudnn-download  (Archives: https://developer.nvidia.com/rdp/cudnn-archive)
#
######################################################################################################

# CudNN needs to be downloaded from Nvidia's site, and a user-agreement needs to be accepted. 
# I've not found a way to download directly from CMDline yet. 
# Run this from local to move download up to GPU server.
scp ~/Downloads/cudnn-8.0-linux-x64-v6.0.tgz dzaratsian@35.238.154.193:/tmp/.
# Go back to server, and run this:
sudo su
cd /tmp
sudo tar zxf cudnn-8.0-linux-x64-v6.0.tgz
sudo cp cuda/include/cudnn.h /usr/local/cuda-8.0/include/
sudo cp cuda/lib64/libcudnn* /usr/local/cuda-8.0/lib64/.
sudo chmod a+x /usr/local/cuda-8.0/include/cudnn.h /usr/local/cuda-8.0/lib64/libcudnn*

# Set ENV Variables
export PATH="/usr/local/cuda-8.0/bin:$PATH"
export LD_LIBRARY_PATH="/usr/local/cuda-8.0/lib64:$LD_LIBRARY_PATH"
export CUDA_HOME=/usr/local/cuda
echo 'export PATH="/usr/local/cuda-8.0/bin:$PATH"' >> ~/.bashrc
echo 'export LD_LIBRARY_PATH="/usr/local/cuda-8.0/lib64:$LD_LIBRARY_PATH"' >> ~/.bashrc
echo 'export CUDA_HOME="/usr/local/cuda"' >> ~/.bashrc

######################################################################################################
#
#   Install Python Dependancies
#
######################################################################################################
sudo pip install --upgrade pip
sudo pip install tensorflow-gpu==1.4.0


#ZEND