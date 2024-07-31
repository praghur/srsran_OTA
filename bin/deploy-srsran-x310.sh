set -ex
COMMIT_HASH=$1
BINDIR=`dirname $0`
ETCDIR=/local/repository/etc
source $BINDIR/common.sh

if [ -f $SRCDIR/srs-setup-complete ]; then
    echo "setup already ran; not running again"
    exit 0
fi

# Get the emulab repo
while ! wget -qO - http://repos.emulab.net/emulab.key | sudo apt-key add -
do
    echo Failed to get emulab key, retrying
done

while ! sudo add-apt-repository -y http://repos.emulab.net/powder/ubuntu/
do
    echo Failed to get johnsond ppa, retrying
done

while ! sudo apt-get update
do
    echo Failed to update, retrying
done

#My Edit Starts Here#
cd /var/tmp/srsRAN_Project
rm -rf build
mkdir build
sudo apt list --installed | grep uhd
sudo apt remove libuhd* gnuradio* uhd-host libgnuradio-* #Click Y here
sudo apt list --installed | grep uhd #Should be blank at this stage
sudo add-apt-repository -y ppa:ettusresearch/uhd
sudo apt-get update
sudo vim /etc/apt/sources.list.d/emulab.list #Delete the line in this file
sudo apt-get update
sudo apt-get install -y libuhd-dev uhd-host
sudo apt list --installed | grep uhd #It should not contain uhd4.4.0. It does for some reason
sudo apt remove libgnuradio-* 
sudo apt remove libuhd #Click on tab. It will show uhd4.4.0 and uhd4.7.0. Remove uhd4.4.0
sudo apt remove libuhd4.4.0
uhd_find_devices
sudo apt-get install -y \
  cmake \
  make \
  gcc \
  g++ \
  iperf3 \
  pkg-config \
  libboost-dev \
  libfftw3-dev \
  libmbedtls-dev \
  libsctp-dev \
  libyaml-cpp-dev \
  libgtest-dev \
  numactl \
  ppp

sudo uhd_images_downloader


cd $SRCDIR
git clone $SRS_PROJECT_REPO
cd srsRAN_Project
git checkout 4cf7513e9fe988449aadedce3278063de761a4ac
# git apply $ETCDIR/srsran/srsran.patch
mkdir build
cd build
cmake ../
make -j $(nproc)

echo configuring nodeb...
mkdir -p $SRCDIR/etc/srsran
cp -r $ETCDIR/srsran/* $SRCDIR/etc/srsran/
LANIF=`ip r | awk '/192\.168\.1\.0/{print $3}'`
if [ ! -z $LANIF ]; then
  LANIP=`ip r | awk '/192\.168\.1\.0/{print $NF}'`
  echo LAN IFACE is $LANIF IP is $LANIP.. updating nodeb config
  find $SRCDIR/etc/srsran/ -type f -exec sed -i "s/LANIP/$LANIP/" {} \;
  IPLAST=`echo $LANIP | awk -F. '{print $NF}'`
  find $SRCDIR/etc/srsran/ -type f -exec sed -i "s/GNBID/$IPLAST/" {} \;
else
  echo No LAN IFACE.. not updating nodeb config
fi
echo configuring nodeb... done.

touch $SRCDIR/srs-setup-complete
