##
# homme/gdal
#
# This creates an Ubuntu derived base image that installs the latest GDAL
# subversion checkout compiled with a broad range of drivers.  The build
# process closely follows that defined in
# <https://github.com/OSGeo/gdal/blob/trunk/.travis.yml> but omits Java
# support.
#

# Ubuntu 12.10
FROM ubuntu:quantal

MAINTAINER Homme Zwaagstra <hrz@geodata.soton.ac.uk>

# Ensure the package repository is up to date
RUN echo "deb http://archive.ubuntu.com/ubuntu quantal main universe" > /etc/apt/sources.list
RUN sed -i -e 's/archive.ubuntu.com/old-releases.ubuntu.com/g' /etc/apt/sources.list
RUN apt-get update -y

# Install basic dependencies
RUN apt-get install -y \
    software-properties-common \
    python-software-properties \
    build-essential \
    wget \
    subversion

# Install the ubuntu gis repository
RUN add-apt-repository -y ppa:ubuntugis/ubuntugis-unstable
RUN add-apt-repository -y ppa:marlam/gta
RUN apt-get update -y

# a mounted file systems table to make MySQL happy
#RUN cat /proc/mounts > /etc/mtab

# Install gdal dependencies provided by Ubuntu repositories
RUN apt-get install -y \
    mysql-server \
    mysql-client \
    python-numpy \
    postgis \
    postgresql-9.1-postgis-2.0-scripts \
    libpq-dev \
    libpng12-dev \
    libjpeg-dev \
    libgif-dev \
    liblzma-dev \
    libgeos-dev \
    libcurl4-gnutls-dev \
    libproj-dev \
    libxml2-dev \
    libexpat-dev \
    libxerces-c-dev \
    libnetcdf-dev \
    netcdf-bin \
    libpoppler-dev \
    libspatialite-dev \
    gpsbabel \
    swig \
    libhdf4-alt-dev \
    libhdf5-serial-dev \
    libpodofo-dev \
    poppler-utils \
    libfreexl-dev \
    unixodbc-dev \
    libwebp-dev \
    libepsilon-dev \
    libgta-dev \
    liblcms2-2 \
    libpcre3-dev \
    python-dev \
    sudo

# Install the GDAL source dependencies
ADD ./install-gdal-deps.sh /tmp/
RUN sh /tmp/install-gdal-deps.sh

# Install mozjpeg (see http://blarg.co.uk/blog/how-to-install-mozjpeg)
RUN apt-get install -y autoconf automake libtool nasm make
RUN cd /tmp/ && \
    wget --no-verbose https://github.com/mozilla/mozjpeg/archive/v2.0.1.tar.gz && \
    tar -xzf v2.0.1.tar.gz && \
    cd mozjpeg-2.0.1 && \
    autoreconf -fi && \
    mkdir build && cd build && \
    ../configure --prefix=/usr/local && \
    make install && \
    ldconfig

# Install GDAL itself
ADD ./gdal-checkout.txt /tmp/gdal-checkout.txt
ADD ./install-gdal.sh /tmp/
RUN sh /tmp/install-gdal.sh

# Clean up APT when done.
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Run the GDAL test suite by default
CMD cd /usr/local/share/gdal-autotest && ./run_all.py
